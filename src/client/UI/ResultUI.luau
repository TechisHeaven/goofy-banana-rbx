local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local ResultGui = PlayerGui:WaitForChild("PopupGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local PopupManager = require(ReplicatedStorage.Shared.Modules.PopupModule)

local ResultUI = {}

local Overlay = ResultGui.Overlay

local WinFrame = Overlay.WinFrame
local LooseFrame = Overlay.LooseFrame

-- PopupManager:Init(Overlay)

-------------------------------------------------------

local function hideAll()

    WinFrame.Visible = false
    LooseFrame.Visible = false

end

-------------------------------------------------------

function ResultUI:Show(data)

    hideAll()

    local frame

    if data.won then
        frame = WinFrame
    else
        frame = LooseFrame
    end

    --------------------------------------------------
    -- Title
    --------------------------------------------------

    frame.Title.Text = data.won and "WIN" or "LOSE"

    frame.Subtitle.Text =
        string.format(
            "%s Wins!",
            data.winner
        )

    --------------------------------------------------
    -- Rewards
    --------------------------------------------------

    frame.Rewards.XP.Text =
        "+" .. data.reward.xp

    frame.Rewards.Coins.Text =
        "+" .. data.reward.coins

    --------------------------------------------------
    -- Stats
    --------------------------------------------------

    frame.Stats.Survival.Text =
        tostring(data.stats.survivalTime)

    frame.Stats.Rescues.Text =
        tostring(data.stats.rescues)

    frame.Stats.Frozen.Text =
        tostring(data.stats.frozenPlayers)

    frame.Visible = true

    --------------------------------------------------
    PopupManager:Open(frame)

    task.delay(GameConfig.Game.ResultScreenDuration or GameConfig.Game.EndTime, function()
      self.Hide()
  end)

end

-------------------------------------------------------

function ResultUI:Hide()

    PopupManager:CloseCurrent()

end

return ResultUI