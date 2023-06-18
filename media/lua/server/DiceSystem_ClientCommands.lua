-- Handle Global Mod Data
local function OnInitGlobalModData()
    ModData.getOrCreate(DICE_SYSTEM_MOD_STRING)
end
Events.OnInitGlobalModData.Add(OnInitGlobalModData)

-----------------------------------------
local function OnClientCommand(module, command, playerObj, args)
	if module == DICE_SYSTEM_MOD_STRING then
		if command == "updatePlayerStats" then
			--print(playerObj)
			--if not ModData.exists(DICE_SYSTEM_MOD_STRING) then ModData.create(DICE_SYSTEM_MOD_STRING) end
			ModData.get(DICE_SYSTEM_MOD_STRING)[playerObj:getUsername()] = args.data
			ModData.transmit(DICE_SYSTEM_MOD_STRING)
		end
	end
end

Events.OnClientCommand.Add(OnClientCommand)
