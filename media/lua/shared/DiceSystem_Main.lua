DICE_SYSTEM_MOD_STRING = "PandemoniumDiceSystem"

local Dice = {}


--- Do a roll for a specific skill and print the result into chat. If something goes
---@param skill string
---@param point number
---@return number
Dice.Roll = function(skill, points)
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
    local message = "Rolled " .. skill .. " " .. additionalMsg .. tostring(rolledValue) .. "+" .. tostring(points) .. "=" .. tostring(finalValue)
    
    -- send to chat
    if isClient() then
        processGeneralMessage(message)
    end

    print(message)
    return finalValue
end



return Dice