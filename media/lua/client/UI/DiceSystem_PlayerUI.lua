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

local PlayerHandler = require("DiceSystem_PlayerHandling")
local DiceHandler = require("DiceSystem_Main")

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

    for i=1, #PLAYER_DICE_VALUES.SKILLS do
        local skill = PLAYER_DICE_VALUES.SKILLS[i]
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
            btnRoll.skill = PLAYER_DICE_VALUES.SKILLS[i]
            btnRoll:setEnable(true)
            panel:addChild(btnRoll)
        else
            local btnPlus = ISButton:new(self.width - btnWidth, 0, btnWidth, frameHeight - 2, "+", self, self.onOptionMouseDown)
            btnPlus.internal = "PLUS_SKILL"
            btnPlus.skill = PLAYER_DICE_VALUES.SKILLS[i]
            btnPlus:initialise()
            btnPlus:instantiate()
            btnPlus:setEnable(true)
            self["btnPlus" .. PLAYER_DICE_VALUES.SKILLS[i]] = btnPlus
            panel:addChild(btnPlus)

            local btnMinus = ISButton:new(self.width - btnWidth*2, 0, btnWidth, frameHeight - 2, "-", self, self.onOptionMouseDown)
            btnMinus.internal = "MINUS_SKILL"
            btnMinus.skill = PLAYER_DICE_VALUES.SKILLS[i]
            btnMinus:initialise()
            btnMinus:instantiate()
            btnMinus:setEnable(true)
            self["btnMinus" .. PLAYER_DICE_VALUES.SKILLS[i]] = btnMinus
            panel:addChild(btnMinus)

        end


        local skillPointsPanel = ISRichTextPanel:new(self.width - btnWidth* 2 - 50, 0, 100, 25)

        skillPointsPanel:initialise()
        panel:addChild(skillPointsPanel)
        skillPointsPanel.autosetheight = true
        skillPointsPanel.background = false
        skillPointsPanel:paginate()
        self["labelSkillPoints" .. skill] = skillPointsPanel




        -- local skillPointsString = string.format("%d", skillPoints)
        -- local skillPointsLabel = ISLabel:new(self.width - btnWidth*2 - 25, frameHeight/4, 25, skillPointsString, 1, 1, 1, 1, UIFont.Small, true)
        -- skillPointsLabel:initialise()
        -- skillPointsLabel:instantiate()
        -- self["labelSkillPoints" .. skill] = skillPointsLabel
        -- panel:addChild(skillPointsLabel)

        yOffset = yOffset + frameHeight
    end


end

