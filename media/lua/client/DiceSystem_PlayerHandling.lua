--This table will describe how much added bonus we should add to each skill.

-- Different naming style 'cause of IGUI crap and I don't wanna manage two naming styles
local occupationsBonusData = {
    Medic = {},
    PeaceOfficer = {},
    Soldier = {Resolve = 1, Sharp = 2},
    Outlaw = {},
    Artisan = {}
}

--------------------------------
--* Global mod data *--

local statsTable = {}
function OnConnected()
    ModData.request(DICE_SYSTEM_MOD_STRING)
    statsTable = ModData.get(DICE_SYSTEM_MOD_STRING)
end
Events.OnConnected.Add(OnConnected)
--------------------------------


local PlayerStatsHandler = {}

--*  Skills handling *--

PlayerStatsHandler.GetFullSkillPoints = function(skill)
    local diceData = statsTable[PlayerStatsHandler.username]
    local points = diceData.skills[skill]
    local bonusPoints = diceData.skillsBonus[skill]

    return points + bonusPoints
    
end

---Get the amount of points for a specific skill.
---@param skill string
---@return number
PlayerStatsHandler.GetSkillPoints = function(skill)

    --print("DiceSystem: playerHandler searching for skill " .. skill)
    local diceData = statsTable[PlayerStatsHandler.username]
    if diceData == nil then
        --print("DiceSystem: modData is nil, can't return skill point value")
        return -1
     end

     local points = diceData.skills[skill]
     if points ~= nil then
        return points
    else
        return -1
    end

end

PlayerStatsHandler.IncrementSkillPoint = function(skill)
    --print("DiceSystem: adding to skill " .. skill)
    local diceData = statsTable[PlayerStatsHandler.username]

    if diceData.allocatedPoints < 20 and diceData.skills[skill] < 5 then
        diceData.skills[skill] = diceData.skills[skill] + 1
        diceData.allocatedPoints = diceData.allocatedPoints + 1

        -- TODO I don't like this
        if skill == 'Deft' then
            PlayerStatsHandler.SetMovementBonus(diceData.skills[skill])
        end
        return true
    else
        return false
    end
end

PlayerStatsHandler.DecrementSkillPoint = function(skill)
    local diceData = statsTable[PlayerStatsHandler.username]

    if diceData.skills[skill] > 0 then
        diceData.skills[skill] = diceData.skills[skill] - 1
        diceData.allocatedPoints = diceData.allocatedPoints - 1
        if skill == 'Deft' then
            PlayerStatsHandler.SetMovementBonus(diceData.skills[skill])
        end

        return true
    else
        return false
    end

end

PlayerStatsHandler.GetBonusSkillPoints = function(skill)
    local diceData = statsTable[PlayerStatsHandler.username]
    if diceData == nil then
        --print("DiceSystem: modData is nil, can't return skill point value")
        return -1
     end

     local points = diceData.skillsBonus[skill]
     if points ~= nil then
        return points
    else
        return -1
    end
end

PlayerStatsHandler.GetAllocatedSkillPoints = function()

    local diceData = statsTable[PlayerStatsHandler.username]

    if diceData == nil then
        --print("DiceSystem: modData is nil, can't return skill point value")
        return -1
     end

     local allocatedPoints = diceData.allocatedPoints
     if allocatedPoints ~= nil then return allocatedPoints else return -1 end


end

--* Occupations *--

PlayerStatsHandler.GetOccupation = function()
    return statsTable[PlayerStatsHandler.username].occupation
end

PlayerStatsHandler.SetOccupation = function(occupation)
    local diceData = statsTable[PlayerStatsHandler.username]

    --print("Setting occupation => " .. occupation)
    diceData.occupation = occupation
    local bonusData = occupationsBonusData[occupation]


    for key, bonus in pairs(bonusData) do
        diceData.skillsBonus[key] = bonus
    end
end

PlayerStatsHandler.GetOccupationBonus = function(occupation, skill)
    if occupationsBonusData[occupation][skill] ~= nil then
        return occupationsBonusData[occupation][skill]
    end
    return 0
end

--* Status Effect *--
PlayerStatsHandler.SetStatusEffectValue = function(status)
    -- if it's already in the list, let's remove it.
    -- Add a check in the UI to make it clear that we have selected them or something
    local diceData = statsTable[PlayerStatsHandler.username]
    if diceData.statusEffects[status] ~= nil then
        diceData.statusEffects[status] = not diceData.statusEffects[status]
    end
    --print("Setting occupation => " .. occupation)
end

PlayerStatsHandler.GetStatusEffectValue = function(status)
    return statsTable[PlayerStatsHandler.username].statusEffects[status]
end

PlayerStatsHandler.GetActiveStatusEffects = function()
    local diceData = statsTable[PlayerStatsHandler.username]
    local list = {}
    for i=1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
        local x = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
        if diceData.statusEffects[x] ~= nil and diceData.statusEffects[x] == true then
            table.insert(list, x)
        end
    end

    return list
end

--* Health *--
PlayerStatsHandler.GetCurrentHealth = function()
    return statsTable[PlayerStatsHandler.username].currentHealth
end

