local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Players =
	game:GetService("Players")

------------------------------------------------
-- SHARED
------------------------------------------------

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local Enums =
	require(Shared.Enums)

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events

local Remotes =
	Shared.Remotes

local HelpSignal =
	Remotes:WaitForChild(
		RemoteIndex.HelpSignal
	)

------------------------------------------------
-- MANAGERS
------------------------------------------------

local PlayerManager =
	require(script.Parent.PlayerManager)

local RoundStatsManager =
	require(script.Parent.RoundStatsManager)
local NotificationManager = require(script.Parent.NotificationManager)
------------------------------------------------
-- CONFIG
------------------------------------------------
local GameConfig = require(Shared.GameConfig)
local HELP_COOLDOWN = GameConfig.Round.HelpSignalCooldown
local HELP_DURATION = GameConfig.Round.HelpSignalDuration

------------------------------------------------
-- STATE
------------------------------------------------

local HelpSignalManager = {}

local Cooldowns = {}

------------------------------------------------
-- HELP
------------------------------------------------

function HelpSignalManager:RequestHelp(player)
	if not player
		or not player.Parent then

		return
	end

	------------------------------------------------
	-- Round validation
	------------------------------------------------

	local round =
		RoundStatsManager:GetRound()

	if not round
		or round.State ~= Enums.RoundState.Playing then

		return
	end

	------------------------------------------------
	-- Player must be Frozen
	------------------------------------------------

	local state =
		PlayerManager:GetState(player)

	if state ~= Enums.PlayerState.Frozen then
		return
	end

	------------------------------------------------
	-- Cooldown
	------------------------------------------------

	local now = os.clock()

	local cooldownEnd =
		Cooldowns[player] or 0

	if now < cooldownEnd then
		return
	end

	Cooldowns[player] =
		now + HELP_COOLDOWN

	------------------------------------------------
	-- Send to teammates
	------------------------------------------------

	for _, targetPlayer in ipairs(
		Players:GetPlayers()
	) do

		if targetPlayer == player then
			continue
		end

		if not targetPlayer.Parent then
			continue
		end

		------------------------------------------------
		-- Only runners receive the signal
		------------------------------------------------

		if PlayerManager:GetTeam(targetPlayer)
			~= Enums.Team.Runner then
			continue
		end
		NotificationManager:Broadcast(
			player.Name .. ": Help Me! 🥹",
			Enums.NotificationTarget.Gameplay
		)
		HelpSignal:FireClient(
			targetPlayer,
			"Show",
			player,
			HELP_DURATION
		)

	end

	print(
		"[HelpSignal]",
		player.Name,
		"requested help"
	)

end

------------------------------------------------
-- CLEAR PLAYER
------------------------------------------------

function HelpSignalManager:RemovePlayer(player)

	Cooldowns[player] = nil

	------------------------------------------------
	-- Tell clients to remove this player's marker
	------------------------------------------------

	for _, targetPlayer in ipairs(
		Players:GetPlayers()
	) do

		HelpSignal:FireClient(
			targetPlayer,
			"Remove",
			player
		)

	end

end

------------------------------------------------
-- CLEANUP
------------------------------------------------

function HelpSignalManager:Cleanup()

	table.clear(Cooldowns)

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		HelpSignal:FireClient(
			player,
			"Clear"
		)

	end

end

------------------------------------------------
-- REMOTE
------------------------------------------------

HelpSignal.OnServerEvent:Connect(
	function(player)
        print("help need-------------------- on server")
		HelpSignalManager:RequestHelp(player)

	end
)

------------------------------------------------
-- PLAYER LEAVING
------------------------------------------------

Players.PlayerRemoving:Connect(
	function(player)

		HelpSignalManager:RemovePlayer(player)

	end
)

return HelpSignalManager