function DiceMenu.OnTick()
    -- TODO Check if skill points are still not allocated
    local isInit = PlayerHandler.IsPlayerInitialized()
    local allocatedPoints = PlayerHandler.GetAllocatedSkillPoints()

    -- Show allocated points during init 
    if not isInit then
        local pointsAllocatedString = getText("IGUI_SkillPointsAllocated") .. string.format(" %d/20", allocatedPoints)
        DiceMenu.instance.labelSkillPointsAllocated:setName(pointsAllocatedString)

        DiceMenu.instance.btnConfirm:setEnable(allocatedPoints == 20)

        local comboOcc = DiceMenu.instance.comboOccupation
        local selectedOccupation = comboOcc:getOptionData(comboOcc.selected)
        PlayerHandler.SetOccupation(selectedOccupation)


        --local comboStatus = DiceMenu.instance.comboStatusEffects
        --local selectedStatus = comboStatus:getOptionData(comboStatus.selected)
        --PlayerHandler.SetStatusEffectValue(selectedStatus)
    else
        -- disable occupation choice and allocated skill points label if it's already initialized
        DiceMenu.instance.comboOccupation.disabled = true
        DiceMenu.instance.labelSkillPointsAllocated:setName("")

    end

    -- Show skill points
    for i=1, #PLAYER_DICE_VALUES.SKILLS do
        local skill = PLAYER_DICE_VALUES.SKILLS[i]
        local skillPoints = PlayerHandler.GetSkillPoints(skill)
        local bonusSkillPoints = PlayerHandler.GetBonusSkillPoints(skill)
        local skillPointsString
        if bonusSkillPoints ~= 0 then
            skillPointsString = string.format(" <RIGHT> %d <SPACE> <SPACE> <RGB:0.94,0.82,0.09> + %d", skillPoints, bonusSkillPoints)

        else
            skillPointsString = string.format(" <RIGHT> %d", skillPoints)
        end
        DiceMenu.instance["labelSkillPoints" .. skill]:setText(skillPointsString)
        DiceMenu.instance["labelSkillPoints" .. skill].textDirty = true

        -- Handles buttons to assign skill points
        if not isInit then
            DiceMenu.instance["btnMinus" .. skill]:setEnable(skillPoints ~= 0 )
            DiceMenu.instance["btnPlus" .. skill]:setEnable(skillPoints ~= 5 and allocatedPoints ~= 20)
        end
    end

    -- Write active status effects
    DiceMenu.instance.comboStatusEffects:clear()
    for i=1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
        local status = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
        local isActive = PlayerHandler.GetStatusEffectValue(status)

        local addedString = ""
        if isActive then
            addedString = "[X] "
        end

        DiceMenu.instance.comboStatusEffects:addOptionWithData(addedString .. getText("IGUI_StsEfct_" .. status), status)
    end

    -- todo armor bonus test only
    DiceMenu.instance.panelArmorBonus:setText(getText("IGUI_ArmorBonus",2))
    DiceMenu.instance.panelArmorBonus.textDirty = true
    DiceMenu.instance.panelMovementBonus:setText(getText("IGUI_MovementBonus", PlayerHandler:GetMovementBonus()))
    DiceMenu.instance.panelMovementBonus.textDirty = true

    local currentHealth = PlayerHandler.GetCurrentHealth()
    local maxHealth = PlayerHandler.GetMaxHealth()
    DiceMenu.instance.panelHealth:setText(getText("IGUI_Health",PlayerHandler.GetCurrentHealth(),PlayerHandler.GetMaxHealth()))
    DiceMenu.instance.panelHealth.textDirty = true
    DiceMenu.instance.btnPlusHealth:setEnable(currentHealth < maxHealth)
    DiceMenu.instance.btnMinusHealth:setEnable(currentHealth > 0)

    local totMovement = PlayerHandler.GetMaxMovement() + PlayerHandler.GetMovementBonus()
    local currMovement = PlayerHandler.GetCurrentMovement()
    DiceMenu.instance.panelMovement:setText(getText("IGUI_Movement", currMovement, totMovement))
    DiceMenu.instance.panelMovement.textDirty = true
    DiceMenu.instance.btnPlusMovement:setEnable(currMovement < totMovement)
    DiceMenu.instance.btnMinusMovement:setEnable(currMovement > 0)
end

