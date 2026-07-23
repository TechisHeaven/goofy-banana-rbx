-- LobbyUI.luau
-- Builds and manages all ScreenGui elements for the lobby phase.
-- LobbyController is responsible for wiring up the button callbacks and
-- calling the Show/Hide/Update methods exposed here.

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")

local LocalPlayer    = Players.LocalPlayer
local PlayerGui      = LocalPlayer:WaitForChild("PlayerGui")

local LobbyUI = {}

-- Internal references ------------------------------------------------------
local screenGui     : ScreenGui
local mainFrame     : Frame
local playButton    : TextButton
local cancelButton  : TextButton
local queueLabel    : TextLabel
local statusLabel   : TextLabel
local currentQueueFrame : Frame
local winnerFrame   : Frame
local winnerLabel   : TextLabel
local rewardFrame   : Frame
local rewardLabel   : TextLabel
local notificationFrame : Frame
local notificationLabel : TextLabel

-- State flags
local isQueued   = false
local isInMatch  = false

-- Callbacks set by LobbyController -----------------------------------------
LobbyUI.OnPlayPressed   = nil :: (() -> ())?
LobbyUI.OnCancelPressed = nil :: (() -> ())?

-- Helpers ------------------------------------------------------------------

local function tweenSize(object: GuiObject, targetSize: UDim2, duration: number?)
	TweenService:Create(
		object,
		TweenInfo.new(duration or 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = targetSize }
	):Play()
end

local function tweenTransparency(object: GuiObject, alpha: number, duration: number?)
	TweenService:Create(
		object,
		TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad),
		{ BackgroundTransparency = alpha }
	):Play()
end


-- Imports -------------------------------------------------------------

local screenGui = PlayerGui:WaitForChild("LobbyGui")
local currentQueueFrame = screenGui.Bottom.Right.QueueStatus

local playButton = screenGui.Bottom.Right.PlayButton
local cancelButton = screenGui.Bottom.Right.CancelButton

local statusLabel = screenGui.Bottom.Right.StatusLabel
local queueLabel = screenGui.Bottom.Right.QueueStatus.Value

-- Initialization ---------------------------------------------------------
function LobbyUI:Init()

    local gui = PlayerGui:WaitForChild("LobbyGui")

    playButton = gui.Bottom.Right.PlayButton
    cancelButton = gui.Bottom.Right.CancelButton

    queueLabel = gui.Bottom.Right.QueueStatus.Value
    statusLabel = gui.Bottom.Right.StatusLabel

    playButton.Activated:Connect(function()

        if self.OnPlayPressed then
            self.OnPlayPressed()
        end

    end)

    cancelButton.Activated:Connect(function()

        if self.OnCancelPressed then
            self.OnCancelPressed()
        end

    end)

end

-- Public API ---------------------------------------------------------------

--- Show the lobby panel (animated slide-in from bottom).
-- function LobbyUI:Show()
-- 	if not mainFrame then return end
-- 	mainFrame.Visible   = true
-- 	mainFrame.Position  = UDim2.new(0, 24, 1, 20)
-- 	tweenSize(mainFrame, mainFrame.Size)
-- 	TweenService:Create(
-- 		mainFrame,
-- 		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
-- 		{ Position = UDim2.new(0, 24, 1, -200) }
-- 	):Play()
-- end

--- Hide the lobby panel (slide out downward).
function LobbyUI:Hide()
	if not mainFrame then return end
	TweenService:Create(
		mainFrame,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = UDim2.new(0, 24, 1, 20) }
	):Play()
	task.delay(0.3, function()
		if mainFrame then mainFrame.Visible = false end
	end)
end

-- --- Switch between idle and queued button states.

function LobbyUI:SetQueued(queued: boolean)
	isQueued = queued

	if not playButton or not cancelButton then
		return
	end

	if queued then
		playButton.Visible = false
		playButton.Active = false

		cancelButton.Visible = true
		cancelButton.Active = true
	else
		cancelButton.Visible = false
		cancelButton.Active = false

		playButton.Visible = true
		playButton.Active = true
	end
end

