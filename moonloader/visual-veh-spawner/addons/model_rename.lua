-- Model Rename
-- Autor: Um_Geek
-- Agradecimentos a Israel.

local imgui = require 'imgui'
local encoding = require 'encoding'
local cmodel_info = require 'visual-veh-spawner.modules.cmodelinfo'

local veh_names = {}
local input_veh_name = imgui.ImBuffer(24)
local json = string.format("%s\\moonloader\\visual-veh-spawner\\addons\\veh_names.json",getGameDirectory())

encoding.default = 'CP1251'
u8 = encoding.UTF8

local hFile = io.open(json,"r") -- open file
if hFile then
	veh_names = decodeJson(hFile:read())
	io.close(hFile) -- close file
end

function apply_new_names()
	for k,v in pairs(veh_names) do
		setGxtEntry(k,v.new)
	end
end

function save_sets()
	local hFile = io.open(json,"w"); -- open file
	if hFile then
		hFile:write(encodeJson(veh_names))
		hFile:close(); -- close file
	end
end

local function convert_code(text)
	local s_out = ''
	for i = 1, #text do 
		local s = text:sub(i,i)
		s_out = s_out .. u8(s)
	end
	return s_out
end

apply_new_names()

return function(tex,settings,model_info)
    local gxt = cmodel_info.game_name(tex.model)
	if imgui.BeginMenu('Rename model',true) then 
		if not (veh_names[gxt]) then
			imgui.InputText('Input name',input_veh_name)
			imgui.Spacing()
			imgui.Separator()
			if imgui.MenuItem('Apply name',nil,false,true) then 	
				veh_names[gxt] = {}
				if not (veh_names[gxt].old) then 
					veh_names[gxt].old = getGxtText(gxt)
					sucess = true
				end
				veh_names[gxt].new = convert_code(input_veh_name.v)
				apply_new_names()
				save_sets()
			end
		else 
			local k = veh_names[gxt]
			imgui.Text('Old name: '..k.old)
			imgui.Spacing()
			imgui.Separator()
			if imgui.MenuItem('Reset name',nil,false,true) then 
				setGxtEntry(gxt,k.old)
				veh_names[gxt] = nil 
				save_sets()
				sucess = true
			end			
		end
		imgui.EndMenu()
	end
	return false
end