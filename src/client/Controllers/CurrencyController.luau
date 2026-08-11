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

------------------------------------------------

local Remotes =
	Shared:WaitForChild("Remotes")

local function GetRemote(name)

	return Remotes:WaitForChild(name)

end

------------------------------------------------

local CurrencyController = {}

------------------------------------------------

local function OnCurrencyUpdate(data)
	CurrencyUI:SetCoins(data.Coins)
	CurrencyUI:SetXP(data.XP)

	print("new currency came", data)
end

------------------------------------------------

function CurrencyController:Init()

	print("CurrencyController Initialized")

	CurrencyUI:Init()

	GetRemote(RemoteIndex.UpdateCurrency)
		.OnClientEvent
		:Connect(OnCurrencyUpdate)

end

------------------------------------------------

return CurrencyController