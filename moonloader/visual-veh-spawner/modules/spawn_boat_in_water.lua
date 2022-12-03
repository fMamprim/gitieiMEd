local boats_coords = {
    {x=2938.41,y=-2061.60,z=0.02,a=272.27},
    {x=264.51,y=-1935.66,z=-0.50,a=359.67},
    {x=-1979.17,y=1469.16,z=-0.42,a=83.93},
    {x=-2320.44,y=2307.69,z=-0.45,a=179.50},
    {x=-1195.82,y=2790.33,z=40.06,a=220.50},
    {x=2363.05,y=514.24,z=-0.66,a=96.11},
    {x=1949.87,y=-183.67,z=0.18,a=274.24},
}

return function(tex,sets,cmodel,imgui)
	local sucess = false
	if cmodel.IsBoatModel(tex.model) or cmodel.IsFakePlaneModel(tex.model) then
		if imgui.BeginMenu("Call the vehicle in the water",true) then 
			for i,coords in ipairs(boats_coords) do
				local zname = getGxtText(getNameOfZone(coords.x,coords.y,coords.z))
				if imgui.MenuItem(string.format("%i %s",i,zname),nil,false,true) then

					local veh_id = cmodel.create(tex.model,coords.x,coords.y,coords.z+3.0,coords.a)
					local veh_h = getCarCharIsUsing(PLAYER_PED)
					if doesVehicleExist(veh_h) then 
						clearCharTasksImmediately(PLAYER_PED)
						deleteCar(veh_h)
					end
					warpCharIntoCar(PLAYER_PED,veh_id) 
					markCarAsNoLongerNeeded(veh_id)  
					markModelAsNoLongerNeeded(tex.model)
					sucess = true                        
				end                         
			end
			imgui.EndMenu()
		end
	end
	return sucess
end

