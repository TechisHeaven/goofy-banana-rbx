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

local InventoryManager= require(script.Parent.InventoryManager)

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

local REACH_DISTANCE = 8

------------------------------------------------
-- REMOTES
------------------------------------------------

local remotes = {}
-- local RescueCinematic =
-- 	getRemote(
-- 		RemoteIndex.RescueCinematic
-- 	)


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
local RescueCinematic =
	getRemote(RemoteIndex.RescueCinematic)
------------------------------------------------
-- RESCUE ANIMATION
------------------------------------------------
local HUNTER_REACH_DISTANCE = 8
local RESCUE_ANIMATION_NAME = "PunchAnimation"


------------------------------------------------
-- FACE EACH OTHER
------------------------------------------------

local function FaceEachOther(rescuer, frozenPlayer)

	local rescuerCharacter =
		rescuer.Character

	local frozenCharacter =
		frozenPlayer.Character

	if not rescuerCharacter
		or not frozenCharacter then
		return
	end

	local rescuerHRP =
		rescuerCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

	local frozenHRP =
		frozenCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

	if not rescuerHRP
		or not frozenHRP then
		return
	end

	------------------------------------------------
	-- Keep their current Y positions.
	-- Only rotate them horizontally.
	------------------------------------------------

	local rescuerPosition =
		rescuerHRP.Position

	local frozenPosition =
		frozenHRP.Position

	local rescuerTarget =
		Vector3.new(
			frozenPosition.X,
			rescuerPosition.Y,
			frozenPosition.Z
		)

	local frozenTarget =
		Vector3.new(
			rescuerPosition.X,
			frozenPosition.Y,
			rescuerPosition.Z
		)

	rescuerHRP.CFrame =
		CFrame.lookAt(
			rescuerPosition,
			rescuerTarget
		)

	frozenHRP.CFrame =
		CFrame.lookAt(
			frozenPosition,
			frozenTarget
		)

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

	local FreezeCooldown =
		getRemote(
			RemoteIndex.FreezeCooldown
		)

	if FreezeCooldown then
		FreezeCooldown:FireClient(
			player,
			cooldownTime
		)
	end

end

