local PlayerHandler = require("DiceSystem_PlayerHandling")
local DiceMenu = require("UI/DiceSystem_PlayerUI")

local ModDataServerCommands = {}


function ModDataServerCommands.ReceiveResetDiceData(args)
    DiceMenu.ClosePanel()
    -- Even if it's not updated, I don't care
    PlayerHandler.data = ModData.get(DICE_SYSTEM_MOD_STRING)
    PlayerHandler.data[PlayerHandler.username] = nil
    PlayerHandler.InitModData(true)
end


function ModDataServerCommands.ReceiveUpdatedStatusEffects(args)
    -- TODO Sync them in a table somewhere instead of relying on the global mod data one
    --print("Receive Updated Status Effects")
    local statusEffectsTable = args.statusEffectsTable
    StatusEffectsUI.UpdateLocalStatusEffectsTable(args.userID, statusEffectsTable)
end


function ModDataServerCommands.SyncStatusEffects(args)
    local statusEffectsTable = args.statusEffectsTable
    local userID = args.userID
    StatusEffectsUI.UpdateLocalStatusEffectsTable(userID, statusEffectsTable)

end





local function OnServerCommand(module, command, args)
    if module ~= DICE_SYSTEM_MOD_STRING then return end

    if ModDataServerCommands[command] then
        ModDataServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
