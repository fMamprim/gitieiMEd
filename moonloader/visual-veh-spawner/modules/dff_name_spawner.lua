local imgui = require 'imgui'
local cmodel_info = require 'visual-veh-spawner.modules.cmodelinfo'

local im_dff_text_name = imgui.ImBuffer(16)

function get_model_base_by_name(name)
    if #name >= 3 and #name <= 8 then 
        local m = allocateMemory(16)
        callFunction(0x004C5940,2,2,name,m)
        local model = readMemory(m,4,false)
        freeMemory(m)
        if model >= 1 and model <= 99999 then
            if isModelAvailable(model) 
            and (
                isThisModelABoat(model)
                or isThisModelAHeli(model)
                or isThisModelACar(model)
                or isThisModelAPlane(model)
                or cmodel_info.IsBmxModel(model)
                or cmodel_info.IsBikeModel(model)
            ) then 
                return model
            end
        end
    end
    return -1
end

return function(find_image,get_name)
    if imgui.InputText('DFF',im_dff_text_name,16) then
    end
    local model = get_model_base_by_name(im_dff_text_name.v)
    local size = (imgui.GetWindowWidth()-20)
    if model ~= -1 then    
        local _tex = find_image(model)
        if _tex then
            imgui.Separator()
            if _tex then
                imgui.Image(_tex.texture,imgui.ImVec2(size,size/2.0),imgui.ImVec2(0,0),imgui.ImVec2(1,1),imgui.ImVec4(1,1,1,1),imgui.ImVec4(0,0,0,0))
            else 
                imgui.InvisibleButton('bt_space',imgui.ImVec2(size,size/2.0))
            end
        end  
        local _gxt = getNameOfVehicleModel(model)
        if _gxt then
            imgui.Text(_gxt..' '..model)
            imgui.Text(string.format("Name: %s", get_name(model) ))
        end
        imgui.Separator()
        imgui.NewLine()
        if imgui.Button("Options",imgui.ImVec2(size,30.0)) then 
            return model  
        end 
    else 
        imgui.Separator()
        imgui.InvisibleButton('bt_space',imgui.ImVec2(size,size/2.0))
        imgui.NewLine()
        imgui.Text('Input DFF name')
        imgui.Separator()
        imgui.NewLine()
        if imgui.Button("Exit",imgui.ImVec2(size,30.0)) then 
            imgui.Process = false
        end     
    end  
    return -1  
end