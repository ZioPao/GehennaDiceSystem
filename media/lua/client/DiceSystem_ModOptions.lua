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

if ModOptions and ModOptions.getInstance then
    local modOptions = ModOptions:getInstance(SETTINGS)

    local enableColorBlind = modOptions:getData("enableColorBlind")

    function enableColorBlind:OnApplyInGame(val)
        print("Reapplying")
        if not val then
            StatusEffectsUI.SetColorsTable(STATUS_EFFECTS_COLORS_TABLE)
        else
            StatusEffectsUI.SetColorsTable(STATUS_EFFECTS_COLORS_TABLE_ALT)
        end
    end
end


local function CheckOptions()

    --* Color blindness check
    if not SETTINGS.options.enableColorBlind then
        StatusEffectsUI.SetColorsTable(STATUS_EFFECTS_COLORS_TABLE)
    else
        StatusEffectsUI.SetColorsTable(STATUS_EFFECTS_COLORS_TABLE_ALT)
    end

    
end

Events.OnGameStart.Add(CheckOptions)