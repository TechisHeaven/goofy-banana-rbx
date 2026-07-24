local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local UIManager = {}

local LobbyGui = PlayerGui:WaitForChild("LobbyGui")
local GameGui = PlayerGui:WaitForChild("GameGui")
local TweenService = game:GetService("TweenService")


local TimerLabel = GameGui.Center.Timer.TimerValue
local RoleLabel = GameGui.Center.Role.RoleLabel
local NotificationLabel = GameGui.Right.Notification
local NotificationsContainer = GameGui.Right.Notifications
local FrozenCounter = GameGui.Right.Frozen.Title

function UIManager:ShowLobby()
	LobbyGui.Enabled = true
	GameGui.Enabled = false
end

function UIManager:ShowGame()
	LobbyGui.Enabled = false
	GameGui.Enabled = true
end

function UIManager:SetGameState(inGame: boolean)
	if inGame then
		self:ShowGame()
	else
		self:ShowLobby()
	end
end

function UIManager:SetTimer(seconds)

	TimerLabel.Text = string.format("%02d:%02d",
		math.floor(seconds / 60),
		seconds % 60
	)

end

function UIManager:SetFrozenPlayers(frozen, total)
	FrozenCounter.Text = string.format("%d/%d", frozen, total)
end


function UIManager:UpdateRoundInfo(payload)
	self:SetTimer(payload.timeLeft)
	self:SetFrozenPlayers(payload.frozenRunners, payload.remainingRunners)
end

function UIManager:SetRole(team)
	RoleLabel.RichText = true
	if team == "Hunter" then
		RoleLabel.Text = 'You are a  <font color="#FF3B30"><b>Hunter</b></font>'
	else
		RoleLabel.Text = 'You are a  <font color="#3DB5F5"><b>Runner</b></font>'
	end
end


function UIManager:ShowNotification(text, duration)

	duration = duration or 5

	local notification = NotificationLabel:Clone()
	notification.Visible = true
	notification.Parent = NotificationsContainer

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

function UIManager:HideNotification()
	NotificationsContainer.Visible = false
end




return UIManager