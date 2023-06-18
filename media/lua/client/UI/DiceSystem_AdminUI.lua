require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local ENTRY_HGT = FONT_HGT_MEDIUM + 2 * 2

local PlayerHandler = require("DiceSystem_PlayerHandling")

DiceMenuAdminViewer = ISCollapsableWindow:derive("DiceMenuAdminViewer")
DiceMenuAdminViewer.messages = {}

function DiceMenuAdminViewer.OnOpenPanel()
    if DiceMenuAdminViewer.instance then
        DiceMenuAdminViewer.instance:close()
    end

    local modal = DiceMenuAdminViewer:new(50, 200, 250, 400)
    modal:initialise()
    modal:addToUIManager()
    modal.instance:setKeyboardFocus()

    return modal
end


function DiceMenuAdminViewer:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=1}
    o.width = width
    o.height = height
    o.resizable = false
    o.moveWithMouse = true
    DiceMenuAdminViewer.instance = o
    -- x = getCore():getScreenWidth() / 2 - (width / 2)
    -- y = getCore():getScreenHeight() / 2 - (height / 2)
    return o
end

function DiceMenuAdminViewer:initialise()
    local top = 50
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local padBottom = 10

    self.panel = ISTabPanel:new(10, top, self.width - 10 * 2, self.height)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0}
    self.panel.target = self
    self.panel.equalTabWidth = false
    self.panel.tabTransparency = 0
    self.panel.tabHeight = 0
    self:addChild(self.panel)


    self.btnClose = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_Close"), self, DiceMenuAdminViewer.onClick)
    self.btnClose.internal = "CLOSE"
    self.btnClose.anchorTop = false
    self.btnClose.anchorBottom = true
    self.btnClose:initialise()
    self.btnClose:instantiate()
    self.btnClose.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.btnClose)


    local mainCategory = DiceMenuAdminScrollingTable:new(0, 0, self.panel.width, self.panel.height, self)
    mainCategory:initialise()
    self.panel:addView("Players", mainCategory)
    self.panel:activateView("Players")

    local players
    if isClient() then
        players = getOnlinePlayers()
    else
        players = ArrayList.new()
        players:add(getPlayer())

    end
    mainCategory:initList(players)


end

function DiceMenuAdminViewer:prerender()
    local z = 20
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local title = getText("IGUI_DiceAdminMenu")
    self:drawText(title, self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, title) / 2), z, 1,1,1,1, UIFont.Medium)
end

function DiceMenuAdminViewer:onClick(button)
    if button.internal == "CLOSE" then
        self:close()
    end

end

function DiceMenuAdminViewer:setKeyboardFocus()
    local view = self.panel:getActiveView()
    if not view then return end
    Core.UnfocusActiveTextEntryBox()
    --view.filterWidgetMap.Type:focus()
end

function DiceMenuAdminViewer:close()
    self:setVisible(false)
    self:removeFromUIManager()
end


--************************************************************************--
DiceMenuAdminScrollingTable = ISPanel:derive("DiceMenuAdminScrollingTable")

function DiceMenuAdminScrollingTable:new (x, y, width, height, viewer)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)

    o.listHeaderColor = {r=0.4, g=0.4, b=0.4, a=0.3}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=0}
    o.backgroundColor = {r=0, g=0, b=0, a=0.0}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.totalResult = 0
    o.viewer = viewer
    DiceMenuAdminScrollingTable.instance = o
    return o
end

function DiceMenuAdminScrollingTable:createChildren()
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local bottomHgt = 5 + FONT_HGT_SMALL * 2 + 5 + btnHgt + 20 + FONT_HGT_LARGE + HEADER_HGT + ENTRY_HGT

    self.datas = ISScrollingListBox:new(0, HEADER_HGT, self.width, self.height - bottomHgt + 10)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true
    self.datas:setOnMouseDoubleClick(self, DiceMenuAdminScrollingTable.openPlayerDiceMenu)
    self.datas:addColumn("", 0)
    self:addChild(self.datas)
end

function DiceMenuAdminScrollingTable:initList(module)
    for i=0, module:size() - 1 do
        local pl = module:get(i)
        local username = pl:getUsername()
        --check if there are dice data for that specific player
        if PlayerHandler.CheckDataPresence(username) then
            self.datas:addItem(username, pl)
        end
    end
end

function DiceMenuAdminScrollingTable:validateInputs()


    return true
    -- local itemName = self.typeEntry:getText()
    -- local maxAmount = self.amountEntry:getText()

    -- local isItemNameValid = false
    -- local isMaxAmountValid = false

    
    -- -- Check itemName via regex validation
    -- local regexItemName = "(%S*)%.(%S*)"
    -- if string.find(itemName, regexItemName) then
    --     isItemNameValid = true
    -- end

    -- -- Rarity is already managed


    -- local maxAmountRegex = "(%d+)"
    -- if string.find(maxAmount, maxAmountRegex) then
    --     isMaxAmountValid = true
    -- end

    -- return isItemNameValid and isMaxAmountValid

end

function DiceMenuAdminScrollingTable:openPlayerDiceMenu(pl)
    --print("Selected " .. tostring(pl))

    -- TODO Request player for their data
    ModData.request(DICE_SYSTEM_MOD_STRING)
    local globalModData = ModData.get(DICE_SYSTEM_MOD_STRING)

    local diceData = globalModData[pl:getUsername()]

    if diceData then
        --print("Found dice data for " ..tostring(pl))
        PlayerHandler.SetUser(pl:getUsername())
        DiceMenu.OpenPanel()
    end
end

function DiceMenuAdminScrollingTable:update()
    self.datas.doDrawItem = self.drawDatas
end

function DiceMenuAdminScrollingTable:drawDatas(y, item, alt)
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

    local xOffset = 10
    self:drawText(item.text, xOffset, y + 4, 1, 1, 1, a, self.font)
    return y + self.itemheight
end


----------------------------------------------

require "ISUI/ISAdminPanelUI"

local _ISAdminPanelUICreate = ISAdminPanelUI.create

function ISAdminPanelUI:create()
    _ISAdminPanelUICreate(self)

    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnGapY = 5
    local y = self.showStatisticsBtn.y + btnHgt + btnGapY
    local btnWid = 150

    self.btnOpenAdminDiceMenu = ISButton:new(10 + btnWid + 20, y, btnWid, btnHgt, getText("IGUI_DiceAdminMenu"), self, DiceMenuAdminViewer.OnOpenPanel)
    self.btnOpenAdminDiceMenu:initialise()
    self.btnOpenAdminDiceMenu:instantiate()
    self.btnOpenAdminDiceMenu.borderColor = self.buttonBorderColor
    self:addChild(self.btnOpenAdminDiceMenu)
end