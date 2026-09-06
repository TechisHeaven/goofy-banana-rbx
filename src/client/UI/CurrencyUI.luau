local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PlayerGui =
	Players.LocalPlayer:WaitForChild("PlayerGui")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Shared =
	ReplicatedStorage.Shared

local LevelConfig =
	require(
		Shared.Config.LevelConfig
	)

------------------------------------------------
-- UI REFERENCES
------------------------------------------------

local LobbyGui =
	PlayerGui:WaitForChild("LobbyGui")

local CoinsLabel =
	LobbyGui.Top.Right.CurrencyFrame.Coins.Amount

local XPFrame =
	LobbyGui.Top.Left.XPFrame

local XPProgressBar =
	XPFrame.ProgressBar

local XPLabel =
	XPProgressBar.XP

local XPBar =
	XPProgressBar.XPBar

local LevelLabel =
	XPFrame.XPImage.Level

local WinsLabel =
	LobbyGui.Top.Right.WinsFrame.Wins.Amount

------------------------------------------------
-- MODULE
------------------------------------------------

local CurrencyUI = {}

------------------------------------------------
-- XP STATE
------------------------------------------------

-- Server's latest known values
local TargetXP = 0
local TargetLevel = 1

-- What is ACTUALLY being shown to the player
local DisplayedXP = 0
local DisplayedLevel = 1

------------------------------------------------
-- ANIMATION STATE
------------------------------------------------

local XPValue = nil
local XPChangedConnection = nil
local XPAnimation = nil

local AnimationId = 0

------------------------------------------------
-- LEVEL LABEL ORIGINAL STATE
------------------------------------------------

local OriginalLevelSize =
	LevelLabel.Size

local OriginalLevelRotation =
	LevelLabel.Rotation

------------------------------------------------
-- HELPERS
------------------------------------------------

local function ToNumber(value, default)

	value = tonumber(value)

	if value == nil then
		return default
	end

	return value

end

------------------------------------------------

local function GetLevelStartXP(level)

	level =
		ToNumber(level, 1)

	return LevelConfig.Levels[level]

end

------------------------------------------------

local function GetNextLevelXP(level)

	level =
		ToNumber(level, 1)

	return LevelConfig.Levels[level + 1]

end

------------------------------------------------
-- FORMAT NUMBERS
------------------------------------------------

function CurrencyUI:Format(amount)

	amount =
		ToNumber(amount, 0)

	amount =
		math.max(0, amount)

	if amount >= 1000000 then

		return string.format(
			"%.1fM",
			amount / 1000000
		)

	end

	if amount >= 10000 then

		return string.format(
			"%.1fK",
			amount / 1000
		)

	end

	return tostring(
		math.floor(amount)
	)

end

------------------------------------------------
-- FIND LEVEL FROM TOTAL XP
------------------------------------------------

function CurrencyUI:GetLevelFromXP(xp, fallbackLevel)

	xp =
		ToNumber(xp, 0)

	fallbackLevel =
		ToNumber(
			fallbackLevel,
			1
		)

	local levels =
		LevelConfig.Levels

	local highestLevel =
		fallbackLevel

	------------------------------------------------
	-- Find the highest level whose starting XP
	-- has been reached.
	------------------------------------------------

	for level, requiredXP in pairs(levels) do

		if
			typeof(level) == "number"
			and typeof(requiredXP) == "number"
			and xp >= requiredXP
		then

			if level > highestLevel then
				highestLevel = level
			end

		end

	end

	return highestLevel

end

------------------------------------------------
-- XP PROGRESS
------------------------------------------------

