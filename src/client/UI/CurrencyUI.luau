local Players = game:GetService("Players")

local PlayerGui =
	Players.LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local LevelConfig =
	require(
		Shared.Config.LevelConfig
	)
------------------------------------------------
-- Change these paths to match your UI
------------------------------------------------

local LobbyGui =
	PlayerGui:WaitForChild("LobbyGui")

local CoinsLabel =
	LobbyGui.Top.Right.CurrencyFrame.Coins.Amount

local XPLabel =  LobbyGui.Top.Left.XPFrame.ProgressBar.XP
local XPBar =
	LobbyGui.Top.Left.XPFrame.ProgressBar.XPBar
local LevelLabel = LobbyGui.Top.Left.XPFrame.XPImage.Level
local WinsLabel = LobbyGui.Top.Right.WinsFrame.Wins.Amount
------------------------------------------------

local CurrencyUI = {}

------------------------------------------------

function CurrencyUI:Init()

	self:SetCoins(0)
    self:SetXP(0,1)
	self:SetLevel(1)
	self:SetWins(0)

end

------------------------------------------------

function CurrencyUI:SetCoins(coins)
	CoinsLabel.Text = self:Format(coins)
end

function CurrencyUI:SetXP(xp, level)
    XPLabel.Text = self:FormatXP(xp, level)

	local progress =
		self:GetXPProgress(
			xp,
			level
		)

	print(progress)

	XPBar.Size =
		UDim2.new(
			progress,
			0,
			XPBar.Size.Y.Scale,
			XPBar.Size.Y.Offset
		)
end

function CurrencyUI:SetWins(wins)
    WinsLabel.Text = self:Format(wins)
end

function CurrencyUI:SetLevel(level)
    LevelLabel.Text = self:Format(level)
end

function CurrencyUI:GetXPProgress(xp, level)

	level = tonumber(level) or 1
	xp = math.max(0, tonumber(xp) or 0)

	local levelStartXP =
		LevelConfig.Levels[level]

	if levelStartXP == nil then
		return 0
	end

	local nextLevelXP =
		LevelConfig.Levels[level + 1]

	------------------------------------------------
	-- MAX LEVEL
	------------------------------------------------

	if not nextLevelXP then
		return 1
	end

	------------------------------------------------
	-- XP INSIDE CURRENT LEVEL
	------------------------------------------------

	local currentXP =
		xp - levelStartXP

	local requiredXP =
		nextLevelXP - levelStartXP

	return math.clamp(
		currentXP / requiredXP,
		0,
		1
	)

end

function CurrencyUI:FormatXP(xp, level)

	level = tonumber(level) or 1
	xp = math.max(0, tonumber(xp) or 0)

	local levelStartXP =
		LevelConfig.Levels[level]

	if levelStartXP == nil then
		return "XP 0/MAX"
	end

	local nextLevelXP =
		LevelConfig.Levels[level + 1]

	------------------------------------------------
	-- MAX LEVEL
	------------------------------------------------

	if not nextLevelXP then

		local currentXP =
			math.max(
				0,
				xp - levelStartXP
			)

		return string.format(
			"XP %d/MAX",
			currentXP
		)

	end

	------------------------------------------------
	-- CURRENT LEVEL XP
	------------------------------------------------

	local currentXP =
		math.clamp(
			xp - levelStartXP,
			0,
			nextLevelXP - levelStartXP
		)

	local requiredXP =
		nextLevelXP - levelStartXP

	return string.format(
		"XP %d/%d",
		currentXP,
		requiredXP
	)

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