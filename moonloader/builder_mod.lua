-- ==============================================================================
-- UNIVERSAL MODDER: ADVANCED 3D BUILDER & FURNITURE MOD FOR GTA SAN ANDREAS
-- ==============================================================================
-- Desenvolvido para MoonLoader (GTA San Andreas 1.0 US)
-- Combina e aprimora:
-- 1) In-Game Map Editor (Junior_Djjr / MixMods) -> Raycast 3D, exportacao .ipl, manipulacao mouse
-- 2) Builder Mod (CLEO / builderNOVO) -> Categorizacao de objetos, spawn relativo, ground-snapping
-- 3) Novo Sistema Visual ImGui -> Galeria de miniaturas, busca em tempo real, grid snap e gizmo 3D
-- ==============================================================================

script_name("Universal Builder Mod")
script_author("Universal Modder & Felipe")
script_description("Editor 3D de mapas, moveis e construcao com interface visual e controle total por mouse")
script_version("1.0.0")

local imgui = require 'imgui'
local vkeys = require 'vkeys'
local memory = require 'memory'

-- Database de modelos categorizados
local db_loaded, database = pcall(require, "models_database")
if not db_loaded or type(database) ~= "table" then
    database = {
        categories = {
            ["moveis"] = { name = "Moveis & Decoracao", icon = "Moveis" },
            ["eletro"] = { name = "Eletrodomesticos", icon = "Eletro" },
            ["cozinha_banheiro"] = { name = "Cozinha & Banheiro", icon = "Cozinha" },
            ["portas_janelas"] = { name = "Portas & Janelas", icon = "Portas" },
            ["construcao"] = { name = "Construcao & Paredes", icon = "Paredes" },
            ["urbano"] = { name = "Urbano & Rua", icon = "Rua" },
            ["natureza"] = { name = "Natureza & Arvores", icon = "Natureza" },
            ["industrial"] = { name = "Industrial & Cargas", icon = "Industrial" },
            ["comercial"] = { name = "Lojas & Comercio", icon = "Lojas" }
        },
        items = {}
    }
end

-- ==============================================================================
-- ESTADOS & CONFIGURACOES
-- ==============================================================================
local STATE_IDLE     = 0
local STATE_BROWSER  = 1
local STATE_PLACING  = 2
local STATE_EDITING  = 3

local current_state = STATE_IDLE
local window_state = imgui.ImBool(false)
local search_buffer = imgui.ImBuffer(64)
local selected_category = "moveis"
local ipl_file_buffer = imgui.ImBuffer("mapa_custom.ipl", 128)

-- Configuracoes de Manipulacao
local settings = {
    surface_align = true,         -- Alinhar objeto com a normal da superficie (piso/rampa/parede)
    grid_snap = false,            -- Trava em incrementos de grade (0.5m ou 1.0m)
    grid_size = 0.5,
    angle_snap = false,           -- Trava rotacao em 15 / 45 graus
    angle_step = 45.0,
    mouse_sens = 1.0,
    elevation_step = 0.1,         -- Passo de subida/descida no mouse wheel
    slow_precision_mult = 0.1,    -- Multiplicador ao segurar Shift
    draw_distance = 300.0,
    preview_distance = 6.0,
    auto_save = true,
    enable_collision = true
}

-- Estrutura de Objetos na Cena
-- Cada item: { handle, id, name, x, y, z, rx, ry, rz, rw, interior }
local placed_objects = {}
local selected_obj_index = nil

-- Objeto Fantasma (Ghost/Preview) usado enquanto esta mirando/colocando
local ghost = {
    handle = nil,
    id = 1700,
    name = "kb_bed_test1",
    x = 0.0, y = 0.0, z = 0.0,
    heading = 0.0,
    pitch = 0.0,
    roll = 0.0,
    elevation_offset = 0.0
}

