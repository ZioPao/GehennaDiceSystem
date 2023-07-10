if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")


TestFramework.registerTestModule("UI Tests", "Normal player", function()
    local Tests = {}
    local DiceMenu = require("UI/DiceSystem_PlayerUI")

    function Tests.OpenPlayerPanel()
        local pnl = DiceMenu.OpenPanel(false)

        if pnl then
            TestUtils.assert(true)
            pnl:close()
        else
            TestUtils.assert(false)
        end
    end
    

    function Tests.simplePass()
        print("Yes it works")
        TestUtils.assert(true)
    end


    return Tests
end
)