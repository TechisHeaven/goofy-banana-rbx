local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = Shared:WaitForChild("Remotes")

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events

local ProfileManager = require(script.Parent.ProfileManager)
local NotificationManager = require(script.Parent.NotificationManager)
------------------------------------------------

local UpdateCurrency =
	Remotes:WaitForChild(RemoteIndex.UpdateCurrency)
local LevelConfig =
	require(Shared.Config.LevelConfig)

local LevelUp =
	Remotes:WaitForChild(RemoteIndex.LevelUp)
------------------------------------------------

local CurrencyManager = {}

------------------------------------------------
-- Internal
------------------------------------------------

local function GetProfile(player)

	return ProfileManager:GetProfile(player)

end

local function UpdateLevel(player, profile)

	if profile.Level == nil then
		profile.Level = 1
	end

	local oldLevel = profile.Level
	local oldXP = profile.XP

	local newLevel = oldLevel

	for level = 1, LevelConfig.MaxLevel do

		local requiredXP =
			LevelConfig.Levels[level]

		if requiredXP == nil then
			break
		end

		if profile.XP >= requiredXP then
			newLevel = level
		else
			break
		end

	end

	profile.Level = newLevel

	-- NotificationManager:Send(
	-- 	player,
	-- 	string.format("Level Upgraded +%d", profile.Level)
	-- )
	------------------------------------------------
	-- Level increased
	------------------------------------------------

	if newLevel > oldLevel then

		NotificationManager:Send(
			player,
			string.format(
				"Level Upgraded +%d",
				newLevel - oldLevel
			)
		)

		LevelUp:FireClient(
			player,
			{
				OldLevel = oldLevel,
				NewLevel = newLevel,

				OldXP = oldXP,
				NewXP = profile.XP,
				CurrentXP = profile.XP,

				LevelStartXP =
					LevelConfig.Levels[newLevel] or 0,

				NextLevelXP =
					LevelConfig.Levels[newLevel + 1],

				MaxLevel =
					LevelConfig.MaxLevel,
			}
		)

	end

	return newLevel

end

------------------------------------------------
-- Networking
------------------------------------------------

function CurrencyManager:Send(player)

	local profile = GetProfile(player)

	if not profile then
		return
	end

	UpdateCurrency:FireClient(player, {
		Coins = profile.Coins,
		XP = profile.XP,
		Level = profile.Level,
		Wins = profile.Wins
	})

end

function CurrencyManager:SendAll()

	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		self:Send(player)
	end

end

------------------------------------------------
-- Queries
------------------------------------------------

function CurrencyManager:GetCoins(player)

	local profile = GetProfile(player)

	if not profile then
		return 0
	end

	return profile.Coins

end


function CurrencyManager:AddResultStats(
	player,
	coins,
	xp,
	won
)

	local profile =
		GetProfile(player)

	if not profile then
		return
	end

	------------------------------------------------
	-- Coins
	------------------------------------------------

	if coins and coins > 0 then

		profile.Coins += coins

	end

	------------------------------------------------
	-- XP
	------------------------------------------------

	if xp and xp > 0 then

		profile.XP += xp

	end

	------------------------------------------------
	-- Win
	------------------------------------------------

	if won then

		profile.Wins += 1

	end

	------------------------------------------------
	-- Level
	------------------------------------------------

	UpdateLevel(
		player,
		profile
	)

	------------------------------------------------
	-- Notification
	------------------------------------------------

	local message = "Round rewards!"

	if coins and coins > 0 then
		message =
			message
			.. string.format(
				" +%d Coins",
				coins
			)
	end

	if xp and xp > 0 then
		message =
			message
			.. string.format(
				" +%d XP",
				xp
			)
	end

	if won then

		message =
			message
			.. " +1 Win"

	end

	NotificationManager:Send(
		player,
		message
	)

	self:Send(player)

end


------------------------------------------------
-- Add
------------------------------------------------

function CurrencyManager:AddCoins(player, amount)

	if amount <= 0 then
		return
	end

	local profile = GetProfile(player)

	if not profile then
		return
	end

	profile.Coins += amount
	NotificationManager:Send(
		player,
		string.format("+%d Coins", amount)
	)
	self:Send(player)

end

------------------------------------------------
-- Remove
------------------------------------------------

function CurrencyManager:RemoveCoins(player, amount)

	if amount <= 0 then
		return false
	end

	local profile = GetProfile(player)

	if not profile then
		return false
	end

	if profile.Coins < amount then
		return false
	end

	profile.Coins -= amount

	self:Send(player)

	return true

end


function CurrencyManager:AddXP(player, amount)

	if amount <= 0 then
		return
	end

	local profile = GetProfile(player)

	if not profile then
		return
	end

	if profile.Level == nil then
		profile.Level = 1
	end

	------------------------------------------------
	-- Add XP
	------------------------------------------------

	profile.XP += amount
	-- NotificationManager:Send(
	-- 		player,
	-- 		string.format("+%d XP", amount)
	-- 	)
	------------------------------------------------
	-- Update Level
	------------------------------------------------

	UpdateLevel(
		player,
		profile
	)

	------------------------------------------------
	-- Send updated currency data
	------------------------------------------------

	self:Send(player)

end


------------------------------------------------
-- Set
------------------------------------------------

function CurrencyManager:SetCoins(player, amount)

	local profile = GetProfile(player)

	if not profile then
		return
	end

	profile.Coins = math.max(0, amount)

	self:Send(player)

end

------------------------------------------------
-- Has Enough
------------------------------------------------

function CurrencyManager:HasCoins(player, amount)

	return self:GetCoins(player) >= amount

end

------------------------------------------------
-- Spend
------------------------------------------------

function CurrencyManager:TrySpend(player, amount)

	if not self:HasCoins(player, amount) then
		NotificationManager:Send(
			player,
			string.format("Doesn't Have Enough Coins")
		)
		return false
	end

	self:RemoveCoins(player, amount)
	
	return true

end

------------------------------------------------
-- Round Rewards
------------------------------------------------

function CurrencyManager:CommitRoundCoins(player, amount)

	if amount <= 0 then
		return
	end

	self:AddCoins(player, amount)

end


function CurrencyManager:PlayerLoaded(player)
    
end
------------------------------------------------

function CurrencyManager:Init()

	print("CurrencyManager Initializing...")
    Players.PlayerAdded:Connect(function(player)
		task.defer(function()
			self:Send(player)
		end)
	end)

	for _, player in ipairs(Players:GetPlayers()) do

		task.defer(function()

			self:Send(player)

		end)

	end

end

------------------------------------------------

return CurrencyManager