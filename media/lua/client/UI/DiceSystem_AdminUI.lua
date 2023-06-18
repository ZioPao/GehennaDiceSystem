require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local FONT_HGT_LARGE = getTextManager():getFontHeight(UIFont.Large)

local HEADER_HGT = FONT_HGT_MEDIUM + 2 * 2
local ENTRY_HGT = FONT_HGT_MEDIUM + 2 * 2

DiceMenuAdminViewer = ISCollapsableWindow:derive("DiceMenuAdminViewer")
DiceMenuAdminViewer.messages = {}

function DiceMenuAdminViewer:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
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

    self.panel = ISTabPanel:new(10, top, self.width - 10 * 2, self.height - padBottom - btnHgt - padBottom - top)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0}
    self.panel.target = self
    self.panel.equalTabWidth = false
    self:addChild(self.panel)


    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_Close"), self, DiceMenuAdminViewer.onClick)
    self.ok.internal = "CLOSE"
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise()
    self.ok:instantiate()
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.ok)


    local mainCategory = DiceMenuAdminScrollingTable:new(0, 0, self.panel.width, self.panel.height - self.panel.tabHeight, self)
    mainCategory:initialise()
    self.panel:addView("Players", mainCategory)
    self.panel:activateView("Players")


    local players = ArrayList.new()
    players:add(getPlayer())
    players:add(getPlayer())
    players:add(getPlayer())
    players:add(getPlayer())

    mainCategory:initList(players)


end

function DiceMenuAdminViewer:prerender()
    local z = 20
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    local title = "Test"
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

function DiceMenuAdminViewer.OnOpenPanel()

    local modal = DiceMenuAdminViewer:new(50, 200, 425, 700)
    modal:initialise()
    modal:addToUIManager()
    modal.instance:setKeyboardFocus()

    return modal
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

function DiceMenuAdminScrollingTable:initialise()
    ISPanel.initialise(self)
end

function DiceMenuAdminScrollingTable:render()
    ISPanel.render(self)
    
    local y = self.datas.y + self.datas.height + 5
    --self:drawText(getText("IGUI_DbViewer_TotalResult") .. self.totalResult, 0, y, 1,1,1,1,UIFont.Small)
    --self:drawText(getText("IGUI_ItemList_Info"), 0, y + FONT_HGT_SMALL, 1,1,1,1,UIFont.Small)

    y = self.labelX:getBottom()
    
    -- self:drawRectBorder(self.datas.x, y, self.datas:getWidth(), HEADER_HGT, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    -- self:drawRect(self.datas.x, y+1, self.datas:getWidth(), HEADER_HGT, self.listHeaderColor.a, self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b)

    local x = 0
    for i,v in ipairs(self.datas.columns) do
        local size
        if i == #self.datas.columns then
            size = self.datas.width - x
        else
            size = self.datas.columns[i+1].size - self.datas.columns[i].size
        end
--        print(v.name, x, v.size)
        self:drawText(v.name, x+10+3, y+2, 1,1,1,1,UIFont.Small)
        self:drawRectBorder(self.datas.x + x, y, 1, self.datas.itemheight + 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b)
        x = x + size
    end
end

function DiceMenuAdminScrollingTable:createChildren()
    ISPanel.createChildren(self)
    
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local bottomHgt = 5 + FONT_HGT_SMALL * 2 + 5 + btnHgt + 20 + FONT_HGT_LARGE + HEADER_HGT + ENTRY_HGT

    self.datas = ISScrollingListBox:new(0, HEADER_HGT, self.width, self.height - bottomHgt - HEADER_HGT)
    self.datas:initialise()
    self.datas:instantiate()
    self.datas.itemheight = FONT_HGT_SMALL + 4 * 2
    self.datas.selected = 0
    self.datas.joypadParent = self
    self.datas.font = UIFont.NewSmall
    self.datas.doDrawItem = self.drawDatas
    self.datas.drawBorder = true

    self.datas:addColumn("", 0)
    self:addChild(self.datas)

    ---------------------------------------
    -- Edit or add tab
    local x = 0

    -- 3 things, divide for width of the viewer I guess

    local size = self.width/3
    local entryY = self.datas:getBottom() + self.datas.itemheight + 25



    self.labelX = ISLabel:new(0 + 20, entryY - 30, FONT_HGT_LARGE, "X", 1, 1, 1, 1, UIFont.Large, true)
    self.labelX:initialise()
    self.labelX:instantiate()
    self:addChild(self.labelX)

    self.coordinatesX = ISTextEntryBox:new("", x, entryY, size, ENTRY_HGT)
    self.coordinatesX.font = UIFont.Medium
    self.coordinatesX:initialise()
    self.coordinatesX:instantiate()
    self.coordinatesX:setOnlyNumbers(true)
    --self.coordinatesX.columnName = self.datas.columns[1].name
    --self.coordinatesX.onOtherKey = function(entry, key) DSE_ItemsListTable.onOtherKey(entry, key) end
    --self.coordinatesX.target = self
    --self.coordinatesX:setClearButton(true)
    self:addChild(self.coordinatesX)
    x = x + size

    -- Y

    self.labelY = ISLabel:new(x + 20, entryY - 30, FONT_HGT_LARGE, "Y", 1, 1, 1, 1, UIFont.Large, true)
    self.labelY:initialise()
    self.labelY:instantiate()
    self:addChild(self.labelY)

    self.coordinatesY = ISTextEntryBox:new("", x, entryY, size, ENTRY_HGT)
    self.coordinatesY.font = UIFont.Medium
    self.coordinatesY:initialise()
    self.coordinatesY:instantiate()
    self.coordinatesY:setOnlyNumbers(true)
    self:addChild(self.coordinatesY)
    x = x + size

    -- Z
    self.labelZ = ISLabel:new(x + 20, entryY - 30, FONT_HGT_LARGE, "Z", 1, 1, 1, 1, UIFont.Large, true)
    self.labelZ:initialise()
    self.labelZ:instantiate()
    self:addChild(self.labelZ)

    self.coordinatesZ = ISTextEntryBox:new("", x, entryY, size, ENTRY_HGT)
    self.coordinatesZ.font = UIFont.Medium
    self.coordinatesZ:initialise()
    self.coordinatesZ:instantiate()
    self.coordinatesZ:setOnlyNumbers(true)
    self:addChild(self.coordinatesZ)
    x = x + size




    self.addBtn = ISButton:new(0, self.coordinatesZ:getBottom() + 20, self.datas:getWidth(), btnHgt, "Start Broadcast", self, DiceMenuAdminScrollingTable.onOptionMouseDown)
    self.addBtn.internal = "STARTSOUND"
    self.addBtn.anchorTop = false
    self.addBtn.anchorBottom = true
    self.addBtn:initialise()
    self.addBtn:instantiate()
    self.addBtn.borderColor = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.addBtn)


    self.loopTickBox = ISTickBox:new(10, self.addBtn:getBottom() + 10, 25, 25, "Loop")
	self.loopTickBox:initialise()
	self.loopTickBox:addOption("Loop", 1, nil)
	self:addChild(self.loopTickBox)


    self.loopAmountsEntrybox = ISTextEntryBox:new("", 100, self.addBtn:getBottom() + 10, 50, ENTRY_HGT)
    self.loopAmountsEntrybox:initialise()
    self.loopAmountsEntrybox:instantiate()
    self.loopAmountsEntrybox:setOnlyNumbers(true)
    self.loopAmountsEntrybox:setTooltip("Amount of loops")
	self:addChild(self.loopAmountsEntrybox)
