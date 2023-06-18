DiceSystem_GlobalModData = {}


local function OnInitGlobalModData()
	DiceSystem_GlobalModData = ModData.getOrCreate(DICE_SYSTEM_MOD_STRING)
end
Events.OnInitGlobalModData.Add(OnInitGlobalModData)
