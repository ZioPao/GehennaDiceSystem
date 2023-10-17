-- TODO Should appear when you toggle it on via a keybind or something when hovering over a player with the mouse


-- Caching stuff
local getOnlinePlayers = getOnlinePlayers
local playerBase = __classmetatables[IsoPlayer.class].__index
local getNum = playerBase.getPlayerNum
local getUsername = playerBase.getUsername
local getOnlineID = playerBase.getOnlineID
local getX = playerBase.getX
local getY = playerBase.getY
local getZ = playerBase.getZ
local isoToScreenX = isoToScreenX
local isoToScreenY = isoToScreenY
local os_time = os.time

local PlayerHandler = require("DiceSystem_PlayerHandling")
local CommonUI = require("UI/DiceSystem_CommonUI")

-----------------


HoverUI = ISCollapsableWindow:derive("HoverUI")
HoverUI.nearPlayersStatusEffects = {}


function HoverUI.Open(x,y)
    local width = 300 * CommonUI.FONT_SCALE
    local height = 300 * CommonUI.FONT_SCALE

    if HoverUI.instance == nil then
        local pnl = HoverUI:new(x, y, width, height)
        pnl:initialise()
        pnl:bringToTop()
    end
end


--************************************--

function HoverUI:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.width = width
    o.height = height
    o.resizable = false
    o.variableColor = { r = 0.9, g = 0.55, b = 0.1, a = 1 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.moveWithMouse = true

    HoverUI.instance = o        -- TODO Can be multiple?
    return o
end

--************************************--
---Initialization
function HoverUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:addToUIManager()

    --self.currPlayerUsername = self.player:getUsername()
    self.sTime = os_time()
    --self.onlinePlayers = getOnlinePlayers()
    self.requestsCounter = {} -- This is to prevent a spam of syncs from users who did not initialize the mod.

end

function HoverUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    print("Running create children")
    local yOffset = 40
    local pl
    if isClient() then pl = getPlayerFromUsername(PlayerHandler.username) else pl = getPlayer() end
    local plDescriptor = pl:getDescriptor()
    local playerName = DiceSystem_Common.GetForenameWithoutTabs(plDescriptor) -- .. " " .. DiceSystem_Common.GetSurnameWithoutBio(plDescriptor)


    -- TOP PANEL
    self.panelTop = ISPanel:new(0, 20, self.width, 100)
    self.panelTop:setAlwaysOnTop(false)
    self.panelTop:initialise()
    self:addChild(self.panelTop)

    --* Name Label *--
    CommonUI.AddCenteredTextLabel(self.panelTop, "nameLabel", playerName, yOffset)
    yOffset = yOffset + 25 + 10     -- TODO Janky

    --* Status Effects Panel *--
    local labelStatusEffectsHeight = 25 * (CommonUI.FONT_SCALE + 0.5)
    CommonUI.AddStatusEffectsPanel(self.panelTop, labelStatusEffectsHeight, yOffset)
    yOffset = yOffset + labelStatusEffectsHeight + 25


    -----------------

    local xOffset = 40
    local frameHeight = self.width / 3  - xOffset
    local frameWidth = self.width / 3 - xOffset

    self.labelHealth = ISLabel:new(xOffset, yOffset, 25, "Health", 1, 1, 1, 1, UIFont.Large, true)
    self.labelHealth:initialise()
    self.labelHealth:instantiate()
    self:addChild(self.labelHealth)

    self.labelArmorClass = ISLabel:new(self.width - frameWidth - xOffset, yOffset, 25, "Armor Class", 1, 1, 1, 1, UIFont.Large, true)
    self.labelArmorClass:initialise()
    self.labelArmorClass:instantiate()
    self:addChild(self.labelArmorClass)

    yOffset = yOffset + 25

    CommonUI.AddPanel(self, "panelHealth", frameWidth, frameHeight, xOffset, yOffset)
    CommonUI.AddPanel(self, "panelArmorClass", frameWidth, frameHeight, self.width - frameWidth - xOffset, yOffset)


    self.panelHealth.background = true
    self.panelHealth.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panelHealth.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }

    self.panelArmorClass.background = true
    self.panelArmorClass.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panelArmorClass.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }

end

function HoverUI:update()
    ISCollapsableWindow.update(self)

    CommonUI.UpdateStatusEffectsText(self.panelTop, PlayerHandler)

end

function HoverUI:render()
    ISCollapsableWindow.render(self)

    --* Health *--
    self.panelHealth:setText("<SIZE:large> " .. PlayerHandler.GetCurrentHealth() .. "/" .. PlayerHandler.GetMaxHealth())
    self.panelHealth.textDirty = true

    --* Armor Class *--
    self.panelArmorClass:setText("<SIZE:large> " .. PlayerHandler.GetArmorClass())
    self.panelArmorClass.textDirty = true
end

function HoverUI:close()
    HoverUI.instance = nil
    ISCollapsableWindow.close(self)
end
--------------------------------------



-- Should run in a loop, check if mouse is over a player with stats
local function CheckMouseOverPlayer()

    -- TODO ACtive this from right click and enable hover thing
    -- TODO Active ONLY if you keep the mouse on the player for about 1-2 seconds

    -- todo add range +1 to account for more squares
    local plZ = getPlayer():getZ()
    local xx, yy = ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled(), plZ)

    local x = math.floor(xx)
    local y = math.floor(yy)

    local sq = getCell():getGridSquare(x, y, plZ)
    --if sq and sq:getFloor() then sq:getFloor():setHighlighted(true) end

    local pl = sq:getPlayer()

    print(pl)

    if pl ~= nil then
        local plNum = getNum(pl)

        local panelX = isoToScreenX(plNum, x, y, plZ)
        local panelY = isoToScreenY(plNum, x, y, plZ)

        HoverUI.Open(panelX, panelY)
    end

    -- local objects = sq:getObjects()
    -- for i=0, objects:size() - 1 do
    --     local obj = objects:get(i)
    --     print(obj:getType())

    --     -- if instanceof(obj, "IsoPlayer") then
    --     --     print("It's a player!")
    --     --     print(obj:getUsername())
    --     -- end
    -- end


end

Events.OnTick.Add(CheckMouseOverPlayer)



function HoverUI.CheckPlayerStats()
    local plNum = getNum(pl)
    local plX = getX(pl)
    local plY = getY(pl)
    local plZ = getZ(pl)
    local baseX = isoToScreenX(plNum, plX, plY, plZ) - 100
    local baseY = isoToScreenY(plNum, plX, plY, plZ) - (150 / self.zoom) - 50 + StatusEffectsUI.GetUserOffset()

    local x = baseX
    local y = baseY

    local isSecondLine = false
    for k = 1, #statusEffects do
        local v = statusEffects[k]

        -- OPTIMIZE This part could be cached if we wanted.
        local stringToPrint = string.format("[%s]", v)
        --print(stringToPrint)
        if k > 3 and isSecondLine == false then
            y = y + getTextManager():MeasureStringY(UIFont.NewMedium, stringToPrint)
            x = baseX
            isSecondLine = true
        end

        local color = DiceSystem_Common.statusEffectsColors[v]

        -- The first DrawText is to simulate a drop shadow to help readability
        self:drawText(stringToPrint, x - 2, y - 2, 0, 0, 0, 0.5, UIFont.NewMedium)
        self:drawText(stringToPrint, x, y, color.r, color.g, color.b, 1, UIFont.NewMedium)
        x = x + getTextManager():MeasureStringX(UIFont.NewMedium, stringToPrint) + 10
    end
end
