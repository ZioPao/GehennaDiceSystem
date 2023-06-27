local function OnServerCommand(module, command, args)
    if module ~= DICE_SYSTEM_MOD_STRING then return end

    if command == "receiveResetDiceData" then
        local PlayerHandler = require("DiceSystem_PlayerHandling")
        PlayerHandler.InitModData(true)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
