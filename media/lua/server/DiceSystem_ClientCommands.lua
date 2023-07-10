local PlayersDiceData = {}

local ModDataCommands = {}


---Gets a FULL table from a client. Extremely heavy
---@param playerObj any
---@param args any
function ModDataCommands.UpdatePlayerStats(playerObj, args)
	if PlayersDiceData == nil then return end
	if args == nil then
		args = {
			data = nil,
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

function ModDataCommands.SetOccupation(_, args)
	local occupation = args.occupation
	local skillsBonus = args.skillsBonus

	-- TODO Set bonuses here
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

function ModDataCommands.UpdateStatusEffects(_, args)
	local statusEffects = args.statusEffects
	PlayersDiceData[args.username].statusEffects = statusEffects
end






local function OnClientCommand(module, command, playerObj, args)
	if module ~= DICE_SYSTEM_MOD_STRING then return end

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
