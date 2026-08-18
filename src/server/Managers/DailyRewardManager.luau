local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local DailyRewardConfig =
	require(Shared.Config.DailyRewardConfig)

local ArchieventSound = ReplicatedStorage.Sounds.ArchievementNotification
local SoundUtils = require(ReplicatedStorage.Shared.Utils.SoundUtils)

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)


local RemoteIndex =
	RemoteIndexData.Events

local RemotesFolder =
	Shared:WaitForChild("Remotes")

local CurrencyManager =
	require(script.Parent.CurrencyManager)

local InventoryManager =
	require(script.Parent.InventoryManager)

local NotificationManager = require(script.Parent.NotificationManager)

local RewardDisplay = require(Shared.Modules.RewardDisplay)


------------------------------------------------
-- Remotes
------------------------------------------------

local RequestReward =
	RemotesFolder:WaitForChild(
		RemoteIndex.RequestDailyReward
	)

local UpdateReward =
	RemotesFolder:WaitForChild(
		RemoteIndex.UpdateDailyReward
	)

------------------------------------------------
-- Manager
------------------------------------------------

local DailyRewardManager = {}

local PlayerData = {}
local PremiumPlayers = {}
local DailyRewardReminderShown = {}
------------------------------------------------
-- Player Data
------------------------------------------------

local function GetPlayerData(player)

	local data = PlayerData[player]

	if not data then

		data = {

			CurrentDay = 5,
	        ClaimedDay = 4,
			LastUnlock = os.time(),

		}

		PlayerData[player] = data

	end

	return data

end

------------------------------------------------
-- Daily Reward Reminder
------------------------------------------------

local function SendDailyRewardReminder(player, day)

	if DailyRewardReminderShown[player] == day then
		return
	end

	DailyRewardReminderShown[player] = day
	NotificationManager:Send(
		player,
				'<font color="#FFD43B"><b>DAILY REWARD READY!</b></font> ' ..
				'<font color="#FFFFFF">Your Day ' ..
				tostring(day) ..
				' reward is waiting to be claimed.</font>'
	)

end

------------------------------------------------
-- Premium
------------------------------------------------

function DailyRewardManager:IsPremium(player)
	if PremiumPlayers[player] then
		return true
	end
	local gamePassId =
		DailyRewardConfig.PremiumGamePassId

	if not gamePassId
		or gamePassId <= 0 then

		return false
	end

	local success, ownsPass =
		pcall(function()
			return MarketplaceService:
				UserOwnsGamePassAsync(
					player.UserId,
					gamePassId
				)

		end)

	if not success then

		warn(
			"[DailyRewardManager] Failed to check Premium:",
			player.Name
		)

		return false
	end
	return ownsPass == true
end

------------------------------------------------
-- Can Claim
------------------------------------------------

function DailyRewardManager:CanClaim(player)

    local data = GetPlayerData(player)

    return data.ClaimedDay < data.CurrentDay

end

------------------------------------------------
-- Remaining Time
------------------------------------------------

function DailyRewardManager:GetRemaining(player)

	local data =
		GetPlayerData(player)

	if data.LastUnlock == 0 then
		return 0
	end

	local nextUnlock =
		data.LastUnlock
		+ DailyRewardConfig.ClaimCooldown

	return math.max(
		0,
		nextUnlock - os.time()
	)

end

------------------------------------------------
-- Refresh
------------------------------------------------

function DailyRewardManager:RefreshPlayer(player)

	local data =
		GetPlayerData(player)

	if data.LastUnlock == 0 then

		-- First reward available immediately
		data.CurrentDay = 1

		return
	end

	local now = os.time()

	while
		data.CurrentDay
			< DailyRewardConfig.MaxDay

		and now >=
			data.LastUnlock
			+ DailyRewardConfig.ClaimCooldown

	do

		data.CurrentDay += 1

		data.LastUnlock +=
			DailyRewardConfig.ClaimCooldown

	end

end

------------------------------------------------
-- Build Cards
------------------------------------------------

function DailyRewardManager:BuildCards(player)

	local data =
		GetPlayerData(player)

	local cards = {}

	------------------------------------------------
	-- Build ALL reward days
	------------------------------------------------

	for day = 1, DailyRewardConfig.MaxDay do

		local reward =
			DailyRewardConfig.Rewards[day]

		if reward then

			table.insert(
				cards,
				{

					Day = day,

					FreeReward =
						RewardDisplay:GetRewardDisplay(
							reward.FreeReward
						),

					PremiumReward =
						RewardDisplay:GetRewardDisplay(
							reward.PremiumReward
						),

					BigReward =
						day == DailyRewardConfig.MaxDay,

					Claimed =
						day <= data.ClaimedDay,

					Current =
						day == data.CurrentDay,

				}
			)

		end

	end

	return cards

