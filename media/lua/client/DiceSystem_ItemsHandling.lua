local function CleanModData(playerIndex, item)
    local PlayerHandler = require("DiceSystem_PlayerHandling")
    PlayerHandler.CleanModData(playerIndex)

    local pl = getPlayer()
    pl:Say("Cleaning data")

    local plInv = pl:getInventory()
    local diceTool = plInv:FindAndReturn("DiceResetTool")
    if diceTool then
        plInv:Remove(diceTool) -- Don't worry about the warning, umbrella must be wrong. This returns a inventoryitem
    end
end


local function OnFillInventoryObjectContextMenu(playerIndex, context, items)
    if items[1] then
        local item = items[1]

        if item.name == 'Dice System - Reset Tool' then
            context:addOption("Reset Dice Data", playerIndex, CleanModData, item)
        end
    end
end


Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)
