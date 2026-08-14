local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData

local DailyRewardUI =
	require(script.Parent.Parent.UI.DailyRewardUI)

local MonetizationController = require(script.Parent.MonetizationController)
local DailyRewardConfig = require(Shared.Config.DailyRewardConfig)
-----------------------------------------------------
-- Remotes
-----------------------------------------------------

local Remotes =
	Shared:WaitForChild("Remotes")

local function getRemote(name)

	return Remotes:WaitForChild(name)

end

local UpdateReward =
	getRemote(
		RemoteIndex.Events.UpdateDailyReward
	)

local RequestReward =
	getRemote(
		RemoteIndex.Events.RequestDailyReward
	)

-----------------------------------------------------
-- Controller
-----------------------------------------------------

local DailyRewardController = {}

local CurrentData = nil


-----------------------------------------------------
-- Server Update
-----------------------------------------------------

function OnDailyRewardUpdate(data)

	if not data then
		return
	end

	CurrentData = data

	------------------------------------------------
	-- Render latest reward information
	------------------------------------------------

	DailyRewardUI:Render(
		data
	)
end

function DailyRewardController:BuyPremium()
	print("buy premium, MonetizationController")
	MonetizationController:PurchaseGamePass(DailyRewardConfig.PremiumGamePassId)
end

-----------------------------------------------------
-- Claim
-----------------------------------------------------

local function OnClaimPressed()

	if not CurrentData then
		return
	end

	if not CurrentData.CanClaim then
		return
	end

	------------------------------------------------
	-- Server handles:
	--
	-- Free reward
	-- Premium ownership
	-- Premium bonus
	-- Claim validation
	-- Updating profile
	------------------------------------------------

	RequestReward:FireServer()

end

-----------------------------------------------------
-- Init
-----------------------------------------------------

function DailyRewardController:Init()

	print(
		"DailyRewardController Initialized"
	)

	DailyRewardUI:Init()

	------------------------------------------------
	-- Claim callback
	------------------------------------------------

	DailyRewardUI.OnClaimPressed =
		OnClaimPressed

	------------------------------------------------
	-- Server updates
	------------------------------------------------

	UpdateReward.OnClientEvent:Connect(
		OnDailyRewardUpdate
	)
	-- Premium Buy
	DailyRewardUI.OnPremiumPressed = function()
		if CurrentData
			and CurrentData.IsPremium then
			return
		end
		self:BuyPremium()

	end

end

return DailyRewardController