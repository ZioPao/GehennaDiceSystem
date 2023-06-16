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

local statusEffects = {"Stable", "Wounded", "Bleeding", "Prone", "Unconscious"}
local occupations = {"Medic", "PeaceOfficer", "Soldier", "Outlaw", "Artisan"}
local skills = {"Charm", "Brutal", "Resolve", "Sharp", "Deft", "Wit", "Luck"}
local PlayerHandler = require("DiceSystem_PlayerHandling")

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


function DiceMenu:fillSkillPanel()

    local yOffset = 0
    local frameHeight = 40
    local isInitialized = PlayerHandler.IsPlayerInitialized()

    for i=1, #skills do
        local skill = skills[i]
        local panel = ISPanel:new(0, yOffset, self.width, frameHeight)

        if i%2 == 0 then
            -- rgb(56, 57, 56)
            panel.backgroundColor = {r=0.22, g=0.22, b=0.22, a=1}
        else
            -- rgb(71, 56, 51)
            panel.backgroundColor = {r=0.28, g=0.22, b=0.2, a=1}

        end

        panel.borderColor = {r=0, g=0, b=0, a=1}
        self.panelSkills:addChild(panel)

        local skillString = getText("IGUI_Skill_" .. skill)
        local label = ISLabel:new(10, frameHeight/4, 25, skillString, 1, 1, 1, 1, UIFont.Small, true)
        label:initialise()
        label:instantiate()
        panel:addChild(label)


        -- Check if skill is initialized
        local skillPoints = PlayerHandler.GetSkillPoints(skill)
        local btnWidth = 100


        -- TODO This check must be related to the allocated skill points, not the skill points themselves
        if isInitialized then
            -- ROLL
            local btnRoll = ISButton:new(self.width - btnWidth * 2, 0, btnWidth * 2, frameHeight - 2, "Roll", self, self.onOptionMouseDown)
            btnRoll.internal = "SKILL_ROLL"
            btnRoll:initialise()
            btnRoll:instantiate()
            btnRoll:setEnable(true)
            panel:addChild(btnRoll)
        else
            local btnPlus = ISButton:new(self.width - btnWidth, 0, btnWidth, frameHeight - 2, "+", self, self.onOptionMouseDown)
            btnPlus.internal = "PLUS_SKILL"
            btnPlus.skill = skills[i]
            btnPlus:initialise()
            btnPlus:instantiate()
            btnPlus:setEnable(true)
            self["btnPlus" .. skills[i]] = btnPlus
            panel:addChild(btnPlus)

            local btnMinus = ISButton:new(self.width - btnWidth*2, 0, btnWidth, frameHeight - 2, "-", self, self.onOptionMouseDown)
            btnMinus.internal = "MINUS_SKILL"
            btnMinus.skill = skills[i]
            btnMinus:initialise()
            btnMinus:instantiate()
            btnMinus:setEnable(true)
            self["btnMinus" .. skills[i]] = btnMinus
            panel:addChild(btnMinus)

        end

        local skillPointsString = string.format("%d", skillPoints)
        local skillPointsLabel = ISLabel:new(self.width - btnWidth*2 - 25, frameHeight/4, 25, skillPointsString, 1, 1, 1, 1, UIFont.Small, true)
        skillPointsLabel:initialise()
        skillPointsLabel:instantiate()
        self["labelSkillPoints" .. skill] = skillPointsLabel
        panel:addChild(skillPointsLabel)

        yOffset = yOffset + frameHeight
    end


end

