DICE_SYSTEM_MOD_STRING = "PandemoniumDiceSystem"
PLAYER_DICE_VALUES = {
    STATUS_EFFECTS = { "Stable", "Wounded", "Bleeding", "Moderate", "Severe", "Prone", "Unconscious" },
    OCCUPATIONS = { "Unemployed", "Artist", "WageSlave", "Soldier", "Frontiersmen", "LawEnforcement", "FirstResponders",
        "Criminal", "BlueCollar", "Engineer", "WhiteCollar", "Clinician", "Academic" },
    SKILLS = { "Charm", "Brutal", "Resolve", "Sharp", "Deft", "Wit", "Luck" },

    DEFAULT_HEALTH = 5,
    DEFAULT_MOVEMENT = 5,


    OCCUPATIONS_BONUS = {
        Unemployed      = { Brutal = 1, Luck = 1, Wit = 1 },
        Artist          = { Charm = 2, Sharp = 1 },
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
}
COLORS_DICE_TABLES = {
    -- Normal colors for status effects
    STATUS_EFFECTS     = {
        Stable = { r = 0, g = 0.68, b = 0.94 },
        Wounded = { r = 0.95, g = 0.35, b = 0.16 },
        Bleeding = { r = 0.66, g = 0.15, b = 0.18 },
        Moderate = { r = 1, g = 1, b = 1 },
        Severe = { r = 1, g = 1, b = 1 },
        Prone = { r = 0.04, g = 0.58, b = 0.27 },
        Unconscious = { r = 0.57, g = 0.15, b = 0.56 }
    },

    -- Used for color blind users
    STATUS_EFFECTS_ALT = {
        Stable = { r = 0.17, g = 0.94, b = 0.45 },     -- #2CF074
        Wounded = { r = 0.46, g = 0.58, b = 0.23 },    -- #75943A
        Bleeding = { r = 0.56, g = 0.15, b = 0.25 },   -- #8F263F
        Moderate = { r = 1, g = 1, b = 1 },            -- only white
        Severe = { r = 1, g = 1, b = 1 },              -- only white
        Prone = { r = 0.35, g = 0.49, b = 0.64 },      -- #5A7EA3
        Unconscious = { r = 0.96, g = 0.69, b = 0.81 } -- #F5B0CF
    }
}

--**************************************--

DiceSystem_Common = {}

---Assign the correct color table for status effects
---@param colorsTable table
function DiceSystem_Common.SetStatusEffectsColorsTable(colorsTable)
    DiceSystem_Common.statusEffectsColors = colorsTable
end

--- Do a roll for a specific skill and print the result into chat. If something goes
---@param skill string
---@param points number
---@return number
function DiceSystem_Common.Roll(skill, points)
    local rolledValue = ZombRand(20) + 1
    local additionalMsg = ""
    if rolledValue == 1 then
        -- crit fail
        additionalMsg = "<SPACE> <RGB:1,0,0> CRITICAL FAILURE! "
    elseif rolledValue == 20 then
        -- crit success
        additionalMsg = "<SPACE> <RGB:0,1,0> CRITICAL SUCCESS! "
    end

    local finalValue = rolledValue + points
    local message = "(||DICE_SYSTEM_MESSAGE||) rolled " ..
        skill .. " " .. additionalMsg .. tostring(rolledValue) .. "+" .. tostring(points) .. "=" .. tostring(finalValue)

    -- send to chat
    if isClient() then
        DiceSystem_ChatOverride.NotifyRoll(message)
    end

    return finalValue
end

if isDebugEnabled() then
    ---Writes a log in the console ONLY if debug is enabled
    ---@param text string
    function DiceSystem_Common.DebugWriteLog(text)
        --writeLog("DiceSystem", text)
        print("[DiceSystem] " .. text)
    end
else
    ---Placeholder, to prevent non essential calls
    function DiceSystem_Common.DebugWriteLog()
        return
    end
end
