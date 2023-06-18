-- Admin tools and stuff
-- TODO Scrolling List

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

AdminDiceScrollingMenu = ISPanel:derive("AdminDiceScrollingMenu")
AdminDiceScrollingMenu.instance = nil

function AdminDiceScrollingMenu:new(x, y, width, height, viewer)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.width = width
    o.height = height

    o.resizable = false

    o.variableColor={r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=1.0}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.moveWithMouse = true
    o.viewer = viewer

    AdminDiceScrollingMenu.instance = o
    return o
end

function AdminDiceScrollingMenu:createChildren()
    local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
    local ENTRY_HGT = FONT_HGT_MEDIUM + 2 * 2
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local bottomHgt = 5 + FONT_HGT_SMALL * 2 + 5 + btnHgt + 20 + FONT_HGT_LARGE + HEADER_HGT + ENTRY_HGT

    self.playersData = ISScrollingListBox:new(0, HEADER_HGT, self.width, self.height - bottomHgt - HEADER_HGT)
    self.playersData:initialise()
    self.playersData:instantiate()
    self.playersData.itemheight = FONT_HGT_SMALL + 4 * 2
    self.playersData.selected = 0
    self.playersData.joypadParent = self
    self.playersData.font = UIFont.NewSmall
    self.playersData.doDrawItem = self.drawPlayersData
    self.playersData.drawBorder = true

    self.playersData:addColumn("", 0)
    self:addChild(self.playersData)


end

function AdminDiceScrollingMenu:initPlayersData(data)
    for i=0, data:size()-1 do
        local pl = data:get(i)
        print(pl)
        self.playersData:addItem(pl)
    end
end

function AdminDiceScrollingMenu:drawPlayersData(y, item, alt)
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    local a = 0.9

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.7, 0.35, 0.15)
    end

    if alt then
        self:drawRect(0, (y), self:getWidth(), self.itemheight, 0.3, 0.6, 0.5, 0.5)
    end

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local iconX = 4
    local iconSize = FONT_HGT_SMALL
    local xoffset = 10


    -------------------------------
    -- Sound

    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    self:drawText(item.text:getUsername(), xoffset, y + 4, 1, 1, 1, a, self.font)
    self:clearStencilRect()
    self:repaintStencilRect(0, clipY, self.width, clipY2 - clipY)
    return y + self.itemheight
end

function AdminDiceScrollingMenu:update()
    self.playersData.doDrawItem = self.drawPlayersData

end
------------------------------------------------------------------------------------------------------

AdminMainDiceMenu = ISPanel:derive("AdminMainDiceMenu")
AdminMainDiceMenu.instance = nil

function AdminMainDiceMenu:new(x, y, width, height)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    -- x = getCore():getScreenWidth() / 2 - (width / 2)
    -- y = getCore():getScreenHeight() / 2 - (height / 2)

    o.resizable = false
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.width = width
    o.height = height
    o.moveWithMouse = true
    AdminMainDiceMenu.instance = o
    return o
end

function AdminMainDiceMenu:createChildren()

    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    local top = 50
    self.panel = ISTabPanel:new(10, top, self.width - 10 * 2, self.height - padBottom - btnHgt - padBottom - top)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0}
    self.panel.target = self
    self.panel.equalTabWidth = false
    self:addChild(self.panel)






    ---------------------------------------
    self.btnClose = ISButton:new(self.width - 100 - 10, self.height - 35, 100, 25, getText("IGUI_Close"), self, self.onOptionMouseDown)
    self.btnClose.internal = "CLOSE"
    self.btnClose:initialise()
    self.btnClose:instantiate()
    self.btnClose:setEnable(true)
    self:addChild(self.btnClose)



    -- TODO This won't work in SP. Thank you tis.
    --local players = getOnlinePlayers()
	local players = ArrayList.new()
    players:add(getPlayer())
    players:add(getPlayer())
    players:add(getPlayer())
    players:add(getPlayer())

    
    local mainCategory = AdminDiceScrollingMenu:new(0, 0, self.panel.width, self.panel.height - self.panel.tabHeight, self)
    mainCategory:initialise()
    self.panel:addView("Players", mainCategory)
    self.panel:activateView("Players")
    mainCategory:initPlayersData(players)
end

function AdminMainDiceMenu:onOptionMouseDown(btn)
    if btn.internal == 'CLOSE' then
        self:close()
    end

end

function AdminMainDiceMenu:prerender()
    -- local z = 20

    -- self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    -- self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    -- -- TODO Use getText
    -- local title = "Dice System - Admin Panel"
    -- self:drawText(title, self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, title) / 2), z, 1,1,1,1, UIFont.Medium)
end

function AdminMainDiceMenu:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function AdminMainDiceMenu:setKeyboardFocus()
    local view = self.panel:getActiveView()
    if not view then return end
    Core.UnfocusActiveTextEntryBox()
end

function AdminMainDiceMenu.OnOpenPanel()
    local modal = AdminMainDiceMenu:new(50, 200, 425, 700)
    modal:createChildren()
    modal:addToUIManager()
    modal.instance:setKeyboardFocus()
    return modal
end