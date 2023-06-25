-- Handle Global Mod Data

local PlayersDiceData = {}




local function OnInitGlobalModData()
	print("Initializing global mod data")
    PlayersDiceData = ModData.getOrCreate(DICE_SYSTEM_MOD_STRING)
end
Events.OnInitGlobalModData.Add(OnInitGlobalModData)

-----------------------------------------
local function OnClientCommand(module, command, playerObj, args)
	if module == DICE_SYSTEM_MOD_STRING then
		if command == "updatePlayerStats" then
			PlayersDiceData[playerObj:getUsername()] = args.data
			ModData.add(DICE_SYSTEM_MOD_STRING, PlayersDiceData)
			--print(playerObj)
			--if not ModData.exists(DICE_SYSTEM_MOD_STRING) then ModData.create(DICE_SYSTEM_MOD_STRING) end
			--ModData.get(DICE_SYSTEM_MOD_STRING)[playerObj:getUsername()] = args.data
			ModData.transmit(DICE_SYSTEM_MOD_STRING)
		end
	end
end

Events.OnClientCommand.Add(OnClientCommand)
