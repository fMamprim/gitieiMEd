script_name("Parcked Car Maker By Um Geek")
script_author("Um_Geek")
script_description("Use K + P para abrir. Crie carros estacionados pelo mapa do jogo sem os deixar no save.")
script_url("https://gta-geek.blogspot.com/")
script_version_number(2)

-- START SETTINGS 

local KEY_1 = 0x50 -- VK_P
local KEY_2 = 0x4B -- VK_K

-- END SETTINGS

local im = require 'imgui'
local parckeds = {}
local vars = {
    doorLock = im.ImInt(0),
    forceSpawn = im.ImBool(true),  
    alarm = im.ImInt(0),  
    plate = im.ImBuffer(8),
    color1 = im.ImInt(),
    color2 = im.ImInt(),
    minDelay = im.ImFloat(0),
    maxDelay = im.ImFloat(7000),
    Advanced_Options = im.ImBool(false), 
}

local m_dir = getWorkingDirectory() .. '\\config\\'
local data_dir = m_dir .. thisScript().filename .. '.json'

if not doesDirectoryExist(m_dir) then 
    createDirectory(m_dir)
end

math.randomseed(os.clock())

local veh_images = nil
--veh_images = veh_images[1].tex

function vehicleGeneratorNoSaveExt(modelId,atX,atY,atZ,angle,color1,color2,doorLock,forceSpawn,alarm,minDelay,maxDelay,plate)
    if plate == 'null' then
        plate = string.format('%s-%i',getNameOfZone(atX,atY,atZ),math.random(100,999))
    end
    local carGenerator = createCarGeneratorWithPlate(atX,atY,atZ,angle,modelId,color1,color2,forceSpawn,alarm,doorLock,minDelay,maxDelay,plate)
	switchCarGenerator(carGenerator,101)
	local value = readMemory(0x6F32AA,1,false)
	local store_result = callFunction(0x479D60,1,1,carGenerator)
	if value >= 0x30 then 
		writeMemory(store_result + 0x22,1,1,false)
	else
		writeMemory(store_result + 0x1C,1,1,false)
	end
	return carGenerator
end

function load_settings()
    local hFile = io.open(data_dir,"r"); -- open file
    if hFile then
        local data = hFile:read();
        io.close(hFile); -- close file
        if data then 
            parckeds = decodeJson(data)
        end
    end
end

function save_settings(insert, index, data)
    local hFile = io.open(data_dir,"w"); -- open file
    if hFile then
        if insert then
            if data == nil then
                data = {
                    model = vars.m_veh,
                    x = vars.pos.x,
                    y = vars.pos.y,
                    z = vars.pos.z,
                    angle = vars.pos.angle,
                    color1 = vars.color1.v,
                    color2 = vars.color2.v,
                    doorLock = vars.doorLock.v,
                    alarm = vars.alarm.v,
                    mindely = vars.minDelay.v,
                    maxdely = vars.maxDelay.v,
                    forceSpawn = vars.forceSpawn.v and 1 or 0,
                    plate = vars.plate.v
                }
            end
            if index then 
                parckeds[index] = data
            else 
                table.insert(parckeds, data)
            end
            local t = data
            vehicleGeneratorNoSaveExt(t.model,t.x,t.y,t.z,t.angle,t.color1,t.color2,t.doorLock,t.forceSpawn,t.alarm,t.mindely,t.maxdely,t.plate)
        end
        hFile:write(encodeJson(parckeds))
        hFile:close(); -- close file
        printHelpString('~y~PARKED CAR CREATOR~n~~w~Vehicle saved!')
    end
end

EXPORTS =  -- (insert, index, data)
{
    create_parked = save_settings,
}

