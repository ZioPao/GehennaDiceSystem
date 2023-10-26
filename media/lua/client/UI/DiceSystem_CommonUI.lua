-- TODO Some stuff is shared between PlayerUI and HoverUI.
local PlayerHandler = require("DiceSystem_PlayerHandler")


--* Helper functions

---Get a string for ISRichTextPanel containing a colored status effect string
---@param status string
---@param translatedStatus string
---@return string
local function GetColoredStatusEffect(status, translatedStatus)
    -- Pick from table colors

    --local translatedStatus = getText("IGUI_StsEfct_" .. status)

    local statusColors = DiceSystem_Common.statusEffectsColors[status]
    local colorString = string.format(" <RGB:%s,%s,%s> ", statusColors.r, statusColors.g, statusColors.b)
    return colorString .. translatedStatus
end


local DiceSystem_CommonUI = {}
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
DiceSystem_CommonUI.FONT_SCALE = FONT_HGT_SMALL / 16
DiceSystem_CommonUI.amountActiveStatusEffects = {}

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
    parent.labelStatusEffectsList.marginLeft = 0
    parent.labelStatusEffectsList.marginRight = 0
    parent.labelStatusEffectsList.autosetheight = false
    parent.labelStatusEffectsList.background = false
    parent.labelStatusEffectsList.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    parent.labelStatusEffectsList.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    parent.labelStatusEffectsList:paginate()
end

local function CalculateStatusEffectsMargin(parentWidth, text)
    return (parentWidth - getTextManager():MeasureStringX(UIFont.NewSmall, text)) / 2
end

---Handles status effects in update
---@param parent any
---@param username string
function DiceSystem_CommonUI.UpdateStatusEffectsText(parent, username)
    local activeStatusEffects = PlayerHandler.GetActiveStatusEffectsByUsername(username)
    local amountActiveStatusEffects = #activeStatusEffects
    if DiceSystem_CommonUI.amountActiveStatusEffects[username] then
        if DiceSystem_CommonUI.amountActiveStatusEffects[username] == amountActiveStatusEffects then return end
    end

    DiceSystem_CommonUI.amountActiveStatusEffects[username] = amountActiveStatusEffects

    local formattedStatusEffects = {}
    local unformattedStatusEffects = {}
    local line = 1

    formattedStatusEffects[line] = ""
    unformattedStatusEffects[line] = ""

    for i = 1, #activeStatusEffects do
        local v = activeStatusEffects[i]
        local unformattedStatusText = getText("IGUI_StsEfct_" .. v)
        local formattedStatusText = GetColoredStatusEffect(v, unformattedStatusText)
        if i == 1 then
            -- First string
            formattedStatusEffects[line] = formattedStatusText
            unformattedStatusEffects[line] = unformattedStatusText
        elseif (i - 1) % 4 == 0 then -- We're gonna use max 4 per line
            -- Go to new line
            formattedStatusEffects[line] = formattedStatusEffects[line] .. " <LINE> "
            line = line + 1
            formattedStatusEffects[line] = formattedStatusText
            unformattedStatusEffects[line] = unformattedStatusText
        else
            -- Normal case
            formattedStatusEffects[line] = formattedStatusEffects[line] ..
            " <RGB:1,1,1> <SPACE> - <SPACE> " .. formattedStatusText
            unformattedStatusEffects[line] = unformattedStatusEffects[line] .. " - " .. unformattedStatusText
        end
    end

    local completeText = ""

    -- Margin is managed directly into the text
    for i = 1, line do
        local xLine = CalculateStatusEffectsMargin(parent.width, unformattedStatusEffects[i])
        formattedStatusEffects[i] = "<SETX:" .. xLine .. "> " .. formattedStatusEffects[i]
        completeText = completeText .. formattedStatusEffects[i]
    end

    parent.labelStatusEffectsList:setText(completeText)
    parent.labelStatusEffectsList.textDirty = true
end

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
