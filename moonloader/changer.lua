local activation_cheat = "CHANGE"
local reload_cheat 	   = "CRLD"

script_author("Israel")
script_name("In-Game Commands Changer")
script_description("Changes commands (cheats, game keys and virtual keys) of scripts (cs, cm and scm), in game")
script_url("http://brmodstudio.forumeiros.com/t6163p50-atualizado-cheat-key-changer-alterar-comandos-de-cleo-scripts-in-game")

local gk  = require "game/keys"
local vk  = require "vkeys"

local onfoot = gk.player
local gk_names = {
	"Left Right", "Forward Backward",
	"Special CTRL Left Right", "Special CTRL UP Down",
	"Action secondary fire",
	"Previous weapon zoom in", "Aim weapon", "Next weapon zoom out",
	"Group CTRL forward", "Group CTRL back",
	"Conversation NO", "Conversation YES",
	"Not exist",
	"Change camera",
	"Jump", "Enter vehicle", "Sprint", "Fire", "Crouch",
	"Look behind"
}

local scripts_names, scripts_paths = {}, {}

function main()
	while true do
		findScripts(getGameDirectory() .. "\\cleo")
		findScripts(getGameDirectory() .. "\\modloader")

		setGxtEntry("IJ_TTL", 	"Commands Changer")			--> Panel title
		setGxtEntry("IJ_KH", 	"~y~Alterar Key")			--> Column header
		setGxtEntry("IJ_CH", 	"~y~Alterar Cheat")			--> Column header
		setGxtEntry("IJ_CK", 	"Deseja alterar")			--> Key or Cheat
		setGxtEntry("IJ_CKK", 	"Key")						--> Key
		setGxtEntry("IJ_CKC", 	"Cheat")					--> Cheat
		setGxtEntry("IJ_HK", 	"Erro") 					--> No keys error header
		setGxtEntry("IJ_CS", 	"Confirmar")				--> Key change confirmation
		setGxtEntry("IJ_CN", 	"Cancelar")					--> Key change cancel
		setGxtEntry("IJ_P1", 	"Pad 1")					--> Pad Selection (1)
		setGxtEntry("IJ_P2", 	"Pad 2")					--> Pad Selection (2)
		setGxtEntry("IJ_MSG", 	"Pressione a nova Tecla !") --> Key change help msg
		setGxtEntry("IJ_MSG2", 	"Use ~y~ENTER~s~ para confirmar.~n~Delete tudo para cancelar.") --> Cheat change help msg
		
		local sc_pages = math.floor(#scripts_names / 10) + ((#scripts_names % 10) ~= 0 and 1 or 0)

		-- Add scripts panel headers FXT Keys
		for i = 1, sc_pages do
			setGxtEntry("IJ_H" .. i, "Scripts " .. i .. '/' .. sc_pages)
		end

		-- Add scripts FXT Keys
		for i, v in ipairs(scripts_names) do
			setGxtEntry("IJ_S" .. i, v)
		end
		
		--/--> MAIN LOOP <--\--
		repeat
			wait(0)

			if testCheat(activation_cheat) then
				if #scripts_names == 0 then
					printStringNow("~r~Nenhum script encontrado !", 2000)
				else				
					setPlayerControl(PLAYER_HANDLE, false)
					printHelpForever("WARDH3") --> Help text

					local current_page = 1
					menu = createMenu("IJ_TTL", 20.0, 115.0, 250.0, 1, true, true, 1)

					-- Script selection panel
					while not isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do
						wait(0)

						local sc, lvl = {}, 10

						if current_page == sc_pages and #scripts_names % 10 ~= 0 then
							lvl = #scripts_names % 10
						end
						for i = 1, 10 do
							sc[i] = (i <= lvl) and "IJ_S" .. 10 * (current_page - 1) + i or "DUMMY"
						end

						setMenuColumn(menu, 0, "IJ_H" .. current_page, sc[1], sc[2], sc[3], sc[4], sc[5], sc[6], sc[7], sc[8], sc[9], sc[10])
						setActiveMenuItem(menu, 0)

						while not isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do
							wait(0)

							if wasKeyPressed(vk.VK_LEFT) then
								if current_page > 1 then current_page = current_page - 1 else current_page = sc_pages end
								break
							elseif wasKeyPressed(vk.VK_RIGHT) then
								if current_page < sc_pages then current_page = current_page + 1 else current_page = 1 end
								break
							end

							if isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) then
								while isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) do wait(0) end
								decompileScript(10 * (current_page - 1) + (getMenuItemSelected(menu) + 1))
								break
							end

							printStringNow("Use ~<~ e ~>~ para navegar entre as paginas.", 300)
						end
					end
					
					while isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do wait(0) end
					
					setPlayerControl(PLAYER_HANDLE, true)
					clearHelp()
					deleteMenu(menu)
				end
			end
		until testCheat(reload_cheat)

		scripts_names, scripts_paths = {}, {} --> Clear scripts lists
		printStringNow("~y~In-Game Key Changer~s~ foi recarregado !", 2000) --> Reload msg
	end
