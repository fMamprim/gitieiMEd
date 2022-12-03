local ffi = require 'ffi'

local cmodel_info = {
	IsBoatModel = 0x4C5A70,
	IsCarModel = 0x4C5AA0,
	IsTrainModel = 0x4C5AD0,
	IsPlaneModel = 0x4C5B30,
	IsBikeModel = 0x4C5B60,
	IsHeliModel = 0x4C5B00,
	IsFakePlaneModel = 0x4C5B90,
	IsMonsterTruckModel = 0x4C5BC0,
	IsBmxModel = 0x4C5C20,
	IsTrailerModel = 0x4C5C50,
	IsQuadBikeModel = 0x4C5BF0,
}

local types = {}
for k,v in pairs(cmodel_info) do
	cmodel_info[k] = ffi.cast('bool (__cdecl *)(int)', v)
	table.insert(types,k)
end
cmodel_info.types = types

cmodel_info.data = ffi.cast("uintptr_t*", 0x00A9B0C8)
function cmodel_info.game_name(model)
    return ffi.string(ffi.cast("char*",cmodel_info.data[model]+0x32))
end

function cmodel_info.create(model,x,y,z,a)
	if not hasModelLoaded(model) then 
		requestModel(model)
		loadAllModelsNow()
	end 
	local v = createCar(model,x,y,z)
	setCarHeading(v,a)
	markModelAsNoLongerNeeded(model)
	return v
end

return cmodel_info