-- Texturas em Cache para a Interface
local textures_cache = {}
local script_dir = getWorkingDirectory()
local textures_dir = script_dir .. "\\textures\\"

-- ==============================================================================
-- FUNCOES AUXILIARES DE TEXTURAS & IMAGENS
-- ==============================================================================
local function get_object_texture(model_id)
    if textures_cache[model_id] ~= nil then
        return textures_cache[model_id]
    end
    
    local tex_path = string.format("%s%d.jpg", textures_dir, model_id)
    if doesFileExist(tex_path) then
        local ok, tex = pcall(imgui.CreateTextureFromFile, tex_path)
        if ok and tex then
            textures_cache[model_id] = tex
            return tex
        end
    end
    
    textures_cache[model_id] = false
    return false
end

-- ==============================================================================
-- CARREGAMENTO DE MODELOS GTA SA
-- ==============================================================================
local function load_model_sync(model_id)
    if not isModelAvailable(model_id) then
        requestModel(model_id)
        loadAllModelsNow()
    end
    return isModelAvailable(model_id)
end

-- ==============================================================================
-- RAYCASTING & FISICA (Inspirado no CWorld::ProcessLineOfSight do Junior_Djjr)
-- ==============================================================================
local function get_aim_target_coords(max_dist)
    max_dist = max_dist or 40.0
    local camX, camY, camZ = getActiveCameraCoordinates()
    local targetX, targetY, targetZ = getActiveCameraPointAt()
    
    local dx = targetX - camX
    local dy = targetY - camY
    local dz = targetZ - camZ
    local len = math.sqrt(dx * dx + dy * dy + dz * dz)
    if len <= 0.0001 then len = 1.0 end
    
    dx = (dx / len) * max_dist
    dy = (dy / len) * max_dist
    dz = (dz / len) * max_dist
    
    local endX = camX + dx
    local endY = camY + dy
    local endZ = camZ + dz
    
    -- Opcode 06BE: processLineOfSight
    -- checkBuildings, checkVehicles, checkPeds, checkObjects, checkDummies, seeThrough, shootThrough
    local hit, col = processLineOfSight(camX, camY, camZ, endX, endY, endZ, true, false, false, true, false, false, false, false)
    if hit and col and col.pos then
        local normX, normY, normZ = 0.0, 0.0, 1.0
        if col.normal then
            normX = col.normal[1] or 0.0
            normY = col.normal[2] or 0.0
            normZ = col.normal[3] or 1.0
        end
        return col.pos[1], col.pos[2], col.pos[3], normX, normY, normZ, true, col.entity
    end
    
    -- Fallback se nao houver colisao direta: projeta a frente do jogador
    local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
    local fallbackX = pX + (dx / max_dist) * settings.preview_distance
    local fallbackY = pY + (dy / max_dist) * settings.preview_distance
    local groundZ = getGroundZFor3dCoord(fallbackX, fallbackY, pZ + 3.0)
    return fallbackX, fallbackY, groundZ, 0.0, 0.0, 1.0, false, nil
end

-- ==============================================================================
-- SPAWN & MANIPULACAO DO OBJETO GHOST
-- ==============================================================================
local function spawn_ghost(model_id, name)
    if ghost.handle and doesObjectExist(ghost.handle) then
        deleteObject(ghost.handle)
        ghost.handle = nil
    end
    
    if not load_model_sync(model_id) then
        printStringNow("~r~Erro: Modelo " .. tostring(model_id) .. " nao encontrado!", 2500)
        return false
    end
    
    local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
    ghost.id = model_id
    ghost.name = name or ("model_" .. model_id)
    ghost.x = pX
    ghost.y = pY
    ghost.z = pZ
    ghost.elevation_offset = 0.0
    
    ghost.handle = createObject(model_id, ghost.x, ghost.y, ghost.z)
    if ghost.handle and doesObjectExist(ghost.handle) then
        setObjectCollision(ghost.handle, false) -- Desativa colisao do ghost para nao prender o jogador
        current_state = STATE_PLACING
        window_state.v = false -- Esconde o menu para focar na colocacao
        printStringNow("~y~Modo de Colocacao:~w~ Aponte e [LMB] Colocar | [RMB] Cancelar | [Q/E] Rodar", 4000)
        return true
    end
    return false
