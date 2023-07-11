local offsets = {"-200", "-150", "-100", "-50", "0", "50", "100", "150", "200"}

local OPTIONS = {
    enableColorBlind = false,
    offsetStatusEffects = 5,       -- Should be 0
}









-- local SETTINGS = {
--     options_data = {
--         enableColorBlind = {
--             name = "Colorblind mode",
--             tooltip = "Enable colorblind alternative colors",
--             default = true,
--             --OnApplyMainMenu = OnApply
--         },
--         offsetStatusEffects = {
--             "0", "+10", "+50", "+100",
--             name = "Vertical offset for status effects",
--             tooltip = "Vertical offset for status effects on the top of players heads",
--             default = 1
--         }
--     },
--     mod_id = DICE_SYSTEM_MOD_STRING,
--     mod_shortname = "Pandemonium RP - Dice System",
--     mod_fullname = "Pandemonium RP - Dice System"
-- }






-- local SETTINGS = {
--     options = {
--         enableColorBlind = false,
--         offsetStatusEffects = 0
--     },
--     names = {
--         enableColorBlind = "Enable Color Blind alternative colors",
--         offsetStatusEffects = "Vertical offset for status effects"
--     },
--     mod_id = DICE_SYSTEM_MOD_STRING,
--     mod_shortname = "Pandemonium RP - Dice System"
-- }
local function CheckOptions()
    --* Color blindness check
    if OPTIONS.enableColorBlind then
        --print("Color Blind colors")
        DiceSystem_Common.SetStatusEffectsColorsTable(COLORS_DICE_TABLES.STATUS_EFFECTS_ALT)
    else
        --print("Normal colors")
        DiceSystem_Common.SetStatusEffectsColorsTable(COLORS_DICE_TABLES.STATUS_EFFECTS)
    end

    local amount = offsets[OPTIONS.offsetStatusEffects]
    StatusEffectsUI.SetUserOffset(tonumber(amount))
end


if ModOptions and ModOptions.getInstance then
    local modOptions = ModOptions:getInstance(OPTIONS, DICE_SYSTEM_MOD_STRING, "Pandemonium RP - Dice System")

    local enableColorBlind = modOptions:getData("enableColorBlind")
    enableColorBlind.name = "Colorblind mode"
    enableColorBlind.tooltip = "Enable colorblind alternative colors"

    function enableColorBlind:OnApplyInGame(val)
        --print("Reapplying")
        if not val then
            DiceSystem_Common.SetStatusEffectsColorsTable(COLORS_DICE_TABLES.STATUS_EFFECTS)
        else
            DiceSystem_Common.SetStatusEffectsColorsTable(COLORS_DICE_TABLES.STATUS_EFFECTS_ALT)
        end
    end

    local offsetStatusEffects = modOptions:getData("offsetStatusEffects")
    for i=1, #offsets do
        offsetStatusEffects[i] = offsets[i]
    end


    offsetStatusEffects.name = "Status Effects offset"
    offsetStatusEffects.tooltip = "Set the offset for the status effects on top of the players heads"
    function offsetStatusEffects:OnApplyInGame(val)

        local amount = offsets[val]
        StatusEffectsUI.SetUserOffset(tonumber(amount))
    end

    Events.OnGameStart.Add(CheckOptions)
else
    --print("Setting normal colors")
    DiceSystem_Common.SetStatusEffectsColorsTable(COLORS_DICE_TABLES.STATUS_EFFECTS)
    StatusEffectsUI.SetUserOffset(0)
end


