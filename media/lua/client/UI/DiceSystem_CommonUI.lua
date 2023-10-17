-- TODO Some stuff is shared between PlayerUI and HoverUI.

local DiceSystem_CommonUI = {}

---Create a name panel and returns the correct offset
---@param parent ISPanel
---@param playerName String
---@param currentOffset number
---@return number
function DiceSystem_CommonUI.AddNameLabel(parent, playerName, currentOffset)
    parent.nameLabel = ISLabel:new((parent.width - getTextManager():MeasureStringX(UIFont.Large, playerName)) / 2, currentOffset, 25, playerName, 1, 1, 1, 1, UIFont.Large, true)
    parent.nameLabel:initialise()
    parent.nameLabel:instantiate()
    parent:addChild(parent.nameLabel)
    local yOffset = currentOffset + 25 + 10

    return yOffset
end

-- Status Effects 


-- Show Health


-- Show Armor Class

return DiceSystem_CommonUI