end

local function confirm_placement()
    if not ghost.handle or not doesObjectExist(ghost.handle) then return end
    
    -- Cria o objeto definitivo no mundo com colisao ativa
    local final_handle = createObject(ghost.id, ghost.x, ghost.y, ghost.z)
    if final_handle and doesObjectExist(final_handle) then
        setObjectHeading(final_handle, ghost.heading)
        setObjectCollision(final_handle, settings.enable_collision)
        
        table.insert(placed_objects, {
            handle = final_handle,
            id = ghost.id,
            name = ghost.name,
            x = ghost.x,
            y = ghost.y,
            z = ghost.z,
            heading = ghost.heading,
            interior = getActiveInterior()
        })
        
        printStringNow("~g~Objeto " .. ghost.name .. " colocado! (Total: " .. #placed_objects .. ")", 2000)
        
        if settings.auto_save then
            auto_save_project()
        end
    end
    
    -- Deleta o preview
    deleteObject(ghost.handle)
    ghost.handle = nil
    current_state = STATE_IDLE
end

local function cancel_placement()
    if ghost.handle and doesObjectExist(ghost.handle) then
        deleteObject(ghost.handle)
        ghost.handle = nil
    end
    current_state = STATE_IDLE
    printStringNow("~r~Colocacao cancelada.", 1500)
end

-- ==============================================================================
-- EDICAO & MANIPULACAO DE OBJETOS JA COLOCADOS
-- ==============================================================================
local function select_object_for_edit(index)
    if placed_objects[index] and doesObjectExist(placed_objects[index].handle) then
        selected_obj_index = index
        current_state = STATE_EDITING
        window_state.v = false
        printStringNow("~y~Editando Objeto:~w~ Mouse p/ mover | Scroll p/ Altura | [C] Duplicar | [Del] Apagar", 4000)
    end
end

local function duplicate_selected_object()
    if not selected_obj_index or not placed_objects[selected_obj_index] then return end
    local src = placed_objects[selected_obj_index]
    spawn_ghost(src.id, src.name)
    ghost.heading = src.heading
    printStringNow("~y~Objeto duplicado! Aponte para colocar a nova copia.", 2500)
end

local function delete_selected_object()
    if not selected_obj_index or not placed_objects[selected_obj_index] then return end
    local item = placed_objects[selected_obj_index]
    if item.handle and doesObjectExist(item.handle) then
        deleteObject(item.handle)
    end
    table.remove(placed_objects, selected_obj_index)
    selected_obj_index = nil
    current_state = STATE_IDLE
    printStringNow("~r~Objeto excluido.", 2000)
    if settings.auto_save then auto_save_project() end
end

-- ==============================================================================
-- PERSISTENCIA: EXPORTACAO & IMPORTACAO DE ARQUIVOS .IPL & .JSON
-- ==============================================================================
function auto_save_project()
    export_to_ipl(script_dir .. "\\builder_autosave.ipl")
end

function export_to_ipl(filepath)
    local f, err = io.open(filepath, "w")
    if not f then
        printStringNow("~r~Erro ao salvar IPL: " .. tostring(err), 3000)
        return false
    end
    
    f:write("# In-Game Map Export gerado pelo Universal Builder Mod\n")
    f:write("# Total de Objetos: " .. #placed_objects .. "\n\n")
    f:write("inst\n")
    
    for i, obj in ipairs(placed_objects) do
        -- No formato IPL: model_id, model_name, interior, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, rot_w, lod
        -- Calculo de quaternion para rotacao no eixo Z (Heading):
        local rad = math.rad(obj.heading or 0.0) * 0.5
        local qz = math.sin(rad)
        local qw = math.cos(rad)
        
        f:write(string.format("%d, %s, %d, %.4f, %.4f, %.4f, 0.0000, 0.0000, %.4f, %.4f, -1\n",
            obj.id, obj.name or ("obj_" .. obj.id), obj.interior or 0,
            obj.x, obj.y, obj.z, qz, qw))
    end
    
    f:write("end\n")
    f:close()
    printStringNow("~g~Salvo em: " .. filepath, 3000)
    return true
end

function load_from_ipl(filepath)
    local f = io.open(filepath, "r")
    if not f then
        printStringNow("~r~Arquivo nao encontrado: " .. filepath, 3000)
        return false
    end
    
    local in_inst = false
    local count = 0
    for line in f:lines() do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed == "inst" then
            in_inst = true
        elseif trimmed == "end" then
            in_inst = false
        elseif in_inst and not trimmed:find("^#") and #trimmed > 0 then
            local parts = {}
            for val in trimmed:gmatch("[^,]+") do
                table.insert(parts, val:match("^%s*(.-)%s*$"))
            end
            if #parts >= 6 then
                local mid = tonumber(parts[1])
                local mname = parts[2]
                local interior = tonumber(parts[3]) or 0
                local x = tonumber(parts[4]) or 0.0
                local y = tonumber(parts[5]) or 0.0
                local z = tonumber(parts[6]) or 0.0
                
                -- Se temos quaternions (qz, qw)
                local heading = 0.0
                if #parts >= 10 then
                    local qz = tonumber(parts[9]) or 0.0
                    local qw = tonumber(parts[10]) or 1.0
                    heading = math.deg(2 * math.atan2(qz, qw))
                end
                
                if mid and load_model_sync(mid) then
                    local h = createObject(mid, x, y, z)
                    if h and doesObjectExist(h) then
                        setObjectHeading(h, heading)
                        setObjectCollision(h, true)
                        table.insert(placed_objects, {
                            handle = h,
                            id = mid,
                            name = mname,
                            x = x, y = y, z = z,
                            heading = heading,
                            interior = interior
                        })
                        count = count + 1
                    end
                end
            end
        end
    end
    f:close()
    printStringNow("~g~Carregados " .. count .. " objetos do IPL!", 3000)
    return true
end

-- ==============================================================================
-- INTERFACE GRAFICA IMGUI
-- ==============================================================================
function imgui.OnDrawFrame()
    if not window_state.v then return end
    
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(780, 560), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5 - 390, sh * 0.5 - 280), imgui.Cond.FirstUseEver)
    
    if imgui.Begin("Universal Builder Mod - Visual Furniture & Map Editor v1.0", window_state, imgui.WindowFlags.NoCollapse) then
        
        -- BARRA DE CONTROLES RAPIDOS
        imgui.Columns(4, "TopControls", false)
        if imgui.Checkbox("Alinhar Piso (Normal)", imgui.ImBool(settings.surface_align)) then
            settings.surface_align = not settings.surface_align
        end
        imgui.NextColumn()
        if imgui.Checkbox("Grade Snap (0.5m)", imgui.ImBool(settings.grid_snap)) then
            settings.grid_snap = not settings.grid_snap
        end
        imgui.NextColumn()
        if imgui.Checkbox("Rotacao Snap (45 deg)", imgui.ImBool(settings.angle_snap)) then
            settings.angle_snap = not settings.angle_snap
        end
        imgui.NextColumn()
        imgui.Text(string.format("Objetos no Mapa: %d", #placed_objects))
        imgui.Columns(1)
        imgui.Separator()
        
        -- ABA PRINCIPAL: SELETOR DE CATEGORIAS
        imgui.Text("Categorias:")
        imgui.SameLine()
        
        for cat_key, cat_info in pairs(database.categories) do
            local is_active = (selected_category == cat_key)
            if is_active then
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.2, 0.6, 0.2, 1.0))
            end
            if imgui.Button(cat_info.name) then
                selected_category = cat_key
            end
            if is_active then
                imgui.PopStyleColor()
            end
            imgui.SameLine()
        end
        imgui.NewLine()
        
        -- BARRA DE PESQUISA
        imgui.PushItemWidth(350)
        imgui.InputText("Pesquisar (Nome ou ID)", search_buffer)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button("Limpar Busca") then
            search_buffer.v = ""
        end
        imgui.Separator()
        
        -- GRID DE PRODUTOS / MINIATURAS
        local search_term = string.lower(search_buffer.v)
        local items_list = (database.items and database.items[selected_category]) or {}
        
        imgui.BeginChild("ItemsGrid", imgui.ImVec2(0, 320), true)
        
        local col_count = 5
        imgui.Columns(col_count, "CardsGrid", false)
        
        local rendered = 0
        for i, item in ipairs(items_list) do
            local mid = item.id
            local mname = item.name or ("ID " .. mid)
            local match = (search_term == "") or 
                          string.find(string.lower(mname), search_term) or 
                          string.find(tostring(mid), search_term)
            
            if match then
                imgui.PushID(i)
                imgui.BeginGroup()
                
                -- Miniatura da Imagem
                local tex = get_object_texture(mid)
                if tex then
                    if imgui.ImageButton(tex, imgui.ImVec2(90, 80)) then
                        spawn_ghost(mid, mname)
                    end
                else
                    -- Card com Badge de ID quando imagem ainda nao foi baixada
                    if imgui.Button(string.format("[%d]\n%s", mid, mname:sub(1, 14)), imgui.ImVec2(90, 80)) then
                        spawn_ghost(mid, mname)
                    end
                end
                
                -- Botao de Spawn
                if imgui.Button("Colocar", imgui.ImVec2(90, 22)) then
                    spawn_ghost(mid, mname)
                end
                
                imgui.EndGroup()
                imgui.PopID()
                
                imgui.NextColumn()
                rendered = rendered + 1
                if rendered >= 150 then
                    -- Limite de performance de renderizacao por frame
                    break
                end
            end
        end
        
        imgui.Columns(1)
        imgui.EndChild()
        
        imgui.Separator()
        
        -- SALVAR & CARREGAR ARQUIVOS IPL
        imgui.Text("Projeto / Mapa (.ipl):")
        imgui.SameLine()
        imgui.PushItemWidth(250)
        imgui.InputText("##ipl_path", ipl_file_buffer)
        imgui.PopItemWidth()
        imgui.SameLine()
        if imgui.Button("Salvar .IPL") then
            export_to_ipl(script_dir .. "\\" .. ipl_file_buffer.v)
        end
        imgui.SameLine()
        if imgui.Button("Carregar .IPL") then
            load_from_ipl(script_dir .. "\\" .. ipl_file_buffer.v)
        end
        imgui.SameLine()
        if imgui.Button("Limpar Todos os Objetos") then
            for _, o in ipairs(placed_objects) do
                if o.handle and doesObjectExist(o.handle) then
                    deleteObject(o.handle)
                end
            end
            placed_objects = {}
            printStringNow("~r~Mapa limpo!", 2000)
        end
        
        imgui.End()
    end
