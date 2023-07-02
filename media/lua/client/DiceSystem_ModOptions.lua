local SETTINGS = {
    options = {
        enableColorBlind = false
    },
    names = {
        enableColorBlind = "Enable Color Blind alternative colors",
    },
    mod_id = DICE_SYSTEM_MOD_STRING,
    mod_shortname = "Pandemonium RP - Dice System"
}

local function CheckOptions()
    --* Color blindness check
    if SETTINGS.options.enableColorBlind then
        print("Color Blind colors")
        DiceSystem_Common.SetStatusEffectsColorsTable(STATUS_EFFECTS_COLORS_TABLE_ALT)
    else
        print("Normal colors")
        DiceSystem_Common.SetStatusEffectsColorsTable(STATUS_EFFECTS_COLORS_TABLE)
    end
end

if ModOptions and ModOptions.getInstance then
    local modOptions = ModOptions:getInstance(SETTINGS)

    local enableColorBlind = modOptions:getData("enableColorBlind")

    function enableColorBlind:OnApplyInGame(val)
        --print("Reapplying")
        if not val then
            DiceSystem_Common.SetStatusEffectsColorsTable(STATUS_EFFECTS_COLORS_TABLE)
        else
            DiceSystem_Common.SetStatusEffectsColorsTable(STATUS_EFFECTS_COLORS_TABLE_ALT)
        end
    end

    Events.OnGameStart.Add(CheckOptions)
else
    --print("Setting normal colors")
    DiceSystem_Common.SetStatusEffectsColorsTable(STATUS_EFFECTS_COLORS_TABLE)
end
