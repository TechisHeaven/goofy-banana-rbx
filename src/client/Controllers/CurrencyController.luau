local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local CurrencyUI =
	require(script.Parent.Parent.UI.CurrencyUI)

------------------------------------------------

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events

local Remotes = Shared.Remotes

------------------------------------------------

local UpdateCurrency =
	Remotes:WaitForChild(RemoteIndex.UpdateCurrency)

local RoundStatsUpdate = Remotes:WaitForChild(RemoteIndex.RoundStatsUpdate)

local UIManager = require(script.Parent.Parent.manager.UImanager)
------------------------------------------------


------------------------------------------------

local CurrencyController = {}

------------------------------------------------

local function OnCurrencyUpdate(data)
	CurrencyUI:SetCoins(data.Coins)
	CurrencyUI:SetXP(data.XP, data.Level)
	CurrencyUI:SetWins(data.Wins)
	CurrencyUI:SetLevel(data.Level)
end

------------------------------------------------

function CurrencyController:Init()

	print("CurrencyController Initialized")

	CurrencyUI:Init()

	UpdateCurrency.OnClientEvent
		:Connect(OnCurrencyUpdate)

	RoundStatsUpdate.OnClientEvent:Connect(
		function(statName, value)

			if statName == "Coins" then

				UIManager:SetRoundCoins(value)

			end

		end
	)

end

------------------------------------------------

return CurrencyController