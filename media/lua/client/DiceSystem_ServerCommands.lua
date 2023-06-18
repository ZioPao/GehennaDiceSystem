local function OnReceiveGlobalModData(module, packet)
	if module ~= DICE_SYSTEM_MOD_STRING then return end
	if packet then
		ModData.add(module, packet)
	end
end

Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)