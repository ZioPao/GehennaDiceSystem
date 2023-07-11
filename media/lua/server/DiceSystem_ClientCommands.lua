local PlayersDiceData = {}
local ModDataCommands = {}


---Gets a FULL table from a client. Extremely heavy
---@param playerObj any
---@param args any
function ModDataCommands.UpdatePlayerStats(playerObj, args)
	--print("Syncing player data for " .. args.username)
	if PlayersDiceData == nil then return end
	if args == nil then
		args = {
			data = {},
			username = playerObj:getUsername()
		}
	end

	PlayersDiceData[args.username] = args.data
	ModData.add(DICE_SYSTEM_MOD_STRING, PlayersDiceData)

	-- NO NO NO NO NEVER DO THIS IF WE'RE GONNA USE IT ON BIG SERVERS!!!!
	--ModData.transmit(DICE_SYSTEM_MOD_STRING)

end

function ModDataCommands.ResetDiceData(_, args)
	local receivingPl = getPlayerByOnlineID(args.userID)
	sendServerCommand(receivingPl, DICE_SYSTEM_MOD_STRING, "ReceiveResetDiceData", {})
end



function ModDataCommands.RequestUpdatedStatusEffects(playerObj, args)


	-- TODO This should be a listener!

	-- TODO Search in MOD DATA
	local statusEffectsTable = PlayersDiceData[args.username].statusEffects
	local userID = args.userID

	sendServerCommand(playerObj, DICE_SYSTEM_MOD_STRING, 'ReceiveUpdatedStatusEffects', {userID = userID, statusEffectsTable=statusEffectsTable})
	-- TODO Check players near playerObj, fetch ONLY those status effects
	-- base it on SandboxVars.PandemoniumDiceSystem.RenderDistanceStatusEffects



	--PlayersDiceData[args.username].statusEffects
	-- todo send updated values of status effects... in form of enum to lessen the load maybe
end



-----------------------------------




--* Some stuff will be set in stone after initialization *--






function ModDataCommands.SetMaxHealth(_, args)
	local maxHealth = args.maxHealth
	PlayersDiceData[args.username].maxHealth = maxHealth
end


function ModDataCommands.SetSkills(_, args)
	local skillsTable = args.skillsTable
	PlayersDiceData[args.username].skills = skillsTable
end

---Set occupation and related bonus points
---@param _ any
---@param args any
function ModDataCommands.SetOccupation(_, args)
	local occupation = args.occupation
	local skillsBonus = args.skillsBonus

	PlayersDiceData[args.username].occupation = occupation
	PlayersDiceData[args.username].skillsBonus = skillsBonus

end

--------------------------------
--* Stuff that can be updated during the game, after init *--

function ModDataCommands.UpdateCurrentHealth(_, args)
	local currentHealth = args.currentHealth
	PlayersDiceData[args.username].currentHealth = currentHealth
end

function ModDataCommands.UpdateCurrentMovement(_, args)
	local currentMovement = args.currentMovement
	PlayersDiceData[args.username].currentMovement = currentMovement
end

function ModDataCommands.UpdateMaxMovement(_, args)
	local maxMovement = args.maxMovement
	PlayersDiceData[args.username].maxMovement = maxMovement
end

function ModDataCommands.UpdateMovementBonus(_, args)
	local movementBonus = args.movementBonus
	PlayersDiceData[args.username].movementBonus = movementBonus
end

function ModDataCommands.UpdateArmorBonus(_, args)
	local armorBonus = args.armorBonus
	PlayersDiceData[args.username].armorBonus = armorBonus
end

function ModDataCommands.UpdateStatusEffect(_, args)

	--print("Update status effect")

	local isActive = args.isActive
	local statusEffect = args.statusEffect
	local userID = args.userID
	-- print(statusEffect)
	-- print(isActive)
	PlayersDiceData[args.username].statusEffects[statusEffect] = isActive
	
	if userID then
		sendServerCommand(DICE_SYSTEM_MOD_STRING, 'SyncStatusEffects', {statusEffectsTable = PlayersDiceData[args.username].statusEffects, userID = userID})
	else
		print("Couldn't find " .. args.username)
	end
	


	--print(PlayersDiceData[args.username].statusEffects[statusEffect])
end






local function OnClientCommand(module, command, playerObj, args)
	if module ~= DICE_SYSTEM_MOD_STRING then return end
	print("Received ModData command " .. command)
	if ModDataCommands[command] and PlayersDiceData ~= nil then
		ModDataCommands[command](playerObj, args)
		ModData.add(DICE_SYSTEM_MOD_STRING, PlayersDiceData)
	end
end

Events.OnClientCommand.Add(OnClientCommand)


------------------------------
-- Handle Global Mod Data

local function OnInitGlobalModData()
	--print("Initializing global mod data")
	PlayersDiceData = ModData.getOrCreate(DICE_SYSTEM_MOD_STRING)
end
Events.OnInitGlobalModData.Add(OnInitGlobalModData)