function DiceMenu.OnTick()
    -- TODO Check if skill points are still not allocated

    local isInit = PlayerHandler.IsPlayerInitialized()

    if not isInit then
        local allocatedPoints = PlayerHandler.GetAllocatedSkillPoints()
        local pointsAllocatedString = getText("IGUI_SkillPointsAllocated") .. string.format(" %d/20", allocatedPoints)

        DiceMenu.instance.labelSkillPointsAllocated:setName(pointsAllocatedString)
        for i=1, #skills do
            local skill = skills[i]
            local skillPoints = PlayerHandler.GetSkillPoints(skill)

            DiceMenu.instance["btnMinus" .. skill]:setEnable(skillPoints ~= 0 )
            DiceMenu.instance["btnPlus" .. skill]:setEnable(skillPoints ~= 20 and allocatedPoints ~= 20)

            local skillPointsString = string.format("%d", skillPoints)
            DiceMenu.instance["labelSkillPoints" .. skill]:setName(skillPointsString)
        end

        -- Players can finish the setup only when they've allocated all their 20 points
        DiceMenu.instance.btnConfirm:setEnable(allocatedPoints == 20)

        local comboOcc = DiceMenu.instance.comboOccupation
        local selectedOccupation = comboOcc:getOptionData(comboOcc.selected)
        PlayerHandler.SetOccupation(selectedOccupation)


        local comboStatus = DiceMenu.instance.comboStatusEffects


    else
        -- TODO Users won't be able to change their profession once it is init.
        DiceMenu.instance.comboOccupation.disabled = true
    end



    -- todo armor bonus test only
    DiceMenu.instance.panelArmorBonus:setText(getText("IGUI_ArmorBonus",2))
    DiceMenu.instance.panelMovementBonus:setText(getText("IGUI_MovementBonus", PlayerHandler:GetMovementBonus()))
end

function DiceMenu:createChildren()
	local yOffset = 40

    local playerName = getPlayer():getUsername()

	self.labelPlayer = ISLabel:new((self.width - getTextManager():MeasureStringX(UIFont.Large, playerName)) / 2, yOffset, 25, playerName, 1, 1, 1, 1, UIFont.Large, true)
    self.labelPlayer:initialise()
    self.labelPlayer:instantiate()
    self:addChild(self.labelPlayer)
    yOffset = yOffset + 50

    -- TODO Add frame for each mini section

    local frameHeight = 40
    local yOffsetFrame = frameHeight/4

    --* Occupation *--
    self.panelOccupation = ISPanel:new(0, yOffset, self.width/2, frameHeight)        -- y = 25, test only
    self.panelOccupation.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.panelOccupation)

    local occupationString = getText("IGUI_Occupation")
    self.labelOccupation = ISLabel:new(10, yOffsetFrame, 25, occupationString .. ": ", 1, 1, 1, 1, UIFont.Small, true)
    self.labelOccupation:initialise()
    self.labelOccupation:instantiate()
    self.panelOccupation:addChild(self.labelOccupation)

	self.comboOccupation = ISComboBox:new(self.labelOccupation:getRight() + 6, self.labelOccupation:getY(), self.width/4, 25, self, self.onChangeOccupation)
	self.comboOccupation.noSelectionText = ""
	self.comboOccupation:setEditable(true)

    for i=1, #occupations do
        self.comboOccupation:addOptionWithData(getText("IGUI_Ocptn_" .. occupations[i]), occupations[i])
    end

	self.panelOccupation:addChild(self.comboOccupation)

    --* Status Effects *--
    self.panelStatusEffects = ISPanel:new(self.width/2, yOffset, self.width/2, frameHeight)
    self.panelStatusEffects.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self:addChild(self.panelStatusEffects)

    local statusEffectString = getText("IGUI_StatusEffect")
    self.labelStatusEffects = ISLabel:new(10, yOffsetFrame, 25, statusEffectString .. ": ", 1, 1, 1, 1, UIFont.Small, true)
    self.labelStatusEffects:initialise()
    self.labelStatusEffects:instantiate()
    self.panelStatusEffects:addChild(self.labelStatusEffects)

	self.comboStatusEffects = ISComboBox:new(self.labelStatusEffects:getRight() + 6, self.labelStatusEffects:getY(), self.width/4, 25, self, self.onChangeStatusEffect)
	self.comboStatusEffects.noSelectionText = ""
	self.comboStatusEffects:setEditable(true)
    for i=1, #statusEffects do
        self.comboStatusEffects:addOptionWithData(getText("IGUI_StsEfct_" .. statusEffects[i]), statusEffects[i])
    end
	self.panelStatusEffects:addChild(self.comboStatusEffects)

    yOffset = yOffset + frameHeight

    --* Armor Bonus *--
    -- TODO add check onUpdate
    self.panelArmorBonus = ISRichTextPanel:new(0, yOffset, self.width/2, frameHeight)
    self.panelArmorBonus:initialise()
    self:addChild(self.panelArmorBonus)
    self.panelArmorBonus.autosetheight = false
    self.panelArmorBonus.background = true
    self.panelArmorBonus.backgroundColor = {r=0, g=0, b=0, a=0}
    self.panelArmorBonus.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.panelArmorBonus:paginate()

    --* Movement Bonus *--
    self.panelMovementBonus = ISRichTextPanel:new(self.width/2, yOffset, self.width/2, frameHeight)
    self.panelMovementBonus:initialise()
    self:addChild(self.panelMovementBonus)
    
    self.panelMovementBonus.marginLeft = 20
    self.panelMovementBonus.autosetheight = false
    self.panelMovementBonus.background = true
    self.panelMovementBonus.backgroundColor = {r=0, g=0, b=0, a=0}
    self.panelMovementBonus.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.panelMovementBonus:paginate()


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

    yOffset = yOffset + frameHeight

    --* Skill points *--

    -- TODO This is gonna be a different check to get if a player has already set up his page or not.

    local arePointsAllocated = false
    if not arePointsAllocated then

        local allocatedPoints = PlayerHandler.GetAllocatedSkillPoints()


        local pointsAllocatedString = getText("IGUI_SkillPointsAllocated") .. string.format(" %d/20", allocatedPoints)
        self.labelSkillPointsAllocated = ISLabel:new((self.width - getTextManager():MeasureStringX(UIFont.Small, pointsAllocatedString)) / 2, yOffset + frameHeight/4, 25, pointsAllocatedString, 1, 1, 1, 1, UIFont.Small, true)
        self.labelSkillPointsAllocated:initialise()
        self.labelSkillPointsAllocated:instantiate()
        self:addChild(self.labelSkillPointsAllocated)
    end

    yOffset = yOffset + frameHeight

    local panelSkillsHeight = frameHeight * 7
    self.panelSkills = ISPanel:new(0, yOffset, self.width, panelSkillsHeight)
    self:addChild(self.panelSkills)
    self:fillSkillPanel()

    Events.OnTick.Add(self.OnTick)

    --------

    if not PlayerHandler.IsPlayerInitialized() then
        self.btnConfirm = ISButton:new(10, self.height - 35, 100, 25, getText("IGUI_Save"), self, self.onOptionMouseDown)
        self.btnConfirm.internal = "SAVE"
        self.btnConfirm:initialise()
        self.btnConfirm:instantiate()
        self.btnConfirm:setEnable(true)
        self:addChild(self.btnConfirm)
    end

    self.btnClose = ISButton:new(self.width - 100 - 10, self.height - 35, 100, 25, getText("IGUI_Close"), self, self.onOptionMouseDown)
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

