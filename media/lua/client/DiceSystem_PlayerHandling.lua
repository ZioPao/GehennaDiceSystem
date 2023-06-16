--This table will describe how much added bonus we should add to each skill.

local occupationsBonusData = {
    medic = {},
    peaceOfficer = {},
    soldier = {resolve = 1, sharp = 2},
    outlaw = {},
    artisan = {}
}

--------------------------------
local PlayerStatsHandler = {}

---comment
---@param skill any
---@return number
PlayerStatsHandler.GetSkillPoints = function(skill)

    local diceData = getPlayer():getModData()['DiceSystem']

    if diceData == nil then
        print("DiceSystem: modData is nil, can't return skill point value")
        return -1
     end

     local points = diceData[skill]
     if points ~= nil then return points else return -1 end

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
            occupation = "",
            statusEffects = {""},
            health = -1,
            movement = -1,
    
            skills = {
                charm = -1,
                brutal = -1,
                resolve = -1,
                sharp = -1,
                deft = -1,
                wit = -1,
                luck = -1
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