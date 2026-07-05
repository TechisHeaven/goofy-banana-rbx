local FreezeManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Enums = require(Shared.Enums)
local GameConfig = require(Shared.GameConfig)

local PlayerManager = require(script.Parent.PlayerManager)

-- Lazy-required to avoid circular dependency
local RoundManager = nil

-- Stores the original colors and materials of frozen players' characters
-- Player -> { [BasePart] = { Color = Color3, Material = Enum.Material } }
local originalAppearance = {}

-- Stores ProximityPrompt objects for frozen players
-- Player -> ProximityPrompt
local activePrompts = {}

-- Freeze a runner
function FreezeManager:FreezePlayer(player: Player)
	PlayerManager:SetState(player, Enums.PlayerState.Frozen)
	print(string.format("FreezeManager: %s has been frozen!", player.Name))

	local character = player.Character
	if character then
		-- Lock movement: Anchor the HumanoidRootPart and set speed to 0
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart and rootPart:IsA("BasePart") then
			rootPart.Anchored = true
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
		end

		-- Play ice effect (change material to Ice and color to light blue)
		local appearance = {}
		for _, child in ipairs(character:GetDescendants()) do
			if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
				appearance[child] = {
					Color = child.Color,
					Material = child.Material
				}
				child.Color = Color3.fromRGB(150, 220, 255)
				child.Material = Enum.Material.Ice
			end
		end
		originalAppearance[player] = appearance

		-- Create a ProximityPrompt on the HumanoidRootPart to allow rescues
		if rootPart then
			-- Remove any existing prompt first
			if activePrompts[player] then
				activePrompts[player]:Destroy()
				activePrompts[player] = nil
			end

			local prompt = Instance.new("ProximityPrompt")
			prompt.ObjectText = player.Name
			prompt.ActionText = "Rescue"
			prompt.HoldDuration = GameConfig.Rescue.HoldTime or 5
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.RequiresLineOfSight = false
			prompt.MaxActivationDistance = 8

			prompt.Triggered:Connect(function(rescuer)
				-- Ensure the round is still active and rescuer is eligible
				if not RoundManager then
					RoundManager = require(script.Parent.RoundManager)
				end
				if RoundManager.CurrentState ~= Enums.RoundState.Playing then return end
				if PlayerManager:GetTeam(rescuer) ~= Enums.Team.Runner then return end
				if PlayerManager:GetState(rescuer) ~= Enums.PlayerState.Alive then return end

				print(string.format("FreezeManager: %s was rescued by %s!", player.Name, rescuer.Name))
				FreezeManager:UnfreezePlayer(player)
			end)

			prompt.Parent = rootPart
			activePrompts[player] = prompt
		end
	end

	-- Notify RoundManager (lazy required)
	if not RoundManager then
		RoundManager = require(script.Parent.RoundManager)
	end
	RoundManager:CheckWinCondition()
end

-- Unfreeze a player and restore movement/appearance
function FreezeManager:UnfreezePlayer(player: Player)
	-- Set state back to Alive
	PlayerManager:SetState(player, Enums.PlayerState.Alive)
	print(string.format("FreezeManager: %s has been unfrozen/rescued!", player.Name))

	-- Clean up ProximityPrompt
	local prompt = activePrompts[player]
	if prompt then
		prompt:Destroy()
		activePrompts[player] = nil
	end

	local character = player.Character
	if character then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart and rootPart:IsA("BasePart") then
			rootPart.Anchored = false
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
		end

		-- Restore original appearance
		local appearance = originalAppearance[player]
		if appearance then
			for part, props in pairs(appearance) do
				if part and part.Parent then
					part.Color = props.Color
					part.Material = props.Material
				end
			end
			originalAppearance[player] = nil
		end
	end

	-- Notify RoundManager so the win condition count is updated
	if not RoundManager then
		RoundManager = require(script.Parent.RoundManager)
	end
	RoundManager:CheckWinCondition()
end

-- Unfreezes everyone in the server
function FreezeManager:UnfreezeAll()
	for _, player in ipairs(Players:GetPlayers()) do
		self:UnfreezePlayer(player)
	end
end

-- Handle touch collisions
function FreezeManager:HandleTouch(toucher: Player, otherPart: BasePart)
	-- Get the player associated with otherPart
	local target = Players:GetPlayerFromCharacter(otherPart.Parent)
	if not target then
		-- Fallback to look up model ancestor (accessories, etc.)
		local character = otherPart:FindFirstAncestorOfClass("Model")
		if character then
			target = Players:GetPlayerFromCharacter(character)
		end
	end

	if not target or target == toucher then
		return
	end

	-- Checks:
	-- 1. Is round playing?
	if not RoundManager then
		RoundManager = require(script.Parent.RoundManager)
	end
	if RoundManager.CurrentState ~= Enums.RoundState.Playing then
		return
	end

	-- 2. Is toucher a Hunter?
	if PlayerManager:GetTeam(toucher) ~= Enums.Team.Hunter then
		return
	end

	-- 3. Is target a Runner?
	if PlayerManager:GetTeam(target) ~= Enums.Team.Runner then
		return
	end

	-- 4. Is target already frozen?
	if PlayerManager:GetState(target) == Enums.PlayerState.Frozen then
		return
	end

	-- Freeze the runner!
	self:FreezePlayer(target)
end

-- Hook up touch listeners when character loads
local function onCharacterAdded(player: Player, character: Model)
	originalAppearance[player] = nil

	-- Clean up old ProximityPrompt if it exists
	if activePrompts[player] then
		activePrompts[player]:Destroy()
		activePrompts[player] = nil
	end

	-- If they respawned while marked as frozen, reset their state to Alive
	if PlayerManager:GetState(player) == Enums.PlayerState.Frozen then
		PlayerManager:SetState(player, Enums.PlayerState.Alive)
	end

	local function connectPart(part: BasePart)
		if not part:IsA("BasePart") then return end
		part.Touched:Connect(function(otherPart)
			FreezeManager:HandleTouch(player, otherPart)
		end)
	end

	for _, descendant in ipairs(character:GetDescendants()) do
		connectPart(descendant)
	end
	character.DescendantAdded:Connect(connectPart)
end

function FreezeManager:Init()
	print("FreezeManager Initializing...")

	-- Setup connections for existing players
	for _, player in ipairs(Players:GetPlayers()) do
		player.CharacterAdded:Connect(function(character)
			onCharacterAdded(player, character)
		end)
		if player.Character then
			task.spawn(onCharacterAdded, player, player.Character)
		end
	end

	-- Setup connections for new players
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			onCharacterAdded(player, character)
		end)
	end)
end

return FreezeManager
