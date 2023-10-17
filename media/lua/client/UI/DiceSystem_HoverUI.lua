-- TODO Should appear when you toggle it on via a keybind or something when hovering over a player with the mouse


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
local os_time = os.time

local UPDATE_DELAY = SandboxVars.GehennaDiceSystem.DelayUpdateStatusEffects
local PlayerHandler = require("DiceSystem_PlayerHandling")
local CommonUI = require("UI/DiceSystem_CommonUI")

-----------------

---Zomboid doesn't really DistTo. So let's have a wrapper to prevent errors
---@param localPlayer IsoPlayer
---@param onlinePlayer IsoPlayer
---@return number
local function TryDistTo(localPlayer, onlinePlayer)
    local dist = 10000000000 -- Fake number, just to prevent problems later.
    if localPlayer and onlinePlayer then
        if onlinePlayer:getCurrentSquare() ~= nil then
            dist = localPlayer:DistTo(onlinePlayer)
        end
    end

    return dist
end



------------------

HoverUI = ISCollapsableWindow:derive("HoverUI")
HoverUI.nearPlayersStatusEffects = {}


function HoverUI.Open()
    local width = 400 * CommonUI.FONT_SCALE
    local height = 400 * CommonUI.FONT_SCALE
    local pnl = HoverUI:new(100, 200, width, height)
    pnl:initialise()
    pnl:bringToTop()
end


--************************************--

