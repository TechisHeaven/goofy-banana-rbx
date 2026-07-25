local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local ResultGui = PlayerGui:WaitForChild("PopupGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Enum = require(ReplicatedStorage.Shared.Enums)

local PopupManager = require(ReplicatedStorage.Shared.Modules.PopupModule)

local ResultUI = {}

local Overlay = ResultGui.Overlay

local ResultFrame = Overlay.ResultFrame

local CountdownTask
local DEFAULT_REDIRECT_TIME = GameConfig.Game.ResultScreenDuration or GameConfig.Game.EndTime or 5

local LOOSE_IMAGE = "rbxassetid://123968522269893"
local WIN_IMAGE = "rbxassetid://114773308781289"
local VIOLET = "#9D5CFF" -- Change to your theme color

-- PopupManager:Init(Overlay)

-------------------------------------------------------

local function hideAll()

    ResultFrame.Visible = false

end


-- Utility functions for formatting and updating the timer
local function FormatTimer(seconds)
	return string.format("%02d", math.max(seconds, 0))
end

local function UpdateTimer(label, seconds)
	label.RichText = true

	label.Text = string.format(
		'Redirecting to lobby in <font color="%s"><font size="22">%s</font></font> seconds',
		VIOLET,
		FormatTimer(seconds)
	)
end

-------------------------------------------------------

function ResultUI:Show(data)

    hideAll()

    if data.won then
        -- frame = WinFrame
        ResultFrame.ResultImage.Image = WIN_IMAGE
        ResultFrame.ResultImage.Size = UDim2.fromOffset(334, 120)
    else
        ResultFrame.ResultImage.Image = LOOSE_IMAGE
        ResultFrame.ResultImage.Size = UDim2.fromOffset(396, 120)
    end

    --------------------------------------------------
    -- Title
    --------------------------------------------------

    local winnerText
    local HunterText = Enum.Team.Hunter or "Hunter"
    if data.winner == HunterText then
        winnerText = '<font color="#ff0000">' .. data.winner .. '</font>'
    else
        winnerText = '<font color="#3db5f5">' .. data.winner .. '</font>'
    end

    ResultFrame.Subtitle.RichText = true
    ResultFrame.Subtitle.Text =
        string.format(
            "%s Wins. Run Better Luck Next Time!",
            winnerText
        )

    --------------------------------------------------
    -- Rewards
    --------------------------------------------------

    ResultFrame.Rewards.XP.Text =
        "+" .. data.reward.xp

    ResultFrame.Rewards.Coins.Text =
        "+" .. data.reward.coins

    --------------------------------------------------
    -- Stats
    --------------------------------------------------

    ResultFrame.Stats.Survival.Text =
        tostring(data.stats.survivalTime)

    ResultFrame.Stats.Rescues.Text =
        tostring(data.stats.rescues)

    ResultFrame.Stats.Frozen.Text =
        tostring(data.stats.frozenPlayers)

    ResultFrame.Visible = true

    --------------------------------------------------
    PopupManager:Open(ResultFrame,{
	    CanClickOutsideToClose = false
    })



--     task.delay(DEFAULT_REDIRECT_TIME, function()
--       self.Hide()
--   end)
if CountdownTask then
	task.cancel(CountdownTask)
end

local timerLabel = ResultFrame.Timer
local duration = DEFAULT_REDIRECT_TIME

CountdownTask = task.spawn(function()

	for i = duration, 0, -1 do
		UpdateTimer(timerLabel, i)

		if i > 0 then
			task.wait(1)
		end
	end

	CountdownTask = nil
	self:Hide()
end)

end





-------------------------------------------------------

function ResultUI:Hide()

    if CountdownTask then
		task.cancel(CountdownTask)
		CountdownTask = nil
	end

    PopupManager:CloseCurrent()

end

return ResultUI