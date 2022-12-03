local dlstatus = require('moonloader').download_status
local encoding = require 'encoding'

encoding.default = 'CP1251'
u8 = encoding.UTF8

local mod_path = thisScript().path
mod_path = mod_path:reverse()
local ct = 0
for i = 1, #mod_path do 
	ct = i; if mod_path:sub(i,i) == '.' then break end
end
mod_path = mod_path:sub(ct+1,#mod_path)
mod_path = mod_path:reverse()
mod_path = mod_path .. '\\'

return {
path = mod_path,

download_json = function(url,file_name,func)
	downloadUrlToFile(url, file_name, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local f = io.open(file_name, 'r')
			if f then
				local info = decodeJson(f:read('*a'))
				io.close(f)
				if type(info) == 'table' then
					lua_thread.create(func,info)
				end
			end
		end
	end)
end,

load_files = function(dir,ext)
    local files = {}
    local mask = dir .. ext 
    local handle,file = findFirstFile(mask)
    if handle and file then
        while handle and file do 
            table.insert(files,{
                name = file,
                path = string.format('%s%s',dir,file),
            })
            file = findNextFile(handle)
        end
        findClose(handle)
    end
    return files
end,

read_text_file = function(txt)
    local hFile = io.open(txt,"r"); -- open file
    if hFile then
        local text = hFile:read("*a");
        io.close(hFile); -- close file
        return text;
    end
	return nil;
end,

find_in_list = function(item,list)
    for i,v in ipairs(list) do
        if v == item then 
            return i
        end
    end
    return nil
end,

save_table = function(file_name,table_name)
    file_name = mod_path .. '\\' .. file_name
	local hFile = io.open(file_name,"w"); -- open file
	if hFile then
		hFile:write(encodeJson(table_name));
		hFile:close(); -- close file
	end
end,

load_table = function(file_name)
    file_name = mod_path .. '\\' .. file_name
	if doesFileExist(file_name) then 
		local hFile = io.open(file_name,"r"); -- open file
		if hFile then
			local text = hFile:read();
			io.close(hFile); -- close file
			return decodeJson(text);
		end
	end
	return nil;
end,

string_to_number = function(name)
    local out = ""
    for i=1, #name do 
        local e = name:sub(i,i)
        if tonumber(e) then 
            out = out .. e
        end
    end
    return tonumber(out)
end,

convert_code = function(text)
    local chars = {
        [144] = "õ",
        [162] = "i",
        [153] = "a",
        [154] = "ã",
    }
    result = ""
    for i=1, #text do 
        local e = text:sub(i,i)
        local c = string.byte(e)
        if c > 122 then 
            if chars[c] then 
                e = chars[c]
            else 
                e = u8(e)
            end
        end
        result = result .. e
    end
    return result
end,
}