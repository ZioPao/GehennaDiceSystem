-- TODO Should appear when you toggle it on via a keybind or something when hovering over a player with the mouse

-- Caching stuff
local playerBase = __classmetatables[IsoPlayer.class].__index
local getNum = playerBase.getPlayerNum
local isoToScreenX = isoToScreenX
local isoToScreenY = isoToScreenY
local os_time = os.time

local PlayerHandler = require("DiceSystem_PlayerHandling")
local CommonUI = require("UI/DiceSystem_CommonUI")

-----------------

local heartIco = getTexture("media/ui/dnd_heart.png") -- Document icons created by Freepik - Flaticon - Document
local armorIco = getTexture("media/ui/dnd_armor.png")

------------------

HoverUI = ISCollapsableWindow:derive("HoverUI")
HoverUI.nearPlayersStatusEffects = {}
HoverUI.isActive = false

-- TODO Status effects are overriden to the other people

function HoverUI.Open(pl, x, y)
    local width = 300 * CommonUI.FONT_SCALE
    local height = 250 * CommonUI.FONT_SCALE

    if HoverUI.instance == nil then
        local pnl = HoverUI:new(x, y, width, height, pl)
        pnl:initialise()
        pnl:bringToTop()
    end
end
--************************************--

function HoverUI:new(x, y, width, height, pl)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.width = width
    o.height = height
    o.resizable = false
    o.variableColor = { r = 0.9, g = 0.55, b = 0.1, a = 1 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.moveWithMouse = true
    o.isOpening = true

    o.pl = pl

    HoverUI.instance = o -- TODO Can be multiple?
    return o
end

--************************************--
---Initialization
function HoverUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:addToUIManager()

    --self.sTime = os_time()
    --self.requestsCounter = {} -- This is to prevent a spam of syncs from users who did not initialize the mod.
end

function HoverUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    print("Running create children")
    local yOffset = 10
    local pl
    --if isClient() then pl = getPlayerFromUsername(PlayerHandler.username) else pl = getPlayer() end
    local plDescriptor = self.pl:getDescriptor()
    local playerName = DiceSystem_Common.GetForenameWithoutTabs(plDescriptor) -- .. " " .. DiceSystem_Common.GetSurnameWithoutBio(plDescriptor)

    -- TOP PANEL
    self.panelTop = ISPanel:new(0, 20, self.width, self.height / 3)
    self.panelTop:setAlwaysOnTop(false)
    self.panelTop:initialise()
    self:addChild(self.panelTop)

    --* Name Label *--
    CommonUI.AddCenteredTextLabel(self.panelTop, "nameLabel", playerName, yOffset)
    yOffset = yOffset + 25

    --* Status Effects Panel *--
    local labelStatusEffectsHeight = 25 * (CommonUI.FONT_SCALE + 0.5)
    CommonUI.AddStatusEffectsPanel(self.panelTop, labelStatusEffectsHeight, yOffset)

    -----------------

    local xOffset = 40
    local frameHeight = self.width / 3 - xOffset
    local frameWidth = self.width / 3 - xOffset

    self.panelBottom = ISPanel:new(0, self.panelTop:getBottom(), self.width, self.height - self.panelTop:getHeight())
    self.panelBottom:setAlwaysOnTop(false)
    self.panelBottom:initialise()
    self:addChild(self.panelBottom)

    CommonUI.AddPanel(self.panelBottom, "panelHealth", frameWidth, frameHeight, xOffset, self.panelBottom:getHeight() / 4)
    CommonUI.AddPanel(self.panelBottom, "panelArmorClass", frameWidth, frameHeight, self.width - frameWidth - xOffset,
        self.panelBottom:getHeight() / 4)

    self.panelBottom.panelHealth.background = true
    self.panelBottom.panelHealth.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panelBottom.panelHealth.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.panelBottom.panelHealth.marginTop = frameHeight / 5
    self.panelBottom.panelHealth.marginLeft = frameWidth / 6
    self.panelBottom.panelHealth.marginRight = frameWidth / 6

    self.panelBottom.panelArmorClass.background = true
    self.panelBottom.panelArmorClass.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panelBottom.panelArmorClass.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.panelBottom.panelArmorClass.marginTop = frameHeight / 5
    self.panelBottom.panelArmorClass.marginLeft = frameWidth / 6
    self.panelBottom.panelArmorClass.marginRight = frameWidth / 6
end

function HoverUI:update()
    ISCollapsableWindow.update(self)
    CommonUI.UpdateStatusEffectsText(self.panelTop, PlayerHandler, self.pl:getUsername())
end

local bStrHealth = "<CENTRE> <SIZE:large> <RGB:0,1,0> %d/%d"
local bStrArmorClass = "<CENTRE> <SIZE:large> <RGB:1,0,0> %d"

function HoverUI:prerender()
    ISCollapsableWindow.prerender(self)
    local yLabel = self.panelBottom.panelHealth:getY() - 35

    local xHealth = (self.width / 2 - getTextManager():MeasureStringX(UIFont.Large, "Health")) / 2.4
    self.panelBottom:drawText("Health", xHealth, yLabel, 1, 1, 1, 1, UIFont.Large)

    local xArmorClass = (self.width - getTextManager():MeasureStringX(UIFont.Large, "Armor Class")) * 0.9
    self.panelBottom:drawText("Armor Class", xArmorClass, yLabel, 1, 1, 1, 1, UIFont.Large)


    --FIXME incredibly janky workaround
    local fontScale = CommonUI.FONT_SCALE

    if fontScale > 1 then
        fontScale = fontScale + 0.5
    end

    local iconSize = 48 * fontScale
    --print(fontScale)

    self.panelBottom.panelHealth:drawTextureScaled(heartIco, 7, 5, iconSize, iconSize, 0.2, 1, 1, 1)
    self.panelBottom.panelArmorClass:drawTextureScaled(armorIco, 7, 5, iconSize, iconSize, 0.2, 1, 1, 1)
end

function HoverUI:render()
    ISCollapsableWindow.render(self)

    if self.isOpening then
        --print(self.backgroundColor.a)
        self.backgroundColor.a = self.backgroundColor.a + 0.1 -- Horrendous
        if self.backgroundColor.a >= 1 then
            self.isOpening = false
        end
    end

    --* Health *--
    self.panelBottom.panelHealth:setText(string.format(bStrHealth, PlayerHandler.GetCurrentHealth(),
        PlayerHandler.GetMaxHealth()))
    self.panelBottom.panelHealth.textDirty = true

    --* Armor Class *--
    self.panelBottom.panelArmorClass:setText(string.format(bStrArmorClass, PlayerHandler.GetArmorClass()))
    self.panelBottom.panelArmorClass.textDirty = true
end

function HoverUI:close()
    HoverUI.instance = nil
    ISCollapsableWindow.close(self)
end

--------------------------------------


local hoverData = {
    pl = nil,

    startTime = nil,
    currentTime = nil,
}


-- Should run in a loop, check if mouse is over a player with stats
local function CheckMouseOverPlayer()
    -- TODO ACtive this from right click and enable hover thing


    local plZ = getPlayer():getZ()
    local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), plZ)
    local x = math.floor(xx)
    local y = math.floor(yy)


    -- x offset max 1, y offset max 2
    -- Double check
    local checkedPlayer

    for i = -1, 1 do
        for j = -1, 1 do
            local sq = getCell():getGridSquare(x + i, y + i + j, plZ)
            if checkedPlayer == nil then
                checkedPlayer = sq:getPlayer()
            end
        end
    end


    -- No player during iteration, start countdown to close the hover ui
    if checkedPlayer == nil then
        hoverData.pl = nil
        hoverData.startTime = nil
        hoverData.currentTime = nil
        if HoverUI.instance then HoverUI.instance:close() end
        return

        -- Player wasn't found in a previous iteration, but now it is
    elseif hoverData.pl == nil then
        hoverData.pl = checkedPlayer
        hoverData.startTime = nil
        hoverData.currentTime = nil
        return
        -- Same player as before, we can manage the timer
    elseif hoverData.pl == checkedPlayer then
        local plUsername = checkedPlayer:getUsername()

        if DICE_CLIENT_MOD_DATA == nil or DICE_CLIENT_MOD_DATA[plUsername] == nil then return end
        if DICE_CLIENT_MOD_DATA[plUsername].isInitialized == false then return end

        -- Timer wasn't started before
        if hoverData.startTime == nil then
            hoverData.startTime = os_time()
            hoverData.currentTime = hoverData.startTime
        else
            hoverData.currentTime = os_time()
        end

        if hoverData.currentTime - hoverData.startTime < 1 then
            if HoverUI.instance then HoverUI.instance:close() end

            -- Set back the og user just to be sure that stuff doesn't break
            PlayerHandler.SetUser(plUsername)
            return
        else
            ModData.request(DICE_SYSTEM_MOD_STRING)
            PlayerHandler.SetUser(plUsername)               -- TODO Not sure if this is gonna work
            local plNum = getNum(hoverData.pl)
            local panelX = isoToScreenX(plNum, x + 1, y, plZ) -- TODO Check if we're at the limit of the screen
            local panelY = isoToScreenY(plNum, x, y + 1, plZ)
            HoverUI.Open(checkedPlayer, panelX, panelY)
        end
    end
end

local function ManageHoverUIActivation(player, context, worldobjects, test)
    if HoverUI.isActive then
        context:addOption("Disable Hover Menu", worldobjects, function()
            HoverUI.isActive = false
            Events.OnTick.Remove(CheckMouseOverPlayer)
        end)
    else
        context:addOption("Enable Hover Menu", worldobjects, function()
            HoverUI.isActive = true
            Events.OnTick.Add(CheckMouseOverPlayer)
        end)
    end
end

Events.OnFillWorldObjectContextMenu.Add(ManageHoverUIActivation)
