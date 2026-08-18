local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerGui =
	Players.LocalPlayer:WaitForChild("PlayerGui")

local GameGui =
	PlayerGui:WaitForChild("GameGui")

local PopupGui =
	PlayerGui:WaitForChild("PopupGui")

local SoundUtils = require(ReplicatedStorage.Shared.Utils.SoundUtils)
local PopSound= ReplicatedStorage.Sounds.Pop

local GameConfig =
	require(
		ReplicatedStorage.Shared.GameConfig
	)

local Enums =
	require(
		ReplicatedStorage.Shared.Enums
	)

local NotificationUI = {}

------------------------------------------------
-- UI
------------------------------------------------

local NotificationTemplate =
	PopupGui
		.NotificationFrame
		.Notification

NotificationUI.PopupContainer =
	PopupGui
		.NotificationFrame
		.Notifications

NotificationUI.GameplayContainer =
	GameGui.Right.Notifications

local NotificationSpawnDelay = 0.2

local LastNotificationTime = 0

------------------------------------------------
-- Get container
------------------------------------------------

local function GetContainer(target)

	if target == Enums.NotificationTarget.Gameplay then
		return NotificationUI.GameplayContainer
	end

	return NotificationUI.PopupContainer

end

------------------------------------------------
-- Show notification
------------------------------------------------

function NotificationUI:ShowNotification(data)

	if not data then
		return
	end

	local container =
		GetContainer(data.Target)

	------------------------------------------------
	-- 0.2 second stagger
	------------------------------------------------

	local now = os.clock()

	local delayTime =
		math.max(
			0,
			NotificationSpawnDelay
				- (now - LastNotificationTime)
		)

	LastNotificationTime =
		now + delayTime

	if delayTime > 0 then
		task.wait(delayTime)
	end

	------------------------------------------------
	-- Create slot
	------------------------------------------------

	local slot = Instance.new("Frame")

	slot.Name = "NotificationSlot"

	slot.BackgroundTransparency = 1
	slot.BorderSizePixel = 0

	slot.Size =
		UDim2.new(
			1,
			0,
			0,
			NotificationTemplate.AbsoluteSize.Y
		)

	slot.Parent = container

	------------------------------------------------
	-- Create notification
	------------------------------------------------

	local notification =
		NotificationTemplate:Clone()

	notification.Name = "Notification"

	notification.Visible = true
	notification.Parent = slot
	notification.RichText = data.RichText == true
	notification.Text =
		data.Message or "Notification"

	------------------------------------------------
	-- START ABOVE
	------------------------------------------------

	notification.Position =
		UDim2.new(
			0.5,
			0,
			-1,
			0
		)

	notification.TextTransparency = 1

	if notification:IsA("TextLabel")
		or notification:IsA("TextButton")
		or notification:IsA("TextBox") then

		notification.TextStrokeTransparency = 1

	end

	------------------------------------------------
	-- SLIDE DOWN + FADE IN
	------------------------------------------------

	local inProperties = {

		Position =
			UDim2.new(
				0.5,
				0,
				0,
				0
			),

		TextTransparency = 0,

	}

	if notification:IsA("TextLabel")
		or notification:IsA("TextButton")
		or notification:IsA("TextBox") then

		inProperties.TextStrokeTransparency = 0

	end

	local inTween =
		TweenService:Create(

			notification,

			TweenInfo.new(
				0.3,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),

			inProperties
		)

	inTween:Play()
	SoundUtils:PlaySound(PopSound, slot)

	------------------------------------------------
	-- Lifetime
	------------------------------------------------

	local duration =
		data.Duration
		or GameConfig.Game.NotificationDuration
		or 5
	task.delay(
		duration,
		function()

			if not notification
				or not notification.Parent then

				return

			end

			------------------------------------------------
			-- SLIDE UP + FADE OUT
			------------------------------------------------

			local outProperties = {

				Position =
					UDim2.new(
						0.5,
						0,
						-1,
						0
					),

				TextTransparency = 1,

			}

			if notification:IsA("TextLabel")
				or notification:IsA("TextButton")
				or notification:IsA("TextBox") then

				outProperties.TextStrokeTransparency = 1

			end

			local outTween =
				TweenService:Create(

					notification,

					TweenInfo.new(
						0.25,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.In
					),

					outProperties
				)

			outTween:Play()

			outTween.Completed:Once(
				function()

					if slot then
						slot:Destroy()
					end

				end
			)

		end
	)

end

return NotificationUI