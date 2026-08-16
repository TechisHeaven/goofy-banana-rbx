local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sounds = ReplicatedStorage.Sounds
local Chime = Sounds.Chime
local Tresure = Sounds.GameTresure
local PopupManager =
	require(ReplicatedStorage.Shared.Modules.PopupModule)
local SoundUtil = require(ReplicatedStorage.Shared.Utils.SoundUtils)
local PlaySound = SoundUtil.PlaySound
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local PopupGui =
	PlayerGui:WaitForChild("PopupGui")

local LevelUpFrame =
	PopupGui.Overlay:WaitForChild("LevelUpFrame")
print(LevelUpFrame)
local LevelUpUI = {}

------------------------------------------------
-- UI REFERENCES
------------------------------------------------

local XPFrame =
	LevelUpFrame:WaitForChild("XPFrame")

local ProgressBar =
	XPFrame:WaitForChild("ProgressBar")

local XPBar =
	ProgressBar:WaitForChild("XPBar")

local XPScore =
	XPFrame:WaitForChild("XPScore")

------------------------------------------------
-- STAR
------------------------------------------------

local Star =
	LevelUpFrame:WaitForChild("Star")

local LevelStar =
	Star:FindFirstChild("LevelStar", true)

local LevelNumber =
	Star:FindFirstChild("XP", true)

------------------------------------------------
-- Original values
------------------------------------------------

local OriginalStarSize =
	Star.Size

local OriginalStarRotation =
	Star.Rotation

local OriginalBarSize =
	XPBar.Size

------------------------------------------------
-- Helpers
------------------------------------------------

local function SetText(object, text)

	if object and object:IsA("TextLabel") then
		object.Text = tostring(text)
	end

end

local function SetProgress(progress)

	progress =
		math.clamp(
			progress,
			0,
			1
		)

	XPBar.Size =
		UDim2.new(
			progress,
			0,
			OriginalBarSize.Y.Scale,
			OriginalBarSize.Y.Offset
		)

end

------------------------------------------------
-- XP text
------------------------------------------------

function LevelUpUI:SetXPText(current, required)

	if not XPScore then
		return
	end

	SetText(
		XPScore,
		string.format(
			"XP %d/%d",
			math.floor(current),
			math.floor(required)
		)
	)

end

------------------------------------------------
-- Level text
------------------------------------------------

function LevelUpUI:SetLevel(level)

	if LevelNumber then

		SetText(
			LevelNumber,
			level
		)

	elseif LevelStar then

		SetText(
			LevelStar,
			level
		)

	end

end

------------------------------------------------
-- XP animation
------------------------------------------------

function LevelUpUI:AnimateXP(
	startXP,
	endXP,
	levelStartXP,
	levelEndXP,
	duration
)

	local startProgress =
		math.clamp(
			(startXP - levelStartXP)
				/ (levelEndXP - levelStartXP),
			0,
			1
		)

	local endProgress =
		math.clamp(
			(endXP - levelStartXP)
				/ (levelEndXP - levelStartXP),
			0,
			1
		)

	SetProgress(startProgress)

	local value =
		Instance.new("NumberValue")

	value.Value =
		startProgress

	local connection

	connection =
		value:GetPropertyChangedSignal("Value")
		:Connect(function()

			SetProgress(
				value.Value
			)

			local currentXP =
				levelStartXP
				+ (
					value.Value
					* (
						levelEndXP
						- levelStartXP
					)
				)

			self:SetXPText(
				currentXP,
				levelEndXP - levelStartXP
			)

		end)

	local tween =
		TweenService:Create(
			value,

			TweenInfo.new(
				duration or 0.6,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),

			{
				Value = endProgress
			}
		)

	tween:Play()
	tween.Completed:Wait()

	connection:Disconnect()
	value:Destroy()

	SetProgress(endProgress)

end

------------------------------------------------
-- Star level-up animation
------------------------------------------------

function LevelUpUI:AnimateLevelChange(level)

	------------------------------------------------
	-- Small shrink
	------------------------------------------------

	local shrink =
		TweenService:Create(
			Star,

			TweenInfo.new(
				0.12,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			),

			{
				Size =
					UDim2.fromScale(
						OriginalStarSize.X.Scale * 0.8,
						OriginalStarSize.Y.Scale * 0.8
					),

				Rotation = -8,
			}
		)

	shrink:Play()
	shrink.Completed:Wait()

	------------------------------------------------
	-- Set new level
	------------------------------------------------

	self:SetLevel(level)

	------------------------------------------------
	-- Bounce
	------------------------------------------------

	local bounce =
		TweenService:Create(
			Star,

			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),

			{
				Size =
					UDim2.fromScale(
						OriginalStarSize.X.Scale * 1.15,
						OriginalStarSize.Y.Scale * 1.15
					),

				Rotation = 8,
			}
		)

	bounce:Play()
	bounce.Completed:Wait()

	------------------------------------------------
	-- Return
	------------------------------------------------

	local settle =
		TweenService:Create(
			Star,

			TweenInfo.new(
				0.18,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),

			{
				Size = OriginalStarSize,
				Rotation = OriginalStarRotation,
			}
		)

	settle:Play()
	settle.Completed:Wait()

end

------------------------------------------------
-- Show
------------------------------------------------

function LevelUpUI:Show(data)

	if not data then
		return
	end

	PopupManager:Open(LevelUpFrame, {
        CanClickOutsideToClose = false,
		ReopenPreviousOnClose = true,
    })

	------------------------------------------------
	-- Initial state
	------------------------------------------------

	self:SetLevel(
		data.OldLevel
	)
	------------------------------------------------
	-- Initial XP
	------------------------------------------------

	local oldLevel =
		data.OldLevel

	local newLevel =
		data.NewLevel

	local oldXP =
		data.OldXP

	local newXP =
		data.NewXP

	------------------------------------------------
	-- Multiple level support
	------------------------------------------------

	for level = oldLevel, newLevel do

		local levelStartXP =
			data.LevelStartXP

		local nextLevelXP =
			data.NextLevelXP

		------------------------------------------------
		-- Current level
		------------------------------------------------

		if level ~= oldLevel then

			levelStartXP =
				data.LevelStartXP

			nextLevelXP =
				data.NextLevelXP

		end

		if not nextLevelXP then
			break
		end

		------------------------------------------------
		-- XP before level
		------------------------------------------------

		local animationStartXP

		if level == oldLevel then
			animationStartXP = oldXP
		else
			animationStartXP = levelStartXP
		end

		------------------------------------------------
		-- If this is the level being reached
		------------------------------------------------

		local animationEndXP

		if level < newLevel then
			animationEndXP = nextLevelXP
		else
			animationEndXP = newXP
		end

		self:AnimateXP(
			animationStartXP,
			animationEndXP,
			levelStartXP,
			nextLevelXP,
			0.55
		)

		------------------------------------------------
		-- Level reached
		------------------------------------------------

		if level < newLevel then
			SoundUtil:PlaySound(
				Chime,
				LevelUpFrame
			)

			self:AnimateLevelChange(
				level + 1
			)

			task.wait(0.15)

		end

	end

	------------------------------------------------
	-- Final state
	------------------------------------------------

	self:SetLevel(newLevel)

	SoundUtil:PlaySound(
		Tresure,
		LevelUpFrame
	)
	-- Treasure:Play()

	task.wait(0.8)

	------------------------------------------------
	-- Hide
	------------------------------------------------

	PopupManager:Close(LevelUpFrame)

end

------------------------------------------------
-- Init
------------------------------------------------

function LevelUpUI:Init()

	LevelUpFrame.Visible = false

end

return LevelUpUI