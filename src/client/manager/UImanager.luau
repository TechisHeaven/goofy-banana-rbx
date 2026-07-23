local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local UIManager = {}

local LobbyGui = PlayerGui:WaitForChild("LobbyGui")
local GameGui = PlayerGui:WaitForChild("GameGui")

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

return UIManager