--!!! DEBUG ONLY
if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")

function DeleteGlobalModData()
    local PlayerHandler = require("DiceSystem_PlayerHandling")
    PlayerHandler.data = {}
    ModData.add(DICE_SYSTEM_MOD_STRING, {})
end

TestFramework.registerTestModule("UI Tests", "Do initialization", function()
    local Tests = {}
    local DiceMenu = require("UI/DiceSystem_PlayerUI")

    function Tests.OpenPlayerPanel()
        Tests.pnl = DiceMenu.OpenPanel(false)
        if Tests.pnl == nil then TestUtils.assert(false) end

        TestUtils.assert(true)
    end

    function Tests.HandleHealth()
        Tests.pnl:onOptionMouseDown({ internal = 'MINUS_HEALTH' })
        Tests.pnl:onOptionMouseDown({ internal = 'PLUS_HEALTH' })
    end

    function Tests.HandleMovement()
        Tests.pnl:onOptionMouseDown({ internal = 'MINUS_MOVEMENT' })
        Tests.pnl:onOptionMouseDown({ internal = 'PLUS_MOVEMENT' })
    end

    function Tests.SetRandomProfession()
        -- TODO This is not really how th UI would work, so it's not really a correct test, but it'll have to do
        local PlayerHandler = require("DiceSystem_PlayerHandling")
        local randOcc = PLAYER_DICE_VALUES.OCCUPATIONS[ZombRand(1, #PLAYER_DICE_VALUES.OCCUPATIONS)]
        PlayerHandler.SetOccupation(randOcc)
    end

    function Tests.SetRandomSkills()
        local PlayerHandler = require("DiceSystem_PlayerHandling")
        repeat
            local loops = ZombRand(5)
            local fakeBtn = { internal = 'PLUS_SKILL', skill = 'Charm' }

            for i = 0, loops do
                Tests.pnl:onOptionMouseDown(fakeBtn)
            end

            loops = ZombRand(5)
            fakeBtn.skill = 'Brutal'
            for i = 0, loops do
                Tests.pnl:onOptionMouseDown(fakeBtn)
            end

            loops = ZombRand(5)
            fakeBtn.skill = 'Deft'
            for i = 0, loops do
                Tests.pnl:onOptionMouseDown(fakeBtn)
            end

            loops = ZombRand(5)
            fakeBtn.skill = 'Resolve'
            for i = 0, loops do
                Tests.pnl:onOptionMouseDown(fakeBtn)
            end

            loops = ZombRand(5)
            fakeBtn.skill = 'Sharp'
            for i = 0, loops do
                Tests.pnl:onOptionMouseDown(fakeBtn)
            end
        until PlayerHandler.GetAllocatedSkillPoints() == 20
    end

    function Tests.SaveDataAndReopen()
        Tests.pnl:onOptionMouseDown({ internal = 'SAVE' })
        Tests.OpenPlayerPanel()
    end

    return Tests
end)

TestFramework.registerTestModule("UI Tests", "Rolls", function()
    local Tests = {}
    local DiceMenu = require("UI/DiceSystem_PlayerUI")

    function Tests.OpenPlayerPanel()
        Tests.pnl = DiceMenu.OpenPanel(false)
        if Tests.pnl == nil then TestUtils.assert(false) end

        TestUtils.assert(true)
    end

    function Tests.TryRoll()
        local randSkill = PLAYER_DICE_VALUES.SKILLS[ZombRand(1, #PLAYER_DICE_VALUES.SKILLS)]
        local fakeBtn = { internal = 'SKILL_ROLL', skill = randSkill }
        Tests.pnl:onOptionMouseDown(fakeBtn)
    end

    return Tests
end)

TestFramework.registerTestModule("Functionality Tests", "Status Effects", function()
    local Tests = {}
    local PlayerHandler = require("DiceSystem_PlayerHandling")

    function Tests.SetRandomEffects()
        for i = 1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
            local x = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
            if ZombRand(100) > 50 then
                PlayerHandler.ToggleStatusEffectValue(x)
            end
        end
    end

    return Tests
end)

TestFramework.registerTestModule("Functionality Tests", "Admin", function()
    local Tests = {}

    -- TODO Try to edit another player page


    -- TODO Try to reset a random player
    return Tests

end)
