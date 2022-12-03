if not doesFileExist(getWorkingDirectory() .. '\\parked-car-maker.lua') then 
	return nil
end

local imgui = require 'imgui'
local add = import 'parked-car-maker'

local foced_spawner = imgui.ImBool(true)
local random_colors = imgui.ImBool(false)

function new_parked(model,rnd_colors,force)
	local x, y, z = getCharCoordinates(PLAYER_PED)
	local data = {
		model = model,
		x = x,
		y = y,
		z = z,
		angle = getCharHeading(PLAYER_PED),
		color1 = -1,
		color2 = -1,
		doorLock = 0,
		alarm = 0,
		mindely = 0,
		maxdely = 7000,
		forceSpawn = 1,
		plate = 'null'
	}
	local t = data
	if not hasModelLoaded(t.model) then 
		requestModel(t.model)
		loadAllModelsNow()
	end
	local v = createCar(t.model,t.x,t.y,t.z)
	if not rnd_colors then 
		data.color1, data.color2 = getCarColours(v)
	end
	if force then 
		data.force = 1
	end
	setCarHeading(v,t.angle)
	warpCharIntoCar(PLAYER_PED,v)
	add.create_parked(true,false,data)
end

return function(tex,settings,model_info)
	local sucess = false
	if imgui.BeginMenu('Create parcked vehicle',(not isCharSittingInAnyCar(PLAYER_PED))) then
		local model = tex.model
		imgui.Checkbox('Force spawner',foced_spawner)
		imgui.Checkbox('Random colors',random_colors)
		imgui.NewLine()
		imgui.Separator()
		if imgui.MenuItem("Confirm",nil,false,true) then
			new_parked(model,random_colors.v,foced_spawner.v)
			sucess = true
		end				
		imgui.EndMenu()
	end
	return sucess
end