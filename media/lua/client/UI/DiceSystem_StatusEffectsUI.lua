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

-----------------

StatusEffectsUI = ISPanel:derive("StatusEffectsUI")

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

    return o
end

--************************************--

---Initialization
function StatusEffectsUI:initialise()
    ISPanel.initialise(self)
    self:addToUIManager()
end

---Render loop
function StatusEffectsUI:render()
    self.zoom = getCore():getZoom(self.player:getPlayerNum())
    local statusEffectsTable = StatusEffectsUI.nearPlayersStatusEffects
    local onlinePlayers = getOnlinePlayers() -- TODO How heavy is it?

    for i = 0, onlinePlayers:size() - 1 do
        local pl = onlinePlayers:get(i)
        -- When servers are overloaded, it seems like they like to make players "disappear". That means they exists, but they're not
        -- in any square. This causes a bunch of issues here, since it needs to access getCurrentSquare in checkCanSeeClient
        if pl and pl:getCurrentSquare() ~= nil and self.player:DistTo(pl) < StatusEffectsUI.renderDistance and self.player:checkCanSeeClient(pl) then
            local userID = getOnlineID(pl)
            if statusEffectsTable[userID] == nil or statusEffectsTable[userID] == {} then
                -- Table needs an update
                --print("Requesting update!")
                local username = getUsername(pl)
                sendClientCommand(DICE_SYSTEM_MOD_STRING, 'RequestUpdatedStatusEffects',
                    { username = username, userID = userID })
            else
                -- Table already present (maybe not complete)
                self:drawStatusEffect(pl, statusEffectsTable[userID])
            end
        end
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
    end
end

---Set the colors table. Used to handle colorblind option
---@param colors table r,g,b
function StatusEffectsUI.SetColorsTable(colors)
    StatusEffectsUI.colorsTable = colors
end

function StatusEffectsUI.SetUserOffset(offset)
    StatusEffectsUI.userOffset = offset
end

---Returns the y offset for status effects
---@return any
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
