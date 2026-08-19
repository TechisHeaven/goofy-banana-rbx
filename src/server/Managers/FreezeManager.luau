local FreezeManager = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

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

local GameConfig =
	require(Shared.GameConfig)

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events

------------------------------------------------
-- MANAGERS
------------------------------------------------

local PlayerManager =
	require(script.Parent.PlayerManager)

local FreezeEventManager =
	require(script.Parent.FreezeEventManager)

local NotificationManager =
	require(script.Parent.NotificationManager)

local RoundStatsManager =
	require(script.Parent.RoundStatsManager)

local GamemodeManager =
	require(script.Parent.GamemodeManager)

local TaskManager =
	require(script.Parent.TaskManager)

local TaskEvents =
	require(
		Shared.EnumsEvents.TaskEvents
	)

------------------------------------------------
-- FREEZE MODULE
------------------------------------------------
-- IMPORTANT:
-- Change this path only if FreezeModule
-- is located somewhere else.

local FreezeModule =
	require(Shared.Modules.FreezeModule)

------------------------------------------------
-- ROUND MANAGER
------------------------------------------------

local RoundManager = nil

------------------------------------------------
-- REMOTES
------------------------------------------------

local remotes = {}

------------------------------------------------
-- COOLDOWN
------------------------------------------------

local FreezeCooldownUntil = {}
local HunterFreezeReadyAt = {}

------------------------------------------------
-- DURATION FREEZES
------------------------------------------------
-- Player -> timestamp

local FreezeUntil = {}

------------------------------------------------
-- RESCUE PROMPTS
------------------------------------------------

local activePrompts = {}

------------------------------------------------
-- REMOTE HELPER
------------------------------------------------

local function getRemote(name: string)

	if remotes[name] then
		return remotes[name]
	end

	local folder =
		ReplicatedStorage
			:WaitForChild("Shared")
			:WaitForChild("Remotes")

	local remote =
		folder:FindFirstChild(name)

	if remote
		and remote:IsA("RemoteEvent") then

		remotes[name] = remote

		return remote
	end

	return nil
end

------------------------------------------------
-- ROUND MANAGER
------------------------------------------------

local function GetRoundManager()

	if not RoundManager then

		RoundManager =
			require(
				script.Parent.RoundManager
			)

	end

	return RoundManager
end

------------------------------------------------
-- COOLDOWN
------------------------------------------------

function FreezeManager:GetFreezeCooldown(
	player: Player
)

	local untilTime =
		FreezeCooldownUntil[player]

	if not untilTime then
		return 0
	end

	return math.max(
		0,
		untilTime - os.clock()
	)

end

------------------------------------------------

function FreezeManager:IsFreezeReady(
	player: Player
)

	------------------------------------------------
	-- Post-freeze cooldown
	------------------------------------------------

	if self:GetFreezeCooldown(player) > 0 then
		return false
	end

	------------------------------------------------
	-- Initial hunter cooldown
	------------------------------------------------

	local readyAt =
		HunterFreezeReadyAt[player]

	if readyAt
		and os.clock() < readyAt then

		return false
	end

	return true

end

------------------------------------------------
-- HUNTER COOLDOWN
------------------------------------------------
-- This is NOT the actual player freeze.
-- It only locks the hunter temporarily
-- after using the freeze ability.

function FreezeManager:ApplyHunterCooldown(
	player: Player,
	duration: number?
)

	if not player
		or not player.Parent then

		return
	end

	local cooldownTime =
		duration
		or GameConfig.Hunter.CooldownTime
		or 4
	
	HunterFreezeReadyAt[player] =
		os.clock() + cooldownTime

	task.delay(
		cooldownTime,
		function()

			if not player
				or not player.Parent then

				return
			end

		end
	)

end

------------------------------------------------
-- FREEZE PLAYER
------------------------------------------------

