local PlayerStatsHandler = {}

--This table will describe how much added bonus we should add to each skill.
-- Different naming style 'cause of IGUI crap and I don't wanna manage two naming styles
local occupationsBonusData = {
    Unemployed      = { Brutal = 1, Luck = 1, Wit = 1 },
    Artist          = { Charm = 2, Sharp = 2 },
    WageSlave       = { Charm = 2, Resolve = 1 },
    Soldier         = { Brutal = 2, Resolve = 1 },
    Frontiersmen    = { Brutal = 2, Deft = 1 },
    LawEnforcement  = { Sharp = 2, Wit = 1 },
    FirstResponders = { Sharp = 2, Resolve = 1 },
    Criminal        = { Sharp = 2, Luck = 1 },
    BlueCollar      = { Deft = 2, Sharp = 1 },
    Engineer        = { Deft = 2, Wit = 1 },
    WhiteCollar     = { Wit = 2, Resolve = 1 },
    Clinician       = { Wit = 2, Sharp = 1 },
    Academic        = { Wit = 2, Charm = 1 }
}

--------------------------------
--* Global mod data *--

local statsTable = {}
function OnConnected()
    --print("Requested global mod data")
    ModData.request(DICE_SYSTEM_MOD_STRING)
    statsTable = ModData.get(DICE_SYSTEM_MOD_STRING)
end

Events.OnConnected.Add(OnConnected)


local function copyTable(tableA, tableB)
    if not tableA or not tableB then
        return
    end
    for key, value in pairs(tableB) do
        tableA[key] = value
    end
    for key, _ in pairs(tableA) do
        if not tableB[key] then
            tableA[key] = nil
        end
    end
end

local function SyncTable(username)
    ModData.request(DICE_SYSTEM_MOD_STRING)
    local syncedTable = ModData.get(DICE_SYSTEM_MOD_STRING)
    syncedTable[username] = statsTable[username]
    sendClientCommand(getPlayer(), DICE_SYSTEM_MOD_STRING, "updatePlayerStats", { data = statsTable[username] })
end

local function ReceiveGlobalModData(key, data)
    print("Received global mod data")
    if key == DICE_SYSTEM_MOD_STRING then
        --Creating a deep copy of recieved data and storing it in local store CLIENT_GLOBALMODDATA table
        copyTable(statsTable, data)
    end

    --Update global mod data with local table (from global_mod_data.bin)
    ModData.add(DICE_SYSTEM_MOD_STRING, statsTable)
end

Events.OnReceiveGlobalModData.Add(ReceiveGlobalModData)

--------------------------------



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
    local result = false

    if diceData.allocatedPoints < 20 and diceData.skills[skill] < 5 then
        diceData.skills[skill] = diceData.skills[skill] + 1
        diceData.allocatedPoints = diceData.allocatedPoints + 1

        -- TODO I don't like this
        if skill == 'Deft' then
            PlayerStatsHandler.SetMovementBonus(diceData.skills[skill])
        end
        result = true
    end

    return result
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
    -- This is used in the prerender for our special combobox. We'll add a bit of added logic to be sure that it doesn't break
    if statsTable and PlayerStatsHandler.username and statsTable[PlayerStatsHandler.username] then
        return statsTable[PlayerStatsHandler.username].occupation
    end

    return ""
end

PlayerStatsHandler.SetOccupation = function(occupation)
    local diceData = statsTable[PlayerStatsHandler.username]
    if diceData == nil then return end

    --print("Setting occupation => " .. occupation)
    diceData.occupation = occupation
    local bonusData = occupationsBonusData[occupation]

    -- Reset diceData.skillBonus
    for k,v in pairs(diceData.skillsBonus) do
        diceData.skillsBonus[k] = 0
    end

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
PlayerStatsHandler.ToggleStatusEffectValue = function(status)
    -- Add a check in the UI to make it clear that we have selected them or something
    local diceData = statsTable[PlayerStatsHandler.username]
    if diceData.statusEffects[status] ~= nil then
        diceData.statusEffects[status] = not diceData.statusEffects[status]
    end

    -- We need to force set an update since this is gonna be visible to all players!
    SyncTable(PlayerStatsHandler.username)

    --print("Setting occupation => " .. occupation)
end

PlayerStatsHandler.GetStatusEffectValue = function(status)
    local val = statsTable[PlayerStatsHandler.username].statusEffects[status]
    --print("Status: " .. status .. ",value: " .. tostring(val))
    return val
end

PlayerStatsHandler.GetActiveStatusEffects = function()
    local diceData = statsTable[PlayerStatsHandler.username]
    local statusEffects = diceData.statusEffects
    local list = {}
    for i = 1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
        local x = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
        if statusEffects[x] ~= nil and statusEffects[x] == true then
            table.insert(list, x)
        end
    end

    return list
end

-- TODO Cache this
---Get a certain player active status effects
---@return table
PlayerStatsHandler.GetActiveStatusEffectsByUsername = function(username)
    local diceData = statsTable[username]
    --if diceData == nil then return {} end
    local statusEffects = diceData.statusEffects
    local list = {}

    for i = 1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
        local x = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
        if statusEffects[x] ~= nil and statusEffects[x] == true then
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
    local addedBonus = math.floor(deftPoints / 2)
    statsTable[PlayerStatsHandler.username].movementBonus = addedBonus
end