end

function findScripts(path)
	local loaded, lib = loadDynamicLibrary("kernel32.dll")
	local result, proc = getDynamicLibraryProcedure("GetFileAttributesA", lib)	
	
	local hFind, filename = findFirstFile(path .. "\\*")
	
	while filename do
		if filename ~= "." and filename ~= ".." then
			local fullpath = path .. "\\" .. filename
			local attr = callFunction(proc, 1, 1, fullpath)

			if attr == 0x10 then --> Directory
				findScripts(fullpath)
			elseif attr == 0x20 then --> File
				if filename:sub(-3) == ".cs" or filename:sub(-3) == ".cm" or filename:sub(-4) == ".scm" then --> Filter
					if filename:len() > 29 then
						filename = filename:sub(1, 30) .. " ..."
					end
					scripts_names[#scripts_names + 1] = filename
					scripts_paths[#scripts_paths + 1] = fullpath
				end
			end
		end
		
		filename = findNextFile(hFind)
	end
end

function decompileScript(index)
	currentScriptPath = scripts_paths[index]

	local input = io.open(currentScriptPath, "rb")
	sc_struct = input:read("*all")
	sc_struct = sc_struct:tohex()

	sc_end = string.find(sc_struct, "56415200F1020000") --> SB extra info start point
	if sc_end == nil then
		sc_end = sc_struct:len()
	end

	store_commands_pos()	
	input:close()

	while not isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do
		setMenuColumn(menu, 0, "IJ_CK", "IJ_CKK", "IJ_CKC")
		setActiveMenuItem(menu, 0)
		
		while not isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do
			wait(0)
			
			if isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) then
				if getMenuItemSelected(menu) == 0 then
					k_pages = math.floor(#keys_pos / 10) + ((#keys_pos % 10) ~= 0 and 1 or 0)
					
					for i = 1, k_pages do
						setGxtEntry("IJ_HK" .. i, "Keys " .. i .. '/' .. k_pages)
					end
					keysMenu()
					break
				else
					c_pages = math.floor(#cheats_pos / 10) + ((#cheats_pos % 10) ~= 0 and 1 or 0)
					
					for i = 1, c_pages do
						setGxtEntry("IJ_HC" .. i, "Cheats " .. i .. '/' .. c_pages)
					end
					cheatsMenu()
					break
				end
			end
			
			printStringNow("Selecione o tipo de comando que deseja alterar.", 150)
		end
	end
	
	keys_pos = {} --> Clear
	while isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do wait(0) end
end

function store_commands_pos()
	cheats_pos = {}
	keys_pos = {}
	
	for i = 1, sc_end, 2 do
		-- Virtual Keys
		if sc_struct:sub(i, i + 5) == "B00A04" or	--> 0AB0: IS_KEY_PRESSED
		sc_struct:sub(i, i + 5) == "B08A04" then	--> 8AB0: NOT IS_KEY_PRESSED
			keys_pos[#keys_pos + 1] = i + 6

			local vkey_id = string.todec(sc_struct:sub(i + 6, i + 7)) * 1
			setGxtEntry("IJ_B" .. #keys_pos, vk.id_to_name(vkey_id))
		end
	end

	gk_Spos = #keys_pos
	
	for i = 1, sc_end, 2 do
		-- Game Keys
		if (sc_struct:sub(i, i + 5) == "E10004" or	--> 00E1: IS_BUTTON_PRESSED
		sc_struct:sub(i, i + 5) == "E18004") and	--> 80E1: NOT IS_BUTTON_PRESSED
		sc_struct:sub(i + 8, i + 9) == "04" then
			keys_pos[#keys_pos + 1] = i + 10

			local gkey = string.todec(sc_struct:sub(i + 10, i + 11)) + 1
			setGxtEntry("IJ_B" .. #keys_pos, gk_names[gkey])
		end
		
		-- Cheats
		if sc_struct:sub(i, i + 5) == "DC0A0E" or	--> 0ADC: TEST_CHEAT
		sc_struct:sub(i, i + 5) == "DC8A0E" then	--> 8ADC: NOT TEST_CHEAT
			cheats_pos[#cheats_pos + 1] = i + 8
			
			local cheat_len = string.todec(sc_struct:sub(i + 6, i + 7))
			str_cheat = string.upper(string.fromhex(sc_struct:sub(i + 8, i + 7 + (cheat_len * 2))))
			
			setGxtEntry("IJ_C" .. #cheats_pos, str_cheat)
		end
	end
end

function keysMenu()
	local keys, current_page = {}, 1

	while not isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do
		wait(0)

		local lvl = 10
		if current_page == k_pages and #keys_pos % 10 ~= 0 then
			lvl = #keys_pos % 10
		end
		for i = 1, 10 do
			keys[i] = (i <= lvl) and "IJ_B" .. 10 * (current_page - 1) + i or "DUMMY"
		end

		if #keys_pos ~= 0 then
			setMenuColumn(menu, 0, "IJ_HK" .. current_page, keys[1], keys[2], keys[3], keys[4], keys[5], keys[6], keys[7], keys[8], keys[9], keys[10])
			setActiveMenuItem(menu, 0)
		end
		
		while isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) do wait(0) end

		while not isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do
			wait(0)

			if wasKeyPressed(vk.VK_LEFT) then
				if current_page > 1 then current_page = current_page - 1 else current_page = k_pages end
				break
			elseif wasKeyPressed(vk.VK_RIGHT) then
				if current_page < k_pages then current_page = current_page + 1 else current_page = 1 end
				break
			end

			if isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) then
				if #keys_pos ~= 0 then		
					changeKey(current_page, (getMenuItemSelected(menu) + (current_page - 1) * 10 >= gk_Spos) and 1 or 2)

					while isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do wait(0) end
					break
				end
			end

			if #keys_pos == 0 then
				setGxtEntry("IJ_F", "~r~Nenhuma Tecla")
				setMenuColumn(menu, 0, "IJ_HK", "IJ_F")
				
				while not isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do
					wait(0)
					printStringNow("~r~Undefined", 300)
				end
			else
				local msg = "Use ~<~ e ~>~ para navegar entre as paginas.~n~KeyType: "
				
				if getMenuItemSelected(menu) + (current_page - 1) * 10 >= gk_Spos then
					local pos = keys_pos[(getMenuItemSelected(menu) + (current_page - 1) * 10) + 1]	- 3	
					printStringNow(msg .. "~g~Game Key~n~~s~Pad: ~y~" .. sc_struct:sub(pos, pos) + 1, 300)
				else			
					printStringNow(msg .. "~b~Virtual Key", 300)
				end
			end
		end
	end

	while isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do wait(0) end
end

function changeKey(page, key_type)
	local selected = getMenuItemSelected(menu)

	while isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) do wait(0) end
	
	setMenuColumn(menu, 0, "IJ_KH", "IJ_B" .. 10 * (page - 1) + (selected + 1))
	setActiveMenuItem(menu, 0)

	printHelpForever("IJ_MSG") --> Help message

	while true do
		wait(0)

		for i = 0, (key_type == 1) and 19 or 0xFF do
			if key_type == 1 then
				if isButtonPressed(PLAYER_HANDLE, i) then
					while isButtonPressed(PLAYER_HANDLE, i) do wait(0) end

					inline(page, key_type, selected, i)
					return
				end
			else
				if vk.id_to_name(i) ~= nil and wasKeyPressed(i) then
					while wasKeyPressed(i) do wait(0) end

					inline(page, key_type, selected, i)
					return
				end
			end
		end
		
		printStringNow("~y~Aguardando nova tecla...", 150)
	end
end

-- Confirmation of change and script write
function inline(page, key_type, selected, i)
	local new = (key_type == 1) and gk_names[i + 1] or vk.id_to_name(i)
	local pad
	
	printHelpForever("WARDH3") --> Help

	setGxtEntry("IJ_KHK", "Alterar para ~g~\"" .. new .. "\"~s~ ?")

	if key_type == 1 then
		setMenuColumn(menu, 0, "IJ_KHK", "IJ_P1", "IJ_P2", "IJ_CN")
	else
		setMenuColumn(menu, 0, "IJ_KHK", "IJ_CS", "IJ_CN")
	end
	
	while isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) or isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) do wait(0) end

	while true do
		wait(0)

		if isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) then
			return
		elseif isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) then
			pad = "0" .. getMenuItemSelected(menu)
			if getMenuItemSelected(menu) == 0 then
				break
			elseif getMenuItemSelected(menu) == 1 then
				if key_type == 1 then
					break
				end
				return
			else return
			end
		end
		
		if key_type == 1 then
			printStringNow("~y~Selecione um pad para confirmar a alteracao.", 150)
		else
			printStringNow("~y~Confirme a alteracao.", 150)
		end
	end

	local new_value = string.format("%02X", i)
	local pos = keys_pos[(selected + (page - 1) * 10) + 1]
	
	sc_struct = sc_struct:sub(1, pos - 1) .. new_value .. sc_struct:sub(pos + 2)
	if key_type == 1 then
		sc_struct = sc_struct:sub(1, pos - 5) .. pad .. sc_struct:sub(pos - 2)
	end

	local output = io.open(currentScriptPath, "wb")
	output:write(sc_struct:fromhex())
	output:close()

	setGxtEntry("IJ_B" .. (selected + (page - 1) * 10) + 1, (key_type == 1) and gk_names[i + 1] or vk.id_to_name(i))
end

function cheatsMenu()
	local cheats, current_page = {}, 1

	while not isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do
		wait(0)

		local lvl = 10
		if current_page == c_pages and #cheats_pos % 10 ~= 0 then
			lvl = #cheats_pos % 10
		end
		for i = 1, 10 do
			cheats[i] = (i <= lvl) and "IJ_C" .. 10 * (current_page - 1) + i or "DUMMY"
		end

		if #cheats_pos ~= 0 then
			setMenuColumn(menu, 0, "IJ_HC" .. current_page, cheats[1], cheats[2], cheats[3], cheats[4], cheats[5], cheats[6], cheats[7], cheats[8], cheats[9], cheats[10])
			setActiveMenuItem(menu, 0)
		end
		
		while isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) do wait(0) end

		while not isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do
			wait(0)

			if wasKeyPressed(vk.VK_LEFT) then
				if current_page > 1 then current_page = current_page - 1 else current_page = c_pages end
				break
			elseif wasKeyPressed(vk.VK_RIGHT) then
				if current_page < c_pages then current_page = current_page + 1 else current_page = 1 end
				break
			end

			if isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) then
				if #cheats_pos ~= 0 then		
					changeCheat(current_page)

					while isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do wait(0) end
					break
				end
			end

			if #cheats_pos == 0 then
				setGxtEntry("IJ_F2", "~r~Nenhum Cheat")
				setMenuColumn(menu, 0, "IJ_HK", "IJ_F2")
				
				while not isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do
					wait(0)
					printStringNow("~r~Undefined", 300)
				end
			else
				printStringNow("Use ~<~ e ~>~ para navegar entre as paginas.", 300)			
			end
		end
	end

	while isButtonPressed(PLAYER_HANDLE, onfoot.ENTERVEHICLE) do wait(0) end	
