local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = Shared:WaitForChild("Remotes")

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events

local ProfileManager = require(script.Parent.ProfileManager)

------------------------------------------------

local UpdateCurrency =
	Remotes:WaitForChild(RemoteIndex.UpdateCurrency)

------------------------------------------------

local CurrencyManager = {}

------------------------------------------------
-- Internal
------------------------------------------------

local function GetProfile(player)

	return ProfileManager:GetProfile(player)

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
		XP = profile.XP
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


function CurrencyManager:AddResultStats(player, Coins, MVPScore)
	local amount = Coins
	local xp = MVPScore

	if amount <= 0 then
		return
	end

	if xp <= 0 then
		return
	end

	local profile = GetProfile(player)

	if not profile then
		return
	end
	profile.XP += xp
	profile.Coins += amount

	print(profile)

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