function CurrencyUI:GetXPProgress(
	xp,
	level
)

	xp =
		math.max(
			0,
			ToNumber(xp, 0)
		)

	level =
		ToNumber(level, 1)

	local levelStartXP =
		GetLevelStartXP(level)

	if levelStartXP == nil then
		return 0
	end

	local nextLevelXP =
		GetNextLevelXP(level)

	------------------------------------------------
	-- MAX LEVEL
	------------------------------------------------

	if nextLevelXP == nil then
		return 1
	end

	local currentXP =
		xp - levelStartXP

	local requiredXP =
		nextLevelXP - levelStartXP

	if requiredXP <= 0 then
		return 0
	end

	return math.clamp(
		currentXP / requiredXP,
		0,
		1
	)

end

------------------------------------------------
-- XP TEXT
------------------------------------------------

function CurrencyUI:FormatXP(
	xp,
	level
)

	xp =
		math.max(
			0,
			ToNumber(xp, 0)
		)

	level =
		ToNumber(level, 1)

	local levelStartXP =
		GetLevelStartXP(level)

	if levelStartXP == nil then
		return "XP 0/MAX"
	end

	local nextLevelXP =
		GetNextLevelXP(level)

	------------------------------------------------
	-- MAX LEVEL
	------------------------------------------------

	if nextLevelXP == nil then

		local currentXP =
			math.max(
				0,
				xp - levelStartXP
			)

		return string.format(
			"XP %d/MAX",
			math.floor(currentXP)
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
		math.floor(currentXP),
		math.floor(requiredXP)
	)

end

------------------------------------------------
-- SET BAR
------------------------------------------------

function CurrencyUI:SetBarProgress(progress)

	progress =
		math.clamp(
			ToNumber(progress, 0),
			0,
			1
		)

	XPBar.Size =
		UDim2.new(
			progress,
			0,
			XPBar.Size.Y.Scale,
			XPBar.Size.Y.Offset
		)

end

------------------------------------------------
-- SET DISPLAY
------------------------------------------------

function CurrencyUI:SetXPDisplay(
	xp,
	level
)

	xp =
		ToNumber(xp, 0)

	level =
		ToNumber(level, 1)

	DisplayedXP = xp
	DisplayedLevel = level

	------------------------------------------------
	-- XP TEXT
	------------------------------------------------

	XPLabel.Text =
		self:FormatXP(
			xp,
			level
		)

	------------------------------------------------
	-- XP BAR
	------------------------------------------------

	self:SetBarProgress(
		self:GetXPProgress(
			xp,
			level
		)
	)

	------------------------------------------------
	-- LEVEL
	------------------------------------------------

	LevelLabel.Text =
		"Level " .. self:Format(level)

end

------------------------------------------------
-- STOP CURRENT XP ANIMATION
------------------------------------------------

function CurrencyUI:StopXPAnimation()

	AnimationId += 1

	------------------------------------------------
	-- Stop Tween
	------------------------------------------------

	if XPAnimation then

		XPAnimation:Cancel()
		XPAnimation = nil

	end

	------------------------------------------------
	-- Disconnect Value
	------------------------------------------------

	if XPChangedConnection then

		XPChangedConnection:Disconnect()
		XPChangedConnection = nil

	end

	------------------------------------------------
	-- Remove NumberValue
	------------------------------------------------

	if XPValue then

		XPValue:Destroy()
		XPValue = nil

	end

end

------------------------------------------------
-- LEVEL POP ANIMATION
------------------------------------------------

