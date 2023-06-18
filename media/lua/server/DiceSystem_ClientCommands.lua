local function OnInitGlobalModData()
	ModData.getOrCreate(DICE_SYSTEM_MOD_STRING)
end
Events.OnInitGlobalModData.Add(OnInitGlobalModData)