function FreezeManager:FreezePlayer(
	player: Player,
	freezer: Player?,
	freezeOptions
)

	if not player
		or not player.Parent then

		return
	end

	freezeOptions =
		freezeOptions or {}

	local mode =
		freezeOptions.Mode
		or "Rescue"

	local duration =
		tonumber(
			freezeOptions.Duration
		)

	------------------------------------------------
	-- Validate mode
	------------------------------------------------

	if mode ~= "Rescue"
		and mode ~= "Duration" then

		warn(
			"[FreezeManager] Invalid freeze mode:",
			mode
		)

		return
	end

	if mode == "Duration" then

		if not duration
			or duration <= 0 then

			warn(
				"[FreezeManager] Duration mode requires Duration"
			)

			return
		end

	end

	------------------------------------------------
	-- Already frozen
	------------------------------------------------

	if PlayerManager:GetState(player)
		== Enums.PlayerState.Frozen then

		return
	end

	------------------------------------------------
	-- Set game state
	------------------------------------------------

	PlayerManager:SetState(
		player,
		Enums.PlayerState.Frozen
	)

	------------------------------------------------
	-- Notification
	------------------------------------------------

	if freezer
		and freezer.Parent then

		NotificationManager:Broadcast(
			("%s froze %s!"):format(
				freezer.Name,
				player.Name
			),
			Enums.NotificationTarget.Gameplay
		)

	else

		NotificationManager:Broadcast(
			("%s was frozen!"):format(
				player.Name
			),
			Enums.NotificationTarget.Gameplay
		)

	end

	------------------------------------------------
	-- ACTUAL FREEZE
	------------------------------------------------
	-- FreezeModule handles:
	--
	-- movement
	-- anchoring
	-- ice
	-- effects
	-- animations
	-- scripts
	-- cleanup
	--
	------------------------------------------------

	FreezeModule.Freeze(
		player.Character,
		{
			Mode = mode,
			Duration = duration,
		}
	)

	------------------------------------------------
	-- RESCUE PROMPT
	------------------------------------------------

	local character =
		player.Character

	local rootPart =
		character
		and character:FindFirstChild(
			"HumanoidRootPart"
		)

	if rootPart then

		------------------------------------------------
		-- Remove old prompt
		------------------------------------------------

		if activePrompts[player] then

			activePrompts[player]:Destroy()

			activePrompts[player] = nil

		end

		------------------------------------------------
		-- Only Rescue mode needs prompt
		------------------------------------------------

		if mode == "Rescue" then

			local prompt =
				Instance.new(
					"ProximityPrompt"
				)

			prompt.ObjectText =
				player.Name

			prompt.ActionText =
				"Rescue"

			prompt.HoldDuration =
				GameConfig.Rescue.HoldTime
				or 5

			prompt.KeyboardKeyCode =
				Enum.KeyCode.E

			prompt.RequiresLineOfSight =
				false

			prompt.MaxActivationDistance =
				8

			prompt.Triggered:Connect(
				function(rescuer)

					------------------------------------------------
					-- Round check
					------------------------------------------------

					local round =
						GetRoundManager()

					if round.CurrentState
						~= Enums.RoundState.Playing then

						return
					end

					------------------------------------------------
					-- Rescuer must be runner
					------------------------------------------------

					if PlayerManager:GetTeam(
						rescuer
					) ~= Enums.Team.Runner then

						return
					end

					------------------------------------------------
					-- Rescuer must be alive
					------------------------------------------------

					if PlayerManager:GetState(
						rescuer
					) ~= Enums.PlayerState.Alive then

						return
					end

					------------------------------------------------
					-- Rescue
					------------------------------------------------

					FreezeManager:UnfreezePlayer(
						player,
						rescuer
					)

					------------------------------------------------
					-- Notifications
					------------------------------------------------

					if rescuer
						and rescuer.Parent then

						NotificationManager:Send(
							player,
							("You were rescued by %s!"):format(
								rescuer.Name
							),
							Enums.NotificationTarget.Gameplay
						)

						NotificationManager:Send(
							rescuer,
							("You rescued %s!"):format(
								player.Name
							),
							Enums.NotificationTarget.Gameplay
						)

					end

				end
			)

			prompt.Parent =
				rootPart

			activePrompts[player] =
				prompt

		end

	end

	------------------------------------------------
	-- ROUND STATS
	------------------------------------------------

	RoundStatsManager:Freeze(
		player
	)

	if freezer then

		RoundStatsManager:AddFrozenPlayer(
			freezer
		)

		TaskManager:AddProgress(
			freezer,
			TaskEvents.PlayerFrozen,
			1
		)

	end

	------------------------------------------------
	-- GAMEMODE EVENT
	------------------------------------------------

	local round = GetRoundManager()
	print(
	"[FreezeManager] Sending OnPlayerFrozen:",
	player,
	"Freezer:",
	freezer and freezer.Name or "nil"
)
	GamemodeManager:OnPlayerFrozen(
		round:GetGamemodeContext(),
		player,
		freezer
	)
	------------------------------------------------
	-- HUNTER COOLDOWN
	------------------------------------------------

	if freezer then

		local cooldown =
			GameConfig.Hunter.FreezeCooldown
			or 3

		FreezeCooldownUntil[freezer] =
			os.clock()
			+ cooldown

		local remote =
			getRemote(
				RemoteIndex.FreezeCooldown
			)

		if remote then

			remote:FireClient(
				freezer,
				cooldown
			)

		end

	end

	------------------------------------------------
	-- Frozen UI
	------------------------------------------------

	if RoundStatsManager:ShouldShowFrozenUI() then

		FreezeEventManager:FirePlayerFrozen(
			player,
			freezer
		)

	end

	------------------------------------------------
	-- Duration tracking
	------------------------------------------------

	if mode == "Duration" then

		FreezeUntil[player] =
			os.clock() + duration

		task.delay(
			duration,
			function()

				if not player
					or not player.Parent then

					return
				end

				if PlayerManager:GetState(
					player
				) ~= Enums.PlayerState.Frozen then

					return
				end

				local freezeTime =
					FreezeUntil[player]

				if not freezeTime then
					return
				end

				if os.clock()
					< freezeTime then

					return
				end

				self:UnfreezePlayer(
					player,
					nil,
					true
				)

			end
		)

	end

	------------------------------------------------
	-- Win condition
	------------------------------------------------

	GetRoundManager():CheckWinCondition()