PlayerStatsHandler.GetMovementBonus = function()
    return statsTable[PlayerStatsHandler.username].movementBonus
end

PlayerStatsHandler.SetMaxMovement = function(movement)
    statsTable[PlayerStatsHandler.username].maxMovement = movement

    if statsTable[PlayerStatsHandler.username].currentMovement > movement then
        statsTable[PlayerStatsHandler.username].currentMovement = movement
    end
end

-- * Armor Bonus
PlayerStatsHandler.CalculateArmorBonus = function(pl)
    if statsTable == nil or statsTable[PlayerStatsHandler.username] == nil then return end

    --getBulletDefense()
    local wornItems = pl:getWornItems()
    local tempProtection = 0
    for i=1,wornItems:size() do
        local item = wornItems:get(i-1):getItem()
        if instanceof(item, "Clothing") then
            tempProtection = tempProtection + item:getBulletDefense()
        end
    end

    local scaledProtection = math.floor(tempProtection/100)

    if scaledProtection < 0 then scaledProtection = 0 end

    -- Set the correct amount of armor bonus
    statsTable[PlayerStatsHandler.username].armorBonus = scaledProtection

    -- We need to scale the movement accordingly
    PlayerStatsHandler.SetMaxMovement(PLAYER_DICE_VALUES.DEFAULT_MOVEMENT - scaledProtection)

end

--- Returns the current value of armor bonus
---@return number
PlayerStatsHandler.GetArmorBonus = function()
    if statsTable and statsTable[PlayerStatsHandler.username] then
        return statsTable[PlayerStatsHandler.username].armorBonus
    else
        return 0
    end


end


-- * Initialization

--- Creates a new ModData for a player
---@param force boolean Force initializiation for the current player
PlayerStatsHandler.InitModData = function(force)
    -- Fetch data from server
    ModData.request(DICE_SYSTEM_MOD_STRING)

    if PlayerStatsHandler.username == nil then
        PlayerStatsHandler.username = getPlayer():getUsername()
    end

    if statsTable == nil then
        --print("Stats Table is nil :(")
        statsTable = {}
    end

    if (statsTable ~= nil and statsTable[PlayerStatsHandler.username] == nil) or force then
        statsTable = {}
        statsTable[PlayerStatsHandler.username] = {
            isInitialized = false,
            occupation = "",
            statusEffects = {},

            currentHealth = PLAYER_DICE_VALUES.DEFAULT_HEALTH,
            maxHealth = PLAYER_DICE_VALUES.DEFAULT_HEALTH,

            armorBonus = 0,

            currentMovement = PLAYER_DICE_VALUES.DEFAULT_MOVEMENT,
            maxMovement = PLAYER_DICE_VALUES.DEFAULT_MOVEMENT,
            movementBonus = 0,

            allocatedPoints = 0,

            skills = {},
            skillsBonus = {}
        }

        -- Setup status effects
        for i = 1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
            local x = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
            statsTable[PlayerStatsHandler.username].statusEffects[x] = false
        end

        -- Setup skills
        for i = 1, #PLAYER_DICE_VALUES.SKILLS do
            local x = PLAYER_DICE_VALUES.SKILLS[i]
            statsTable[PlayerStatsHandler.username].skills[x] = 0
            statsTable[PlayerStatsHandler.username].skillsBonus[x] = 0
        end


        PlayerStatsHandler.CalculateArmorBonus(getPlayer())


        sendClientCommand(getPlayer(), DICE_SYSTEM_MOD_STRING, "updatePlayerStats",
            { data = statsTable[PlayerStatsHandler.username] })
       --print("DiceSystem: initialized player")
    elseif statsTable[PlayerStatsHandler.username] ~= nil then
        --print("DiceSystem: Player already initialized")
    else
        error("DiceSystem: Global mod data is broken")
    end
end

---Set if player has finished their setup via the UI
---@param val boolean
PlayerStatsHandler.SetIsInitialized = function(val)
    -- Syncs it with server
    statsTable[PlayerStatsHandler.username].isInitialized = val
    if val then
        SyncTable(PlayerStatsHandler.username)
    end
end

PlayerStatsHandler.IsPlayerInitialized = function()
    if statsTable[PlayerStatsHandler.username] == nil then
        --error("Couldn't find player dice data!")
        return
    end


    local isInit = statsTable[PlayerStatsHandler.username].isInitialized

    if isInit == nil then
        return false
    end

    return isInit
end

--* Admin functions *--

---Start cleaning process for a specific user
---@param userID any
PlayerStatsHandler.CleanModData = function(userID)
    sendClientCommand(DICE_SYSTEM_MOD_STRING, "resetDiceData", { userID = userID })
    --statsTable[username] = nil
    --SyncTable(username)
end

PlayerStatsHandler.SetUser = function(user)
    PlayerStatsHandler.username = user
    statsTable = ModData.get(DICE_SYSTEM_MOD_STRING)
end

PlayerStatsHandler.CheckDataPresence = function(username)
    statsTable = ModData.get(DICE_SYSTEM_MOD_STRING)
    if statsTable[username] then return true else return false end
end
---------------


-- Various events handling
Events.OnGameStart.Add(PlayerStatsHandler.InitModData)
Events.OnPlayerDeath.Add(PlayerStatsHandler.CleanModData)
Events.OnClothingUpdated.Add(PlayerStatsHandler.CalculateArmorBonus)

return PlayerStatsHandler