local function IsValidRescue(
	rescuer,
	frozenPlayer
)

	if not rescuer
		or not rescuer.Parent
	then
		return false
	end

	if not frozenPlayer
		or not frozenPlayer.Parent
	then
		return false
	end

	------------------------------------------------
	-- Cannot rescue yourself
	------------------------------------------------

	if rescuer == frozenPlayer then
		return false
	end

	------------------------------------------------
	-- Round must be playing
	------------------------------------------------

	local round =
		GetRoundManager()

	if round.CurrentState
		~= Enums.RoundState.Playing
	then
		return false
	end

	------------------------------------------------
	-- Rescuer must be runner
	------------------------------------------------

	if PlayerManager:GetTeam(
		rescuer
	) ~= Enums.Team.Runner then
		return false
	end

	------------------------------------------------
	-- Rescuer must be alive
	------------------------------------------------

	if PlayerManager:GetState(
		rescuer
	) ~= Enums.PlayerState.Alive
	then
		return false
	end

	------------------------------------------------
	-- Target must be frozen
	------------------------------------------------

	if PlayerManager:GetState(
		frozenPlayer
	) ~= Enums.PlayerState.Frozen
	then
		return false
	end

	------------------------------------------------
	-- Both characters must exist
	------------------------------------------------

	local rescuerCharacter =
		rescuer.Character

	local frozenCharacter =
		frozenPlayer.Character

	if not rescuerCharacter
		or not frozenCharacter
	then
		return false
	end

	local rescuerRoot =
		rescuerCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

	local frozenRoot =
		frozenCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

	if not rescuerRoot
		or not frozenRoot
	then
		return false
	end

	------------------------------------------------
	-- Distance validation
	------------------------------------------------

	local distance =
		(
			rescuerRoot.Position
			- frozenRoot.Position
		).Magnitude

	if distance > GameConfig.Rescue.RescueDistance then
		return false
	end

	return true

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
				6
			
			------------------------------------------------
			-- HOLD START
			------------------------------------------------

			prompt.PromptButtonHoldBegan:Connect(
				function(rescuer)
			

				if not IsValidRescue(rescuer, player) then
					print("[RESCUE DEBUG] HOLD BEGIN INVALID")
					return
				end
					------------------------------------------------
					-- EQUIPPED RESCUE EFFECT
					------------------------------------------------

					local effectName =
						InventoryManager:GetEquipped(
							rescuer,
							"RescueEffects"
						)

					-- No rescue effect equipped
					-- -> normal rescue behavior
					if not effectName then
						-- effectName = "DefaultPunch"
						return
					end

					------------------------------------------------
					-- ROUND CHECK
					------------------------------------------------

					local round =
						GetRoundManager()

					if round.CurrentState
						~= Enums.RoundState.Playing then
						return
					end

					------------------------------------------------
					-- RESCUER CHECK
					------------------------------------------------

					if PlayerManager:GetTeam(rescuer)
						~= Enums.Team.Runner then
						return
					end

					if PlayerManager:GetState(rescuer)
						~= Enums.PlayerState.Alive then
						return
					end

					------------------------------------------------
					-- TARGET CHECK
					------------------------------------------------

					if PlayerManager:GetState(player)
						~= Enums.PlayerState.Frozen then
						return
					end

					------------------------------------------------
					-- FACE EACH OTHER
					------------------------------------------------

					FaceEachOther(
						rescuer,
						player
					)

					self:StartRescue(rescuer, player, effectName)

				end
			)

			------------------------------------------------
			-- HOLD END
			------------------------------------------------

			prompt.PromptButtonHoldEnded:Connect(
				function(rescuer)
				

					self:StopRescue(rescuer, player)
				end
			)
		------------------------------------------------
		-- RESCUE COMPLETE
		------------------------------------------------

		prompt.Triggered:Connect(function(rescuer)
		
			if not IsValidRescue(rescuer, player) then
				print("[RESCUE DEBUG] TRIGGER INVALID")
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
			-- STOP CINEMATIC
			-- Rescue is complete
			------------------------------------------------
			self:StopRescue(rescuer, player)
			-- RescueCinematic:FireClient(
			-- 	rescuer,
			-- 	"Stop"
			-- )

			-- RescueCinematic:FireClient(
			-- 	player,
			-- 	"Stop"
			-- )

			------------------------------------------------
			-- ACTUAL RESCUE
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

		end)
			-- prompt.Triggered:Connect(
			-- 	function(rescuer)

			-- 		------------------------------------------------
			-- 		-- Round check
			-- 		------------------------------------------------

			-- 		local round =
			-- 			GetRoundManager()

			-- 		if round.CurrentState
			-- 			~= Enums.RoundState.Playing then

			-- 			return
			-- 		end

			-- 		------------------------------------------------
			-- 		-- Rescuer must be runner
			-- 		------------------------------------------------

			-- 		if PlayerManager:GetTeam(
			-- 			rescuer
			-- 		) ~= Enums.Team.Runner then

			-- 			return
			-- 		end

			-- 		------------------------------------------------
			-- 		-- Rescuer must be alive
			-- 		------------------------------------------------

			-- 		if PlayerManager:GetState(
			-- 			rescuer
			-- 		) ~= Enums.PlayerState.Alive then

			-- 			return
			-- 		end

			-- 		------------------------------------------------
			-- 		-- Rescue
			-- 		------------------------------------------------

			-- 		FreezeManager:UnfreezePlayer(
			-- 			player,
			-- 			rescuer
			-- 		)

			-- 		------------------------------------------------
			-- 		-- Notifications
			-- 		------------------------------------------------

			-- 		if rescuer
			-- 			and rescuer.Parent then

			-- 			NotificationManager:Send(
			-- 				player,
			-- 				("You were rescued by %s!"):format(
			-- 					rescuer.Name
			-- 				),
			-- 				Enums.NotificationTarget.Gameplay
			-- 			)

			-- 			NotificationManager:Send(
			-- 				rescuer,
			-- 				("You rescued %s!"):format(
			-- 					player.Name
			-- 				),
			-- 				Enums.NotificationTarget.Gameplay
			-- 			)

			-- 		end

			-- 	end
			-- )

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

	if not GamemodeManager:IsMode(Enums.Modes.Infected) then
		GetRoundManager():CheckWinCondition()
	end

end


local RescueCinematic =
	getRemote(
		RemoteIndex.RescueCinematic
	)
------------------------------------------------
-- RESCUE VALIDATION
------------------------------------------------


------------------------------------------------
-- START RESCUE
------------------------------------------------

function FreezeManager:StartRescue(
	rescuer,
	frozenPlayer,
	rescueEffect
)

	if not IsValidRescue(
		rescuer,
		frozenPlayer
	) then
		return false
	end

	------------------------------------------------
	-- Already being rescued
	------------------------------------------------

	-- if ActiveRescues[frozenPlayer] then
	-- 	return false
	-- end

	-- ActiveRescues[frozenPlayer] =
	-- 	rescuer

	------------------------------------------------
	-- Tell BOTH clients
	------------------------------------------------

	RescueCinematic:FireClient(
		rescuer,
		"Start",
		rescueEffect
	)

	RescueCinematic:FireClient(
		frozenPlayer,
		"Start",
		rescueEffect
	)

	return true

end

------------------------------------------------
-- STOP RESCUE
------------------------------------------------

function FreezeManager:StopRescue(
	rescuer,
	frozenPlayer
)



	------------------------------------------------
	-- Tell BOTH clients to stop
	------------------------------------------------

	if rescuer
		and rescuer.Parent
	then

		RescueCinematic:FireClient(
			rescuer,
			"Stop"
		)

	end

	if frozenPlayer
		and frozenPlayer.Parent
	then

		RescueCinematic:FireClient(
			frozenPlayer,
			"Stop"
		)

	end

	-- ------------------------------------------------
	-- -- Actually rescue player
	-- ------------------------------------------------

	-- if PlayerManager:GetState(
	-- 	frozenPlayer
	-- ) == Enums.PlayerState.Frozen then

	-- 	self:UnfreezePlayer(
	-- 		frozenPlayer,
	-- 		rescuer
	-- 	)

	-- end

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