end

function DiceMenuAdminScrollingTable:initList(module)
    for i=0, module:size() - 1 do
        local pl = module:get(i)
        self.datas:addItem(pl:getUsername(), pl)

    end
end

---@return boolean
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


function DiceMenuAdminScrollingTable:onOptionMouseDown(button, _, _)


    if button.internal == "STARTSOUND" then
        print("GovOps: start sound!")
        local sound = button.parent.datas.items[button.parent.datas.selected].item

        local x = self.coordinatesX:getText()
        local y = self.coordinatesY:getText()
        local z = self.coordinatesZ:getText()

        local isLoop = self.loopTickBox:isSelected(1)
        local loopAmounts = self.loopAmountsEntrybox:getText()

        --print(loopAmounts)
        --print(type(loopAmounts))


        if not isLoop and (x ~= "" and y ~= "" and z ~= "") then
            sendClientCommand(getPlayer(), "PZRPGovOps", "StartSound", {sound = sound, x = x, y = y, z = z, isLoop = false, loopAmounts = 0})

        elseif isLoop and loopAmounts ~= "" and (x ~= "" and y ~= "" and z ~= "") then
            sendClientCommand(getPlayer(), "PZRPGovOps", "StartSound", {sound = sound, x = x, y = y, z = z, isLoop = isLoop, loopAmounts = loopAmounts})
        end
    end

end

function DiceMenuAdminScrollingTable:update()


    -- Check if can be sent
    local x = self.coordinatesX:getText()
    local y = self.coordinatesY:getText()
    local z = self.coordinatesZ:getText()

    self.addBtn:setEnable(x ~= "" and y ~= "" and z ~= "" and self.datas.selected ~= 0)


    self.loopAmountsEntrybox:setEditable(self.loopTickBox:isSelected(1))

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

    local iconX = 4
    local iconSize = FONT_HGT_SMALL
    local xoffset = 10


    -------------------------------
    -- Sound

    local clipY = math.max(0, y + self:getYScroll())
    local clipY2 = math.min(self.height, y + self:getYScroll() + self.itemheight)

    self:drawText(item.text, xoffset, y + 4, 1, 1, 1, a, self.font)
    self:clearStencilRect()
    self:repaintStencilRect(0, clipY, self.width, clipY2 - clipY)
    return y + self.itemheight
end