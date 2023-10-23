-- TODO Some stuff is shared between PlayerUI and HoverUI.
local PlayerHandler = require("DiceSystem_PlayerHandling")


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


---Create a text panel
---@param parent ISPanel
---@param text String
---@param currentOffset number
function DiceSystem_CommonUI.AddCenteredTextLabel(parent, name, text, currentOffset)
    parent[name] = ISLabel:new((parent.width - getTextManager():MeasureStringX(UIFont.Large, text)) / 2, currentOffset,
        25, text, 1, 1, 1, 1, UIFont.Large, true)
    parent[name]:initialise()
    parent[name]:instantiate()
    parent:addChild(parent[name])
end

-- Status Effects Panel
function DiceSystem_CommonUI.AddStatusEffectsPanel(parent, height, currentOffset)
    parent.labelStatusEffectsList = ISRichTextPanel:new(0, currentOffset, parent.width, height) -- TODO Check if this is ok
    parent.labelStatusEffectsList:initialise()
    parent:addChild(parent.labelStatusEffectsList)

    parent.labelStatusEffectsList.marginTop = 0
    parent.labelStatusEffectsList.marginLeft = parent.width / 6
    parent.labelStatusEffectsList.marginRight = parent.width / 6
    parent.labelStatusEffectsList.autosetheight = false
    parent.labelStatusEffectsList.background = false
    parent.labelStatusEffectsList.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    parent.labelStatusEffectsList.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    parent.labelStatusEffectsList:paginate()
end

---Handles status effects in update
---@param parent any
---@param username string
function DiceSystem_CommonUI.UpdateStatusEffectsText(parent, username)
    local statusEffectsText = ""
    local activeStatusEffects = PlayerHandler.GetActiveStatusEffectsByUsername(username)

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