end

------------------------------------------------
-- UNFREEZE PLAYER
------------------------------------------------

function FreezeManager:UnfreezePlayer(
	player: Player,
	rescuer: Player?,
	isAutomatic: boolean?
)

	if not player
		or not player.Parent then

		return
	end

	------------------------------------------------
	-- Must actually be frozen
	------------------------------------------------

	if PlayerManager:GetState(
		player
	) ~= Enums.PlayerState.Frozen then

		return
	end

	------------------------------------------------
	-- Clear duration
	------------------------------------------------

	FreezeUntil[player] = nil

	------------------------------------------------
	-- Rescue stats
	------------------------------------------------
	-- Automatic duration unfreeze does NOT
	-- count as a rescue.

	if not isAutomatic
		and rescuer then

		RoundStatsManager:Rescue(
			rescuer,
			player
		)

		TaskManager:AddProgress(
			rescuer,
			TaskEvents.PlayerRescued,
			1
		)

	end

	------------------------------------------------
	-- GAMEMODE EVENT
	------------------------------------------------

	local round = GetRoundManager()
	print(
	"[FreezeManager] Sending OnPlayerRescued:",
		player,
		"Rescuer:",
		rescuer
	)
	GamemodeManager:OnPlayerRescued(
		round:GetGamemodeContext(),
		player,
		rescuer
	)
	------------------------------------------------
	-- Player state
	------------------------------------------------

	PlayerManager:SetState(
		player,
		Enums.PlayerState.Alive
	)

	------------------------------------------------
	-- Remove rescue prompt
	------------------------------------------------

	local prompt =
		activePrompts[player]

	if prompt then

		prompt:Destroy()

		activePrompts[player] = nil

	end

	------------------------------------------------
	-- ACTUAL UNFREEZE
	------------------------------------------------
	-- FreezeModule handles all cleanup.

	if player.Character then

		FreezeModule.Unfreeze(
			player.Character
		)

	end

	------------------------------------------------
	-- Rescue notification
	------------------------------------------------

	if not isAutomatic
		and rescuer
		and rescuer.Parent then

		NotificationManager:Broadcast(
			("%s rescued %s!"):format(
				rescuer.Name,
				player.Name
			),
			Enums.NotificationTarget.Gameplay
		)

	end

	------------------------------------------------
	-- Win condition
	------------------------------------------------

	GetRoundManager():CheckWinCondition()

end

------------------------------------------------
-- UNFREEZE ALL
------------------------------------------------

function FreezeManager:UnfreezeAll()

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if PlayerManager:GetState(
			player
		) == Enums.PlayerState.Frozen then

			self:UnfreezePlayer(
				player,
				nil,
				true
			)

		end

	end

	table.clear(
		FreezeCooldownUntil
	)

	table.clear(
		FreezeUntil
	)

	table.clear(
		HunterFreezeReadyAt
	)