end

------------------------------------------------
-- Send Data
------------------------------------------------

function DailyRewardManager:SendData(player)

	self:RefreshPlayer(player)

	local data =
		GetPlayerData(player)

	local premium =
		self:IsPremium(player)

	local canClaim = self:CanClaim(player)

	if canClaim then

		SendDailyRewardReminder(
			player,
			data.CurrentDay
		)

	end

	UpdateReward:FireClient(
		player,
		{

			CurrentDay =
				data.CurrentDay,

			IsPremium =
				premium,

			CanClaim =
				canClaim,

			Remaining =
				self:GetRemaining(player),

			NextClaimTime =
				canClaim
					and 0
					or (
						data.LastUnlock
						+ DailyRewardConfig.ClaimCooldown
					),
            ClaimedDay = data.ClaimedDay,
			Cards =
				self:BuildCards(player),

		}
	)

end



------------------------------------------------
-- Give Reward
------------------------------------------------

function DailyRewardManager:GiveReward(player, reward)

	if not reward then
		return false
	end

	------------------------------------------------
	-- COINS
	------------------------------------------------

	if reward.Coins then

		CurrencyManager:AddCoins(
			player,
			reward.Coins
		)

		return true
	end

	------------------------------------------------
	-- XP
	------------------------------------------------

	if reward.XP then

		-- Add your XP manager here later.
		-- Example:
		-- XPManager:AddXP(player, reward.XP)
		CurrencyManager:AddXP(
			player,
			reward.XP
		)
		return true
	end

	------------------------------------------------
	-- SKIN
	------------------------------------------------

	if reward.Skin then

		InventoryManager:AddItem(
			player,
			"Skins",
			reward.Skin
		)

		return true
	end

	------------------------------------------------
	-- BANANA SKIN
	------------------------------------------------

	if reward.BananaSkin then

		InventoryManager:AddItem(
			player,
			"BananaSkins",
			reward.BananaSkin
		)

		return true
	end

	------------------------------------------------
	-- VICTORY POSE
	------------------------------------------------

	if reward.VictoryPose then

		InventoryManager:AddItem(
			player,
			"VictoryPoses",
			reward.VictoryPose
		)

		return true
	end

	------------------------------------------------
	-- RESCUE EFFECT
	------------------------------------------------

	if reward.RescueEffect then

		InventoryManager:AddItem(
			player,
			"RescueEffects",
			reward.RescueEffect
		)

		return true
	end

	warn(
		"[DailyRewardManager] Unknown reward type"
	)

	return false

end
------------------------------------------------
-- Claim
------------------------------------------------
function DailyRewardManager:Claim(player)

	self:RefreshPlayer(player)

	if not self:CanClaim(player) then
		self:SendData(player)
		return false
	end

	local data =
		GetPlayerData(player)

	local rewardData =
		DailyRewardConfig.Rewards[data.CurrentDay]

	if not rewardData then
		return false
	end

	------------------------------------------------
	-- FREE REWARD
	------------------------------------------------

	local success =
		self:GiveReward(
			player,
			rewardData.FreeReward
		)

	if not success then
		return false
	end

	------------------------------------------------
	-- PREMIUM BONUS
	------------------------------------------------

	if self:IsPremium(player) then

		self:GiveReward(
			player,
			rewardData.PremiumReward
		)

	end

	------------------------------------------------
	-- ONE CLAIM FOR THE DAY
	------------------------------------------------

	data.ClaimedDay =
		data.CurrentDay

	self:SendData(player)

	return true

end

------------------------------------------------
-- Init
------------------------------------------------

function DailyRewardManager:Init()

	print(
		"DailyRewardManager Initialized"
	)

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		GetPlayerData(player)

		task.defer(function()

			self:SendData(player)

		end)

	end

	Players.PlayerAdded:Connect(
		function(player)

			GetPlayerData(player)

			task.defer(function()

				self:SendData(player)

			end)

		end
	)

	Players.PlayerRemoving:Connect(
		function(player)
			PremiumPlayers[player] = nil
			PlayerData[player] = nil
			DailyRewardReminderShown[player] = nil
		end
	)

	RequestReward.OnServerEvent:Connect(
		function(player)

			self:Claim(
				player
			)

		end
	)

	------------------------------------------------
	-- GamePass purchase
	------------------------------------------------

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player, purchasedPassId, purchaseSuccess)

			if not purchaseSuccess then
				return
			end

			if purchasedPassId
				~= DailyRewardConfig.PremiumGamePassId then
				return
			end

			-- Session ownership
			PremiumPlayers[player] = true

			print(
				"[DailyRewardManager]",
				player.Name,
				"purchased Premium Pass"
			)

			self:SendData(player)

		end
	)

end

return DailyRewardManager