-- TODO Some stuff is shared between PlayerUI and HoverUI.
local PlayerHandler = require("DiceSystem_PlayerHandler")


--* Helper functions

---Get a string for ISRichTextPanel containing a colored status effect string
---@param status string
---@return string
local function GetColoredStatusEffect(status)
    -- Pick from table colors

    local translatedStatus = getText("IGUI_StsEfct_" .. status)

    local statusColors = DiceSystem_Common.statusEffectsColors[status]
    local colorString = string.format(" <RGB:%s,%s,%s> ", statusColors.r, statusColors.g, statusColors.b)
    return colorString .. translatedStatus
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
    parent.labelStatusEffectsList.marginLeft = 0
    parent.labelStatusEffectsList.marginRight = 0
    parent.labelStatusEffectsList.autosetheight = false
    parent.labelStatusEffectsList.background = false
    parent.labelStatusEffectsList.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    parent.labelStatusEffectsList.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    parent.labelStatusEffectsList:paginate()
end

local function CalculateStatusEffectsMargin(parentWidth, text)
    return (parentWidth - getTextManager():MeasureStringX(UIFont.NewSmall, text))/2

end


---Handles status effects in update
---@param parent any
---@param username string
function DiceSystem_CommonUI.UpdateStatusEffectsText(parent, username)
    local statusEffectsText = ""
    local uncoloredStatusEffectsText = ""
    local activeStatusEffects = PlayerHandler.GetActiveStatusEffectsByUsername(username)
    local reachedMaxMargin = false
    local marginLeft = 0
    for i = 1, #activeStatusEffects do
        local v = activeStatusEffects[i]
        local singleStatus = GetColoredStatusEffect(v)
        if i == 1 then
            -- First string
            statusEffectsText = statusEffectsText .. singleStatus
            uncoloredStatusEffectsText = uncoloredStatusEffectsText .. getText("IGUI_StsEfct_"..v)
            marginLeft = CalculateStatusEffectsMargin(parent.width, uncoloredStatusEffectsText)
        elseif (i-1)%4 == 0 then        -- We're gonna use max 3 per line to let it be compatible with the hover ui too
            -- Go to new line
            if reachedMaxMargin == false then
                reachedMaxMargin = true
                marginLeft = CalculateStatusEffectsMargin(parent.width, uncoloredStatusEffectsText)
                reachedMaxMargin = true
            end
            statusEffectsText = statusEffectsText .. " <RGB:1,1,1> <SPACE> - <LINE> " .. singleStatus
            uncoloredStatusEffectsText = uncoloredStatusEffectsText .. getText("IGUI_StsEfct_"..v)
        else
            -- Normal case
            statusEffectsText = statusEffectsText .. " <RGB:1,1,1> <SPACE> - <SPACE> " .. singleStatus
            uncoloredStatusEffectsText = uncoloredStatusEffectsText .. " - " .. getText("IGUI_StsEfct_".. v)
            if reachedMaxMargin == false then
                marginLeft = CalculateStatusEffectsMargin(parent.width, uncoloredStatusEffectsText)
            end
        end
    end

    -- Set correct margin
    --print(uncoloredStatusEffectsText)
    --print(getTextManager():MeasureStringX(UIFont.NewSmall, uncoloredStatusEffectsText))
    --marginLeft = CalculateStatusEffectsMargin(parent.width, uncoloredStatusEffectsText)
    parent.labelStatusEffectsList.marginLeft = marginLeft
    parent.labelStatusEffectsList:setText(statusEffectsText)
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
