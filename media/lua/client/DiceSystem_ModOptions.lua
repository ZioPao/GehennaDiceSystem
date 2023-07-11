local SETTINGS = {
    options = {
        enableColorBlind = false,
        offsetStatusEffects = 0
    },
    names = {
        enableColorBlind = "Enable Color Blind alternative colors",
        offsetStatusEffects = "Vertical offset for status effects"
    },
    mod_id = DICE_SYSTEM_MOD_STRING,
    mod_shortname = "Pandemonium RP - Dice System"
}

local function CheckOptions()
    --* Color blindness check
    if SETTINGS.options.enableColorBlind then
        --print("Color Blind colors")
        DiceSystem_Common.SetStatusEffectsColorsTable(COLORS_DICE_TABLES.STATUS_EFFECTS_ALT)
    else
        --print("Normal colors")
        DiceSystem_Common.SetStatusEffectsColorsTable(COLORS_DICE_TABLES.STATUS_EFFECTS)
    end

    StatusEffectsUI.SetUserOffset(SETTINGS.options.offsetStatusEffects)
end

if ModOptions and ModOptions.getInstance then
    local modOptions = ModOptions:getInstance(SETTINGS)

    local enableColorBlind = modOptions:getData("enableColorBlind")

    function enableColorBlind:OnApplyInGame(val)
        --print("Reapplying")
        if not val then
            DiceSystem_Common.SetStatusEffectsColorsTable(COLORS_DICE_TABLES.STATUS_EFFECTS)
        else
            DiceSystem_Common.SetStatusEffectsColorsTable(COLORS_DICE_TABLES.STATUS_EFFECTS_ALT)
        end
    end

    local offsetStatusEffects = modOptions:getData("offsetStatusEffects")
    function offsetStatusEffects:OnApplyInGame(offset)
        if offset > 100 then offset = 100 end
        StatusEffectsUI.SetUserOffset(offset)
    end

    Events.OnGameStart.Add(CheckOptions)
else
    --print("Setting normal colors")
    DiceSystem_Common.SetStatusEffectsColorsTable(COLORS_DICE_TABLES.STATUS_EFFECTS)
    StatusEffectsUI.SetUserOffset(0)
end
