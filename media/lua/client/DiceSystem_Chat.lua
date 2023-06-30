local PlayerHandler = require("DiceSystem_PlayerHandling")

DiceSystem_ChatOverride = {}
DiceSystem_ChatOverride.currentMsg = ""


local function GetStatusEffectsString(username)

    local effectsTable = PlayerHandler.GetActiveStatusEffectsByUsername(username)
    local formattedString = ""
    for i=1, #effectsTable do
        local effect = effectsTable[i]
        local color = DiceSystem_Common.statusEffectsColors[effect]
        formattedString = formattedString .. string.format(" <RGB:%.2f,%.2f,%.2f> [%s] <SPACE> <RGB:1,1,1> ", color.r, color.g, color.b, effect)

    end
    return formattedString
end


function DiceSystem_ChatOverride.getTextWithPrefix(originalFunc)
    return function(self, ...)
        local originalReturn = originalFunc(self, ...)
        self:setOverHeadSpeech(true)    -- TODO Test this with general message
        if DiceSystem_ChatOverride.currentMsg ~= "" then

            local plDescriptor = getPlayer():getDescriptor()
            local forename = plDescriptor:getForename()
            local surname = plDescriptor:getSurname()

            local statusEffectsString = GetStatusEffectsString(getPlayer():getUsername())
            local correctedMsg = string.format("<RGB:1,1,1> %s %s <SPACE> %s %s", forename, surname, statusEffectsString, DiceSystem_ChatOverride.currentMsg )
            DiceSystem_ChatOverride.currentMsg = ""
            self:setOverHeadSpeech(false)
            return correctedMsg

        end
        -- DiceSystem_Common.Roll("Deft", 19)
        --local role = getStatusEffectForMessage(self) or ""
        --     line = line:gsub("%[" .. escape_pattern(message:getAuthor()) .. "%]" .. "%:", "");

        --print(originalReturn)
        return originalReturn
    end
end

function DiceSystem_ChatOverride.Apply(class, methodName)
    local metatable = __classmetatables[class]
    local ogMethod = metatable.__index[methodName]
    metatable.__index[methodName] = DiceSystem_ChatOverride[methodName](ogMethod)
end

function DiceSystem_ChatOverride.NotifyRoll(message)
    DiceSystem_ChatOverride.currentMsg = message
    processSayMessage(message)
end

DiceSystem_ChatOverride.Apply(zombie.chat.ChatMessage.class, "getTextWithPrefix")