-- TODO Some stuff is shared between PlayerUI and HoverUI.


--* Helper functions

---Get a string for ISRichTextPanel containing a colored status effect string
---@param status string
---@return string
local function GetColoredStatusEffect(status)
    -- Pick from table colors
    local statusColors = DiceSystem_Common.statusEffectsColors[status]
    local colorString = string.format(" <RGB:%s,%s,%s> ", statusColors.r, statusColors.g, statusColors.b)
    return colorString .. status
end





local DiceSystem_CommonUI = {}



local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
DiceSystem_CommonUI.FONT_SCALE = FONT_HGT_SMALL / 16

if DiceSystem_CommonUI.FONT_SCALE < 1 then
    DiceSystem_CommonUI.FONT_SCALE = 1
end




---Create a name panel and returns the correct offset
---@param parent ISPanel
---@param playerName String
---@param currentOffset number
function DiceSystem_CommonUI.AddNameLabel(parent, playerName, currentOffset)
    parent.nameLabel = ISLabel:new((parent.width - getTextManager():MeasureStringX(UIFont.Large, playerName)) / 2, currentOffset, 25, playerName, 1, 1, 1, 1, UIFont.Large, true)
    parent.nameLabel:initialise()
    parent.nameLabel:instantiate()
    parent:addChild(parent.nameLabel)
end

-- Status Effects Panel
function DiceSystem_CommonUI.AddStatusEffectsPanel(parent, height, currentOffset)
    parent.labelStatusEffectsList = ISRichTextPanel:new(20, currentOffset, parent.width - 20, height)
    parent.labelStatusEffectsList:initialise()
    parent:addChild(parent.labelStatusEffectsList)

    parent.labelStatusEffectsList.marginTop = 0
    parent.labelStatusEffectsList.marginLeft = parent.width/6
    parent.labelStatusEffectsList.marginRight = parent.width/6
    parent.labelStatusEffectsList.autosetheight = false
    parent.labelStatusEffectsList.background = false
    parent.labelStatusEffectsList.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    parent.labelStatusEffectsList.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    parent.labelStatusEffectsList:paginate()
end




---Handles status effects in update
---@param parent any
---@param playerHandler any
function DiceSystem_CommonUI.UpdateStatusEffectsText(parent, playerHandler)
    local statusEffectsText = ""
    local activeStatusEffects = playerHandler.GetActiveStatusEffectsByUsername(playerHandler.username)

    for i = 1, #activeStatusEffects do
        local v = activeStatusEffects[i]
        local singleStatus = GetColoredStatusEffect(v)

        if statusEffectsText == "" then
            statusEffectsText = " <CENTRE> " .. singleStatus
        else
            statusEffectsText = statusEffectsText .. " <SPACE> - <SPACE> " .. singleStatus
        end
    end
    parent.labelStatusEffectsList:setText(statusEffectsText)
    parent.labelStatusEffectsList.textDirty = true

end


-- Show Armor Class
-- function DiceSystem_CommonUI.Add
-- end


function DiceSystem_CommonUI.AddPanel(parent, name, width, height, offsetX, offsetY)
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end

    parent[name] = ISRichTextPanel:new(offsetX, offsetY, width, height)
    parent[name]:initialise()
    parent:addChild(parent[name])
    parent[name].autosetheight = false
    parent[name].background = false
    parent[name]:paginate()
end



return DiceSystem_CommonUI
