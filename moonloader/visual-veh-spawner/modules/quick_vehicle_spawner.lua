return function(tex,sets,cmodel,imgui)

    if not cmodel.IsTrainModel(tex.model) then 
        if imgui.MenuItem("Quick spawner",nil,false,true) then 
            local x,y,z = getCharCoordinates(PLAYER_PED)
            local veh = cmodel.create(tex.model,x,y,z,getCharHeading(PLAYER_PED))
            markModelAsNoLongerNeeded(tex.model)

            local h_veh = getCarCharIsUsing(PLAYER_PED)
            if doesVehicleExist(h_veh) then 
                clearCharTasksImmediately(PLAYER_PED)
                deleteCar(h_veh)
            end
            warpCharIntoCar(PLAYER_PED,veh)
            markCarAsNoLongerNeeded(veh)
            
            return true
        end
    end
    return false
end