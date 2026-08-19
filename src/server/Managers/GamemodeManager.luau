-- GamemodeManager.luau
--
-- Controls which gamemode is active for the current round.
-- Does NOT own the round lifecycle.
-- RoundManager remains the main round controller.
--
-- Responsibilities:
--   • Select the next gamemode
--   • Load the active gamemode
--   • Pass round lifecycle hooks to the active gamemode
--   • Keep gamemode-specific logic outside RoundManager
--
-- The active gamemode should NOT directly control the entire round.
-- It should modify/respond to the round when necessary.

local ServerScriptService = game:GetService("ServerScriptService")

local GamemodesFolder =
	ServerScriptService.Server
		:WaitForChild("Gamemodes")

local GamemodeManager = {}

------------------------------------------------
-- Configuration
------------------------------------------------

local AVAILABLE_MODES = {
	-- "ClassicFreeze",
	"MarkedHunt",
	-- "Infected",
}

------------------------------------------------
-- State
------------------------------------------------

GamemodeManager.CurrentModeName = nil
GamemodeManager.CurrentMode = nil
GamemodeManager.CurrentModeIndex = 0

------------------------------------------------
-- Internal
------------------------------------------------

local loadedModes = {}

local function loadMode(modeName)
	if loadedModes[modeName] then
		return loadedModes[modeName]
	end

	local module = GamemodesFolder:FindFirstChild(modeName)

	if not module then
		warn(
			"GamemodeManager: Gamemode module not found:",
			modeName
		)

		return nil
	end

	local success, result = pcall(function()
		return require(module)
	end)

	if not success then
		warn(
			"GamemodeManager: Failed to load",
			modeName,
			result
		)

		return nil
	end

	loadedModes[modeName] = result

	return result
end

------------------------------------------------
-- Mode Selection
------------------------------------------------

function GamemodeManager:GetAvailableModes()
	local modes = {}

	for _, modeName in ipairs(AVAILABLE_MODES) do
		table.insert(modes, modeName)
	end

	return modes
end

function GamemodeManager:SelectNextMode()
	local availableModes = self:GetAvailableModes()

	if #availableModes == 0 then
		error("GamemodeManager: No gamemodes registered.")
	end

	------------------------------------------------
	-- Only one mode available
	------------------------------------------------

	if #availableModes == 1 then
		return availableModes[1]
	end

	self.CurrentModeIndex += 1

	------------------------------------------------
	-- Loop back to first mode
	------------------------------------------------

	if self.CurrentModeIndex > #availableModes then
		self.CurrentModeIndex = 1
	end

	return availableModes[self.CurrentModeIndex]
end

------------------------------------------------
-- Start Round
------------------------------------------------

function GamemodeManager:StartRound(context)
	------------------------------------------------
	-- Select mode
	------------------------------------------------

	local modeName = self:SelectNextMode()

	self.CurrentModeName = modeName

	------------------------------------------------
	-- Load mode
	------------------------------------------------

	local mode = loadMode(modeName)

	if not mode then
		error(
			"GamemodeManager: Unable to load mode "
				.. modeName
		)
	end

	self.CurrentMode = mode

	------------------------------------------------
	-- Mode setup
	------------------------------------------------

	if mode.Setup then
		mode:Setup(context)
	end

	if mode.Start then
		mode:Start(context)
	end

	print(
		"[GamemodeManager] Started:",
		modeName
	)
end


------------------------------------------------
-- Player Frozen
------------------------------------------------

function GamemodeManager:OnPlayerFrozen(
	context,
	player,
	freezer
)
	print(
			"[GamemodeManager] Player Frozen:",
			player and player.Name or "nil",
			"by:",
			freezer and freezer.Name or "nil",
			"Mode:",
			self.CurrentModeName
		)

	local mode = self.CurrentMode

	if not mode then
		warn(
			"[GamemodeManager] No active mode for freeze event"
		)
		return
	end

	if mode.OnPlayerFrozen then
		mode:OnPlayerFrozen(context, player, freezer)
	end
end

------------------------------------------------
-- Player Rescued
------------------------------------------------

function GamemodeManager:OnPlayerRescued(context, player, rescuer)
	print(
		"[GamemodeManager] Player Rescued:",
		player and player.Name or "nil",
		"by:",
		rescuer and rescuer.Name or "nil",
		"Mode:",
		self.CurrentModeName
	)
	local mode = self.CurrentMode

	if not mode then
		warn(
			"[GamemodeManager] No active mode for rescue event"
		)
		return
	end

	if mode.OnPlayerRescued then
		mode:OnPlayerRescued(
			context,
			player,
			rescuer
		)
	end
end

------------------------------------------------
-- Player Removed
------------------------------------------------

function GamemodeManager:OnPlayerRemoved(context, player)
	local mode = self.CurrentMode

	if not mode then
		return
	end

	if mode.OnPlayerRemoved then
		mode:OnPlayerRemoved(
			context,
			player
		)
	end
end

------------------------------------------------
-- End Round
------------------------------------------------

function GamemodeManager:EndRound(context)
	print(
		"[GamemodeManager] Ending:",
		self.CurrentModeName
	)

	local mode = self.CurrentMode

	if not mode then
		return
	end

	if mode.End then
		mode:End(context)
	end
end

------------------------------------------------
-- Cleanup
------------------------------------------------

function GamemodeManager:Cleanup(context)
	print(
		"[GamemodeManager] Cleanup:",
		self.CurrentModeName
	)

	local mode = self.CurrentMode

	if mode and mode.Cleanup then
		mode:Cleanup(context)
	end

	self.CurrentMode = nil
	self.CurrentModeName = nil
end

------------------------------------------------
-- Getters
------------------------------------------------

function GamemodeManager:GetCurrentMode()
	return self.CurrentMode
end

function GamemodeManager:GetCurrentModeName()
	return self.CurrentModeName
end

function GamemodeManager:IsMode(modeName)
	return self.CurrentModeName == modeName
end

return GamemodeManager