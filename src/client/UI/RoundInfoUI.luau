local Players = game:GetService("Players")

local PlayerGui =
	Players.LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local LevelConfig =
	require(
		Shared.Config.LevelConfig
	)
------------------------------------------------
-- Change these paths to match your UI
------------------------------------------------

local GameGui =
	PlayerGui:WaitForChild("GameGui")

local ModeName =
	GameGui.Left.ModeName

------------------------------------------------

local RoundInfoUI = {}

------------------------------------------------

function RoundInfoUI:SetMode(mode)
    ModeName.Text = mode
end


------------------------------------------------

return RoundInfoUI