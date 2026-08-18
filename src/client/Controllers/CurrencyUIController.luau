local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Players =
	game:GetService("Players")

local Player =
	Players.LocalPlayer

local PlayerGui =
	Player:WaitForChild("PlayerGui")

------------------------------------------------
-- MODULE
------------------------------------------------

local CurrencyGainFX =
	require(
		ReplicatedStorage
			.Shared
			.Modules
			.CurrencyGainFX
	)

------------------------------------------------
-- UI
------------------------------------------------

local PopupGui =
	PlayerGui:WaitForChild("PopupGui")


local CoinGainFrame =
	PopupGui:WaitForChild("CoinGainFrame")

local CoinTarget =
	PlayerGui
		:WaitForChild("LobbyGui").Top.Right.CurrencyFrame


------------------------------------------------
-- REMOTE
------------------------------------------------

local Remotes =
	ReplicatedStorage
		.Shared
		.Remotes

local RemoteIndex =
	require(
		ReplicatedStorage
			.Shared
			.Remotes
			.RemoteIndex
	)

local UpdateCurrency =
	Remotes:WaitForChild(
		RemoteIndex.Events.UpdateCurrency
	)

------------------------------------------------
-- CONTROLLER
------------------------------------------------

local CurrencyUIController = {}
local PreviousCoins = nil

function CurrencyUIController:Init()

	UpdateCurrency.OnClientEvent:Connect(
		function(
			data
		)
           if not data then
				return
			end

			local currentCoins =
				data.Coins

			if typeof(currentCoins) ~= "number" then
				return
			end

			------------------------------------------------
			-- FIRST UPDATE
			------------------------------------------------
			-- Don't play gain animation when the player
			-- receives their initial currency state.
			------------------------------------------------

			if PreviousCoins == nil then

				PreviousCoins =
					currentCoins

				return

			end

			------------------------------------------------
			-- CALCULATE CHANGE
			------------------------------------------------

			local changeAmount =
				currentCoins - PreviousCoins

			------------------------------------------------
			-- UPDATE PREVIOUS VALUE
			------------------------------------------------

			PreviousCoins =
				currentCoins

			------------------------------------------------
			-- ONLY PLAY WHEN CURRENCY INCREASES
			------------------------------------------------

			if changeAmount <= 0 then
				return
			end

			------------------------------------------------
			-- PLAY COIN FX
			------------------------------------------------
			CurrencyGainFX:Play(
				CoinGainFrame,
				CoinTarget,
				changeAmount
			)

		end
	)

end

return CurrencyUIController