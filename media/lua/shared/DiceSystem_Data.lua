DICE_SYSTEM_MOD_STRING = "PandemoniumDiceSystem"
PLAYER_DICE_VALUES = {
    STATUS_EFFECTS = { "Stable", "Wounded", "Bleeding", "Prone", "Unconscious" },
    OCCUPATIONS = { "Medic", "PeaceOfficer", "Soldier", "Outlaw", "Artisan" },
    SKILLS = { "Charm", "Brutal", "Resolve", "Sharp", "Deft", "Wit", "Luck" }
}
STATUS_EFFECTS_COLORS_TABLE = {
    Stable = { r = 0, g = 0.68, b = 0.94 },
    Wounded = { r = 0.95, g = 0.35, b = 0.16 },
    Bleeding = { r = 0.66, g = 0.15, b = 0.18 },
    Prone = { r = 0.04, g = 0.58, b = 0.27 },
    Unconscious = { r = 0.57, g = 0.15, b = 0.56 }
}

-- Used for color blind users
STATUS_EFFECTS_COLORS_TABLE_ALT = {
    Stable = { r = 0.17, g = 0.94, b = 0.45 },   -- #2CF074
    Wounded = { r = 0.46, g = 0.58, b = 0.23 },  -- #75943A
    Bleeding = { r = 0.56, g = 0.15, b = 0.25 }, -- #8F263F
    Prone = { r = 0.35, g = 0.49, b = 0.64 },    -- #5A7EA3
    Unconscious = { r = 0.96, g = 0.69, b = 0.81 } -- #F5B0CF
}


--**************************************--

DiceSystem_Common = {}

DiceSystem_Common.activeStatusEffects = {}

function DiceSystem_Common.SetStatusEffectsColorsTable(table)
    DiceSystem_Common.statusEffectsColors = table
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
        additionalMsg = "CRITICAL FAILURE! "
    elseif rolledValue == 20 then
        -- crit success
        additionalMsg = "CRITICAL SUCCESS! "
    end

    local finalValue = rolledValue + points
    local message = "Rolled " ..
    skill .. " " .. additionalMsg .. tostring(rolledValue) .. "+" .. tostring(points) .. "=" .. tostring(finalValue)

    -- send to chat
    if isClient() then
        processGeneralMessage(message)
    end

    --print(message)
    return finalValue
end
