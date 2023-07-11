-- Caching stuff
local getOnlinePlayers = getOnlinePlayers

local playerBase = __classmetatables[IsoPlayer.class].__index
local getNum = playerBase.getPlayerNum
local getUsername = playerBase.getUsername
local getX = playerBase.getX
local getY = playerBase.getY
local getZ = playerBase.getZ


local isoToScreenX = isoToScreenX
local isoToScreenY = isoToScreenY

-----------------

StatusEffectsUI = ISPanel:derive("StatusEffectsUI")
StatusEffectsUI.nearPlayersStatusEffects = {}

function StatusEffectsUI:drawStatusEffect(pl, statusEffectsTable)
    local plNum = getNum(pl)
    local plX = getX(pl)
    local plY = getY(pl)
    local plZ = getZ(pl)

    local baseX = isoToScreenX(plNum, plX, plY, plZ) - 150
    local baseY = isoToScreenY(plNum, plX, plY, plZ) - (150 / self.zoom)
    local x = baseX
    local y = baseY

    local isSecondLine = false
    for k = 1, #statusEffectsTable do
        local v = statusEffectsTable[k]
        local stringToPrint = string.format("[%s]", v)
        --print(stringToPrint)
        if k > 3 and isSecondLine == false then
            y = y + getTextManager():MeasureStringY(UIFont.NewMedium, stringToPrint)
            x = baseX
            isSecondLine = true
        end

        local color = DiceSystem_Common.statusEffectsColors[v]

        -- The first DrawText is to simulate a drop shadow to help readability
        self:drawText(stringToPrint, x - 2, y - 2, 0, 0, 0, 0.5, UIFont.NewMedium)
        self:drawText(stringToPrint, x, y, color.r, color.g, color.b, 1, UIFont.NewMedium)
        x = x + getTextManager():MeasureStringX(UIFont.NewMedium, stringToPrint) + 10
    end
end

function StatusEffectsUI:render()
    self.zoom = getCore():getZoom(self.player:getPlayerNum())
    local statusEffectsTable = StatusEffectsUI.nearPlayersStatusEffects

    --self:drawStatusEffect(self.player, PlayerHandler.GetActiveStatusEffectsByUsername(getUsername(self.player)))
    local onlinePlayers = getOnlinePlayers()        -- TODO How heavy is it?

    for i=0, onlinePlayers:size() - 1 do
        local pl = onlinePlayers:get(i)
        if pl and self.player:DistTo(pl) < StatusEffectsUI.renderDistance and self.player:checkCanSeeClient(pl) then
            local userID = pl:getOnlineID()
            if statusEffectsTable[userID] == nil or statusEffectsTable[userID] == {} then
                --print("Requesting update!")
                local username = pl:getUsername()
                sendClientCommand(DICE_SYSTEM_MOD_STRING, 'RequestUpdatedStatusEffects', {username = username, userID = userID})
            else
                self:drawStatusEffect(pl, statusEffectsTable[userID])
            end

        end
    end



end

function StatusEffectsUI:initialise()
    ISPanel.initialise(self)
    self:addToUIManager()
    self:bringToTop()
end

function StatusEffectsUI.UpdateLocalStatusEffectsTable(userID, statusEffectsTable)
    StatusEffectsUI.mainPlayer = getPlayer()
    local receivedPlayer = getPlayerByOnlineID(userID)
    local dist = StatusEffectsUI.mainPlayer:DistTo(receivedPlayer)
    if dist < StatusEffectsUI.renderDistance then
        StatusEffectsUI.nearPlayersStatusEffects[userID] = {}
        local newStatusEffectsTable = {}
        for i = 1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
            local x = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
            if statusEffectsTable[x] ~= nil and statusEffectsTable[x] == true then
                print(x)
                table.insert(newStatusEffectsTable, x)
            end
        end

        if table.concat(newStatusEffectsTable) ~= table.concat(StatusEffectsUI.nearPlayersStatusEffects[userID]) then
            print("Changing table! Some stuff is different")
            StatusEffectsUI.nearPlayersStatusEffects[userID] = newStatusEffectsTable
        else
            print("Same effects! No change needed")
        end
    else
        StatusEffectsUI.nearPlayersStatusEffects[userID] = {}

        -- for i=1, #StatusEffectsUI.nearPlayersUserIds do
        --     local idInTable = StatusEffectsUI.nearPlayersUserIds[i]
        --     if idInTable == userID then
        --         table.remove(StatusEffectsUI.nearPlayersUserIds, i)
        --         break
        --     end
        -- end

    end
end

function StatusEffectsUI.SetColorsTable(table)
    StatusEffectsUI.colorsTable = table
end

--************************************--

function StatusEffectsUI:new()
    local o = ISPanel:new(0, 0, 0, 0)
    setmetatable(o, self)
    self.__index    = self

    o.player        = getPlayer()
    o.zoom          = 1
    o.visibleTarget = o
    o:setAlwaysOnTop(false)
    o:initialise()
    return o
end

--************************************--
-- Setup Status Effects UI
if isClient() then
    local function InitStatusEffectsUI()
        StatusEffectsUI.renderDistance = SandboxVars.PandemoniumDiceSystem.RenderDistanceStatusEffects
        StatusEffectsUI:new()
    end
    Events.OnGameStart.Add(InitStatusEffectsUI)
end
