-- Caching stuff
local getOnlinePlayers = getOnlinePlayers
local playerBase = __classmetatables[IsoPlayer.class].__index
local getNum = playerBase.getPlayerNum
local getUsername = playerBase.getUsername
local getOnlineID = playerBase.getOnlineID
local getX = playerBase.getX
local getY = playerBase.getY
local getZ = playerBase.getZ
local isoToScreenX = isoToScreenX
local isoToScreenY = isoToScreenY
local debugWriteLog = DiceSystem_Common.DebugWriteLog


local REQUEST_LIMIT = 10

-----------------

StatusEffectsUI = ISPanel:derive("StatusEffectsUI")
StatusEffectsUI.nearPlayersStatusEffects = {}

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

    -- Init a table where we're gonna cache the status effects from nearby players
    StatusEffectsUI.nearPlayersStatusEffects = {}
    o.requestsCounter = {}         -- TODO This is to prevent a spam of syncs from users who did not initialize the mod.
    --StatusEffectsUI.instance = o
    return o
end

--************************************--

---Initialization
function StatusEffectsUI:initialise()
    ISPanel.initialise(self)
    self:addToUIManager()

    self.currPlayerUsername = self.player:getUsername()
end

function StatusEffectsUI:checkPlayerForRequest(username)

    -- TODO Add a timer, after a certain amount let's delete this user from the blacklist
    if self.requestsCounter[username] and self.requestsCounter[username] > REQUEST_LIMIT then
        return false
    end

    return true

end


function StatusEffectsUI:addRequestToCounter(username)
    if self.requestsCounter[username] then
        self.requestsCounter[username] = self.requestsCounter[username] + 1
    else
        self.requestsCounter[username] = 1
    end

end


---Render loop
function StatusEffectsUI:render()
    -- TODO TEST THIS CHECK WITH A FRESH START!!!

    if DICE_CLIENT_MOD_DATA and DICE_CLIENT_MOD_DATA[self.currPlayerUsername] and DICE_CLIENT_MOD_DATA[self.currPlayerUsername].isInitialized then
        self.zoom = getCore():getZoom(self.player:getPlayerNum())
        local statusEffectsTable = StatusEffectsUI.nearPlayersStatusEffects
        local onlinePlayers = getOnlinePlayers() -- TODO How heavy is it?

        for i = 0, onlinePlayers:size() - 1 do
            local pl = onlinePlayers:get(i)
            -- When servers are overloaded, it seems like they like to make players "disappear". That means they exists, but they're not
            -- in any square. This causes a bunch of issues here, since it needs to access getCurrentSquare in checkCanSeeClient
            if pl and pl:getCurrentSquare() ~= nil and self.player:DistTo(pl) < StatusEffectsUI.renderDistance and self.player:checkCanSeeClient(pl) then
                local userID = getOnlineID(pl)
                if statusEffectsTable[userID] == nil then
                    -- Table needs an update
                    -- TODO Delete this before releasing it
                    local username = getUsername(pl)

                    if self:checkPlayerForRequest(username) then
                        --print("Requesting update for " .. pl:getUsername())
                        sendClientCommand(DICE_SYSTEM_MOD_STRING, 'RequestUpdatedStatusEffects',
                        { username = username, userID = userID })
                        self:addRequestToCounter(username)
                    --else
                        --print("Limit exceeded for " .. pl:getUsername())
                    end
                else
                    --print("Table already present. Could be uncomplete")
                    -- Table already present (maybe not complete)
                    self:drawStatusEffect(pl, statusEffectsTable[userID])
                end
            end
        end
    --else
        --print("Waiting for init")
    end
end

---Main function ran during the render loop
---@param pl IsoPlayer
---@param statusEffects table
function StatusEffectsUI:drawStatusEffect(pl, statusEffects)
    local plNum = getNum(pl)
    local plX = getX(pl)
    local plY = getY(pl)
    local plZ = getZ(pl)
    local baseX = isoToScreenX(plNum, plX, plY, plZ) - 100
    local baseY = isoToScreenY(plNum, plX, plY, plZ) - (150 / self.zoom) - 50 + StatusEffectsUI.GetUserOffset()

    local x = baseX
    local y = baseY

    local isSecondLine = false
    for k = 1, #statusEffects do
        local v = statusEffects[k]

        -- TODO This part could be cached if we wanted.
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

----------------------
-- Static functions, to be used to set stuff from external sources

---Used to update the local status effects table
---@param userID number
---@param statusEffects table
function StatusEffectsUI.UpdateLocalStatusEffectsTable(userID, statusEffects)
    StatusEffectsUI.mainPlayer = getPlayer()
    local receivedPlayer = getPlayerByOnlineID(userID)
    local dist = StatusEffectsUI.mainPlayer:DistTo(receivedPlayer)
    if dist < StatusEffectsUI.renderDistance then
        StatusEffectsUI.nearPlayersStatusEffects[userID] = {}
        local newStatusEffectsTable = {}
        for i = 1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
            local x = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
            if statusEffects[x] ~= nil and statusEffects[x] == true then
                --print(x)
                table.insert(newStatusEffectsTable, x)
            end
        end

        if table.concat(newStatusEffectsTable) ~= table.concat(StatusEffectsUI.nearPlayersStatusEffects[userID]) then
            --print("Changing table! Some stuff is different")
            StatusEffectsUI.nearPlayersStatusEffects[userID] = newStatusEffectsTable
        --else
            --print("Same effects! No change needed")
        end
    else
        StatusEffectsUI.nearPlayersStatusEffects[userID] = {}
    end
end

---Set the colors table. Used to handle colorblind option
---@param colors table r,g,b
function StatusEffectsUI.SetColorsTable(colors)
    StatusEffectsUI.colorsTable = colors
end

---Set the Y offset for the status effects on top of the players heads
---@param offset number
function StatusEffectsUI.SetUserOffset(offset)
    StatusEffectsUI.userOffset = offset
end

---Returns the y offset for status effects
---@return number
function StatusEffectsUI.GetUserOffset()
    return StatusEffectsUI.userOffset
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
