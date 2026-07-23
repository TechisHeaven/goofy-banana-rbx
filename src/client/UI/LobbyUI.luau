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
local waitingBanner : Frame
local waitingLabel  : TextLabel
local winnerFrame   : Frame
local winnerLabel   : TextLabel
local countdownLabel: TextLabel
local roundInfoLabel: TextLabel
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

-- Build -------------------------------------------------------------------

function LobbyUI:Build()
	-- Destroy old GUI if rebuilding
	local existing = PlayerGui:FindFirstChild("LobbyGui")
	if existing then existing:Destroy() end

	-- Root ScreenGui
	screenGui           = Instance.new("ScreenGui")
	screenGui.Name      = "LobbyGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent    = PlayerGui

	-- Semi-transparent dark panel anchored bottom-center
	mainFrame                          = Instance.new("Frame")
	mainFrame.Name                     = "LobbyPanel"
	mainFrame.Size                     = UDim2.new(0, 280, 0, 180)
	mainFrame.Position                 = UDim2.new(0, 24, 1, -200)
	mainFrame.BackgroundColor3         = Color3.fromRGB(18, 18, 28)
	mainFrame.BackgroundTransparency   = 0.1
	mainFrame.BorderSizePixel          = 0
	mainFrame.Parent                   = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = mainFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color     = Color3.fromRGB(120, 80, 255)
	stroke.Thickness = 2
	stroke.Transparency = 0.3
	stroke.Parent = mainFrame

	-- Title label
	local titleLabel                    = Instance.new("TextLabel")
	titleLabel.Name                     = "TitleLabel"
	titleLabel.Size                     = UDim2.new(1, 0, 0, 40)
	titleLabel.Position                 = UDim2.new(0, 0, 0, 12)
	titleLabel.BackgroundTransparency   = 1
	titleLabel.Font                     = Enum.Font.GothamBold
	titleLabel.Text                     = "🍌  GOOFY BANANAS"
	titleLabel.TextColor3               = Color3.fromRGB(255, 210, 60)
	titleLabel.TextSize                 = 22
	titleLabel.Parent                   = mainFrame

	-- Match status label
	statusLabel                         = Instance.new("TextLabel")
	statusLabel.Name                    = "StatusLabel"
	statusLabel.Size                    = UDim2.new(1, -24, 0, 30)
	statusLabel.Position                = UDim2.new(0, 12, 0, 56)
	statusLabel.BackgroundTransparency  = 1
	statusLabel.Font                    = Enum.Font.Gotham
	statusLabel.Text                    = "Waiting for players..."
	statusLabel.TextColor3              = Color3.fromRGB(180, 180, 210)
	statusLabel.TextSize                = 15
	statusLabel.TextXAlignment          = Enum.TextXAlignment.Center
	statusLabel.Parent                  = mainFrame

	-- Queue count label
	queueLabel                          = Instance.new("TextLabel")
	queueLabel.Name                     = "QueueLabel"
	queueLabel.Size                     = UDim2.new(1, -24, 0, 24)
	queueLabel.Position                 = UDim2.new(0, 12, 0, 90)
	queueLabel.BackgroundTransparency   = 1
	queueLabel.Font                     = Enum.Font.Gotham
	queueLabel.Text                     = ""
	queueLabel.TextColor3              = Color3.fromRGB(140, 255, 180)
	queueLabel.TextSize                 = 14
	queueLabel.TextXAlignment           = Enum.TextXAlignment.Center
	queueLabel.Parent                   = mainFrame

	-- Countdown label (shown during intermission)
	countdownLabel                      = Instance.new("TextLabel")
	countdownLabel.Name                 = "CountdownLabel"
	countdownLabel.Size                 = UDim2.new(1, 0, 0, 38)
	countdownLabel.Position             = UDim2.new(0, 0, 0, 118)
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.Font                 = Enum.Font.GothamBold
	countdownLabel.Text                 = ""
	countdownLabel.TextColor3           = Color3.fromRGB(255, 180, 60)
	countdownLabel.TextSize             = 28
	countdownLabel.TextXAlignment       = Enum.TextXAlignment.Center
	countdownLabel.Visible              = false
	countdownLabel.Parent               = mainFrame

	-- Round information label (hunter + runner counts)
	roundInfoLabel                      = Instance.new("TextLabel")
	roundInfoLabel.Name                 = "RoundInfoLabel"
	roundInfoLabel.Size                 = UDim2.new(1, -24, 0, 44)
	roundInfoLabel.Position             = UDim2.new(0, 12, 0, 128)
	roundInfoLabel.BackgroundTransparency = 1
	roundInfoLabel.Font                 = Enum.Font.Gotham
	roundInfoLabel.Text                 = "Hunter: Waiting\nAlive: 0 • Frozen: 0"
	roundInfoLabel.TextColor3           = Color3.fromRGB(255, 220, 120)
	roundInfoLabel.TextSize             = 13
	roundInfoLabel.TextWrapped          = true
	roundInfoLabel.TextXAlignment       = Enum.TextXAlignment.Center
	roundInfoLabel.Parent               = mainFrame

	-- Play button
	playButton                          = Instance.new("TextButton")
	playButton.Name                     = "PlayButton"
	playButton.Size                     = UDim2.new(0, 140, 0, 44)
	playButton.Position                 = UDim2.new(0.5, -70, 1, -58)
	playButton.BackgroundColor3         = Color3.fromRGB(90, 60, 220)
	playButton.Font                     = Enum.Font.GothamBold
	playButton.Text                     = "▶  PLAY"
	playButton.TextColor3               = Color3.fromRGB(255, 255, 255)
	playButton.TextSize                 = 18
	playButton.BorderSizePixel          = 0
	playButton.AutoButtonColor          = false
	playButton.Parent                   = mainFrame

	local playCorner = Instance.new("UICorner")
	playCorner.CornerRadius = UDim.new(0, 12)
	playCorner.Parent = playButton

	-- Play button hover glow effect
	playButton.MouseEnter:Connect(function()
		TweenService:Create(playButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(110, 80, 255)
		}):Play()
	end)
	playButton.MouseLeave:Connect(function()
		TweenService:Create(playButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(90, 60, 220)
		}):Play()
	end)
	playButton.MouseButton1Click:Connect(function()
		if LobbyUI.OnPlayPressed then
			LobbyUI.OnPlayPressed()
		end
	end)

	-- Leave queue button (hidden until queued)
	cancelButton                        = Instance.new("TextButton")
	cancelButton.Name                   = "CancelButton"
	cancelButton.Size                   = UDim2.new(0, 140, 0, 38)
	cancelButton.Position               = UDim2.new(0.5, -70, 1, -18)
	cancelButton.BackgroundColor3       = Color3.fromRGB(60, 20, 20)
	cancelButton.Font                   = Enum.Font.GothamBold
	cancelButton.Text                   = "✕  Leave Queue"
	cancelButton.TextColor3             = Color3.fromRGB(255, 120, 120)
	cancelButton.TextSize               = 14
	cancelButton.BorderSizePixel        = 0
	cancelButton.AutoButtonColor        = false
	cancelButton.Visible                = false
	cancelButton.Parent                 = mainFrame

	local cancelCorner = Instance.new("UICorner")
	cancelCorner.CornerRadius = UDim.new(0, 8)
	cancelCorner.Parent = cancelButton

	cancelButton.MouseEnter:Connect(function()
		TweenService:Create(cancelButton, TweenInfo.new(0.12), {
			BackgroundColor3 = Color3.fromRGB(90, 30, 30)
		}):Play()
	end)
	cancelButton.MouseLeave:Connect(function()
		TweenService:Create(cancelButton, TweenInfo.new(0.12), {
			BackgroundColor3 = Color3.fromRGB(60, 20, 20)
		}):Play()
	end)
	cancelButton.MouseButton1Click:Connect(function()
		if LobbyUI.OnCancelPressed then
			LobbyUI.OnCancelPressed()
		end
	end)

	-- "Waiting" banner (shown when queued but a round is in progress)
	waitingBanner                          = Instance.new("Frame")
	waitingBanner.Name                     = "WaitingBanner"
	waitingBanner.Size                     = UDim2.new(1, -24, 0, 36)
	waitingBanner.Position                 = UDim2.new(0, 12, 0, 160)
	waitingBanner.BackgroundColor3         = Color3.fromRGB(40, 100, 60)
	waitingBanner.BackgroundTransparency   = 0.3
	waitingBanner.BorderSizePixel          = 0
	waitingBanner.Visible                  = false
	waitingBanner.Parent                   = mainFrame

	local bannerCorner = Instance.new("UICorner")
	bannerCorner.CornerRadius = UDim.new(0, 8)
	bannerCorner.Parent = waitingBanner

	waitingLabel                         = Instance.new("TextLabel")
	waitingLabel.Size                    = UDim2.new(1, 0, 1, 0)
	waitingLabel.BackgroundTransparency  = 1
	waitingLabel.Font                    = Enum.Font.Gotham
	waitingLabel.Text                    = "⏳  You'll join the next round"
	waitingLabel.TextColor3              = Color3.fromRGB(160, 255, 180)
	waitingLabel.TextSize                = 14
	waitingLabel.Parent                  = waitingBanner

	-- Reward preview / end-of-round screen (compact popup)
	rewardFrame                          = Instance.new("Frame")
	rewardFrame.Name                     = "RewardFrame"
	rewardFrame.Size                     = UDim2.new(0, 320, 0, 160)
	rewardFrame.Position                 = UDim2.new(0.5, -160, 0.5, -80)
	rewardFrame.AnchorPoint              = Vector2.new(0.5, 0.5)
	rewardFrame.BackgroundColor3         = Color3.fromRGB(20, 18, 34)
	rewardFrame.BackgroundTransparency   = 0.05
	rewardFrame.BorderSizePixel          = 0
	rewardFrame.Visible                  = false
	rewardFrame.ZIndex                   = 12
	rewardFrame.Parent                   = screenGui

	local rewardCorner = Instance.new("UICorner")
	rewardCorner.CornerRadius = UDim.new(0, 18)
	rewardCorner.Parent = rewardFrame

	local rewardStroke = Instance.new("UIStroke")
	rewardStroke.Color      = Color3.fromRGB(130, 90, 255)
	rewardStroke.Thickness  = 2
	rewardStroke.Parent     = rewardFrame

	rewardLabel                          = Instance.new("TextLabel")
	rewardLabel.Name                     = "RewardLabel"
	rewardLabel.Size                     = UDim2.new(1, -24, 1, -24)
	rewardLabel.Position                 = UDim2.new(0, 12, 0, 12)
	rewardLabel.BackgroundTransparency   = 1
	rewardLabel.Font                     = Enum.Font.GothamBold
	rewardLabel.Text                     = ""
	rewardLabel.TextColor3              = Color3.fromRGB(255, 220, 100)
	rewardLabel.TextSize                 = 22
	rewardLabel.TextWrapped              = true
	rewardLabel.Parent                   = rewardFrame

	-- Winner / end-of-round screen (compact popup)
	winnerFrame                          = Instance.new("Frame")
	winnerFrame.Name                     = "WinnerFrame"
	winnerFrame.Size                     = UDim2.new(0, 300, 0, 150)
	winnerFrame.Position                 = UDim2.new(0.5, -150, 0.5, -75)
	winnerFrame.AnchorPoint              = Vector2.new(0.5, 0.5)
	winnerFrame.BackgroundColor3         = Color3.fromRGB(12, 12, 24)
	winnerFrame.BackgroundTransparency   = 0.05
	winnerFrame.BorderSizePixel          = 0
	winnerFrame.Visible                  = false
	winnerFrame.ZIndex                   = 10
	winnerFrame.Parent                   = screenGui

	local winCorner = Instance.new("UICorner")
	winCorner.CornerRadius = UDim.new(0, 20)
	winCorner.Parent = winnerFrame

	local winStroke = Instance.new("UIStroke")
	winStroke.Color      = Color3.fromRGB(255, 210, 60)
	winStroke.Thickness  = 2
	winStroke.Parent     = winnerFrame

	winnerLabel                          = Instance.new("TextLabel")
	winnerLabel.Name                     = "WinnerLabel"
	winnerLabel.Size                     = UDim2.new(1, 0, 1, 0)
	winnerLabel.BackgroundTransparency   = 1
	winnerLabel.Font                     = Enum.Font.GothamBold
	winnerLabel.Text                     = ""
	winnerLabel.TextColor3              = Color3.fromRGB(255, 220, 80)
	winnerLabel.TextSize                 = 32
	winnerLabel.TextWrapped              = true
	winnerLabel.Parent                   = winnerFrame

	-- Notification toast
	notificationFrame                    = Instance.new("Frame")
	notificationFrame.Name               = "NotificationFrame"
	notificationFrame.Size               = UDim2.new(0, 280, 0, 60)
	notificationFrame.Position           = UDim2.new(1, -300, 0, 24)
	notificationFrame.BackgroundColor3   = Color3.fromRGB(24, 24, 36)
	notificationFrame.BackgroundTransparency = 0.08
	notificationFrame.BorderSizePixel    = 0
	notificationFrame.Visible            = false
	notificationFrame.ZIndex             = 15
	notificationFrame.Parent             = screenGui

	local notificationCorner = Instance.new("UICorner")
	notificationCorner.CornerRadius = UDim.new(0, 12)
	notificationCorner.Parent = notificationFrame

	notificationLabel                    = Instance.new("TextLabel")
	notificationLabel.Name               = "NotificationLabel"
	notificationLabel.Size               = UDim2.new(1, -16, 1, -16)
	notificationLabel.Position           = UDim2.new(0, 8, 0, 8)
	notificationLabel.BackgroundTransparency = 1
	notificationLabel.Font               = Enum.Font.Gotham
	notificationLabel.Text               = ""
	notificationLabel.TextColor3         = Color3.fromRGB(240, 240, 255)
	notificationLabel.TextSize           = 14
	notificationLabel.TextWrapped        = true
	notificationLabel.Parent             = notificationFrame
