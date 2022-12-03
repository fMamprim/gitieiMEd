return function(tex, sets, cmodel, imgui)
	local model = tex.model
	if cmodel.IsTrainModel(model) then
		if imgui.MenuItem("Create train mission (Test)",nil,false,true) then
			printHelpString('Indisponible~n~Model:'..model)
			return true				
		end
	end
	return false
end

