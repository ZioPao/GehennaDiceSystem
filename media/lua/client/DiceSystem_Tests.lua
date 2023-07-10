--!!! DEBUG ONLY


function DeleteGlobalModData()
    local PlayerHandler = require("DiceSystem_PlayerHandling")
    PlayerHandler.data = {}
    ModData.add(DICE_SYSTEM_MOD_STRING, {})

end



if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")


TestFramework.registerTestModule("UI Tests", "Do initialization", function()
    local Tests = {}
    local DiceMenu = require("UI/DiceSystem_PlayerUI")

    function Tests.OpenPlayerPanel()
        Tests.pnl = DiceMenu.OpenPanel(false)
        if Tests.pnl == nil then TestUtils.assert(false) end

        TestUtils.assert(true)
    end

    function Tests.HandleHealth()
        Tests.pnl:onOptionMouseDown({internal = 'MINUS_HEALTH'})
        Tests.pnl:onOptionMouseDown({internal = 'PLUS_HEALTH'})
    end

    function Tests.HandleMovement()
        Tests.pnl:onOptionMouseDown({internal = 'MINUS_MOVEMENT'})
        Tests.pnl:onOptionMouseDown({internal = 'PLUS_MOVEMENT'})
    end

    function Tests.SetRandomProfession()
        -- TODO Do it or it will add a null profession. Doesn't really break anything, but it's wrong
    end

    function Tests.SetRandomSkills()
        local PlayerHandler = require("DiceSystem_PlayerHandling")
        repeat
            local loops = ZombRand(5)
            local fakeBtn = {internal = 'PLUS_SKILL', skill = 'Charm'}

            for i=0, loops do
                Tests.pnl:onOptionMouseDown(fakeBtn)
            end
    
            loops = ZombRand(5)
            fakeBtn.skill = 'Brutal'
            for i=0, loops do
                Tests.pnl:onOptionMouseDown(fakeBtn)
            end
    
            loops = ZombRand(5)
            fakeBtn.skill = 'Deft'
            for i=0, loops do
                Tests.pnl:onOptionMouseDown(fakeBtn)
            end
    
            loops = ZombRand(5)
            fakeBtn.skill = 'Resolve'
            for i=0, loops do
                Tests.pnl:onOptionMouseDown(fakeBtn)
            end
    
            loops = ZombRand(5)
            fakeBtn.skill = 'Sharp'
            for i=0, loops do
                Tests.pnl:onOptionMouseDown(fakeBtn)
            end
        until PlayerHandler.GetAllocatedSkillPoints() == 20
    end

    function Tests.SaveDataAndReopen()
        Tests.pnl:onOptionMouseDown({internal='SAVE'})
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
        local fakeBtn = {internal = 'SKILL_ROLL', skill = 'Charm'}
        Tests.pnl:onOptionMouseDown(fakeBtn)
    end


    return Tests
end)