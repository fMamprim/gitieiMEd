if not (getGameVersion) then 
    print('Lua Visual Veh Spawner By Um_Geek\nLua Script for GTA Sa Moonloader\nVersion: 8')
    while 1 do end
end -- > se não for pelo moonloader para aqui

script_name("Lua Visual Veh Spawner")
script_author("Um_Geek")
script_description("Chame veiculos do jogo atravez da imagem e um sistema de busca, alem de usar varias farrementas para aplicar a modelos.")
script_url("https://gta-geek.blogspot.com/2019/06/gta-sa-lua-novo-visual-vehicle-spawner.html")
script_version_number(8)

local imgui = require 'imgui'
local memory = require 'memory'

local cmodel_info = require ('visual-veh-spawner.modules.cmodelinfo')
local modules = require ('visual-veh-spawner.modules.modules')
local tools = require ('visual-veh-spawner.modules.tools')
local dff_name_spawner = require ('visual-veh-spawner.modules.dff_name_spawner')

local addons_commands = {}
local settings = {}
local textures = {}
local screen = {}
local functions = {}
local filters = {}
local historic = {}
local mod_path = tools.path
local mod_filters_path = string.format("%sfilters\\",mod_path)
local mod_imgui_style = "style.json"
local mod_settings_file = "configs.json"
local enable_new_filter = nil

settings.start_window = 'Simple'
settings.pics_size = 100.0
settings.spawn_flying_height = 60.0
settings.pics_in_line = 7
settings.max_num_itens_in_gallery = 300
settings.exit_on_spawner = true
settings.save_sets_on_exit = false
settings.fast_load = false
settings.enable_fast_spawn_keys = true
settings.fast_spawn_keys = {}
settings.images_format = '*.jpg'
settings.fav_list = {}
settings.active_filter = 0

settings.active_key = {
    [1] = 0x50, -- vk_p
    [2] = 0x55, -- vk_u
    [3] = 0x4B, -- vk_k > fast spawner
}

function load_addons()
    local files = tools.load_files(mod_path..'addons\\','*.lua')
    addons_commands = {}
    local count = 0
    for k,v in pairs(files) do
        if (v.name):sub(1,1) ~= '.' then
            local m = loadstring(tools.read_text_file(v.path))
            if type(m) == 'function' then
                addons_commands[k] = m()
                count = count + 1 
            end
        end
    end
    return count
end
load_addons()

local _sets = tools.load_table(mod_settings_file)
if _sets then 
    settings = _sets
    if not (settings.fav_list) then 
        settings.fav_list = {}
    end
end