--- Update the status board from the payload sent by LobbyManager.
--- payload = { state, playerCount, queueCount, timeLeft }
function LobbyUI:UpdateStatus(payload: { state: string, playerCount: number, queueCount: number, timeLeft: number })
	if not statusLabel then return end

	local state      = payload.state or "Waiting"
	local queueCount = payload.queueCount or 0
	local timeLeft   = payload.timeLeft or 0

	if state == "Waiting" then
	if isQueued then
		statusLabel.Text = "Waiting for players..."
	else
		statusLabel.Text = "Click Play to start playing!"
	end

	playButton.Active = true
	playButton.AutoButtonColor = true

	elseif state == "Intermission" then
		statusLabel.Text = string.format("Match starting in %ds...", timeLeft)

		playButton.Active = false
		playButton.AutoButtonColor = false

	elseif state == "Playing" then
		statusLabel.Text = string.format("Match ends in %ds...", timeLeft)

		playButton.Active = false
		playButton.AutoButtonColor = false

	elseif state == "Ending" then
		statusLabel.Text = "Match ending..."

		playButton.Active = false
		playButton.AutoButtonColor = false

	else
		statusLabel.Text = state

		playButton.Active = true
		playButton.AutoButtonColor = true
	end

	if queueLabel then
		if queueCount > 0 then
			queueLabel.Text = string.format("%02d/10", queueCount)
			currentQueueFrame.Visible = true
		else
			queueLabel.Text = ""
			currentQueueFrame.Visible = false
		end
	end

	-- Show the waiting banner when the player is queued but a round is live
	if waitingBanner then
		waitingBanner.Visible = isQueued and (state == "Playing" or state == "Ending")
	end

	if roundInfoLabel then
		local hunterName = payload.hunterName or "None"
		local aliveRunners = payload.aliveRunners or 0
		local frozenRunners = payload.frozenRunners or 0
		local remainingRunners = payload.remainingRunners or 0
		roundInfoLabel.Text = string.format("Hunter: %s\nAlive: %d • Frozen: %d • Left: %d", hunterName, aliveRunners, frozenRunners, remainingRunners)
		roundInfoLabel.Visible = true
	end
end

--- Show the intermission countdown overlay on queued clients.
function LobbyUI:ShowCountdown(seconds: number)
	if statusLabel then
		statusLabel.Text = string.format("Match starting in %ds...", seconds)
	end
end

--- Show the winner screen overlay, then auto-hide after `duration` seconds.
function LobbyUI:ShowWinnerScreen(info: { winnerTeam: string, hunterName: string }, duration: number?)
	if not winnerFrame or not winnerLabel or not rewardFrame or not rewardLabel then return end

	local winnerTeam = (info and (info.winnerTeam or info.winner)) or "Unknown"
	local hunterName = (info and info.hunterName) or "Unknown"
	local teamText = winnerTeam == "Hunter"
		and string.format("🏆 Hunter Wins!\n(%s)", hunterName)
		or  "🏃 Runners Escape!\nRunners Win!"

	winnerLabel.Text  = teamText
	winnerFrame.Visible = true

	local rewardPreview = info and info.rewardPreview or "XP +25\nCoins +10"
	rewardLabel.Text = string.format("Round Complete\n%s\n\nReward Preview: %s", teamText, rewardPreview)
	rewardFrame.Visible = true

	-- Fade in
	winnerFrame.BackgroundTransparency = 1
	winnerLabel.TextTransparency       = 1
	rewardFrame.BackgroundTransparency = 1
	rewardLabel.TextTransparency       = 1
	TweenService:Create(winnerFrame, TweenInfo.new(0.4), { BackgroundTransparency = 0.05 }):Play()
	TweenService:Create(winnerLabel, TweenInfo.new(0.4),  { TextTransparency = 0 }):Play()
	TweenService:Create(rewardFrame, TweenInfo.new(0.4), { BackgroundTransparency = 0.05 }):Play()
	TweenService:Create(rewardLabel, TweenInfo.new(0.4),  { TextTransparency = 0 }):Play()

	-- Auto-hide
	task.delay(duration or 6, function()
		if winnerFrame then
			TweenService:Create(winnerFrame, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(winnerLabel, TweenInfo.new(0.4),  { TextTransparency = 1 }):Play()
			TweenService:Create(rewardFrame, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(rewardLabel, TweenInfo.new(0.4),  { TextTransparency = 1 }):Play()
			task.delay(0.5, function()
				if winnerFrame then winnerFrame.Visible = false end
				if rewardFrame then rewardFrame.Visible = false end
			end)
		end
	end)
end

--- Destroy the GUI (useful during testing reloads).
function LobbyUI:ShowNotification(message: string)
	if not notificationFrame or not notificationLabel then return end
	notificationLabel.Text = message
	notificationFrame.Visible = true
	notificationFrame.Position = UDim2.new(1, 0, 0, 24)
	TweenService:Create(notificationFrame, TweenInfo.new(0.25), { Position = UDim2.new(1, -300, 0, 24) }):Play()
	task.delay(3, function()
		if notificationFrame then
			TweenService:Create(notificationFrame, TweenInfo.new(0.25), { Position = UDim2.new(1, 0, 0, 24) }):Play()
			task.delay(0.3, function()
				if notificationFrame then notificationFrame.Visible = false end
			end)
		end
	end)
end

function LobbyUI:Destroy()
	if screenGui then
		screenGui:Destroy()
		screenGui    = nil
		mainFrame    = nil
		playButton   = nil
		cancelButton = nil
		queueLabel   = nil
		statusLabel  = nil
		winnerFrame  = nil
		winnerLabel  = nil
		rewardFrame = nil
		rewardLabel = nil
		notificationFrame = nil
		notificationLabel = nil
	end
end

return LobbyUI
