local PlayerHandler = require("DiceSystem_PlayerHandling")
local DiceMenu = require("UI/DiceSystem_PlayerUI")

local ModDataServerCommands = {}



---Run on a client after successfully resetting or changing their data. Will close their dice panel automatically
function ModDataServerCommands.ResetClientDiceData(_)
    DiceMenu.ClosePanel()
    -- Even if it's not updated, I don't care
    PlayerHandler.data = ModData.get(DICE_SYSTEM_MOD_STRING)
    PlayerHandler.data[PlayerHandler.username] = nil

    -- Reset status effects local table
    StatusEffectsUI.UpdateLocalStatusEffectsTable(getPlayer():getOnlineID(), {})
    PlayerHandler.InitModData(true)
end

---Sync status effects for a certain player in a table inside StatusEffectsUI
---@param args table statusEffectsTable=table, userID=number
function ModDataServerCommands.ReceiveUpdatedStatusEffects(args)
    local statusEffectsTable = args.statusEffectsTable
    StatusEffectsUI.UpdateLocalStatusEffectsTable(args.userID, statusEffectsTable)
end

--****************************************************-

local function OnServerCommand(module, command, args)
    if module ~= DICE_SYSTEM_MOD_STRING then return end

    if ModDataServerCommands[command] then
        ModDataServerCommands[command](args)
    end
end

Events.OnServerCommand.Add(OnServerCommand)
