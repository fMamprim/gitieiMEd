return function(tex, sets, cmodel, imgui)
	local sucess = false
	if cmodel.IsPlaneModel(tex.model) or cmodel.IsHeliModel(tex.model) then
		if imgui.MenuItem("Call vehicle flying",nil,false,true) then

			local veh_h = getCarCharIsUsing(PLAYER_PED)
			local x,y,z = getCharCoordinates(PLAYER_PED)
			local veh_id = cmodel.create(tex.model,x,y,z,getCharHeading(PLAYER_PED))

			if doesVehicleExist(veh_h) then 
				clearCharTasksImmediately(PLAYER_PED)
				deleteCar(veh_h)
			end
			warpCharIntoCar(PLAYER_PED,veh_id)
			setCarCoordinates(veh_id,x,y,z+sets.spawn_flying_height)
			setCarForwardSpeed(veh_id,25.0)
			markCarAsNoLongerNeeded(veh_id)  
			markModelAsNoLongerNeeded(tex.model)

			sucess = true                        
		end 
	end
	return sucess
end