function DiceMenu:onOptionMouseDown(btn)
    if btn.internal == 'PLUS_HEALTH' then
        PlayerHandler.IncrementHealth()
    end

    if btn.internal == 'MINUS_HEALTH' then
        PlayerHandler.DecrementHealth()

    end

    if btn.internal == 'PLUS_MOVEMENT' then
        PlayerHandler.IncrementMovement()
    end

    if btn.internal == 'MINUS_MOVEMENT' then
        PlayerHandler.DecrementMovement()
    end

    if btn.internal == 'PLUS_SKILL' then
        --print(btn.skill)
        PlayerHandler.IncrementSkillPoint(btn.skill)
    end
    if btn.internal == 'MINUS_SKILL' then
        --print(btn.skill)
        PlayerHandler.DecrementSkillPoint(btn.skill)
    end


    if btn.internal == 'SAVE' then
        PlayerHandler.SetIsInitialized(true)
    end

    if btn.internal == 'CLOSE' then
        self:closeMenu()
    end




	--local scriptName = self.comboAddModel:getOptionText(self.comboAddModel.selected)
end

function DiceMenu:setVisible(visible)
    self.javaObject:setVisible(visible)
end

function DiceMenu:closeMenu()
    Events.OnTick.Remove(self.OnTick)
    self.instance:close()
end


function DiceMenu.OpenPanel()
	--local UI_SCALE = getTextManager():getFontHeight(UIFont.Small) / 14

    local pnl = DiceMenu:new(50, 200, 400, 700)
    pnl:initialise()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end


--****************************--


--return DiceMenu