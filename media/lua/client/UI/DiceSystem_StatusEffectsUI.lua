-- TODO We should use some kind of asynchronous event so that we don't have to use a for in the render func

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
StatusEffectsUI.nearPlayersUserIds = {}


local PlayerHandler = require("DiceSystem_PlayerHandling")

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

-- local plNum = getNum(pl)
-- local plX = getX(pl)
-- local plY = getY(pl)
-- local plZ = getZ(pl)

-- local list = PlayerHandler.GetActiveStatusEffectsByUsername(getUsername(pl))

-- local baseX = isoToScreenX(plNum, plX, plY, plZ) - 150
-- local baseY = isoToScreenY(plNum, plX, plY, plZ) - (150 / self.zoom)

-- local x = baseX
-- local y = baseY

-- local isSecondLine = false

-- for k = 1, #list do
--     local v = list[k]
--     local stringToPrint = string.format("[%s]", v)
--     if k > 3 and isSecondLine == false then
--         y = y + getTextManager():MeasureStringY(UIFont.NewMedium, stringToPrint)
--         x = baseX
--         isSecondLine = true
--     end

--     local color = DiceSystem_Common.statusEffectsColors[v]

--     -- The first DrawText is to simulate a drop shadow to help readability
--     self:drawText(stringToPrint, x - 2, y - 2, 0, 0, 0, 0.5, UIFont.NewMedium)
--     self:drawText(stringToPrint, x, y, color.r, color.g, color.b, 1, UIFont.NewMedium)
--     x = x + getTextManager():MeasureStringX(UIFont.NewMedium, stringToPrint) + 10
-- end
-- end

function StatusEffectsUI:render()
    self.zoom = getCore():getZoom(self.player:getPlayerNum())
    local userIdsTable = StatusEffectsUI.nearPlayersUserIds
    local statusEffectsTable = StatusEffectsUI.nearPlayersStatusEffects

    self:drawStatusEffect(self.player, PlayerHandler.GetActiveStatusEffectsByUsername(getUsername(self.player)))

    for i = 1, #userIdsTable do
        local id = userIdsTable[i]
        local pl = getPlayerByOnlineID(id)
        if pl then
            self:drawStatusEffect(pl, statusEffectsTable[id])
        end
    end



    -- local players = getOnlinePlayers()
    -- for i = 0, players:size() - 1 do
    --     local pl = players:get(i)
    --     if pl and PlayerHandler.CheckInitializedStatus(pl:getUsername()) then
    --         if self.player:getDistanceSq(pl) < StatusEffectsUI.renderDistance then
    --             self:drawStatusEffect(pl)
    --         end
    --     end
    -- end
end

function StatusEffectsUI:initialise()
    ISPanel.initialise(self)
    self:addToUIManager()
    self:bringToTop()
end

local function SetupPlayerStatusEffectsTable(username)
    StatusEffectsUI.nearPlayersStatusEffects[username] = {}
    local tableRef = StatusEffectsUI.nearPlayersStatusEffects[username]

    for i = 1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
        local statusEffect = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
        tableRef[statusEffect] = false
    end
end
function StatusEffectsUI.UpdateLocalStatusEffectsTable(userID, statusEffectsTable)
    -- if StatusEffectsUI.nearPlayersStatusEffects[username] == nil then
    --     SetupPlayerStatusEffectsTable(username)
    -- end

    -- StatusEffectsUI.nearPlayersStatusEffects[username][status] = isActive
    StatusEffectsUI.nearPlayersStatusEffects[userID] = {}
    for i = 1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
        local x = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
        if statusEffectsTable[x] ~= nil and statusEffectsTable[x] == true then
            --print(x)
            table.insert(StatusEffectsUI.nearPlayersStatusEffects[userID], x)
        end
    end

    --  = statusEffectsTable
    table.insert(StatusEffectsUI.nearPlayersUserIds, userID)
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


    -- Handler that manages syncing between clients
    local function HandleStatusEffectsSyncing()
        StatusEffectsUI.nearPlayersStatusEffects = {} -- Clean
        StatusEffectsUI.nearPlayersUserIds = {}
        local currPlayer = getPlayer()
        local players = getOnlinePlayers()
        for i = 0, players:size() - 1 do
            local pl = players:get(i)
            if currPlayer ~= pl then
                local dist = currPlayer:DistTo(pl)
                if dist < StatusEffectsUI.renderDistance then
                    local username = pl:getUsername()
                    local userID = pl:getOnlineID()
                    --print(username)
                    sendClientCommand(DICE_SYSTEM_MOD_STRING, 'RequestUpdatedStatusEffects',
                        { username = username, userID = userID })
                end
            end
        end
    end

    Events.EveryOneMinute.Add(HandleStatusEffectsSyncing)
end