function CurrencyUI:AnimateLevel(level)

	level =
		ToNumber(level, 1)

	LevelLabel.Text =
		"Level " .. self:Format(level)

	------------------------------------------------
	-- Calculate sizes
	------------------------------------------------

	local smallSize =
		UDim2.new(
			OriginalLevelSize.X.Scale * 0.82,
			OriginalLevelSize.X.Offset * 0.82,

			OriginalLevelSize.Y.Scale * 0.82,
			OriginalLevelSize.Y.Offset * 0.82
		)

	local bigSize =
		UDim2.new(
			OriginalLevelSize.X.Scale * 1.18,
			OriginalLevelSize.X.Offset * 1.18,

			OriginalLevelSize.Y.Scale * 1.18,
			OriginalLevelSize.Y.Offset * 1.18
		)

	------------------------------------------------
	-- Reset
	------------------------------------------------

	LevelLabel.Size =
		OriginalLevelSize

	LevelLabel.Rotation =
		OriginalLevelRotation

	------------------------------------------------
	-- Shrink
	------------------------------------------------

	local shrink =
		TweenService:Create(
			LevelLabel,

			TweenInfo.new(
				0.08,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			),

			{
				Size = smallSize,
				Rotation = -5,
			}
		)

	shrink:Play()

	shrink.Completed:Wait()

	------------------------------------------------
	-- Big bounce
	------------------------------------------------

	local bounce =
		TweenService:Create(
			LevelLabel,

			TweenInfo.new(
				0.20,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),

			{
				Size = bigSize,
				Rotation = 5,
			}
		)

	bounce:Play()

	bounce.Completed:Wait()

	------------------------------------------------
	-- Settle
	------------------------------------------------

	local settle =
		TweenService:Create(
			LevelLabel,

			TweenInfo.new(
				0.12,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),

			{
				Size = OriginalLevelSize,
				Rotation = OriginalLevelRotation,
			}
		)

	settle:Play()

end

------------------------------------------------
-- ANIMATE XP
------------------------------------------------

function CurrencyUI:AnimateXP(
	startXP,
	targetXP,
	startLevel,
	targetLevel
)

	------------------------------------------------
	-- Cancel previous animation
	------------------------------------------------

	self:StopXPAnimation()

	local thisAnimationId =
		AnimationId

	------------------------------------------------
	-- Sanitize values
	------------------------------------------------

	startXP =
		ToNumber(startXP, 0)

	targetXP =
		ToNumber(targetXP, 0)

	startLevel =
		ToNumber(startLevel, 1)

	targetLevel =
		ToNumber(targetLevel, startLevel)

	------------------------------------------------
	-- No change
	------------------------------------------------

	if startXP == targetXP then

		DisplayedXP =
			targetXP

		DisplayedLevel =
			targetLevel

		self:SetXPDisplay(
			targetXP,
			targetLevel
		)

		return

	end

	------------------------------------------------
	-- Create animation value
	------------------------------------------------

	XPValue =
		Instance.new("NumberValue")

	XPValue.Value =
		startXP

	------------------------------------------------
	-- Update UI whenever value changes
	------------------------------------------------

	XPChangedConnection =
		XPValue:GetPropertyChangedSignal(
			"Value"
		):Connect(function()

			------------------------------------------------
			-- Ignore old animation
			------------------------------------------------

			if thisAnimationId ~= AnimationId then
				return
			end

			local xp =
				XPValue.Value

			------------------------------------------------
			-- Determine current level from XP
			------------------------------------------------

			local level =
				self:GetLevelFromXP(
					xp,
					startLevel
				)

			------------------------------------------------
			-- Never go beyond server target level
			------------------------------------------------

			if level > targetLevel then
				level = targetLevel
			end

			------------------------------------------------
			-- Detect level change
			------------------------------------------------

			if level ~= DisplayedLevel then

				DisplayedLevel =
					level

				LevelLabel.Text =
					"Level " ..
					self:Format(level)

				------------------------------------------------
				-- Animate level number
				------------------------------------------------

				task.spawn(function()

					self:AnimateLevel(level)

				end)

			end

			------------------------------------------------
			-- SAVE EXACT DISPLAYED XP
			------------------------------------------------

			DisplayedXP =
				xp

			DisplayedLevel =
				level

			------------------------------------------------
			-- UPDATE XP TEXT
			------------------------------------------------

			XPLabel.Text =
				self:FormatXP(
					xp,
					level
				)

			------------------------------------------------
			-- UPDATE XP BAR
			------------------------------------------------

			self:SetBarProgress(
				self:GetXPProgress(
					xp,
					level
				)
			)

		end)

	------------------------------------------------
	-- Animation duration
	------------------------------------------------

	local difference =
		math.abs(
			targetXP - startXP
		)

	local duration =
		math.clamp(
			0.45 + (difference / 300),
			0.45,
			1.25
		)

	------------------------------------------------
	-- Tween
	------------------------------------------------

	XPAnimation =
		TweenService:Create(

			XPValue,

			TweenInfo.new(
				duration,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),

			{
				Value = targetXP
			}

		)

	XPAnimation:Play()

	------------------------------------------------
	-- Wait for completion
	------------------------------------------------

	XPAnimation.Completed:Wait()

	------------------------------------------------
	-- Check whether this is still
	-- the current animation
	------------------------------------------------

	if thisAnimationId ~= AnimationId then
		return
	end

	------------------------------------------------
	-- FINAL EXACT STATE
	------------------------------------------------

	DisplayedXP =
		targetXP

	DisplayedLevel =
		targetLevel

	XPLabel.Text =
		self:FormatXP(
			targetXP,
			targetLevel
		)

	self:SetBarProgress(
		self:GetXPProgress(
			targetXP,
			targetLevel
		)
	)

	LevelLabel.Text =
		"Level " ..
		self:Format(targetLevel)

	------------------------------------------------
	-- Cleanup
	------------------------------------------------

	if XPChangedConnection then

		XPChangedConnection:Disconnect()
		XPChangedConnection = nil

	end

	if XPValue then

		XPValue:Destroy()
		XPValue = nil

	end

	XPAnimation = nil

