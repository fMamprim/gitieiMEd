return {
	name = 'Modelos proximos',

	func = function(m)
		local x,y,z = getCharCoordinates(PLAYER_PED)
		local list = {}
		for i,veh in ipairs(getAllVehicles()) do
		
			if locateCar2d(veh,x,y,250,250,false) then 
				table.insert(list,getCarModel(veh))
			end
		end
		return list
	end,
}