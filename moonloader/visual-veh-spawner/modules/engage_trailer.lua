local function trailerInVehicle(car)
	return getVehiclePointerHandle(readMemory(getCarPointer(car)+1224,4,false));
end

return function(tex,sets,cmodel,imgui)
	if isCharSittingInAnyCar(PLAYER_PED) and (cmodel.IsCarModel(tex.model) or cmodel.IsTrailerModel(tex.model)) then
		local h_veh = getCarCharIsUsing(PLAYER_PED)
		local mult_trailers = 0
		::chck_trailers::
		local h_trl = trailerInVehicle(h_veh)
		if doesVehicleExist(h_trl) then 
			h_veh = h_trl
			mult_trailers = mult_trailers + 1
			goto chck_trailers
		end
		if mult_trailers > 0 then
			local m_veh = getCarModel(h_veh)
			if (cmodel.IsCarModel(m_veh) or cmodel.IsTrailerModel(m_veh)) then
				if imgui.MenuItem("Engage trailer to trailer",nil,false,true) then 
					local x,y,z = getCharCoordinates(PLAYER_PED)
					local veh_id = cmodel.create(tex.model,x,y,z,getCharHeading(PLAYER_PED))
					attachTrailerToCab(veh_id,h_veh)
					markCarAsNoLongerNeeded(veh_id)
					return true			
				end
			end
		end

		local h_veh = getCarCharIsUsing(PLAYER_PED)
		local m_veh = getCarModel(h_veh)
		if (cmodel.IsCarModel(m_veh) or cmodel.IsTrailerModel(m_veh)) then
			if imgui.MenuItem("Engage trailer to vehicle",nil,false,true) then 
				local x,y,z = getCharCoordinates(PLAYER_PED)
				local veh_id = cmodel.create(tex.model,x,y,z,getCharHeading(PLAYER_PED))
				local h_trl = trailerInVehicle(h_veh)
				if doesVehicleExist(h_trl) then 
					deleteCar(h_trl)
				end
				attachTrailerToCab(veh_id,h_veh)
				markCarAsNoLongerNeeded(veh_id)
				return true			
			end
		end
	end
	return false
end