function FreezeManager:HandleHandTouch(
	toucher: Player,
	hand: BasePart,
	otherPart: BasePart
)

	------------------------------------------------
	-- BASIC VALIDATION
	------------------------------------------------

	if not toucher
		or not toucher.Parent
		or not hand
		or not hand.Parent
		or not otherPart
		or not otherPart.Parent then

		return
	end

	------------------------------------------------
	-- ONLY HUNTER CAN USE HAND FREEZE
	------------------------------------------------

	if PlayerManager:GetTeam(toucher)
		~= Enums.Team.Hunter then

		return
	end

	------------------------------------------------
	-- TARGET MUST BE A CHARACTER
	------------------------------------------------

	local targetCharacter =
		otherPart:FindFirstAncestorOfClass("Model")

	if not targetCharacter then
		return
	end

	local target =
		Players:GetPlayerFromCharacter(
			targetCharacter
		)

	if not target then
		return
	end

	------------------------------------------------
	-- NEVER FREEZE YOURSELF
	------------------------------------------------

	if target == toucher then
		return
	end

	------------------------------------------------
	-- TARGET MUST BE RUNNER
	------------------------------------------------

	if PlayerManager:GetTeam(target)
		~= Enums.Team.Runner then

		return
	end

	------------------------------------------------
	-- TARGET MUST HAVE A HUMANOID
	------------------------------------------------

	local targetHumanoid =
		targetCharacter:FindFirstChildOfClass(
			"Humanoid"
		)

	if not targetHumanoid then
		return
	end

	------------------------------------------------
	-- TARGET MUST HAVE ROOT
	------------------------------------------------

	local targetRoot =
		targetCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

	if not targetRoot then
		return
	end

	------------------------------------------------
	-- HUNTER MUST HAVE ROOT
	------------------------------------------------

	local hunterCharacter =
		toucher.Character

	if not hunterCharacter then
		return
	end

	local hunterRoot =
		hunterCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

	if not hunterRoot then
		return
	end

	------------------------------------------------
	-- DISTANCE VALIDATION
	--
	-- Prevents weird touches from distant /
	-- physically connected objects.
	------------------------------------------------

	local distance =
		(hunterRoot.Position - targetRoot.Position).Magnitude

	if distance > 8 then
		return
	end

	------------------------------------------------
	-- ROUND CHECK
	------------------------------------------------

	local round =
		GetRoundManager()

	if round.CurrentState
		~= Enums.RoundState.Playing then

		return
	end

	------------------------------------------------
	-- ALREADY FROZEN
	------------------------------------------------

	if PlayerManager:GetState(target)
		== Enums.PlayerState.Frozen then

		return
	end

	------------------------------------------------
	-- FREEZE COOLDOWN
	------------------------------------------------

	if not self:IsFreezeReady(toucher) then
		return
	end

	------------------------------------------------
	-- VALID HAND CONTACT
	------------------------------------------------

	print(
		"[FreezeManager] HAND HIT:",
		toucher.Name,
		"->",
		target.Name,
		"Hand:",
		hand.Name,
		"Distance:",
		distance
	)

	------------------------------------------------
	-- FREEZE
	------------------------------------------------

	self:FreezePlayer(
		target,
		toucher,
		{
			Mode = "Rescue"
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

	-- local function connectPart(
	-- 	part: BasePart
	-- )

	-- 	if not part:IsA("BasePart") then
	-- 		return
	-- 	end

	-- 	part.Touched:Connect(
	-- 		function(otherPart)

	-- 			FreezeManager:HandleTouch(
	-- 				player,
	-- 				otherPart
	-- 			)

	-- 		end
	-- 	)

	-- end

	local function connectHand(
		hand: BasePart
	)
		if not hand:IsA("BasePart") then
			return
		end

		hand.Touched:Connect(function(otherPart)

			FreezeManager:HandleHandTouch(
				player,
				hand,
				otherPart
			)

		end)
	end

	------------------------------------------------

	-- for _, descendant in ipairs(
	-- 	character:GetDescendants()
	-- ) do

	-- 	connectPart(
	-- 		descendant
	-- 	)

	-- end

	-- ------------------------------------------------

	-- character.DescendantAdded:Connect(
	-- 	connectPart
	-- )

	if not character then
		return
	end

	local rightHand = character:FindFirstChild("RightHand")
	local leftHand = character:FindFirstChild("LeftHand")

	if rightHand and rightHand:IsA("BasePart") then
		connectHand(rightHand)
	end

	if leftHand and leftHand:IsA("BasePart") then
		connectHand(leftHand)
	end

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