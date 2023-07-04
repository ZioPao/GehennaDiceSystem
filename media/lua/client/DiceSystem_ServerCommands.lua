local PlayerHandler = require("DiceSystem_PlayerHandling")
local DiceMenu = require("DiceSystem_PlayerUI")

local function OnServerCommand(module, command, args)
    if module ~= DICE_SYSTEM_MOD_STRING then return end

    if command == "receiveResetDiceData" then
        DiceMenu.ClosePanel()
        PlayerHandler.InitModData(true)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
