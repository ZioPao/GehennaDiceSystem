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

-- TODO you idiot, currentmsg will be empty for the other players. Fix this
function DiceSystem_ChatOverride.getTextWithPrefix(originalFunc)
    return function(self, ...)
        local originalReturn = originalFunc(self, ...)
        self:setOverHeadSpeech(true)    -- TODO Test this with general message

        --print(originalReturn)
        if string.find(originalReturn, '(||DICE_SYSTEM_MESSAGE||)') then
            -- TODO Scrub first part

            local match = "%[.+%]:"
            local found = string.sub(originalReturn, string.find(originalReturn, match))
            if found then
                local correctUsername = string.sub(found, 2, string.len(found) - 2)
                print(correctUsername)

                -- TODO We have their name, now we have to find the desciptor

                local onlinePlayers = getOnlinePlayers()

                for i=0, onlinePlayers:size() - 1 do
                    local player = onlinePlayers:get(i)

                    if player:getUsername() == correctUsername then
                        local plDescriptor = player:getDescriptor()
                        local forename = plDescriptor:getForename()
                        local surname = plDescriptor:getSurname()

                        local statusEffectsString = GetStatusEffectsString(correctUsername)
                        local _, endMatch = string.find(originalReturn, '(||DICE_SYSTEM_MESSAGE||)')

                        local separatedMsg = string.sub(originalReturn, endMatch + 2, string.len(originalReturn))

                        --local correctedMsg = string.format("<RGB:1,1,1> %s %s <SPACE> %s %s", forename, surname, statusEffectsString, separatedMsg)
                        local correctedMsg = string.format("%s %s", statusEffectsString, separatedMsg)
                        
                        
                        
                        self:setOverHeadSpeech(false)
                        return correctedMsg
                    end
                end

            end


        end




            --local plDescriptor = getPlayer():getDescriptor()


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