end

-- Public API ---------------------------------------------------------------

--- Show the lobby panel (animated slide-in from bottom).
function LobbyUI:Show()
	if not mainFrame then return end
	mainFrame.Visible   = true
	mainFrame.Position  = UDim2.new(0, 24, 1, 20)
	tweenSize(mainFrame, mainFrame.Size)
	TweenService:Create(
		mainFrame,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0, 24, 1, -200) }
	):Play()
end

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

--- Switch between idle and queued button states.
function LobbyUI:SetQueued(queued: boolean)
	isQueued = queued
	if not playButton or not cancelButton then return end
	if queued then
		playButton.Text              = "✔  Queued!"
		playButton.BackgroundColor3  = Color3.fromRGB(40, 160, 80)
		playButton.Active            = false
		cancelButton.Visible         = true
	else
		playButton.Text              = "▶  PLAY"
		playButton.BackgroundColor3  = Color3.fromRGB(90, 60, 220)
		playButton.Active            = true
		cancelButton.Visible         = false
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
		statusLabel.Text    = "Waiting for players to queue…"
		countdownLabel.Visible = false
	elseif state == "Intermission" then
		statusLabel.Text    = "Match starting soon!"
		countdownLabel.Text    = string.format("Round in %ds", timeLeft)
		countdownLabel.Visible = true
	elseif state == "Playing" then
		statusLabel.Text    = string.format("Round in progress — %ds remaining", timeLeft)
		countdownLabel.Visible = false
	elseif state == "Ending" then
		statusLabel.Text    = "Round ending…"
		countdownLabel.Visible = false
	else
		statusLabel.Text    = state
		countdownLabel.Visible = false
	end

	if queueLabel then
		if queueCount > 0 then
			queueLabel.Text = string.format("%d player%s in queue", queueCount, queueCount == 1 and "" or "s")
		else
			queueLabel.Text = ""
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
	if not countdownLabel then return end
	countdownLabel.Visible = true
	countdownLabel.Text    = string.format("Round starts in %ds!", seconds)
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
		waitingBanner = nil
		waitingLabel  = nil
		winnerFrame  = nil
		winnerLabel  = nil
		countdownLabel = nil
		roundInfoLabel = nil
		rewardFrame = nil
		rewardLabel = nil
		notificationFrame = nil
		notificationLabel = nil
	end
end

return LobbyUI
