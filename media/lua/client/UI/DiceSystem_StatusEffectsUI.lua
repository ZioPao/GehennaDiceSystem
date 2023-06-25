-- TODO We should use some kind of asynchronous event so that we don't have to use a for in the render func

StatusEffectsUI = ISPanel:derive("StatusEffectsUI")
local PlayerHandler = require("DiceSystem_PlayerHandling")


function StatusEffectsUI:render()
    self.zoom = getCore():getZoom(self.player:getPlayerNum())

    local players
    if isClient() then
        players = getOnlinePlayers()
    else
        players = ArrayList.new()
        players:add(getPlayer())

    end

    for i=0, players:size() - 1 do
        local statusString = ""
        local pl = players:get(i)
        if pl then
            local list = PlayerHandler.GetActiveStatusEffectsByUsername(pl:getUsername())
            local x = isoToScreenX(pl:getPlayerNum(), pl:getX(), pl:getY(), pl:getZ()) - 40
            local y = isoToScreenY(pl:getPlayerNum(), pl:getX(), pl:getY(), pl:getZ()) - (150 / self.zoom)
            --print(pl:getUsername())
            for _,v in ipairs(list) do
                if statusString == "" then
                    statusString = v
                else
                    statusString = statusString .. ", " .. v
                end
            end

            if statusString == "" then
                statusString = "Test"
            end

            --print(statusString)
            self:drawText(statusString, x, y, 1, 1, 1, 1, UIFont.Large)


            --if statusString ~=
            --pl:setDisplayName(statusString +)
            --pl:setHaloNote(statusString, 255,255,255, 1000)
        end

    end



    local dx, dy = self:getScreenDelta()


    --print(x)

end
function StatusEffectsUI:getScreenDelta()
    return -getPlayerScreenLeft(self.player:getPlayerNum()), -getPlayerScreenTop(self.player:getPlayerNum())
end

function StatusEffectsUI:initialise()
	ISPanel.initialise(self)
    self:addToUIManager()
    self:bringToTop()
end

function StatusEffectsUI:new()
    local o = ISPanel:new(0, 0, 0, 0)
	--local w, h = eyeTex.eyeconOn:getWidth(), eyeTex.eyeconOn:getHeight();

	setmetatable(o, self)
	self.__index      = self;
	o.width          		= 0
	o.height         		= 0

	o.alphaStep				= 0.05;
	o.minAlpha				= 0;	 --minimum alpha value (debug)
	o.activeAlpha			= 0;	 --mode is active
	o.spotAlpha				= 0.33;  --something is in view not center view

    o.player = getPlayer()
	-- o.character       		= _character;
	-- o.player          		= _character:getPlayerNum();
	-- o.square				= _character:getCurrentSquare();
	-- o.cell            		= _character:getCell();
	-- o.perkLevel				= _character:getPerkLevel(Perks.PlantScavenging);

	o.isSearchMode    		= false;
	o.isEffectOverlay   	= false;
	o.isSpotting      		= false;

	o.iconStack				= {};
	o.iconQueue				= 0;
	o.worldIconStack		= {};

	--activating icons
	o.iconLoadRate			= 100;
	o.activeIconRadius		= 20;
	o.cellIconRadius		= 8;

	--zone data
	o.activeZones			= {};
	o.activeZoneRadius		= 10;
	o.currentZoneName		= nil;
	o.currentZone			= nil;

	o.updateTick			= 0;
	o.updateTickMax			= 200;

	o.disableTick			= 0;
	o.disableTickMax		= 15;

	--force find system
	o.currentTimestamp		= getTimestampMs();
	o.lastTimestamp			= 0;
	o.timeDelta				= 0;
	o.timeSinceFind			= 0;
	o.timeToMoveIcon		= 30000;
	o.timeToMoveIconMax		= 30000;
	o.timeToMoveIconExtra	= 1000;
	o.reducedTimePerLevel	= -1500;
	o.distanceMoveExtra		= 10;
	o.distanceMoveThreshold	= 10;

	-- o.lastUpdateX			= _character:getX();
	-- o.lastUpdateY			= _character:getY();
	o.distanceSinceFind		= 0;
	o.lastFoundX			= 0;
	o.lastFoundY			= 0;

	--sprite affinity
	o.movedIcons			= {};
	o.movedIconsSquares		= {};
	o.checkedSquares		= {};
	o.spriteCheckedSquares	= {};
	o.squareStack			= {};
	o.squareCheckRate		= 100

	--overlay
	o.radius				= 0;
	o.zoom                  = 1

	o.visibleTarget			= o;
	o:initialise()
	return o

end