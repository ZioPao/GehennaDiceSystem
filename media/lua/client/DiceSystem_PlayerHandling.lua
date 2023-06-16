--This table will describe how much added bonus we should add to each skill.

-- Different naming style 'cause of IGUI crap and I don't wanna manage two naming styles
local occupationsBonusData = {
    Medic = {},
    PeaceOfficer = {},
    Soldier = {resolve = 1, sharp = 2},
    Outlaw = {},
    Artisan = {}
}

--------------------------------
local PlayerStatsHandler = {}


---Get the amount of points for a specific skill.
---@param skill string
---@return number
PlayerStatsHandler.GetSkillPoints = function(skill)

    --print("DiceSystem: playerHandler searching for skill " .. skill)
    local diceData = getPlayer():getModData()['DiceSystem']
    if diceData == nil then
        print("DiceSystem: modData is nil, can't return skill point value")
        return -1
     end

     local points = diceData.skills[skill]
     if points ~= nil then
        return points
    else
        return -1
    end

end

PlayerStatsHandler.GetAllocatedSkillPoints = function()

    local diceData = getPlayer():getModData()['DiceSystem']

    if diceData == nil then
        print("DiceSystem: modData is nil, can't return skill point value")
        return -1
     end

     local allocatedPoints = diceData.allocatedPoints
     if allocatedPoints ~= nil then return allocatedPoints else return -1 end


end

---comment
---@param val any
PlayerStatsHandler.SetIsInitialized = function(val)
    getPlayer():getModData()['DiceSystem'].isInitialized = val
end

PlayerStatsHandler.SetMovementBonus = function(deftPoints)
    -- Movement starts at 5
    local addedBonus = math.floor(deftPoints/2)
    getPlayer():getModData()['DiceSystem'].movementBonus = addedBonus
end

PlayerStatsHandler.GetMovementBonus = function()

    return getPlayer():getModData()['DiceSystem'].movementBonus

end

PlayerStatsHandler.SetOccupation = function(occupation)
    getPlayer():getModData()['DiceSystem'].occupation = occupation
end

PlayerStatsHandler.IncrementSkillPoint = function(skill)
    print("DiceSystem: adding to skill " .. skill)
    local diceData = getPlayer():getModData()['DiceSystem']

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
    local diceData = getPlayer():getModData()['DiceSystem']

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

PlayerStatsHandler.IsPlayerInitialized = function()

    local isInit = getPlayer():getModData()['DiceSystem'].isInitialized

    if isInit == nil then
        return false
    end

    return isInit

end


PlayerStatsHandler.GetOccupationBonus = function(occupation, skill)
    if occupationsBonusData[occupation][skill] ~= nil then
        return occupationsBonusData[occupation][skill]
    end
    return 0
end

--- Creates a new ModData for a player
PlayerStatsHandler.InitModData = function(force)
    -- TODO This should run when a player gets created for the first time, or if he doesn't have DiceSystem mod data.
    local modData = getPlayer():getModData()

    if modData['DiceSystem'] == nil or force then
        print("DiceSystem: creating mod data")
        modData['DiceSystem'] = {
            isInitialized = false,
            occupation = "",
            statusEffects = {""},
            health = 5,
            armorBonus = 0,
            movement = 5,
            movementBonus = 0,

            allocatedPoints = 0,

            skills = {
                Charm = 0,
                Brutal = 0,
                Resolve = 0,
                Sharp = 0,
                Deft = 0,
                Wit = 0,
                Luck = 0
            }
        }
    end
end

PlayerStatsHandler.CleanModData = function()
    getPlayer():getModData()['DiceSystem'] = nil
end

PlayerStatsHandler.SendData = function()
    -- TODO an admin should be able to "ping" another client and ask him to send the data. Or use global mod data and be done with it

end


-- Various events handling
Events.OnGameStart.Add(PlayerStatsHandler.InitModData)
Events.OnPlayerDeath.Add(PlayerStatsHandler.CleanModData)


return PlayerStatsHandler