function im.OnDrawFrame() 
    local win_w, win_h = getScreenResolution()
    local size_w, size_h = 240.0, 380.0

    --im.SetNextWindowPos(im.ImVec2(win_w-(size_w+10),20.0),im.Cond.FirstUseEver)
    im.SetNextWindowSize(im.ImVec2(size_w,size_h),im.Cond.FirstUseEver)
    im.Begin(thisScript().name,nil)

    im.Spacing()

    if not im.CollapsingHeader(string.format("Display Veh List - %i Parckeds.",#parckeds),true) then
        if doesVehicleExist(vars.h_veh) and isCharSittingInAnyCar(PLAYER_PED) then
            im.Text(string.format('Model: %i',vars.m_veh))
            im.Separator()
            im.Spacing()

            if vars.Advanced_Options.v then
                im.InputText('Plate',vars.plate)
                im.SliderFloat('Min Delay',vars.minDelay,0,vars.maxDelay.v)
                im.SliderFloat('Max Delay',vars.maxDelay,vars.minDelay.v,10000)
                im.InputInt('Color [1]',vars.color1,-1,100)
                im.InputInt('Color [2]',vars.color2,-1,100)
                im.InputInt('Doors lock',vars.doorLock)
                im.InputInt('Alarm',vars.alarm)

                im.Spacing()
            end
            im.Checkbox('Force spawn',vars.forceSpawn)
            im.Checkbox("Advanced Options",vars.Advanced_Options)

            im.NewLine()
            im.Separator()
            im.Spacing() 
        else 
            im.TextWrapped('Esteja em um veiculo para usar as funcionalidades do mod.')
            im.NewLine()
        end

        local b_size = (im.GetWindowWidth()-25)/2.0

        if im.Button('Save',im.ImVec2(b_size,30.0)) then 
            save_settings(isCharSittingInAnyCar(PLAYER_PED))
        end

        im.SameLine()
        if im.Button('Quit',im.ImVec2(b_size,30.0)) then 
            im.Process = false
        end
    else
        if #parckeds > 0 then
            for i,veh in ipairs(parckeds) do
                local z_name = (getGxtText(getNameOfZone(veh.x,veh.y,veh.z))):lower()
                im.Bullet()
                if im.BeginMenu(string.format('%i: %i in %s',i,veh.model,z_name),true) then 
                    drawSphere(veh.x,veh.y,veh.z,2.0)
                    if im.MenuItem('Remove',nil,false,true) then 
                        table.remove(parckeds, i)
                        local res, veh = findAllRandomVehiclesInSphere(veh.x,veh.y,veh.z,2.5,false,false)
                        if res and veh then 
                            setCarVisible(veh,false)
                            setCarCollision(veh,false)
                            markCarAsNoLongerNeeded(veh)
                        end
                        save_settings()
                    end   
                    if isCharSittingInAnyCar(PLAYER_PED) then
                        if im.MenuItem('Edit',nil,false,true) then 
                            save_settings(true, i)
                        end  
                    else 
                        if im.MenuItem('Teleport to',nil,false,true) then 
                            setCharCoordinates(PLAYER_PED,veh.x,veh.y,veh.z)
                            setCharHeading(PLAYER_PED,veh.angle)
                            local res, veh = findAllRandomVehiclesInSphere(veh.x,veh.y,veh.z,2.0,true,false) 
                            if res and veh then 
                                if not doesCharExist(getDriverOfCar(veh)) then 
                                    warpCharIntoCar(PLAYER_PED,veh)
                                end
                            end
                        end  
                    end              
                    im.EndMenu()
                end
                im.Separator()
            end
        else 
            im.TextWrapped('Não possui veiculos estacionados na lista.')
        end
    end
    im.End()
end 

function main()

    im.SwitchContext()
    
	local style = im.GetStyle()
	style.WindowRounding = 2.0
	style.WindowTitleAlign = im.ImVec2(0.5, 0.84)
	style.ChildWindowRounding = 2.0
	style.FrameRounding = 2.0
	style.ItemSpacing = im.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.ScrollbarRounding = 0
	style.GrabMinSize = 8.0
	style.GrabRounding = 1.0

    load_settings()

    wait(1000)

    for _,t in ipairs(parckeds) do  
        vehicleGeneratorNoSaveExt(t.model,t.x,t.y,t.z,t.angle,t.color1,t.color2,t.doorLock,t.forceSpawn,t.alarm,t.mindely,t.maxdely,t.plate)
    end

    while true do 
        if isPlayerPlaying(PLAYER_HANDLE) then 
            if isKeyDown(KEY_1) and isKeyDown(KEY_2) then
                im.Process = not im.Process
                if isCharSittingInAnyCar(PLAYER_PED) then 
                    vars.h_veh = getCarCharIsUsing(PLAYER_PED)
                    vars.m_veh = getCarModel(vars.h_veh)
                    local x, y, z = getCarCoordinates(vars.h_veh)
                    vars.col1,vars.col2 = getCarColours(vars.h_veh)
                    vars.pos = {
                        x = x, 
                        y = y, 
                        z = z, 
                        angle = getCarHeading(vars.h_veh),
                    }
                    vars.plate.v = 'null'
                    vars.color1.v = vars.col1
                    vars.color2.v = vars.col2
                    while im.Process do wait( 4 ) end
                end 
                while im.Process do wait( 4 ) end
            end
        end

        wait( 10 )
    end
end