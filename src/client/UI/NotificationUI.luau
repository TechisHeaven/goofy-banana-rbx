local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local GameGui = PlayerGui:WaitForChild("GameGui")
local PopupGui = PlayerGui:WaitForChild("PopupGui")

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Enums = require(ReplicatedStorage.Shared.Enums)
local NotificationUI = {}

local NotificationLabel = PopupGui.Overlay.NotificationFrame.Notification

NotificationUI.Container = nil

NotificationUI.PopupContainer =
	PopupGui.Overlay.NotificationFrame.Notifications

NotificationUI.GameplayContainer =
	GameGui.Right.Notifications


local function GetContainer(target)

	if target == Enums.NotificationTarget.Gameplay then
		return NotificationUI.GameplayContainer
	end

	return NotificationUI.PopupContainer

end

function NotificationUI:ShowNotification(data)
	local duration = data.Duration or GameConfig.Game.NotificationDuration or 5
	local text = data.Message or "Notification"
 local container =
		GetContainer(data.Target)
	local notification = NotificationLabel:Clone()
	notification.Visible = true
	notification.Parent = container

	notification.Text = text

	notification.Position = UDim2.new(1,0,0,0)

	local inTween = TweenService:Create(
		notification,
		TweenInfo.new(
			0.3,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Position = UDim2.new(0,0,0,0)
		}
	)

	inTween:Play()

	task.delay(duration,function()

		local outTween = TweenService:Create(
			notification,
			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In
			),
			{
				Position = UDim2.new(1,0,0,0)
			}
		)

		outTween:Play()

		outTween.Completed:Once(function()

			notification:Destroy()

		end)

	end)
end



return NotificationUI