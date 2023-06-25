-- TODO We should use some kind of asynchronous event so that we don't have to use a for in the render func
local StatusEffectsUI = ISPanel:derive("StatusEffectsUI")
local PlayerHandler = require("DiceSystem_PlayerHandling")


function StatusEffectsUI:render()
    self.zoom = getCore():getZoom(self.player:getPlayerNum())
    local players = getOnlinePlayers()
    for i=0, players:size() - 1 do
        local statusString = ""
        local pl = players:get(i)
        if pl then
            local list = PlayerHandler.GetActiveStatusEffectsByUsername(pl:getUsername())
            local x = isoToScreenX(pl:getPlayerNum(), pl:getX(), pl:getY(), pl:getZ()) - 40
            local y = isoToScreenY(pl:getPlayerNum(), pl:getX(), pl:getY(), pl:getZ()) - (150 / self.zoom)
            for _,v in ipairs(list) do
                if statusString == "" then
                    statusString = v
                else
                    statusString = statusString .. ", " .. v
                end
            end
            self:drawText(statusString, x, y, 1, 1, 1, 1, UIFont.Large)

        end
    end
end

function StatusEffectsUI:initialise()
	ISPanel.initialise(self)
    self:addToUIManager()
    self:bringToTop()
end

--************************************--

function StatusEffectsUI:new()
    local o = ISPanel:new(0, 0, 0, 0)
	setmetatable(o, self)
	self.__index      = self

    o.player = getPlayer()
	o.zoom                  = 1
	o.visibleTarget			= o
	o:initialise()
	return o
end

--************************************--
-- Setup Status Effects UI
if isClient() then
    local function InitStatusEffectsUI()
        StatusEffectsUI:new()
    end
    Events.OnGameStart.Add(InitStatusEffectsUI)
end