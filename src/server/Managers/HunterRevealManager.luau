local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local RemoteIndex =
	require(Shared.Remotes.RemoteIndex)

local Remotes =
	Shared:WaitForChild("Remotes")

local PlayerManager =
	require(script.Parent.PlayerManager)

local Enums =
	require(Shared.Enums)

local HunterRevealConfig =
	require(Shared.Config.HunterRevealConfig)

local RoundManager =
	require(script.Parent.RoundManager)
------------------------------------------------
-- REMOTES
------------------------------------------------

local RevealEffect =
	Remotes:WaitForChild(
		RemoteIndex.Events.HunterRevealEffect
	)
local NotificationManager = require(script.Parent.NotificationManager)

------------------------------------------------
-- MANAGER
------------------------------------------------

local HunterRevealManager = {}

------------------------------------------------
-- ACTIVATE
------------------------------------------------

function HunterRevealManager:Activate(player)

	if not player
		or not player.Parent then

		return false
	end

	------------------------------------------------
	-- MUST BE HUNTER
	------------------------------------------------

	if PlayerManager:GetTeam(player)
		~= Enums.Team.Hunter then

		warn(
			"[HunterReveal] Player is not Hunter:",
			player.Name
		)

		return false
	end

	------------------------------------------------
	-- MUST BE PLAYING
	------------------------------------------------

	local RoundManager =
		require(script.Parent.RoundManager)

	if RoundManager.CurrentState
		~= Enums.RoundState.Playing then

		warn(
			"[HunterReveal] Round is not playing"
		)

		return false
	end

	------------------------------------------------
	-- GET OTHER PLAYERS
	------------------------------------------------

	local targetUserIds = {}

	for _, targetPlayer in ipairs(
		Players:GetPlayers()
	) do

		if targetPlayer ~= player then

			table.insert(
				targetUserIds,
				targetPlayer.UserId
			)

		end

	end

	------------------------------------------------
	-- ONLY HUNTER GETS EFFECT
	------------------------------------------------

	RevealEffect:FireClient(
		player,
		targetUserIds,
		HunterRevealConfig.Duration
	)

	------------------------------------------------
	-- NOTIFY EVERYONE
	------------------------------------------------
    local context = RoundManager:GetGamemodeContext()

    NotificationManager:BroadcastToRound(context.Players,
        "<b>" .. player.Name .. "</b> used <font color='#FFD54A'>Hunter Reveal</font>! " ..
        "Everyone is highlighted for <b>" ..
        HunterRevealConfig.Duration ..
        " seconds</b>."
    )

	print(
		"[HunterReveal] Activated:",
		player.Name
	)

	return true

end

return HunterRevealManager