function HoverUI:new(x, y, width, height)
    local o = {}
    o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.width = width
    o.height = height

    o.resizable = false

    o.variableColor = { r = 0.9, g = 0.55, b = 0.1, a = 1 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.moveWithMouse = true

    HoverUI.instance = o        -- TODO Can be multiple?
    return o
end

--************************************--

---Initialization
function HoverUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:addToUIManager()

    --self.currPlayerUsername = self.player:getUsername()
    self.sTime = os_time()
    --self.onlinePlayers = getOnlinePlayers()
    self.requestsCounter = {} -- This is to prevent a spam of syncs from users who did not initialize the mod.

end

function HoverUI:createChildren()
    print("Running create children")
    local yOffset = 40
    local pl
    if isClient() then pl = getPlayerFromUsername(PlayerHandler.username) else pl = getPlayer() end
    local plDescriptor = pl:getDescriptor()
    local playerName = DiceSystem_Common.GetForenameWithoutTabs(plDescriptor) -- .. " " .. DiceSystem_Common.GetSurnameWithoutBio(plDescriptor)

    --* Name Label *--
    CommonUI.AddNameLabel(self, playerName, yOffset)
    yOffset = yOffset + 25 + 10     -- TODO Janky

    --* Status Effects Panel *--
    local labelStatusEffectsHeight = 25 * (CommonUI.FONT_SCALE + 0.5)
    CommonUI.AddStatusEffectsPanel(self, labelStatusEffectsHeight, yOffset)
    yOffset = yOffset + labelStatusEffectsHeight + 25

    --local xFrameMargin = 10 * CommonUI.FONT_SCALE
    --local comboBoxHeight = 25       -- TODO This should scale?
    --local marginPanelTop = (frameHeight/4)

    local frameHeight = 50

    --* Health *--
    CommonUI.AddPanel(self, "panelHealth", self.width / 2, frameHeight, 0, yOffset)

    --* Armor Class *--
    CommonUI.AddPanel(self, "panelArmorClass", self.width / 2, frameHeight, self.width / 2, yOffset)


end

function HoverUI:render()
    ISCollapsableWindow.render(self)

    self.panelHealth:setText("Test Health")
    self.panelHealth.textDirty = true

    self.panelArmorClass:setText("Test Armor Class")
    self.panelArmorClass.textDirty = true
end

---Render loop
--function HoverUI:render()
    -- if DICE_CLIENT_MOD_DATA == nil or DICE_CLIENT_MOD_DATA[self.currPlayerUsername] == nil then return end
    -- if DICE_CLIENT_MOD_DATA[self.currPlayerUsername].isInitialized == false then return end

    -- self.zoom = getCore():getZoom(self.player:getPlayerNum())
    -- local statusEffectsTable = StatusEffectsUI.nearPlayersStatusEffects

    -- -- Check timer and update if it's over
    -- local cTime = os_time()
    -- local shouldUpdate = false
    -- if cTime > self.sTime + UPDATE_DELAY then
    --     shouldUpdate = true
    --     self.onlinePlayers = getOnlinePlayers()
    --     self.sTime = os_time()
    -- end

    -- for i = 0, self.onlinePlayers:size() - 1 do
    --     local pl = self.onlinePlayers:get(i)
    --     -- When servers are overloaded, it seems like they like to make players "disappear". That means they exists, but they're not
    --     -- in any square. This causes a bunch of issues here, since it needs to access getCurrentSquare in checkCanSeeClient
    --     if pl and TryDistTo(self.player, pl) < StatusEffectsUI.renderDistance then
    --         local userID = getOnlineID(pl)
    --         if shouldUpdate then
    --             local username = getUsername(pl)
    --             print("Updating for " ..username)
    --             --print("Requesting update for " .. pl:getUsername())
    --             sendClientCommand(DICE_SYSTEM_MOD_STRING, 'RequestUpdatedStatusEffects',
    --                 { username = username, userID = userID })
    --         end

    --         -- Player is visible and their data is present locally
    --         if self.player:checkCanSeeClient(pl) and statusEffectsTable[userID] then
    --             self:drawStatusEffect(pl, statusEffectsTable[userID])
    --         end
    --     end
    -- end
--end

-- ---Main function ran during the render loop
-- ---@param pl IsoPlayer
-- ---@param statusEffects table
-- function StatusEffectsUI:drawStatusEffect(pl, statusEffects)
--     local plNum = getNum(pl)
--     local plX = getX(pl)
--     local plY = getY(pl)
--     local plZ = getZ(pl)
--     local baseX = isoToScreenX(plNum, plX, plY, plZ) - 100
--     local baseY = isoToScreenY(plNum, plX, plY, plZ) - (150 / self.zoom) - 50 + StatusEffectsUI.GetUserOffset()

--     local x = baseX
--     local y = baseY

--     local isSecondLine = false
--     for k = 1, #statusEffects do
--         local v = statusEffects[k]

--         -- OPTIMIZE This part could be cached if we wanted.
--         local stringToPrint = string.format("[%s]", v)
--         --print(stringToPrint)
--         if k > 3 and isSecondLine == false then
--             y = y + getTextManager():MeasureStringY(UIFont.NewMedium, stringToPrint)
--             x = baseX
--             isSecondLine = true
--         end

--         local color = DiceSystem_Common.statusEffectsColors[v]

--         -- The first DrawText is to simulate a drop shadow to help readability
--         self:drawText(stringToPrint, x - 2, y - 2, 0, 0, 0, 0.5, UIFont.NewMedium)
--         self:drawText(stringToPrint, x, y, color.r, color.g, color.b, 1, UIFont.NewMedium)
--         x = x + getTextManager():MeasureStringX(UIFont.NewMedium, stringToPrint) + 10
--     end
-- end

----------------------
-- Static functions, to be used to set stuff from external sources

---Used to update the local status effects table
-- ---@param userID number
-- ---@param statusEffects table
-- function StatusEffectsUI.UpdateLocalStatusEffectsTable(userID, statusEffects)
--     StatusEffectsUI.mainPlayer = getPlayer()
--     local receivedPlayer = getPlayerByOnlineID(userID)
--     local dist = TryDistTo(StatusEffectsUI.mainPlayer, receivedPlayer)
--     if dist < StatusEffectsUI.renderDistance then
--         StatusEffectsUI.nearPlayersStatusEffects[userID] = {}
--         local newStatusEffectsTable = {}
--         for i = 1, #PLAYER_DICE_VALUES.STATUS_EFFECTS do
--             local x = PLAYER_DICE_VALUES.STATUS_EFFECTS[i]
--             if statusEffects[x] ~= nil and statusEffects[x] == true then
--                 --print(x)
--                 table.insert(newStatusEffectsTable, x)
--             end
--         end

--         if table.concat(newStatusEffectsTable) ~= table.concat(StatusEffectsUI.nearPlayersStatusEffects[userID]) then
--             --print("Changing table! Some stuff is different")
--             StatusEffectsUI.nearPlayersStatusEffects[userID] = newStatusEffectsTable
--             --else
--             --print("Same effects! No change needed")
--         end
--     else
--         StatusEffectsUI.nearPlayersStatusEffects[userID] = {}
--     end
-- end

-- ---Set the colors table. Used to handle colorblind option
-- ---@param colors table r,g,b
-- function StatusEffectsUI.SetColorsTable(colors)
--     StatusEffectsUI.colorsTable = colors
-- end

-- ---Set the Y offset for the status effects on top of the players heads
-- ---@param offset number
-- function StatusEffectsUI.SetUserOffset(offset)
--     StatusEffectsUI.userOffset = offset
-- end

-- ---Returns the y offset for status effects
-- ---@return number
-- function StatusEffectsUI.GetUserOffset()
--     return StatusEffectsUI.userOffset
-- end

--************************************--

--!! BEGONE !!--

-- Setup Status Effects UI
-- if isClient() then
--     local function InitStatusEffectsUI()
--         StatusEffectsUI.renderDistance = SandboxVars.GehennaDiceSystem.RenderDistanceStatusEffects
--         StatusEffectsUI:new()
--     end

--     if SandboxVars.GehennaDiceSystem.ShowStatusEffects then
--         Events.OnGameStart.Add(InitStatusEffectsUI)
--     end
-- end
