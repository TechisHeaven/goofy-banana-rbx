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


local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local PopupGui = PlayerGui:WaitForChild("PopupGui")
local Overlay = PopupGui:WaitForChild("Overlay")
local DailyRewardFrame = Overlay:WaitForChild("DailyRewardFrame")


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
local OpenUI = getRemote(RemoteIndexData.Events.OpenUI)

local RequestReward =
	getRemote(
		RemoteIndex.Events.RequestDailyReward
	)

local PopupModule = require(ReplicatedStorage.Shared.Modules.PopupModule)

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

	OpenUI.OnClientEvent:Connect(function(uiName)
		if uiName == "DailyReward" then
			PopupModule:Open(DailyRewardFrame, {
				CanClickOutsideToClose = true
			})
		end

	end)
end

return DailyRewardController