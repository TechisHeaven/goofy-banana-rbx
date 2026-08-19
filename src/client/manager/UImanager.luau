local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local UIManager = {}

local LobbyGui = PlayerGui:WaitForChild("LobbyGui")
local GameGui = PlayerGui:WaitForChild("GameGui")

local ResultUI = require(script.Parent.Parent.UI.ResultUI)

local TweenService = game:GetService("TweenService")


local TimerLabel = GameGui.Center.Timer.TimerValue
local RoleLabel = GameGui.Center.Role.RoleLabel
local NotificationsContainer = GameGui.Right.Notifications
local FrozenCounter = GameGui.Right.FrozenFrame.Frozen.Title
local RoundCoinsLabel =
	GameGui.Right.RoundStats.CurrencyFrame.Coins.Amount


function UIManager:ShowLobby()
	LobbyGui.Enabled = true
	GameGui.Enabled = false
end

function UIManager:ShowGame()
	LobbyGui.Enabled = false
	GameGui.Enabled = true
end


function UIManager:SetRoundCoins(coins)

	coins = tonumber(coins) or 0

	RoundCoinsLabel.Text =
		self:Format(coins)

end

function UIManager:Format(amount)

	if amount >= 1000000 then
		return string.format("%.1fM", amount / 1000000)
	end

	if amount >= 10000 then
		return string.format("%.1fK", amount / 1000)
	end

	return tostring(amount)

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


function UIManager:HideNotification()
	NotificationsContainer.Visible = false
end



-- Round Handling ---------------------------------------------------------------
function UIManager:ShowWin(data)
    ResultUI:ShowWin(data)
end

function UIManager:ShowLose(data)
    ResultUI:ShowLose(data)

end

function UIManager:ShowRoundResult(data)
    ResultUI:Show(data)
end


return UIManager