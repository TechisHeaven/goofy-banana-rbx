local Players = game:GetService("Players")

local PlayerGui =
	Players.LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------
-- Change these paths to match your UI
------------------------------------------------

local LobbyGui =
	PlayerGui:WaitForChild("LobbyGui")

local CoinsLabel =
	LobbyGui.Top.Right.CurrencyFrame.Coins.Amount

local XPLabel = LobbyGui.Top.Right.XPFrame.XP.Amount
------------------------------------------------

local CurrencyUI = {}

------------------------------------------------

function CurrencyUI:Init()

	self:SetCoins(0)
    self:SetXP(0)

end

------------------------------------------------

function CurrencyUI:SetCoins(coins)
	CoinsLabel.Text = self:Format(coins)
end

function CurrencyUI:SetXP(xp)
    XPLabel.Text = self:Format(xp)
end

------------------------------------------------

function CurrencyUI:Format(amount)

	if amount >= 1000000 then
		return string.format("%.1fM", amount / 1000000)
	end

	if amount >= 10000 then
		return string.format("%.1fK", amount / 1000)
	end

	return tostring(amount)

end

------------------------------------------------

return CurrencyUI