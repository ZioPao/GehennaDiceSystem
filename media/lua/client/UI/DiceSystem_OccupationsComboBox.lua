OccupationsComboBox = ISComboBox:derive("OccupationsComboBox")
OccupationsComboBoxPopup = ISComboBoxPopup:derive("OccupationsComboBoxPopup")
local playerHandler = require("DiceSystem_PlayerHandling")

function OccupationsComboBoxPopup:doDrawItem(y, item, alt)
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

    -- todo check if current item is selected
    local color = {r=1,b=1,g=1,a=1}
    --print(item.text)
    if playerHandler.GetStatusEffectValue(item.text) then
        print("Active!")
        color.r = 0
        color.g = 1
        color.b = 0
    end


    self:drawText(item.text, 10, y + itemPadY, color.r, color.g, color.b, color.a, self.font)
    y = y + item.height
    return y
end

function OccupationsComboBoxPopup:new(x, y, width, height)
    local o = ISComboBoxPopup:new(x, y, width, height)
    setmetatable(o, self)
    return o
end


--**************************************************--

function OccupationsComboBox:createChildren()
    self.popup = OccupationsComboBoxPopup:new(0, 0, 100, 50)
    self.popup:initialise()
    self.popup:instantiate()
    self.popup:setFont(self.font, 4)
    self.popup:setAlwaysOnTop(true)
    self.popup.drawBorder = true
    self.popup:setCapture(true)
    OccupationsComboBox.SharedPopup = self.popup
end

function OccupationsComboBox:onMouseUp(x, y)
    if self.disabled or not self.sawMouseDown then return end
    self.sawMouseDown = false
    self.expanded = not self.expanded
    if self.expanded then
        self:showPopup()
    else
        self:hidePopup()
        self.mouseOver = self:isMouseOver()
    end
end

function OccupationsComboBox:hidePopup()
    getSoundManager():playUISound("UIToggleComboBox")
    self.popup:removeFromUIManager()
end
function OccupationsComboBox:prerender()
	if not self.disabled then
		self.fade:setFadeIn(self.joypadFocused or self:isMouseOver())
		self.fade:update()
	end

	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);

    if self.expanded then
    elseif not self.joypadFocused then
        self:drawRect(0, 0, self.width, self.height, self.backgroundColorMouseOver.a * 0.5 * self.fade:fraction(), self.backgroundColorMouseOver.r, self.backgroundColorMouseOver.g, self.backgroundColorMouseOver.b);
	else
        self:drawRect(0, 0, self.width, self.height, self.backgroundColorMouseOver.a, self.backgroundColorMouseOver.r, self.backgroundColorMouseOver.g, self.backgroundColorMouseOver.b);
    end
    local alpha = math.min(self.borderColor.a + 0.2 * self.fade:fraction(), 1.0)
	if not self.disabled then
		self:drawRectBorder(0, 0, self.width, self.height, alpha, self.borderColor.r, self.borderColor.g, self.borderColor.b);
	else
		self:drawRectBorder(0, 0, self.width, self.height, alpha, 0.5, 0.5, 0.5);
	end

	local fontHgt = getTextManager():getFontHeight(self.font)
	local y = (self.height - fontHgt) / 2

    self:drawText("Open List", 10, y, self.textColor.r, self.textColor.g, self.textColor.b, self.textColor.a, self.font)

	if self:isMouseOver() and not self.expanded and self:getOptionTooltip(self.selected) then
		local text = self:getOptionTooltip(self.selected)
		if not self.tooltipUI then
			self.tooltipUI = ISToolTip:new()
			self.tooltipUI:setOwner(self)
			self.tooltipUI:setVisible(false)
			self.tooltipUI:setAlwaysOnTop(true)
		end
		if not self.tooltipUI:getIsVisible() then
			if string.contains(text, "\n") then
				self.tooltipUI.maxLineWidth = 1000 -- don't wrap the lines
			else
				self.tooltipUI.maxLineWidth = 300
			end
			self.tooltipUI:addToUIManager()
			self.tooltipUI:setVisible(true)
		end
		self.tooltipUI.description = text
		self.tooltipUI:setX(self:getMouseX() + 23)
		self.tooltipUI:setY(self:getMouseY() + 23)
	else
		if self.tooltipUI and self.tooltipUI:getIsVisible() then
			self.tooltipUI:setVisible(false)
			self.tooltipUI:removeFromUIManager()
		end
    end

	if not self.disabled then
    	self:drawTexture(self.image, self.width - self.image:getWidthOrig() - 3, (self.baseHeight / 2) - (self.image:getHeight() / 2), 1, 1, 1, 1)
	else
		self:drawTexture(self.image, self.width - self.image:getWidthOrig() - 3, (self.baseHeight / 2) - (self.image:getHeight() / 2), 1, 0.5, 0.5, 0.5)
	end
end
function OccupationsComboBox:new (x, y, width, height, target, onChange, onChangeArg1, onChangeArg2)
    local o = ISComboBox:new(x, y, width, height, target, onChange, onChangeArg1, onChangeArg2)
    setmetatable(o, self)
	self.__index = self
	return o
end
