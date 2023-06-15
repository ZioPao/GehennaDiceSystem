--[[
Main interface
    Name of the player on top
    Occupation dropdown menu
        The player can choose this only ONCE, unless they have a special item to reset the whole skill assignment
    Status effects dropdown menu
        The player can change this whenever they want. It'll affect eventual rolls
    Status effects should be shown near a player's name, on top of their head.
        Multiple status effects can be selected; in that case, in the select you will read "X status effects selected" instead.
    Armor Bonus (Only visual, dependent on equipped clothing)
    Movement Bonus (Only visual, dependent on Deft skill and armor bonus)
    Health handling bar
        Players should be able to change the current amount of health
    Movement handling bar
        Players should be able to change the current movement value
    Skill points section
        Maximum of 20 assignable points
        When setting this up, the player can assign points to each skill
        When a player has already setup their skills, they will be able to press "Roll" for each skill.
        When a player press on "Roll", results must be shown in the chat

Admin utilities
    An Item that users can use to reset their skills\occupations
    Menu with a list of players, where admins can open a specific player dice menu.
]]

DiceMenu = ISCollapsableWindow:derive("DiceMenu")
DiceMenu.instance = nil


function DiceMenu:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
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

    DiceMenu.instance = o
    return o
end

function DiceMenu:createChildren()
	local yOffset = 25

    local playerName = getPlayer():getUsername()

	self.labelPlayer = ISLabel:new((self.width - getTextManager():MeasureStringX(UIFont.Large, playerName)) / 2, yOffset, 25, playerName, 1, 1, 1, 1, UIFont.Large, true)
    self.labelPlayer:initialise()
    self.labelPlayer:instantiate()
    self:addChild(self.labelPlayer)
    yOffset = yOffset + 50

    -- TODO Add frame for each mini section

    local frameHeight = 50
    local yOffsetFrame = frameHeight/4

    --* Occupation *--
    self.panelOccupation = ISPanel:new(0, yOffset, self.width/2, frameHeight)        -- y = 25, test only
    self:addChild(self.panelOccupation)

    local occupationString = getText("IGUI_Occupation")
    self.labelOccupation = ISLabel:new(10, yOffsetFrame, 25, occupationString .. ": ", 1, 1, 1, 1, UIFont.Small, true)
    self.labelOccupation:initialise()
    self.labelOccupation:instantiate()
    self.panelOccupation:addChild(self.labelOccupation)

	self.comboOccupation = ISComboBox:new(self.labelOccupation:getRight() + 6, self.labelOccupation:getY(), self.width/4, 25, self, self.onChangeOccupation)
	self.comboOccupation.noSelectionText = ""
	self.comboOccupation:setEditable(true)
    self.comboOccupation:addOptionWithData("Test", nil)
	self.panelOccupation:addChild(self.comboOccupation)

    --* Status Effects *--
    self.panelStatusEffects = ISPanel:new(self.width/2, yOffset, self.width/2, frameHeight)
    self:addChild(self.panelStatusEffects)

    local statusEffectString = getText("IGUI_StatusEffect")
    self.labelStatusEffects = ISLabel:new(10, yOffsetFrame, 25, statusEffectString .. ": ", 1, 1, 1, 1, UIFont.Small, true)
    self.labelStatusEffects:initialise()
    self.labelStatusEffects:instantiate()
    self.panelStatusEffects:addChild(self.labelStatusEffects)

	self.comboStatusEffects = ISComboBox:new(self.labelStatusEffects:getRight() + 6, self.labelStatusEffects:getY(), self.width/4, 25, self, self.onChangeStatusEffect)
	self.comboStatusEffects.noSelectionText = ""
	self.comboStatusEffects:setEditable(true)
    self.comboStatusEffects:addOptionWithData("Test", nil)
	self.panelStatusEffects:addChild(self.comboStatusEffects)

    yOffset = yOffset + frameHeight

    --* Armor Bonus *--
    -- TODO add check onUpdate
    self.panelArmorBonus = ISPanel:new(0, yOffset, self.width/2, frameHeight)
    self:addChild(self.panelArmorBonus)

    local armorBonusString = getText("IGUI_ArmorBonus")
    self.labelArmorBonus = ISLabel:new(10, yOffsetFrame, 25, armorBonusString .. ": ", 1, 1, 1, 1, UIFont.Small, true)
    self.labelArmorBonus:initialise()
    self.labelArmorBonus:instantiate()
    self.panelArmorBonus:addChild(self.labelArmorBonus)


    --* Movement Bonus *--
    -- TODO add check onUpdate
    self.panelMovementBonus = ISPanel:new(self.width/2, yOffset, self.width/2, frameHeight)
    self:addChild(self.panelMovementBonus)

    local movementBonusString = getText("IGUI_MovementBonus")
    self.labelMovementBonus = ISLabel:new(10, yOffsetFrame, 25, movementBonusString .. ": ", 1, 1, 1, 1, UIFont.Small, true)
    self.labelMovementBonus:initialise()
    self.labelMovementBonus:instantiate()
    self.panelMovementBonus:addChild(self.labelMovementBonus)

    yOffset = yOffset + frameHeight


    --* Health Line *--
    local healthString = getText("IGUI_Health")
    self.labelHealth = ISLabel:new((self.width - getTextManager():MeasureStringX(UIFont.Small, healthString)) / 2, yOffset + frameHeight/4, 25, healthString, 1, 1, 1, 1, UIFont.Small, true)
    self.labelHealth:initialise()
    self.labelHealth:instantiate()
    self:addChild(self.labelHealth)

    --LEFT MINUS BUTTON

    self.btnMinusHealth = ISButton:new(2, yOffset, self.width/4, frameHeight, "-", self, self.onOptionMouseDown)
    self.btnMinusHealth.internal = "MINUS_HEALTH"
    self.btnMinusHealth:initialise()
    self.btnMinusHealth:instantiate()
    self.btnMinusHealth:setEnable(true)
    self:addChild(self.btnMinusHealth)

    --RIGHT PLUS BUTTON

    self.btnPlusHealth = ISButton:new(self.width/1.333 - 2, yOffset, self.width/4, frameHeight, "+", self, self.onOptionMouseDown)
    self.btnPlusHealth.internal = "PLUS_HEALTH"
    self.btnPlusHealth:initialise()
    self.btnPlusHealth:instantiate()
    self.btnPlusHealth:setEnable(true)
    self:addChild(self.btnPlusHealth)


    yOffset = yOffset + frameHeight


    --* Movement Line *--
    local movementString = getText("IGUI_Movement")
    self.labelMovement = ISLabel:new((self.width - getTextManager():MeasureStringX(UIFont.Small, movementString)) / 2, yOffset + frameHeight/4, 25, movementString, 1, 1, 1, 1, UIFont.Small, true)
    self.labelMovement:initialise()
    self.labelMovement:instantiate()
    self:addChild(self.labelMovement)

    --LEFT MINUS BUTTON

    self.btnMinusMovement = ISButton:new(2, yOffset, self.width/4, frameHeight, "-", self, self.onOptionMouseDown)
    self.btnMinusMovement.internal = "MINUS_HEALTH"
    self.btnMinusMovement:initialise()
    self.btnMinusMovement:instantiate()
    self.btnMinusMovement:setEnable(true)
    self:addChild(self.btnMinusMovement)

    --RIGHT PLUS BUTTON

    self.btnPlusMovement = ISButton:new(self.width/1.333 - 2, yOffset, self.width/4, frameHeight, "+", self, self.onOptionMouseDown)
    self.btnPlusMovement.internal = "PLUS_HEALTH"
    self.btnPlusMovement:initialise()
    self.btnPlusMovement:instantiate()
    self.btnPlusMovement:setEnable(true)
    self:addChild(self.btnPlusMovement)

    --------

    self.btnClose = ISButton:new(10, self.height - 35, self.width - 20, 25, getText("IGUI_Close"), self, self.onOptionMouseDown)
    self.btnClose.internal = "CLOSE"
    self.btnClose:initialise()
    self.btnClose:instantiate()
    self.btnClose:setEnable(true)
    self:addChild(self.btnClose)

end

function DiceMenu:onChangeOccupation()
	--local scriptName = self.comboAddModel:getOptionText(self.comboAddModel.selected)

end

function DiceMenu:onChangeStatusEffect()

end

function DiceMenu:onOptionMouseDown()
	--local scriptName = self.comboAddModel:getOptionText(self.comboAddModel.selected)
    self.instance:close()
end


-- function DiceMenu:initialise()
-- 	ISPanel.initialise(self)
--     self:createChildren()
-- end

function DiceMenu:setVisible(visible)
    self.javaObject:setVisible(visible)
end




function DiceMenu.OpenPanel()
	--local UI_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14

    local pnl = DiceMenu:new(50, 200, 400, 600)
    pnl:initialise()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end


--****************************--


--return DiceMenu