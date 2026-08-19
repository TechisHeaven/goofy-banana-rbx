local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerGui =
	Players.LocalPlayer:WaitForChild("PlayerGui")

local ResultGui =
	PlayerGui:WaitForChild("PopupGui")

local GameConfig =
	require(ReplicatedStorage.Shared.GameConfig)

local Enum =
	require(ReplicatedStorage.Shared.Enums)

local PopupManager =
	require(ReplicatedStorage.Shared.Modules.PopupModule)

local ResultUI = {}

------------------------------------------------
-- UI
------------------------------------------------

local Overlay =
	ResultGui.Overlay

local ResultFrame =
	Overlay.ResultFrame

------------------------------------------------
-- CONFIG
------------------------------------------------

local DEFAULT_REDIRECT_TIME =
	GameConfig.Game.ResultScreenDuration
	or GameConfig.Game.EndTime
	or 5

local LOOSE_IMAGE =
	"rbxassetid://123968522269893"

local WIN_IMAGE =
	"rbxassetid://114773308781289"

local VIOLET =
	"#9D5CFF"

------------------------------------------------
-- STATE
------------------------------------------------

local CountdownTask = nil

-- Used to invalidate old Show/Hide tasks
local ResultVersion = 0

------------------------------------------------
-- HIDE
------------------------------------------------

local function hideAll()

	ResultFrame.Visible = false

end

------------------------------------------------
-- TIMER
------------------------------------------------

local function FormatTimer(seconds)

	return string.format(
		"%02d",
		math.max(seconds, 0)
	)

end

local function UpdateTimer(
	label,
	seconds
)

	label.RichText = true

	label.Text = string.format(
		'Redirecting to lobby in <font color="%s"><font size="22">%s</font></font> seconds',
		VIOLET,
		FormatTimer(seconds)
	)

end

------------------------------------------------
-- CANCEL CURRENT COUNTDOWN
------------------------------------------------

local function CancelCountdown()

	if CountdownTask then

		task.cancel(
			CountdownTask
		)

		CountdownTask = nil

	end

end

------------------------------------------------
-- SHOW
------------------------------------------------

function ResultUI:Show(data)

	------------------------------------------------
	-- Invalidate anything from previous result
	------------------------------------------------

	ResultVersion += 1

	local currentVersion =
		ResultVersion

	------------------------------------------------
	-- Cancel previous countdown
	------------------------------------------------

	CancelCountdown()

	------------------------------------------------
	-- Reset UI
	------------------------------------------------

	hideAll()

	print(
		"[ResultUI] Show:",
		data,
		"Won:",
		data.won
	)

	------------------------------------------------
	-- WIN / LOSS IMAGE
	------------------------------------------------

	if data.won then

		ResultFrame.ResultImage.Image =
			WIN_IMAGE

		ResultFrame.ResultImage.Size =
			UDim2.fromOffset(
				334,
				120
			)

	else

		ResultFrame.ResultImage.Image =
			LOOSE_IMAGE

		ResultFrame.ResultImage.Size =
			UDim2.fromOffset(
				396,
				120
			)

	end

	------------------------------------------------
	-- WINNER TEXT
	------------------------------------------------

	local winnerText

	local HunterText =
		Enum.Team.Hunter
		or "Hunter"

	if data.winner == HunterText then

		winnerText =
			'<font color="#ff0000">'
			.. tostring(data.winner)
			.. "</font>"

	else

		winnerText =
			'<font color="#3db5f5">'
			.. tostring(data.winner)
			.. "</font>"

	end

	ResultFrame.Subtitle.RichText = true

	ResultFrame.Subtitle.Text =
		string.format(
			"%s Wins. Run Better Luck Next Time!",
			winnerText
		)

	------------------------------------------------
	-- REWARDS
	------------------------------------------------

	ResultFrame.Rewards.XP.Text =
		"+" .. tostring(
			data.stats.MVPScore
		)

	ResultFrame.Rewards.Coins.Text =
		"+" .. tostring(
			data.stats.Coins
		)

	------------------------------------------------
	-- STATS
	------------------------------------------------

	ResultFrame.Stats.Survival.Text =
		tostring(
			data.stats.SurvivalTime
		)

	ResultFrame.Stats.Rescues.Text =
		tostring(
			data.stats.Rescues
		)

	ResultFrame.Stats.Frozen.Text =
		tostring(
			data.stats.FrozenPlayers
		)

	------------------------------------------------
	-- SHOW
	------------------------------------------------

	ResultFrame.Visible = true

	PopupManager:Open(
		ResultFrame,
		{
			CanClickOutsideToClose = false,
			ReopenPreviousOnClose = false,
		}
	)

	------------------------------------------------
	-- COUNTDOWN
	------------------------------------------------

	local timerLabel =
		ResultFrame.Timer

	local duration =
		DEFAULT_REDIRECT_TIME

	CountdownTask = task.spawn(function()

		for i = duration, 0, -1 do

			------------------------------------------------
			-- Stop if another result was shown
			------------------------------------------------

			if currentVersion ~= ResultVersion then
				return
			end

			UpdateTimer(
				timerLabel,
				i
			)

			if i > 0 then
				task.wait(1)
			end

		end

		------------------------------------------------
		-- Make sure this is still
		-- the current result
		------------------------------------------------

		if currentVersion ~= ResultVersion then
			return
		end

		CountdownTask = nil

		self:Hide()

	end)

end

------------------------------------------------
-- HIDE
------------------------------------------------

function ResultUI:Hide()

	------------------------------------------------
	-- Invalidate current result
	------------------------------------------------

	ResultVersion += 1

	------------------------------------------------
	-- Cancel countdown
	------------------------------------------------

	CancelCountdown()

	------------------------------------------------
	-- Close popup
	------------------------------------------------

	PopupManager:Close(
		ResultFrame
	)

	ResultFrame.Visible = false

end

return ResultUI