--[[--
local checked_comand = false
local function check_version()
    -- check in: https://jsonbin.io
    checked_comand = true
    local fpath = os.getenv('TEMP') .. '\\mod-versions-um_geek_temp.json'
    tools.download_json('https://api.jsonbin.io/b/5d4313eaea04da211dc64bd2/1',fpath,function(info)
        if info.data then
            local name = thisScript().filename
            name = name:reverse()
            local ct = 0
            for i = 1, #name do 
                ct = i; if name:sub(i,i) == '.' then break end
            end
            name = name:sub(ct+1,#name)
            name = name:reverse()
            local v = info.data[name]
            print('version disponible ' .. v)
            settings.version_avaliable = v
        end
    end)    
end
--]]--

local function load_mod_filters()
    filters = {}

    filters[0] = {name="All Vehicles",fun=function(m) return true end}

    filters[1] = {name="Cars",fun=cmodel_info.IsCarModel}
    filters[2] = {name="Planes",fun=cmodel_info.IsPlaneModel}
    filters[3] = {name="Helis",fun=cmodel_info.IsHeliModel}
    filters[4] = {name ="Boats",fun=cmodel_info.IsBoatModel}

    filters[5] = {name="Trains", fun=function(m)
        return cmodel_info.IsTrainModel(m)
    end}

    filters[6] = {name="Trailers", fun=function(m)
        return cmodel_info.IsTrailerModel(m)
    end}

    filters[7] = {name="Bikes", fun=function(m)
        return (cmodel_info.IsBikeModel(m) or cmodel_info.IsBmxModel(m))
    end}

    filters[8] = {name="Favorites", fun=function(m)
        return tools.find_in_list(m,settings.fav_list)
    end} 

    filters[9] = {name="Historic", fun=function(m)
        return tools.find_in_list(m,historic)
    end}

    if doesDirectoryExist(mod_filters_path) then 
        local txts = tools.load_files(mod_filters_path,"*.json")
        local result = true
        for i=1, #txts do 
            local out_t = decodeJson(tools.read_text_file(txts[i].path))
            filters[#filters+1] = {
                name = out_t.name, 
                edit = out_t.edit,
                fun = function(m)
                    return tools.find_in_list(m,out_t.models)
                end,
            }
        end

        local txts = tools.load_files(mod_filters_path,"*.lua")
        local result = true
        for i=1, #txts do 
            local out_f = loadstring(tools.read_text_file(txts[i].path))
            if type(out_f) == "function" then 
                local out_t = out_f()
                filters[#filters+1] = {
                    name = out_t.name, 
                    edit = false,
                    fun = function(m)
                        return tools.find_in_list(m,out_t.func())
                    end,
                }
            end
        end
    end
end

local function apply_filters(model)
    local counter = 0
    for i = 1, #filters do 
        if i == settings.active_filter then 
            if filters[i].fun(model) then 
                return true 
            end
        end
    end
    return (settings.active_filter == 0)
end



local function get_vehicle_name_by_model(model)
    local gxt = cmodel_info.game_name(model)
    local text = getGxtText(gxt)
    if (text ~= '') then
        text = tools.convert_code(text)
        return (text:sub(1,1)):upper()..(text:sub(2,#text)):lower()
    end
    return gxt:upper()
end

local display_itens_loading = 0
local loading_pictures = false
local pictures_dir = mod_path .. 'pictures\\'

local function load_all_textures(dir,ext,fast)
    local files = tools.load_files(dir,ext)
    display_itens_loading = #files
    loading_images = true
    if #textures > 0 then -- unload
        for i = 1 , #textures do 
            local tex = textures[i].texture
            imgui.ReleaseTexture(tex)
            textures[i] = nil
        end  
    end
    loading_pictures = true
    for i,file in ipairs(files) do
        local model = tools.string_to_number(file.name)
        if model then
            if isModelAvailable(model) then
                table.insert(textures,{
                    model = model,
                    texture = imgui.CreateTextureFromFile(file.path),
                })
                if not fast then wait(0) end
            end
        end  
    end
    loading_pictures = false
end

local function find_vehicles_names(text,tex) -- name,vehname)
    if #text >= 2 then
        local zname = get_vehicle_name_by_model(tex.model)
        local gxt = getNameOfVehicleModel(tex.model)
        zname = string.format("%s %s %s",zname,gxt,tex.model)
        zname = zname:lower()
        return zname:find(text)
    end
    return true
end

local im_input_box_buffer = imgui.ImBuffer(24)
local im_input_filter_name = imgui.ImBuffer(24)
local im_picture_size = imgui.ImFloat(settings.pics_size)
local im_max_num_itens_in_gallery = imgui.ImInt(settings.max_num_itens_in_gallery)
local im_spawn_flying_height = imgui.ImFloat(settings.spawn_flying_height)
local edit_color = {
    r = imgui.ImFloat(),
    g = imgui.ImFloat(),
    b = imgui.ImFloat(),
    a = imgui.ImFloat(),
}



local function display_popup(index)
    local tex = textures[index]
    local spawner_command = false   
    if tex then 
        if isModelAvailable(tex.model) then
            if imgui.BeginPopup("Apply Actions") then 
                imgui.Text(get_vehicle_name_by_model(tex.model):upper())
                imgui.Separator()

                if not cmodel_info.IsTrainModel(tex.model) then
                    if imgui.MenuItem("Spawner by cheat",nil,false,true) then 
                        spawnVehicleByCheating(tex.model)
                        spawner_command = true
                    end
                end

                for _,module_function in pairs(modules) do
                    if (type(module_function) == 'function') then
                        if module_function(tex,settings,cmodel_info,imgui) then 
                            spawner_command = true
                        end
                    end
                end

                if #addons_commands > 0 then 
                    imgui.Separator()
                    for k, m in pairs(addons_commands) do
                        if type(m) == 'function' then
                            if m(tex,settings,cmodel_info,imgui) then 
                                spawner_command = true
                            end
                        end
                    end
                end
                imgui.Separator()
                if not tools.find_in_list(tex.model,settings.fav_list) then
                    if imgui.MenuItem("Mark as a favorite",nil,false,true) then 
                        table.insert(settings.fav_list,tex.model)
                    end 
                else 
                    if imgui.MenuItem("Remove from favorites",nil,false,true) then 
                        for index,fav in ipairs(settings.fav_list) do
                            if fav == tex.model then 
                                table.remove(settings.fav_list,index)
                            end
                        end
                    end 
                end   
                if (enable_new_filter) then 
                    local index = tools.find_in_list(tex.model,enable_new_filter)
                    if not (index) then
                        if imgui.MenuItem("Add to filter",nil,false,true) then 
                            table.insert(enable_new_filter,tex.model)
                        end 
                    else 
                        if imgui.MenuItem("Remove in filter",nil,false,true) then 
                            table.remove(enable_new_filter,index)
                        end 
                    end
                end 
                
                if (settings.enable_fast_spawn_keys) then     
                    if imgui.BeginMenu("Spawn keys",true) then 
                        imgui.Text(string.format("Press '%c' and NUM",settings.active_key[3]))
                        imgui.Separator()
                        for i = 0, 9 do 
                            local k = tostring(i)
                            local name = (settings.fast_spawn_keys[k]) and k ..':' .. get_vehicle_name_by_model(settings.fast_spawn_keys[k]) or k ..': Free'
                            if imgui.MenuItem(name,nil,false,true) then 
                                settings.fast_spawn_keys[k] = tex.model
                                tools.save_table(mod_settings_file,settings)
                            end      
                        end
                        imgui.EndMenu()                   
                    end
                end
                
                imgui.Separator()
                imgui.Spacing()        
                if imgui.MenuItem("Cancel",nil,false,true) then 
                    imgui.CloseCurrentPopup()
                end 
                imgui.Separator()        
                if imgui.MenuItem("Quit",nil,false,true) then 
                    imgui.Process = false
                end             
                imgui.EndPopup()
            end
        else 
            spawner_command = true
        end
    end
    if spawner_command then
        table.insert(historic,tex.model)
        if settings.exit_on_spawner then 
            imgui.Process = false
        end
    end
end

local function sub_menu_config_keys_menu(num)
    local ret = 0
    local bts = "0123456789ABCDEFGHIJKLMNOPQRSTUVXYWZ"
    for i = 1,#bts do 
        if ret <= 9 and i > 1 then imgui.SameLine() else ret = 0 end
        if imgui.Button(bts:sub(i,i),imgui.ImVec2(24.0,24)) then
            settings.active_key[num] = (bts:sub(i,i)):byte()
        end
        ret = ret + 1
    end
end

local function find_image_model(model)
    for i,tex in ipairs(textures) do
        if model == tex.model then 
            return tex
        end
    end
    return nil
end

local function quick_spawner(model)
    if not cmodel_info.IsTrainModel(model) then 
        local x, y, z = getCharCoordinates(PLAYER_PED)
        local angle = getCharHeading(PLAYER_PED)
        if isCharSittingInAnyCar(PLAYER_PED) then 
            local v = getCarCharIsUsing(PLAYER_PED)
            clearCharTasksImmediately(PLAYER_PED)
            deleteCar(v)
        end
        local veh = cmodel_info.create(model,x,y,z,angle)
        markCarAsNoLongerNeeded(veh)
        warpCharIntoCar(PLAYER_PED,veh)
        table.insert(historic,model)
        if settings.exit_on_spawner then 
            imgui.Process = false
        end              
    end
end

-- display All 
local active_index = nil
local start_gallery_in = 1


functions['Gallery'] = function() 
    imgui.SetNextWindowPos(imgui.ImVec2(8,30),imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(screen.x-14,screen.y-40),imgui.Cond.FirstUseEver)
    imgui.Begin("Gallery - "..filters[settings.active_filter].name,nil,2+4+32+128+2048)

    local f_win_size_w = imgui.GetWindowWidth()
    local im_pictures_clmns = (f_win_size_w-25)/im_picture_size.v
    local max_itens = im_max_num_itens_in_gallery.v
    local nColmns = 0

    imgui.Spacing()

    local show_item = function(tex,index)
        local name = get_vehicle_name_by_model(tex.model)
        if find_vehicles_names(im_input_box_buffer.v,tex) and apply_filters(tex.model) then
            if nColmns < f_win_size_w and nColmns > 0 then
                if index > 1 then imgui.SameLine() end
            else
                nColmns = 0
                imgui.Spacing()
            end
            imgui.BeginGroup() 
            if imgui.ImageButton(tex.texture,imgui.ImVec2(im_picture_size.v,im_picture_size.v/1.72),imgui.ImVec2(0,0),imgui.ImVec2(1,1),0,imgui.ImVec4(1,1,1,1),imgui.ImVec4(1,1,1,1)) then 
                imgui.OpenPopup("Apply Actions")
                active_index = index               
            end  
            if imgui.IsItemHovered() then 
                local name = get_vehicle_name_by_model(tex.model)
                imgui.SetTooltip(tex.model..'\n'..name)
                if imgui.IsItemClicked(1) then 
                    quick_spawner(tex.model)
                end
            end
            imgui.EndGroup()
            nColmns = nColmns + (im_picture_size.v+(im_picture_size.v/8))
        end
    end

    if (max_itens < #textures) then
        if imgui.Button('<<',imgui.ImVec2(im_picture_size.v,30.0)) then
            if (textures[start_gallery_in - max_itens]) then 
                start_gallery_in = start_gallery_in - max_itens
            end
        end 
        imgui.SameLine()
        for i = 0.0, (f_win_size_w-((im_picture_size.v+(im_picture_size.v/8))*2)), (im_picture_size.v+(im_picture_size.v/8)) do 
            imgui.InvisibleButton('bt_inv'..i,imgui.ImVec2(im_picture_size.v,30.0))
            imgui.SameLine()
        end
        if imgui.Button('>>',imgui.ImVec2(im_picture_size.v,30.0)) then
            if (textures[start_gallery_in+max_itens]) then 
                start_gallery_in = start_gallery_in + max_itens
            end
        end 
        imgui.NewLine()

        local count = 0
        for i,tex in ipairs(textures) do
            if (start_gallery_in <= i) then 
                show_item(tex,i)
                count = count + 1
            end
            if max_itens <= count then 
                break 
            end
        end
    else 
        for i,tex in ipairs(textures) do
            show_item(tex,i)
        end
    end
    imgui.NewLine()
    display_popup(active_index)
    imgui.End()
end 

-- Fast Spawner
functions['Simple'] = function() 
    
    imgui.SetNextWindowPos(imgui.ImVec2(4.0,screen.y-(im_picture_size.v+4)))
    imgui.SetNextWindowSize(imgui.ImVec2(screen.x-8.0,im_picture_size.v))
    imgui.Begin("Simple - "..filters[settings.active_filter].name,nil,2+4+32+128+2048)
    imgui.Spacing()

    local box_picture_size = (imgui.GetWindowHeight()-50.0)
    for i,tex in ipairs(textures) do
        local name = (get_vehicle_name_by_model(tex.model))
        if find_vehicles_names(im_input_box_buffer.v,tex) and apply_filters(tex.model) then
            if i > 1 then imgui.SameLine() end
            imgui.BeginGroup() 
            if imgui.ImageButton(tex.texture,imgui.ImVec2(box_picture_size*1.72,box_picture_size),imgui.ImVec2(0,0),imgui.ImVec2(1,1),1,imgui.ImVec4(1,1,1,1),imgui.ImVec4(1,1,1,1)) then 
            end
            if imgui.IsItemHovered() then
                if imgui.IsMouseClicked(0,false) then 
                    active_index = i
                    imgui.OpenPopup("Apply Actions")
                elseif imgui.IsMouseClicked(1,false) then  
                    quick_spawner(tex.model)
                end 
                imgui.SetTooltip(tex.model..'\n'..name)
            end
            imgui.EndGroup()
        end
    end
    display_popup(active_index) 
    imgui.End()
end 

-- list Spawner
functions['List'] = function() 
    local w_size = 280.0
    if (settings.invert_list_pos) then
        imgui.SetNextWindowPos(imgui.ImVec2(screen.x-(w_size+8.0),30.0))
    else 
        imgui.SetNextWindowPos(imgui.ImVec2(4.0,30.0))
    end

    imgui.SetNextWindowSize(imgui.ImVec2(w_size,screen.y-38.0),imgui.Cond.FirstUseEver)
    imgui.Begin("List - "..filters[settings.active_filter].name,nil,2+4+32+128+2048)
    imgui.Spacing()   
    if imgui.MenuItem('Show filters',nil,(settings.show_filtes_in_list),true) then 
        settings.show_filtes_in_list = not (settings.show_filtes_in_list)
    end 
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()

    local list_item_func = function(tex, index)
        local name = get_vehicle_name_by_model(tex.model)
        if find_vehicles_names(im_input_box_buffer.v,tex) and apply_filters(tex.model) then
            imgui.Bullet()
            if imgui.MenuItem(name,tostring(tex.model),false,true) then 
                imgui.OpenPopup("Apply Actions")
                active_index = index
            end 
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Image(tex.texture,imgui.ImVec2(120,80),imgui.ImVec2(0,0),imgui.ImVec2(1,1),imgui.ImVec4(1,1,1,1),imgui.ImVec4(0,0,0,0))
                imgui.EndTooltip()
            end
        end
    end
    if (settings.show_filtes_in_list) and (#(im_input_box_buffer.v) <= 1) then 
        for k,list in pairs(filters) do
            if imgui.CollapsingHeader(list.name,0,false) then
                for i,tex in ipairs(textures) do 
                    if list.fun(tex.model) then 
                        list_item_func(tex, i)
                    end
                end
            end
        end
    else 
        for i,tex in ipairs(textures) do 
            list_item_func(tex, i)
        end
    end

    display_popup(active_index)
    imgui.End()
end

functions['DFF'] = function() 
    local size_w = 240.0 
    local size_y = 280.0

    imgui.SetNextWindowPos(imgui.ImVec2((screen.x/2)-(size_w/2), (screen.y/2)-(size_y/2)),imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(size_w,size_y),imgui.Cond.FirstUseEver)
    imgui.Begin("DFF Spawner",nil,2+4+32+128+2048)

    local result = dff_name_spawner(find_image_model,get_vehicle_name_by_model)
    if result then 
        for i,tex in ipairs(textures) do
            if result == tex.model then 
                imgui.OpenPopup("Apply Actions")
                active_index = i
            end
        end
    end
    display_popup(active_index)
    imgui.End()
end


imgui.SwitchContext()
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4

style.WindowRounding = 2.0
style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
style.ChildWindowRounding = 2.0
style.FrameRounding = 2.0
style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
style.ScrollbarSize = 12.0
style.ScrollbarRounding = 0
style.GrabMinSize = 8.0
style.GrabRounding = 0.0

function colors_reset()
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 0.75)
	colors[clr.TitleBgActive]          = ImVec4(0.00, 0.00, 0.00, 0.75)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.50)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 0.75)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
colors_reset()

local function convertRGBAtoHex(r,g,b,a)
    return (a*0x01000000)+(r*0x00010000)+(g*0x00000100)+(b*0x00000001)
end

local bg_color1 = convertRGBAtoHex(175,175,175,255)
local bg_color2 = convertRGBAtoHex(10,10,10,255)
local border_color = convertRGBAtoHex(0,0,0,255)

function imgui.OnDrawFrame()
    screen.x,screen.y = getScreenResolution()
    if loading_pictures then 
        local screen_w,screen_h = screen.x,screen.y
        local sizex = screen_w/4.0
        local sizey = 14.0       

        local border = 2
        local posx,posy = (screen_w/2 )- (sizex/2), (screen_h/4) + (sizey/2) 

        local k = sizex / display_itens_loading
        local v = #textures * k

        renderDrawBoxWithBorder(posx,posy,sizex,sizey,bg_color1,border,border_color)
        renderDrawBoxWithBorder(posx+v,posy,sizex-v,sizey,bg_color2,border,border_color)
    else
        if #filters > 0 then
            for k = 0, 9 do 
                if wasKeyPressed(k+48) then 
                    for j=0, #filters do
                        im_input_box_buffer.v = ''
                        settings.active_filter = k
                    end
                end
            end
        end
        if imgui.BeginMainMenuBar() then 
            imgui.TextColored(colors[clr.TextDisabled],string.format(" %s by %s ",thisScript().name,thisScript().authors[1]))
            if isCharInAnyCar(PLAYER_PED) then
                imgui.Separator()  
                if imgui.BeginMenu("Vehicle",true) then
                    local veh_h = getCarCharIsUsing(PLAYER_PED)
                    imgui.Spacing()
                    local _mod = getCarModel(veh_h)
                    local _tex = find_image_model(_mod)
                    local _gxt = getNameOfVehicleModel(_mod)
                    if _tex then
                        imgui.Image(_tex.texture,imgui.ImVec2(180,90),imgui.ImVec2(0,0),imgui.ImVec2(1,1),imgui.ImVec4(1,1,1,1),imgui.ImVec4(0,0,0,0))
                    end
                    if _gxt then
                        imgui.Text(_gxt)
                        imgui.Separator()
                        imgui.Text(string.format("Model: %s",_mod))
                        imgui.Text(string.format("Name: %s",getGxtText(_gxt)))
                    end
                    imgui.NewLine()
                    imgui.Separator() 
                    if imgui.MenuItem('Fix car',nil,false,true) then 
                        fixCar(veh_h)
                        printHelpString('Fix Car OK!')
                    end
                    imgui.Separator() 
                    if imgui.MenuItem('Leave car',nil,false,true) then 
                        clearCharTasksImmediately(PLAYER_PED)
                        deleteCar(veh_h)
                    end
                    imgui.EndMenu()
                end 
            elseif (settings.add_jetpack_in_menu) then
                imgui.Separator()
                if imgui.MenuItem('Jetpack',nil,false,true) then 
                    if not hasModelLoaded(370) then
                        requestModel(370)
                        loadAllModelsNow()
                    end
                    taskJetpack(PLAYER_PED)
                    markModelAsNoLongerNeeded(370)
                    imgui.Process = false
                end                 
            end

            for k,v in pairs(functions) do
                imgui.Separator() 
                if imgui.MenuItem(k,nil,false,not (settings.start_window == k)) then 
                    settings.start_window = k
                end
            end

            imgui.Separator() 
            local display_filters = (settings.start_window ~= 'DFF')
            if imgui.BeginMenu('Filters',display_filters) then
                for i=0, #filters do
                    if i == (#filters-1) then 
                        imgui.Spacing()
                        imgui.Separator()
                    end 
                    imgui.Bullet()
                    local label = filters[i].name
                    if i <= 9 then 
                        label = string.format("[%i] %s",i,filters[i].name)
                    end
                    if imgui.MenuItem(label,nil,false,(settings.active_filter ~= i)) then 
                        settings.active_filter = i  
                        im_input_box_buffer.v = ''      
                    end  
                end
                imgui.Separator()
                imgui.NewLine()
                imgui.Separator()
                if imgui.MenuItem('New json filter',nil,false,true) then 
                    enable_new_filter = {}
                end  
                if imgui.MenuItem('Reload filters',nil,false,true) then 
                    load_mod_filters()
                end                 
                imgui.EndMenu()
            end

            imgui.Separator() 
            if imgui.BeginMenu('Find',display_filters) then
                imgui.Spacing()
                if imgui.InputText('Name',im_input_box_buffer) then 
                end
                imgui.NewLine()
                imgui.Separator()
                if imgui.MenuItem('Clear textbox',nil,false,(#im_input_box_buffer.v > 0)) then 
                    im_input_box_buffer.v = ''
                end               
                imgui.EndMenu()
            end  

            imgui.Separator() 
            if imgui.BeginMenu('Settings',true) then
                imgui.TextColored(colors[clr.TextDisabled],string.format("Models: %i / Pictures: %i",#textures,display_itens_loading))
                imgui.Spacing()
                imgui.Separator()                
                if imgui.MenuItem('Save Settings',nil,false,true) then 
                    settings.pics_size = im_picture_size.v
                    settings.spawn_flying_height = im_spawn_flying_height.v
                    settings.max_num_itens_in_gallery = im_max_num_itens_in_gallery.v
                    tools.save_table(mod_settings_file,settings) 
                    printHelpString("Settings saved!")
                end     
                imgui.Spacing()
                imgui.Separator() 
                if imgui.MenuItem('Reload addons',nil,false,true) then 
                    printHelpString(string.format('%i Addons loadeds!',load_addons()))
                end
                imgui.Spacing()
                imgui.Separator() 
                imgui.SliderFloat("Picture Size", im_picture_size,100.0,300.0)
                imgui.InputInt("Gallery itens", im_max_num_itens_in_gallery,1,display_itens_loading) 
                if im_max_num_itens_in_gallery.v <= 0 then 
                    im_max_num_itens_in_gallery.v = display_itens_loading
                end
                imgui.Spacing()
                imgui.Separator() 
                imgui.Spacing()
                local x,y,z = getCharCoordinates(PLAYER_PED)
                imgui.SliderFloat("Spawn flying in height",im_spawn_flying_height,z,z+120.0) 
                imgui.NewLine()
                imgui.Separator()

                if imgui.MenuItem('Invert list pos',nil,(settings.invert_list_pos),true) then 
                    settings.invert_list_pos = not (settings.invert_list_pos)
                end  

                if imgui.MenuItem('Exit on spawner',nil,(settings.exit_on_spawner),true) then 
                    settings.exit_on_spawner = not (settings.exit_on_spawner)
                end

                if imgui.MenuItem('Add jetpack in menu',nil,(settings.add_jetpack_in_menu),true) then 
                    settings.add_jetpack_in_menu = not (settings.add_jetpack_in_menu)
                end                

                if imgui.MenuItem('Save settings on exit',nil,settings.save_sets_on_exit,true) then 
                    settings.save_sets_on_exit = not (settings.save_sets_on_exit)
                    tools.save_table(mod_settings_file,settings) 
                    printHelpString("Settings saved!")
                end

                if imgui.MenuItem('Fast load',nil,(settings.fast_load),true) then 
                    settings.fast_load = not (settings.fast_load)
                end

                if imgui.BeginMenu('Images format',(not loading_pictures)) then                
                    for i,t in ipairs({'*.jpg','*.png','*.bmp'}) do
                        if imgui.MenuItem(t:upper(),nil,(settings.images_format == t),(not loading_pictures)) then 
                            settings.images_format = t
                            load_all_textures(pictures_dir,settings.images_format,true)
                            tools.save_table(mod_settings_file,settings) 
                        end
                    end
                    imgui.Separator()
                    if imgui.MenuItem('Reload images',nil,false,(not loading_pictures)) then 
                        if (settings.fast_load) then
                            load_all_textures(pictures_dir,settings.images_format,true)
                        else 
                            local load_thread = lua_thread.create(load_all_textures,pictures_dir,settings.images_format,false)
                            load_thread.work_in_pause = true
                        end
                    end                       
                    imgui.EndMenu()
                end
                imgui.NewLine()                              
                imgui.Separator() 
                for i = 1, #settings.active_key do
                    if imgui.BeginMenu(string.format("Active key %i ( %c )",i,settings.active_key[i]),true) then 
                        sub_menu_config_keys_menu(i)
                        imgui.EndMenu()
                    end 
                end     
                imgui.Separator() 
                if imgui.BeginMenu("Spawn keys",true) then 
                    if imgui.MenuItem('Enable fast spawn',nil,(settings.enable_fast_spawn_keys),true) then 
                        settings.enable_fast_spawn_keys = not settings.enable_fast_spawn_keys
                    end                   
                    imgui.Separator() 
                    for i = 0, 9 do 
                        local k = tostring(i)
                        local name = (settings.fast_spawn_keys[k]) and k ..': ' .. get_vehicle_name_by_model(settings.fast_spawn_keys[k]) or k ..': Free'
                        if imgui.MenuItem(name,nil,false,true) then 
                            settings.fast_spawn_keys[k] = nil
                            tools.save_table(mod_settings_file,settings)
                        end      
                    end
                    imgui.EndMenu()                   
                end
                imgui.NewLine()
                imgui.Separator()
                imgui.Text('ABOUT')
                imgui.Text('Author: '..thisScript().authors[1])
                imgui.Text('Version Number: '..thisScript().version)
                imgui.Separator()
                if imgui.MenuItem("Copy link to see new updates.",nil,false,true) then 
                    if setClipboardText(thisScript().url) then 
                        printHelpString("Paste the link into your browser.")
                        imgui.Process = false
                    end
                end
                --[[-- 
                imgui.Separator()
                if imgui.MenuItem("Enable check version",nil,(settings.check_version),true) then 
                    settings.check_version = not (settings.check_version)
                end  
                if not (settings.check_version) and not (checked_comand) then
                    imgui.Separator()
                    if imgui.MenuItem("Check version",nil,false,true) then 
                        check_version()
                    end                   
                end
                if (settings.version_avaliable) then 
                    imgui.Separator()
                    if settings.version_avaliable > thisScript().version then 
                        imgui.TextColored(imgui.ImVec4(0.53,0.53,0.00,1.00),string.format('New version available. Version %i',settings.version_avaliable))
                    else 
                        imgui.TextColored(imgui.ImVec4(0.00,0.53,0.53,1.00),'Latest Installed Version')
                    end
                end
                --]]--
                imgui.EndMenu()
            end 

            imgui.Separator()      
            if imgui.BeginMenu('Style',true) then
                imgui.ListBoxHeader('clr',#clr,12)
                for k,v in pairs(clr) do
                    imgui.ColorButton(k,colors[v],0,imgui.ImVec2(24,24))
                    imgui.SameLine()
                    if imgui.BeginMenu(k,true) then 
                        imgui.SliderFloat4('Color',colors[v],0.0,1.0)
                        imgui.EndMenu()
                    end
                end
                imgui.ListBoxFooter()
                imgui.NewLine()
                imgui.Separator()
                if imgui.MenuItem("Reset style",nil,false,true) then 
                    colors_reset()
                end
                if imgui.MenuItem("Save style",nil,false,true) then 
                    local t_style = {}
                    for k,v in pairs(clr) do
                        if colors[v] then
                            local r,g,b,a = (imgui.ImColor(colors[v])):GetFloat4()
                            t_style[k] = {r=r,g=g,b=b,a=a}
                        end
                    end
                    tools.save_table(mod_imgui_style,t_style) 
                    printHelpString("Style Saved!")
                end
                imgui.EndMenu()
            end
            imgui.Separator()  
            if imgui.MenuItem('Close',nil,false,true) then 
                imgui.Process = false
            end  
            if (enable_new_filter) then
                imgui.Separator()  
                if imgui.BeginMenu(string.format('New filter ( %i )', #enable_new_filter),true) then 
                    imgui.InputText('Name',im_input_filter_name)
                    imgui.Spacing()
                    imgui.Separator()
                    if imgui.MenuItem('Save list filter',nil,false,true) then 
                        if #im_input_filter_name.v >= 1 then
                            local text_filter_out = {
                                name = im_input_filter_name.v,
                                edit = true,
                                models = {},
                            }
                            local add_split = false
                            for i = 1, #enable_new_filter do
                                table.insert(text_filter_out.models, enable_new_filter[i])
                            end
                            local filter_name = string.format("%s\\%s.json",mod_filters_path,im_input_filter_name.v)
                            local hFile = io.open(filter_name,"w"); -- open file
                            if hFile then
                                hFile:write(encodeJson(text_filter_out));
                                hFile:close(); -- close file
                            end
                            enable_new_filter = nil
                            load_mod_filters()
                            printHelpString("New filter saved!")
                        end
                    end      
                    if imgui.MenuItem('Cancel',nil,false,true) then 
                        enable_new_filter = nil
                    end
                    imgui.Separator()
                    if (enable_new_filter) then
                        for i = 1, #enable_new_filter do
                            local model = enable_new_filter[i]
                            local name = get_vehicle_name_by_model(model)
                            imgui.Bullet()
                            if imgui.MenuItem(model..':'..name,'DEL',false,true) then 
                                table.remove(enable_new_filter, i)
                            end
                        end  
                    end               
                    imgui.EndMenu()
                end
            end
            imgui.Separator() 
            imgui.EndMainMenuBar()
        end
        if type(functions[settings.start_window]) == 'function' then
            functions[settings.start_window]()
        end
    end
end

local m_map, m_hud

function main()
    if (settings.fast_load) then
        load_all_textures(pictures_dir,settings.images_format,true)
    else 
        local load_thread = lua_thread.create(load_all_textures,pictures_dir,settings.images_format,false)
        load_thread.work_in_pause = true
    end
    local _style = tools.load_table(mod_imgui_style)
    if _style then 
        for k,v in pairs(clr) do
            if _style[k] then 
                colors[v] = ImVec4(_style[k].r,_style[k].g,_style[k].b,_style[k].a)
            end
        end
    end

    --[[--
    if (settings.check_version) then
        check_version()                  
    end
    --]]--

    while true do 
        wait(0)
        if isPlayerControlOn(PLAYER_HANDLE) then
            if isKeyDown(settings.active_key[1]) and isKeyDown(settings.active_key[2]) then -- tecla N 
                if isKeyDown(0x09) then loading_pictures = false end -- test
                while isKeyDown(settings.active_key[1]) or isKeyDown(settings.active_key[2]) do 
                    wait(0)
                end
                imgui.Process = true 
                setPlayerControl(PLAYER_HANDLE,false)
                setCameraBehindPlayer()
                load_mod_filters()
                m_map = readMemory(0xBA676C,1,false)
                m_hud = readMemory(0xBA6769,1,false)
                writeMemory(0xBA676C,1,2,false)
                writeMemory(0xBA6769,1,0,false)
                active_index = nil
                if isPlayerUsingJetpack(PLAYER_HANDLE) then 
                    clearCharTasksImmediately(PLAYER_PED)
                    wait(1000)
                end
                while imgui.Process do 
                    if (isKeyDown(settings.active_key[1])
                    and isKeyDown(settings.active_key[2])) then 
                        imgui.Process = false
                    end
                    wait(0)
                end
                writeMemory(0xBA676C,1,m_map,false)
                writeMemory(0xBA6769,1,m_hud,false)
                restoreCamera()
                setPlayerControl(PLAYER_HANDLE,true)
            end
            if isKeyDown(settings.active_key[3]) and (settings.enable_fast_spawn_keys) then 
                for i = 0, 9 do 
                    if wasKeyPressed(48+i) then
                        local k = tostring(i)
                        if (settings.fast_spawn_keys[k]) then 
                            local x, y, z = getCharCoordinates(PLAYER_PED)
                            local angle = getCharHeading(PLAYER_PED)
                            if isCharSittingInAnyCar(PLAYER_PED) then 
                                local v = getCarCharIsUsing(PLAYER_PED)
                                clearCharTasksImmediately(PLAYER_PED)
                                deleteCar(v)
                            end
                            local veh = cmodel_info.create(settings.fast_spawn_keys[k],x,y,z,angle)
                            warpCharIntoCar(PLAYER_PED,veh)
                        else 
                            printHelpString('Indisponible!')
                        end
                    end
                end
            end
        end
    end
end

function onScriptTerminate(script,quitGame)
    if (script == thisScript()) then
        if settings.save_sets_on_exit then
            if doesFileExist(mod_path..mod_settings_file) then
                tools.save_table(mod_settings_file,settings)
                print('save settings on exit - Ok!')
            end
        end 
        if (m_map and m_hud) then 
            writeMemory(0xBA676C,1,m_map,false)
            writeMemory(0xBA6769,1,m_hud,false)
        end
        if #textures > 0 then -- unload
            for i = 1 , #textures do 
                local tex = textures[i].texture
                imgui.ReleaseTexture(tex)
                textures[i] = nil
            end  
        end
    end
end