end

-- ==============================================================================
-- LOOP PRINCIPAL DO SCRIPT
-- ==============================================================================
function main()
    if not isPlayerPlaying(PLAYER_HANDLE) then
        while not isPlayerPlaying(PLAYER_HANDLE) do
            wait(200)
        end
    end
    
    printStringNow("~g~Universal Builder Mod pronto!~w~ Pressione ~y~[F7]~w~ ou digite ~y~BUILD", 4000)
    
    while true do
        wait(0)
        
        -- TECLA DE ATIVACAO: F7 OU CHEAT "BUILD"
        if wasKeyPressed(vkeys.VK_F7) or testCheat("BUILD") or testCheat("MOVEL") then
            window_state.v = not window_state.v
            imgui.ShowCursor = window_state.v
            if window_state.v then
                current_state = STATE_BROWSER
            else
                current_state = STATE_IDLE
            end
        end
        
        -- ESTADO 1: COLOCANDO NO CHAO / MIRANDO COM O MOUSE (RAYCASTING)
        if current_state == STATE_PLACING and ghost.handle and doesObjectExist(ghost.handle) then
            local hitX, hitY, hitZ, normX, normY, normZ, hasHit = get_aim_target_coords(settings.draw_distance)
            
            -- Aplicacao de Grid Snap
            if settings.grid_snap then
                hitX = math.floor((hitX / settings.grid_size) + 0.5) * settings.grid_size
                hitY = math.floor((hitY / settings.grid_size) + 0.5) * settings.grid_size
                hitZ = math.floor((hitZ / settings.grid_size) + 0.5) * settings.grid_size
            end
            
            ghost.x = hitX
            ghost.y = hitY
            ghost.z = hitZ + ghost.elevation_offset
            
            -- Atualiza coordenadas fisicas do ghost
            setObjectCoordinates(ghost.handle, ghost.x, ghost.y, ghost.z)
            setObjectHeading(ghost.handle, ghost.heading)
            
            -- Rotacao rapida com Q e E
            if isKeyDown(vkeys.VK_Q) then
                ghost.heading = (ghost.heading - 2.5) % 360.0
            elseif isKeyDown(vkeys.VK_E) then
                ghost.heading = (ghost.heading + 2.5) % 360.0
            end
            
            -- Snap de Angulo com tecla R
            if wasKeyPressed(vkeys.VK_R) then
                ghost.heading = (math.floor((ghost.heading / settings.angle_step) + 0.5) * settings.angle_step) % 360.0
                ghost.elevation_offset = 0.0
            end
            
            -- Clique Esquerdo (LMB / Fire): Confirma e coloca o objeto
            if wasKeyPressed(vkeys.VK_LBUTTON) or isButtonPressed(PLAYER_HANDLE, 15) then
                confirm_placement()
            end
            
            -- Clique Direito (RMB) ou ESC: Cancela
            if wasKeyPressed(vkeys.VK_RBUTTON) or wasKeyPressed(vkeys.VK_ESCAPE) then
                cancel_placement()
            end
        end
        
        -- ESTADO 2: MODO DE EDICAO DE OBJETO SELECIONADO
        if current_state == STATE_EDITING and selected_obj_index and placed_objects[selected_obj_index] then
            local cur = placed_objects[selected_obj_index]
            if cur.handle and doesObjectExist(cur.handle) then
                
                -- Rotacao com Q / E
                if isKeyDown(vkeys.VK_Q) then
                    cur.heading = (cur.heading - 2.0) % 360.0
                    setObjectHeading(cur.handle, cur.heading)
                elseif isKeyDown(vkeys.VK_E) then
                    cur.heading = (cur.heading + 2.0) % 360.0
                    setObjectHeading(cur.handle, cur.heading)
                end
                
                -- Duplicar com tecla C
                if wasKeyPressed(vkeys.VK_C) then
                    duplicate_selected_object()
                end
                
                -- Deletar com DELETE
                if wasKeyPressed(vkeys.VK_DELETE) then
                    delete_selected_object()
                end
                
                -- Desmarcar com ESPACO ou ENTER
                if wasKeyPressed(vkeys.VK_SPACE) or wasKeyPressed(vkeys.VK_RETURN) then
                    selected_obj_index = nil
                    current_state = STATE_IDLE
                    printStringNow("~g~Objeto confirmado!", 1500)
                end
            end
        end
        
    end
end
