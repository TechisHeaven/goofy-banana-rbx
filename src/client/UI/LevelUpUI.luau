local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider =
	game:GetService("ContentProvider")

local PopupManager =
	require(ReplicatedStorage.Shared.Modules.PopupModule)
local SoundService = require(script.Parent.Parent.Services.SoundService)

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local PopupGui =
	PlayerGui:WaitForChild("PopupGui")

local LevelUpFrame =
	PopupGui.Overlay:WaitForChild("LevelUpFrame")

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


function LevelUpUI:Preload()

	------------------------------------------------
	-- PRELOAD UI ASSETS
	------------------------------------------------

	local preloadObjects = {}

	for _, object in ipairs(
		LevelUpFrame:GetDescendants()
	) do

		if object:IsA("ImageLabel")
			or object:IsA("ImageButton")
			or object:IsA("Decal")
			or object:IsA("Texture")
		then

			table.insert(
				preloadObjects,
				object
			)

		end

	end

	if #preloadObjects > 0 then

		ContentProvider:PreloadAsync(
			preloadObjects
		)

	end

	------------------------------------------------
	-- WARM UP UI RENDER
	------------------------------------------------

	local wasVisible =
		LevelUpFrame.Visible

	LevelUpFrame.Visible =
		true

	task.wait()

	LevelUpFrame.Visible =
		wasVisible

end

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

	local levelRange =
		levelEndXP - levelStartXP

	if levelRange <= 0 then
		return
	end

	local startProgress =
		math.clamp(
			(startXP - levelStartXP)
				/ levelRange,
			0,
			1
		)

	local endProgress =
		math.clamp(
			(endXP - levelStartXP)
				/ levelRange,
			0,
			1
		)

	------------------------------------------------
	-- INITIAL
	------------------------------------------------

	SetProgress(
		startProgress
	)

	self:SetXPText(
		startXP,
		levelRange
	)

	------------------------------------------------
	-- TWEEN DRIVER
	------------------------------------------------

	local driver =
		Instance.new("NumberValue")

	driver.Value =
		startProgress

	------------------------------------------------
	-- UPDATE UI
	------------------------------------------------

	local connection =
		driver:GetPropertyChangedSignal("Value")
		:Connect(function()

			local progress =
				driver.Value

			SetProgress(
				progress
			)

			local currentXP =
				levelStartXP
				+ progress * levelRange

			self:SetXPText(
				currentXP,
				levelRange
			)

		end)

	------------------------------------------------
	-- TWEEN
	------------------------------------------------

	local tween =
		TweenService:Create(

			driver,

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

	------------------------------------------------
	-- CLEANUP
	------------------------------------------------

	connection:Disconnect()

	tween:Destroy()
	driver:Destroy()

	SetProgress(
		endProgress
	)

	self:SetXPText(
		endXP,
		levelRange
	)

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
		ReopenPreviousOnClose = false,
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
			SoundService:Play("Chime", nil, LevelUpFrame)

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
	
	SoundService:Play("GameTreasure", nil, LevelUpFrame)

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
	-- self:Preload()
end

return LevelUpUI