PlayerStatsHandler.GetMaxHealth = function()
    return statsTable[PlayerStatsHandler.username].maxHealth

end

PlayerStatsHandler.IncrementCurrentHealth = function()
    local diceData = statsTable[PlayerStatsHandler.username]
    if diceData.currentHealth < diceData.maxHealth then
        diceData.currentHealth = diceData.currentHealth + 1
        return true
    end

    return false
end

PlayerStatsHandler.DecrementCurrentHealth = function()
    local diceData = statsTable[PlayerStatsHandler.username]
    if diceData.currentHealth > 0 then
        diceData.currentHealth = diceData.currentHealth - 1
        return true
    end

    return false
end

--* Movement *--
PlayerStatsHandler.IncrementCurrentMovement = function()
    local diceData = statsTable[PlayerStatsHandler.username]
    if diceData.currentMovement < diceData.maxMovement + diceData.movementBonus then
        diceData.currentMovement = diceData.currentMovement + 1
        return true
    end

    return false
end

PlayerStatsHandler.DecrementCurrentMovement = function()
    local diceData = statsTable[PlayerStatsHandler.username]
    if diceData.currentMovement > 0 then
        diceData.currentMovement = diceData.currentMovement - 1
        return true
    end

    return false
end
PlayerStatsHandler.GetCurrentMovement = function()
    return statsTable[PlayerStatsHandler.username].currentMovement
end

PlayerStatsHandler.SetCurrentMovement = function(movement)
    statsTable[PlayerStatsHandler.username].currentMovement = movement
end

PlayerStatsHandler.GetMaxMovement = function()
    return statsTable[PlayerStatsHandler.username].maxMovement
end

PlayerStatsHandler.SetMovementBonus = function(deftPoints)
    -- Movement starts at 5
    --print("Setting bonus")
    local addedBonus = math.floor(deftPoints/2)
    statsTable[PlayerStatsHandler.username].movementBonus = addedBonus
end

PlayerStatsHandler.GetMovementBonus = function()

    return statsTable[PlayerStatsHandler.username].movementBonus

end


-- * Initialization

--- Creates a new ModData for a player
PlayerStatsHandler.InitModData = function(force)

    -- Fetch data from server
	ModData.request(DICE_SYSTEM_MOD_STRING)


    if PlayerStatsHandler.username == nil then
        PlayerStatsHandler.username = getPlayer():getUsername()
    end


    statsTable = ModData.get(DICE_SYSTEM_MOD_STRING)

    if (statsTable ~= nil and statsTable[PlayerStatsHandler.username] == nil) or force then
        statsTable = {}
        statsTable[PlayerStatsHandler.username] = {
            isInitialized = false,
            occupation = "",
            statusEffects = {},

            currentHealth = 5,
            maxHealth = 5,

            armorBonus = 0,

            currentMovement = 5,
            maxMovement = 5,
            movementBonus = 0,

            allocatedPoints = 0,

            skills = {},
            skillsBonus = {}
        }

        -- Setup status effects
        for i=1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
            local x = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
            statsTable[PlayerStatsHandler.username].statusEffects[x] = false
        end

        -- Setup skills
        for i=1, #PLAYER_DICE_VALUES.SKILLS do
            local x = PLAYER_DICE_VALUES.SKILLS[i]
            statsTable[PlayerStatsHandler.username].skills[x] = 0
            statsTable[PlayerStatsHandler.username].skillsBonus[x] = 0
        end

    end

end

---Set if player has finished their setup via the UI
---@param val boolean
PlayerStatsHandler.SetIsInitialized = function(val)
    statsTable[PlayerStatsHandler.username].isInitialized = val

    if val then
        sendClientCommand(getPlayer(), DICE_SYSTEM_MOD_STRING, "updatePlayerStats", {data = statsTable[PlayerStatsHandler.username]})
    end
end

PlayerStatsHandler.IsPlayerInitialized = function()

    local isInit = statsTable[PlayerStatsHandler.username].isInitialized

    if isInit == nil then
        return false
    end

    return isInit

end

--* Admin functions *--

PlayerStatsHandler.CleanModData = function()
    statsTable[PlayerStatsHandler.username] = nil
end

PlayerStatsHandler.SetUser = function(user)
    -- TODO an admin should be able to "ping" another client and ask him to send the data. Or use global mod data and be done with it
    PlayerStatsHandler.username = user
    statsTable = ModData.get(DICE_SYSTEM_MOD_STRING)
end

PlayerStatsHandler.CheckDataPresence = function(username)

    statsTable = ModData.get(DICE_SYSTEM_MOD_STRING)
    if statsTable[username] then return true else return false end
end
---------------


-- function SetStatusNote()

--     local pl = getPlayer()
--     getPlayer():setHaloNote("[Status]\n[Injured]", 255,255,255,100)
--     getPlayer():setHaloNote("\n\n\n[Injured]", 0, 255, 0, 100)

-- end

--Events.OnTick.Add(SetStatusNote)


-- Various events handling
Events.OnGameStart.Add(PlayerStatsHandler.InitModData)
Events.OnPlayerDeath.Add(PlayerStatsHandler.CleanModData)


return PlayerStatsHandler