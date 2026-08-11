local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local GameConfig = require(Shared.GameConfig)

local CoinManager = {}

------------------------------------------------
-- Configuration
------------------------------------------------

local MAX_ACTIVE_COINS = GameConfig.Game.MaxCoinActive
local COIN_AMOUNT = GameConfig.Game.CoinAmount
local RESPAWN_DELAY = GameConfig.Game.CoinRespawnTime

------------------------------------------------
-- References
------------------------------------------------

local RoundStatsManager =
	require(script.Parent.RoundStatsManager)
local TaskManager = require(script.Parent.TaskManager)
local TaskEvents = require(Shared.EnumsEvents.TaskEvents)
local CoinTemplate =
	ServerStorage.Templates:WaitForChild("Coin")

local CoinPlatforms =
	Workspace:WaitForChild("CoinPlatforms")


------------------------------------------------
-- State
------------------------------------------------

local ActiveCoins = {}
local PlatformOccupied = {}

local RoundActive = false

------------------------------------------------
-- Get Platforms
------------------------------------------------

local function GetPlatforms()

	local platforms = {}

	for _, object in ipairs(CoinPlatforms:GetChildren()) do

		if object:IsA("BasePart")
			or object:IsA("Model") then

			table.insert(platforms, object)

		end

	end

	return platforms

end

------------------------------------------------
-- Find Random Empty Platform
------------------------------------------------