end

function changeCheat(page)
	local selected = getMenuItemSelected(menu)

	while isButtonPressed(PLAYER_HANDLE, onfoot.SPRINT) do wait(0) end
	
	setMenuColumn(menu, 0, "IJ_CH", "IJ_C" .. 10 * (page - 1) + (selected + 1))
	setActiveMenuItem(menu, 0)

	printHelpForever("IJ_MSG2") --> Help message

	local new_cheat, fake_cheat = "", ""
	while not wasKeyPressed(vk.VK_RETURN) do
		wait(0)

		-- Alpha (0~9)
		for i = 0x30, 0x39 do
			if wasKeyPressed(i) and new_cheat:len() < 29 then
				fake_cheat = new_cheat .. string.char(i)
				new_cheat = fake_cheat
			end
		end
		-- Numpad (0~9)
		for i = 0x60, 0x69 do
			if wasKeyPressed(i) and new_cheat:len() < 29 then
				fake_cheat = new_cheat .. string.char(i - 0x30)
				new_cheat = fake_cheat
			end
		end
		-- A~Z
		for i = 0x41, 0x5A do
			if wasKeyPressed(i) and new_cheat:len() < 29 then
				fake_cheat = new_cheat .. string.char(i)
				new_cheat = fake_cheat
			end
		end
		-- Space
		if wasKeyPressed(vk.VK_SPACE) and new_cheat:len() < 29 then
			fake_cheat = new_cheat .. string.char(0xFF)
			new_cheat = new_cheat .. string.char(0x20)
		end
		-- Backspace
		if wasKeyPressed(vk.VK_BACK) then
			if new_cheat:len() > 0 then
				fake_cheat = new_cheat:sub(1, new_cheat:len() - 1)
				new_cheat = fake_cheat
			else
				break
			end
		end
		
		printStringNow("~y~Novo Cheat:~s~ " .. fake_cheat .. "~n~~y~Length: ~s~" .. new_cheat:len() .. "/29", 150)
	end
	
	if wasKeyPressed(vk.VK_RETURN) and new_cheat:len() > 0 then
		local new_value = new_cheat:tohex()
		local pos = cheats_pos[(selected + (page - 1) * 10) + 1]
				
		local cheat_len = string.todec(sc_struct:sub(pos - 2, pos - 1))
		
		sc_struct = sc_struct:sub(1, pos + 1) .. new_value .. sc_struct:sub(pos + (cheat_len * 2))
		sc_struct = sc_struct:sub(1, pos - 3) .. string.format("%02X", new_cheat:len()) .. sc_struct:sub(pos + 2)
		
		local value = new_cheat:len() - cheat_len
		
		for i = 1, sc_end, 2 do
			if sc_struct:sub(i, i + 5) == "4D0001" 	--> 004D: GOTO_IF_FALSE
			or sc_struct:sub(i, i + 5) == "020001"  --> 0002: GOTO
			or sc_struct:sub(i, i + 5) == "500001"  --> 0050: GOSUB
			or sc_struct:sub(i, i + 5) == "A00A01"  --> 0AA0: ELSE_GOSUB
			or sc_struct:sub(i, i + 5) == "710801"  --> 0871: SWITCH_START
			or sc_struct:sub(i, i + 5) == "720801"  --> 0872: SWITCH_CONTINUED
			or sc_struct:sub(i, i + 5) == "B10A01"  --> 0AB1: CLEO_CALL
			or sc_struct:sub(i, i + 5) == "070701"  --> 0707: SKIP_CUTSCENE_START_INTERNAL
			or sc_struct:sub(i, i + 5) == "C60A01"  --> 0AC6: GET_LABEL_POINTER
			or sc_struct:sub(i, i + 5) == "4F0001"  --> 004F: START_NEW_SCRIPT
			or sc_struct:sub(i, i + 5) == "D70001" then --> 00D7: LAUNCH_MISSION
				local prev = sc_struct:sub(i + 12, i + 13) .. sc_struct:sub(i + 10, i + 11) .. sc_struct:sub(i + 8, i + 9) .. sc_struct:sub(i + 6, i + 7)
				prev = string.format("%08X", tonumber("0x" .. prev) - value)
				
				local label_point = string.format("%i", 0xFFFFFFFF - tonumber("0x" .. prev))
				prev = prev:sub(7, 8) .. prev:sub(5, 6) .. prev:sub(3, 4) .. prev:sub(1, 2)
				
				if tonumber(label_point) > math.floor(pos / 2) then
					sc_struct = sc_struct:sub(1, i + 5) .. prev .. sc_struct:sub(i + 14)
				end
			end
		end
		
		local output = io.open(currentScriptPath, "wb")
		output:write(sc_struct:fromhex())
		output:close()

		setGxtEntry("IJ_C" .. (selected + (page - 1) * 10) + 1, new_cheat)
	end

	store_commands_pos()
	
	printHelpForever("WARDH3") --> Help text
	while wasKeyPressed(vk.VK_RETURN) do wait(0) end
end

-- String funcs
function string.todec(str)
	return (str:gsub("..", function (cc)
		return tonumber(cc, 16)
	end))
end
function string.tohex(str)
	return (str:gsub(".", function (c)
		return string.format("%02X", string.byte(c))
	end))
end
function string.fromhex(str)
	return (str:gsub("..", function (cc)
		return string.char(tonumber(cc, 16))
	end))
end