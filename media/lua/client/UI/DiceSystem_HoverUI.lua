
-- TODO Instead of checking if a player has the mouse over them, just right click. It's easier and less expensive.

-- TODO Admins shouldn't be hoverable
-- TODO add command /showstats "playername"

-- TODO Make it more condensed
-- TODO If you are setting your stats and hover somebody that has already set their stats, your stats are gonna die :( 

-- Caching stuff
local playerBase = __classmetatables[IsoPlayer.class].__index
local getNum = playerBase.getPlayerNum
local heartIco = getTexture("media/ui/dnd_heart.png") -- Document icons created by Freepik - Flaticon - Document
local armorIco = getTexture("media/ui/dnd_armor.png")

local PlayerHandler = require("DiceSystem_PlayerHandler")
local CommonUI = require("UI/DiceSystem_CommonUI")

-----------------


------------------

HoverUI = ISCollapsableWindow:derive("HoverUI")
HoverUI.openMenus = {}

---comment
---@param pl IsoPlayer
---@param username string Just the username of the player, since we've already referenced it before
function HoverUI.Open(pl, username)
    local width = 300 * CommonUI.FONT_SCALE
    local height = 250 * CommonUI.FONT_SCALE

    local plNum = getNum(pl)
    local plX = pl:getX()
    local plY = pl:getY()
    local plZ = pl:getZ()

    --TODO check if there's space, if not, switch to the left or bottom or up or whatever
    local x = isoToScreenX(plNum, plX, plY, plZ) * 1.1
    local y = isoToScreenY(plNum, plX, plY, plZ) * 0.7

    ModData.request(DICE_SYSTEM_MOD_STRING)
    local handler = PlayerHandler:instantiate(username)
    HoverUI.openMenus[username] = HoverUI:new(x, y, width, height, pl, handler)
    HoverUI.openMenus[username]:initialise()
    HoverUI.openMenus[username]:bringToTop()
end


function HoverUI.Close(username)
    HoverUI.openMenus[username]:close()
end

--************************************--

function HoverUI:new(x, y, width, height, pl, playerHandler)
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
    o.playerHandler = playerHandler

    return o
end

--************************************--
---Initialization
function HoverUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:addToUIManager()
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
    CommonUI.UpdateStatusEffectsText(self.panelTop, self.pl:getUsername())
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
    self.panelBottom.panelHealth:setText(string.format(bStrHealth, self.playerHandler:getCurrentHealth(),
        self.playerHandler:getMaxHealth()))
    self.panelBottom.panelHealth.textDirty = true

    --* Armor Class *--
    self.panelBottom.panelArmorClass:setText(string.format(bStrArmorClass, self.playerHandler:getArmorClass()))
    self.panelBottom.panelArmorClass.textDirty = true
end

function HoverUI:close()
    HoverUI.openMenus[self.pl:getUsername()] = nil
    ISCollapsableWindow.close(self)
end

--------------------------------------

local function FillHoverMenuOptions(player, context, worldobjects, test)
    local addedSubMenu = false
    local subMenu
    print("Running fillhovermenu")

    -- Got it directly from the base game, man this sucks ass
    for i,v in ipairs(worldobjects) do
        if v:getSquare() then
            -- help detecting a player by checking nearby squares
            for x=v:getSquare():getX()-1,v:getSquare():getX()+1 do
                for y=v:getSquare():getY()-1,v:getSquare():getY()+1 do
                    local sq = getCell():getGridSquare(x,y,v:getSquare():getZ())
                    if sq then
                        for i=0,sq:getMovingObjects():size()-1 do
                            local o = sq:getMovingObjects():get(i)
                            if instanceof(o, "IsoPlayer") and not o:isInvisible() then
                                local username = o:getUsername()
                                if addedSubMenu == false then
                                    local optionHoverMenu = context:addOption("Dice Mini Menu", worldobjects, nil)
                                    subMenu = ISContextMenu:getNew(context)
                                    context:addSubMenu(optionHoverMenu, subMenu)
                                end
                                if HoverUI.openMenus[username] == nil then
                                    subMenu:addOption("Open Menu for " .. username, o, HoverUI.Open, username)
                                else
                                    subMenu:addOption("Close Menu for " .. username, username, HoverUI.Close)
                                end
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(FillHoverMenuOptions)