local function GetRandomAvailablePlatform()

	local available = {}

	for _, platform in ipairs(GetPlatforms()) do

		if not PlatformOccupied[platform] then

			table.insert(
				available,
				platform
			)

		end

	end

	if #available == 0 then
		return nil
	end

	return available[
		math.random(1, #available)
	]

end




------------------------------------------------
-- Get Player From Touch
------------------------------------------------

local function GetPlayerFromHit(hit)

	if not hit then
		return nil
	end

	local character =
		hit:FindFirstAncestorOfClass("Model")

	if not character then
		return nil
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil
	end

	return Players:GetPlayerFromCharacter(character)

end

------------------------------------------------
-- Remove Coin
------------------------------------------------

local function RemoveCoin(coin)

	if not coin then
		return
	end

	local platform =
		ActiveCoins[coin]

	if platform then
		PlatformOccupied[platform] = nil
	end

	ActiveCoins[coin] = nil

	coin:Destroy()

end

local function GetPlatformAnchor(platform)

	if platform:IsA("BasePart") then
		return platform
	end

	if platform:IsA("Model") then

		local anchor =
			platform:FindFirstChild("AnchorPart", true)

		if anchor and anchor:IsA("BasePart") then
			return anchor
		end

	end

	return nil
end


------------------------------------------------
-- Get Platform Position
------------------------------------------------


local function GetPlatformCFrame(platform)

	local anchor = GetPlatformAnchor(platform)

	if not anchor then
		warn(
			"[CoinManager] No AnchorPart found for:",
			platform:GetFullName()
		)

		return nil
	end

	return anchor.CFrame
end


------------------------------------------------
-- Prepare Coin For Runtime
------------------------------------------------
local function PrepareCoin(coin, platform)

	local anchorPart = GetPlatformAnchor(platform)

	if not anchorPart then
		return false
	end
	local anchorAttachment =
		anchorPart:FindFirstChild("AnchorPart"):FindFirstChild("AnchorAttachment")

	if not anchorAttachment then

		warn(
			"[CoinManager] AnchorAttachment missing:",
			anchorPart:GetFullName()
		)

		return false
	end

	------------------------------------------------
	-- Find coin hinge
	------------------------------------------------

	local hinge =
		coin:FindFirstChildWhichIsA(
			"HingeConstraint",
			true
		)

	if not hinge then

		warn(
			"[CoinManager] HingeConstraint missing in coin"
		)

		return false
	end

	------------------------------------------------
	-- Find coin attachment
	------------------------------------------------

	local coinAttachment =
		coin:FindFirstChild(
			"HingeAttachment",
			true
		)

	if not coinAttachment then

		warn(
			"[CoinManager] HingeAttachment missing in coin"
		)

		return false
	end

	------------------------------------------------
	-- IMPORTANT
	-- Connect this coin to THIS platform's anchor.
	------------------------------------------------

	hinge.Attachment0 = coinAttachment
	hinge.Attachment1 = anchorAttachment

	------------------------------------------------
	-- Keep your rotation
	------------------------------------------------

	hinge.ActuatorType = Enum.ActuatorType.Motor
	hinge.AngularVelocity = 2
	hinge.MotorMaxTorque = math.huge
	hinge.Enabled = true

	------------------------------------------------
	-- Coin physics
	------------------------------------------------

	for _, object in ipairs(coin:GetDescendants()) do

		if object:IsA("BasePart") then

			object.Anchored = false
			object.CanCollide = false
			object.CanTouch = true
			object.CanQuery = true
			object.Massless = true

		end

	end

	return true
end


------------------------------------------------
-- Spawn Coin
------------------------------------------------

function CoinManager:SpawnCoin()

	if not RoundActive then
		return
	end

	------------------------------------------------
	-- Don't exceed active coin limit
	------------------------------------------------

	local activeCount = 0

	for coin in pairs(ActiveCoins) do

		if coin and coin.Parent then
			activeCount += 1
		else
			ActiveCoins[coin] = nil
		end

	end

	if activeCount >= MAX_ACTIVE_COINS then
		return
	end

	------------------------------------------------
	-- Find random platform
	------------------------------------------------

	local platform =
		GetRandomAvailablePlatform()

	if not platform then
		return
	end

	local platformCFrame =
		GetPlatformCFrame(platform)

	if not platformCFrame then
		return
	end

	------------------------------------------------
	-- Clone coin
	------------------------------------------------

	local coin =
		CoinTemplate:Clone()

	coin.Name = "RoundCoin"

    coin.Parent = Workspace


   
    local prepared =
        PrepareCoin(
            coin,
            platform
        )

    -- if not prepared then

    --     coin:Destroy()

    --     return

    -- end
	------------------------------------------------
	-- Position
	------------------------------------------------

	local height = 3

	if coin:IsA("Model") then

		coin:PivotTo(
			platformCFrame
			* CFrame.new(0, height, 0)
		)

	elseif coin:IsA("BasePart") then

		coin.CFrame =
			platformCFrame
			* CFrame.new(0, height, 0)

	end


	------------------------------------------------
	-- Mark platform occupied
	------------------------------------------------

	ActiveCoins[coin] = platform
	PlatformOccupied[platform] = true

	------------------------------------------------
	-- Touch detection
	------------------------------------------------

	local touchPart

	if coin:IsA("BasePart") then

		touchPart = coin

	else

		touchPart =
			coin:FindFirstChildWhichIsA(
				"BasePart",
				true
			)

	end

	if not touchPart then

		warn(
			"[CoinManager] Coin has no BasePart:",
			coin:GetFullName()
		)

		RemoveCoin(coin)

		return

	end

	local collected = false

	touchPart.Touched:Connect(function(hit)

		if collected then
			return
		end

		if not RoundActive then
			return
		end

		local player =
			GetPlayerFromHit(hit)

		if not player then
			return
		end

		------------------------------------------------
		-- Prevent double collection
		------------------------------------------------

		collected = true
		------------------------------------------------
		-- Add to ROUND stats
		------------------------------------------------

		RoundStatsManager:AddCoins(
			player,
			COIN_AMOUNT
		)

		TaskManager:AddProgress(
			player,
			TaskEvents.CoinCollected,
			COIN_AMOUNT
		)

		------------------------------------------------
		-- Remove
		------------------------------------------------

		RemoveCoin(coin)

		------------------------------------------------
		-- Spawn replacement
		------------------------------------------------

		task.delay(
			RESPAWN_DELAY,
			function()

				if RoundActive then
					self:SpawnCoin()
				end

			end
		)

	end)

end

------------------------------------------------
-- Start Round
------------------------------------------------

function CoinManager:StartRound()

	self:StopRound()

	RoundActive = true

	------------------------------------------------
	-- Spawn initial coins
	------------------------------------------------

	for i = 1, MAX_ACTIVE_COINS do

		self:SpawnCoin()

	end

end

------------------------------------------------
-- Stop Round
------------------------------------------------

function CoinManager:StopRound()

	RoundActive = false

	------------------------------------------------
	-- Remove all active coins
	------------------------------------------------

	for coin, platform in pairs(ActiveCoins) do

		if platform then
			PlatformOccupied[platform] = nil
		end

		if coin and coin.Parent then
			coin:Destroy()
		end

	end

	table.clear(ActiveCoins)
	table.clear(PlatformOccupied)


end

------------------------------------------------
-- Init
------------------------------------------------

function CoinManager:Init()

	print("[CoinManager] Initializing...")

	local platforms =
		GetPlatforms()


	if #platforms < MAX_ACTIVE_COINS then

		warn(
			"[CoinManager] Need at least "
			.. MAX_ACTIVE_COINS
			.. " coin platforms."
		)

	end

end

------------------------------------------------

return CoinManager