end

------------------------------------------------
-- SET XP
------------------------------------------------

function CurrencyUI:SetXP(
	xp,
	level
)

	xp =
		ToNumber(xp, 0)

	level =
		ToNumber(level, 1)

	------------------------------------------------
	-- FIRST INITIALIZATION
	------------------------------------------------

	if not self.InitializedXP then

		self.InitializedXP = true

		TargetXP =
			xp

		TargetLevel =
			level

		DisplayedXP =
			xp

		DisplayedLevel =
			level

		self:SetXPDisplay(
			xp,
			level
		)

		return

	end

	------------------------------------------------
	-- IMPORTANT:
	-- Read the ACTUAL currently displayed XP
	------------------------------------------------

	local startXP =
		DisplayedXP

	local startLevel =
		DisplayedLevel

	------------------------------------------------
	-- Update server target
	------------------------------------------------

	TargetXP =
		xp

	TargetLevel =
		level

	------------------------------------------------
	-- Animate from what the player currently sees
	-- to the newest server value.
	------------------------------------------------

	task.spawn(function()

		self:AnimateXP(
			startXP,
			xp,
			startLevel,
			level
		)

	end)

end

------------------------------------------------
-- COINS
------------------------------------------------

function CurrencyUI:SetCoins(coins)

	CoinsLabel.Text =
		self:Format(coins)

end

------------------------------------------------
-- WINS
------------------------------------------------

function CurrencyUI:SetWins(wins)

	WinsLabel.Text =
		self:Format(wins)

end

------------------------------------------------
-- LEVEL
------------------------------------------------

function CurrencyUI:SetLevel(level)

	level =
		ToNumber(level, 1)

	TargetLevel =
		level

	DisplayedLevel =
		level

	LevelLabel.Text =
		"Level " ..
		self:Format(level)

end

------------------------------------------------
-- INIT
------------------------------------------------

function CurrencyUI:Init()

	------------------------------------------------
	-- Reset animation
	------------------------------------------------

	self:StopXPAnimation()

	self.InitializedXP =
		false

	TargetXP =
		0

	TargetLevel =
		1

	DisplayedXP =
		0

	DisplayedLevel =
		1

	------------------------------------------------
	-- Initial UI
	------------------------------------------------

	self:SetCoins(0)

	self:SetXP(
		0,
		1
	)

	self:SetLevel(1)

	self:SetWins(0)

end

------------------------------------------------

return CurrencyUI