function DiceMenu:createChildren()
	local yOffset = 40

    local playerName = getPlayer():getUsername()

	self.labelPlayer = ISLabel:new((self.width - getTextManager():MeasureStringX(UIFont.Large, playerName)) / 2, yOffset, 25, playerName, 1, 1, 1, 1, UIFont.Large, true)
    self.labelPlayer:initialise()
    self.labelPlayer:instantiate()
    self:addChild(self.labelPlayer)
    yOffset = yOffset + 50

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

    for i=1, #PLAYER_DICE_VALUES.OCCUPATIONS do
        local occ = PLAYER_DICE_VALUES.OCCUPATIONS[i]
        self.comboOccupation:addOptionWithData(getText("IGUI_Ocptn_" .. occ), occ)
    end
    local occupation = PlayerHandler.GetOccupation()
    if occupation ~= "" then
        --print(occupation)
        self.comboOccupation:select(occupation)
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
    for i=1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
        local statusEffect = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
        self.comboStatusEffects:addOptionWithData(getText("IGUI_StsEfct_" .. statusEffect), statusEffect)
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
    self.panelHealth = ISRichTextPanel:new(0, yOffset, self.width, frameHeight)
    self.panelHealth:initialise()
    self:addChild(self.panelHealth)
    self.panelHealth.autosetheight = false
    self.panelHealth.background = false
    self.panelHealth:paginate()


    --LEFT MINUS BUTTON
    self.btnMinusHealth = ISButton:new(2, 0, self.width/4, frameHeight, "-", self, self.onOptionMouseDown)
    self.btnMinusHealth.internal = "MINUS_HEALTH"
    self.btnMinusHealth:initialise()
    self.btnMinusHealth:instantiate()
    self.btnMinusHealth:setEnable(true)
    self.panelHealth:addChild(self.btnMinusHealth)

    --RIGHT PLUS BUTTON
    self.btnPlusHealth = ISButton:new(self.width/1.333 - 2, 0, self.width/4, frameHeight, "+", self, self.onOptionMouseDown)
    self.btnPlusHealth.internal = "PLUS_HEALTH"
    self.btnPlusHealth:initialise()
    self.btnPlusHealth:instantiate()
    self.btnPlusHealth:setEnable(true)
    self.panelHealth:addChild(self.btnPlusHealth)


    yOffset = yOffset + frameHeight


    --* Movement Line *--
    self.panelMovement = ISRichTextPanel:new(0, yOffset, self.width, frameHeight)
    self.panelMovement:initialise()
    self:addChild(self.panelMovement)
    self.panelMovement.autosetheight = false
    self.panelMovement.background = false
    self.panelMovement:paginate()

    --LEFT MINUS BUTTON
    self.btnMinusMovement = ISButton:new(2, 0, self.width/4, frameHeight, "-", self, self.onOptionMouseDown)
    self.btnMinusMovement.internal = "MINUS_MOVEMENT"
    self.btnMinusMovement:initialise()
    self.btnMinusMovement:instantiate()
    self.btnMinusMovement:setEnable(true)
    self.panelMovement:addChild(self.btnMinusMovement)

    --RIGHT PLUS BUTTON
    self.btnPlusMovement = ISButton:new(self.width/1.333 - 2, 0, self.width/4, frameHeight, "+", self, self.onOptionMouseDown)
    self.btnPlusMovement.internal = "PLUS_MOVEMENT"
    self.btnPlusMovement:initialise()
    self.btnPlusMovement:instantiate()
    self.btnPlusMovement:setEnable(true)
    self.panelMovement:addChild(self.btnPlusMovement)

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
        PlayerHandler.IncrementCurrentHealth()
    elseif btn.internal == 'MINUS_HEALTH' then
        PlayerHandler.DecrementCurrentHealth()
    elseif btn.internal == 'PLUS_MOVEMENT' then
        PlayerHandler.IncrementCurrentMovement()
    elseif btn.internal == 'MINUS_MOVEMENT' then
        PlayerHandler.DecrementCurrentMovement()
    elseif btn.internal == 'PLUS_SKILL' then
        --print(btn.skill)
        PlayerHandler.IncrementSkillPoint(btn.skill)
    elseif btn.internal == 'MINUS_SKILL' then
        --print(btn.skill)
        PlayerHandler.DecrementSkillPoint(btn.skill)
    elseif btn.internal == 'SKILL_ROLL' then
        --print(btn.skill)
        local points = PlayerHandler.GetFullSkillPoints(btn.skill)
        DiceHandler.Roll(btn.skill, points)
    elseif btn.internal == 'SAVE' then
        PlayerHandler.SetIsInitialized(true)
        DiceMenu.instance.btnConfirm:setEnable(false)
    elseif btn.internal == 'CLOSE' then
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
    PlayerHandler.InitModData()

    if DiceMenu.instance then
        DiceMenu.instance:closeMenu()
    end
    local pnl = DiceMenu:new(50, 200, 400, 700)
    pnl:initialise()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end


--****************************--


--return DiceMenu