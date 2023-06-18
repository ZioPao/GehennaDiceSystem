require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISTextEntryBox"


-- TODO This has low priority, but still cool nonetheless


ColoredComboBoxPopup = ISScrollingListBox:derive("ColoredComboBoxPopup")


function ColoredComboBoxPopup:new(x, y, width, height)
    local o = ISScrollingListBox:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    self.parentCombo = nil
    return o
end

function ColoredComboBoxPopup:prerender()
    if not self.parentCombo:isReallyVisible() then
        -- Hack for gamepad being disconnected
        self:removeFromUIManager()
        return
    end
    self.tooWide = nil
    
    local numVisible = self:size()
    if self.parentCombo:hasFilterText() then
        local filterText = self.parentCombo:getFilterText():lower()
        for i=1,self:size() do
            local text = self.items[i].text:lower()
            if not text:contains(filterText) then
                numVisible = numVisible - 1
            end
        end
    end
--    numVisible = math.max(numVisible, 1)
    self:setScrollHeight(numVisible * self.itemheight)
    self:setHeight(math.min(numVisible, 8) * self.itemheight)
    self.vscroll:setHeight(self.height)

    ISScrollingListBox.prerender(self)
end

function ColoredComboBoxPopup:render()
    ISScrollingListBox.render(self)
    self:drawRectBorderStatic(-1, -1, self:getWidth() + 2, self:getHeight() + 2, 0.8, 1, 1, 1)

    if self.tooWide then
        local item = self.tooWide
        local y = self.tooWideY
        local textWid = getTextManager():MeasureStringX(self.font, item.text)
        local selectColor = self.parentCombo.backgroundColorMouseOver
        self:drawRect(0, y, 10 + textWid + 8, item.height-1, selectColor.a, selectColor.r, selectColor.g, selectColor.b)
        local itemPadY = self.itemPadY or (item.height - self.fontHgt) / 2
        self:drawText(item.text, 10, y + itemPadY, self.parentCombo.textColor.r, self.parentCombo.textColor.g, self.parentCombo.textColor.b, self.parentCombo.textColor.a, self.font)
    end
end

function ColoredComboBoxPopup:doDrawItem(y, item, alt)
    if self.parentCombo:hasFilterText() then
        if not item.text:lower():contains(self.parentCombo:getFilterText():lower()) then
            return y
        end
    end
    if item.height == 0 then
        item.height = self.itemheight
    end
    local highlight = (self:isMouseOver() and not self:isMouseOverScrollBar()) and self.mouseoverselected or self.selected
    if self.parentCombo.joypadFocused then
        highlight = self.selected
    end
    if highlight == item.index then
        local selectColor = self.parentCombo.backgroundColorMouseOver
        self:drawRect(0, (y), self:getWidth(), item.height-1, selectColor.a, selectColor.r, selectColor.g, selectColor.b)

        if self:isMouseOver() and not self:isMouseOverScrollBar() then
            local textWid = getTextManager():MeasureStringX(self.font, item.text)
            local scrollBarWid = self:isVScrollBarVisible() and 13 or 0
            if 10 + textWid > self.width - scrollBarWid then
                self.tooWide = item
                self.tooWideY = y
            end
        end
    end
    local itemPadY = self.itemPadY or (item.height - self.fontHgt) / 2
    self:drawText(item.text, 10, y + itemPadY, self.parentCombo.textColor.r, self.parentCombo.textColor.g, self.parentCombo.textColor.b, self.parentCombo.textColor.a, self.font)
    y = y + item.height
    return y
end

function ColoredComboBoxPopup:onMouseDown(x, y)
	if self.parentCombo.disabled then return false; end
    if not self:isMouseOver() then -- due to setCapture()
        self.parentCombo.expanded = false
        self.parentCombo:hidePopup()
        return
    end
    return true
end

function ColoredComboBoxPopup:onMouseUp(x, y)
	if self.parentCombo.disabled then return; end
    if self.vscroll then
        self.vscroll.scrolling = false
    end
    if not self:isMouseOver() then -- due to setCapture()
        self.parentCombo.expanded = false
        self.parentCombo:hidePopup()
        return
    end
    if not self.joypadFocused then
        local row = self:rowAt(x, y)
        if row > #self.items then
            row = #self.items
        elseif row < 1 then
            row = 1
        end
        self.parentCombo.selected = row
        self.parentCombo.expanded = false
        self.parentCombo:hidePopup()
        if self.parentCombo.onChange then
            self.parentCombo.onChange(self.parentCombo.target, self.parentCombo, self.parentCombo.onChangeArgs[1], self.parentCombo.onChangeArgs[2])
        end
    end
end

function ColoredComboBoxPopup:setComboBox(comboBox)
    self:clear()
    for i=1,#comboBox.options do
        self:addItem(comboBox:getOptionText(i), nil)
    end
    self:setYScroll(0)
    self.selected = comboBox.selected
    self:setHeight(math.min(#comboBox.options, 8) * self.itemheight)
    
    self:setX(comboBox:getAbsoluteX())
    self:setWidth(comboBox:getWidth())
    if comboBox.openUpwards or (comboBox:getAbsoluteY() + comboBox:getHeight() + self:getHeight() > getCore():getScreenHeight()) then
        self:setY(comboBox:getAbsoluteY() - self:getHeight())
    else
        self:setY(comboBox:getAbsoluteY() + comboBox:getHeight())
    end
    self.borderColor = { r = comboBox.borderColor.r, g = comboBox.borderColor.g, b = comboBox.borderColor.b, a = comboBox.borderColor.a }
    self.backgroundColor = { r = comboBox.backgroundColor.r, g = comboBox.backgroundColor.g, b = comboBox.backgroundColor.b, a = comboBox.backgroundColor.a }
    self.parentCombo = comboBox
    self:ensureVisible(self.selected)
end