end

------------------------------------------------
-- TOUCH
------------------------------------------------

function FreezeManager:HandleTouch(
	toucher: Player,
	otherPart: BasePart
)

	if not toucher
		or not toucher.Parent then

		return
	end

	------------------------------------------------
	-- Find target
	------------------------------------------------

	local character =
		otherPart
		and otherPart:FindFirstAncestorOfClass(
			"Model"
		)

	local target

	if character then

		target =
			Players:GetPlayerFromCharacter(
				character
			)

	end

	if not target then
		return
	end

	if target == toucher then
		return
	end

	------------------------------------------------
	-- Round check
	------------------------------------------------

	local round =
		GetRoundManager()

	if round.CurrentState
		~= Enums.RoundState.Playing then

		return
	end

	------------------------------------------------
	-- Hunter check
	------------------------------------------------

	if PlayerManager:GetTeam(
		toucher
	) ~= Enums.Team.Hunter then

		return
	end

	------------------------------------------------
	-- Runner check
	------------------------------------------------

	if PlayerManager:GetTeam(
		target
	) ~= Enums.Team.Runner then

		return
	end

	------------------------------------------------
	-- Already frozen
	------------------------------------------------

	if PlayerManager:GetState(
		target
	) == Enums.PlayerState.Frozen then

		return
	end

	------------------------------------------------
	-- Cooldown
	------------------------------------------------

	if not self:IsFreezeReady(
		toucher
	) then

		return
	end

	------------------------------------------------
	-- MAIN GAME FREEZE
	------------------------------------------------
	-- Your normal game freeze is rescue-based.

	self:FreezePlayer(
		target,
		toucher,
		{
			Mode = "Rescue",
		}
	)

end

------------------------------------------------
-- CHARACTER ADDED
------------------------------------------------

local function onCharacterAdded(
	player: Player,
	character: Model
)

	------------------------------------------------
	-- Remove old rescue prompt
	------------------------------------------------

	if activePrompts[player] then

		activePrompts[player]:Destroy()

		activePrompts[player] = nil

	end

	------------------------------------------------
	-- Reset frozen state after respawn
	------------------------------------------------

	if PlayerManager:GetState(
		player
	) == Enums.PlayerState.Frozen then

		PlayerManager:SetState(
			player,
			Enums.PlayerState.Alive
		)

	end

	------------------------------------------------
	-- Clear duration timer
	------------------------------------------------

	FreezeUntil[player] = nil

	------------------------------------------------
	-- Touch listeners
	------------------------------------------------

	local function connectPart(
		part: BasePart
	)

		if not part:IsA("BasePart") then
			return
		end

		part.Touched:Connect(
			function(otherPart)

				FreezeManager:HandleTouch(
					player,
					otherPart
				)

			end
		)

	end

	------------------------------------------------

	for _, descendant in ipairs(
		character:GetDescendants()
	) do

		connectPart(
			descendant
		)

	end

	------------------------------------------------

	character.DescendantAdded:Connect(
		connectPart
	)

end

------------------------------------------------
-- INIT
------------------------------------------------

function FreezeManager:Init()

	print(
		"FreezeManager Initializing..."
	)

	------------------------------------------------
	-- Existing players
	------------------------------------------------

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		player.CharacterAdded:Connect(
			function(character)

				onCharacterAdded(
					player,
					character
				)

			end
		)

		if player.Character then

			task.spawn(
				onCharacterAdded,
				player,
				player.Character
			)

		end

	end

	------------------------------------------------
	-- New players
	------------------------------------------------

	Players.PlayerAdded:Connect(
		function(player)

			player.CharacterAdded:Connect(
				function(character)

					onCharacterAdded(
						player,
						character
					)

				end
			)

		end
	)

	------------------------------------------------
	-- Player leaving
	------------------------------------------------

	Players.PlayerRemoving:Connect(
		function(player)

			FreezeCooldownUntil[player] =
				nil

			FreezeUntil[player] =
				nil

			if activePrompts[player] then

				activePrompts[player]:Destroy()

				activePrompts[player] =
					nil

			end

		end
	)

end

------------------------------------------------

return FreezeManager