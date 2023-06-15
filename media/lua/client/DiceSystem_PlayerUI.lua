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

local DiceMenu = ISPanel:derive("DiceMenu")
DiceMenu.instance = nil


function DiceMenu:new(x, y, width, height)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.width = width
    o.height = height

    o.variableColor={r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.moveWithMouse = true

    DiceMenu.instance = o
    return o
end

function DiceMenu:create()
	local yOffset = 10

    local playerName = getPlayer():getUsername()

	self.playerLabel = ISLabel:new((self.width - getTextManager():MeasureStringX(UIFont.Large, playerName)) / 2, yOffset, 25, playerName, 1, 1, 1, 1, UIFont.Large, true)
    self.playerLabel:initialise()
    self.playerLabel:instantiate()
    self:addChild(self.playerLabel)
    yOffset = yOffset + 20

    --* Occupation *--

    -- TODO Add frame for each mini section

    local occupationString = getText("IGUI_Occupation")
    local occupationLabel = ISLabel:new((self.width - getTextManager():MeasureStringX(UIFont.Medium, occupationString)) / 2, yOffset, 25, occupationString, 1, 1, 1, 1, UIFont.Medium, true)

	local occupationCombo = ISComboBox:new(occupationLabel:getRight() + 6, 0, self.width/2, 25, self, self.OnChangeOccupation)
	occupationCombo.noSelectionText = ""
	occupationCombo:setEditable(true)
	self:addChild(occupationCombo)


    --------

    self.closeBtn = ISButton:new(10, self.height - 35, self.width - 20, 25, "Save", self, self.OnOptionMouseDown)
    self.closeBtn.internal = "CLOSE"
    self.closeBtn:initialise()
    self.closeBtn:instantiate()
    self.closeBtn:setEnable(true)
    self:addChild(self.saveBtn)

end

function DiceMenu.OnChangeOccupation()
	--local scriptName = self.comboAddModel:getOptionText(self.comboAddModel.selected)

end

function DiceMenu.OnOptionMouseDown()
	--local scriptName = self.comboAddModel:getOptionText(self.comboAddModel.selected)

end


function DiceMenu:initialise()
	ISPanel.initialise(self)
    self:create()
end

function DiceMenu:setVisible(visible)
    self.javaObject:setVisible(visible)
end




function DiceMenu.OpenPanel()
	local UI_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14

    local pnl = DiceMenu:new(50, 200, 250 * UI_SCALE, 150 * UI_SCALE)
    pnl:initialise()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end


--****************************--


return DiceMenu