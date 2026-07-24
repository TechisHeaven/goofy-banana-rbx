-- LobbyController.luau
-- Client-side controller for the lobby & queue system.
-- Listens to server remotes, updates LobbyUI, and fires back player actions.

local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Players            = game:GetService("Players")

local LocalPlayer        = Players.LocalPlayer

local Shared             = ReplicatedStorage:WaitForChild("Shared")
local RemoteIndex        = require(Shared.Remotes.RemoteIndex)

local LobbyUI            = require(script.Parent.Parent.UI.LobbyUI)
local UIManager          = require(script.Parent.Parent.manager.UImanager)

local GameConfig  	     = require(Shared.GameConfig)

local LobbyController    = {}

-- Internal state -----------------------------------------------------------
local isQueued  = false
local isInMatch = false

-- Cached remotes -----------------------------------------------------------
local remotesFolder = Shared:WaitForChild("Remotes")

local function getRemote(name: string): RemoteEvent
	return remotesFolder:WaitForChild(name)
end

-- Helpers ------------------------------------------------------------------

local function setQueued(queued: boolean)
	isQueued = queued
	LobbyUI:SetQueued(queued)
end

local function syncLobbyStateFromServer()
	local lobbyState = LocalPlayer:GetAttribute("LobbyState")
	local queuedFromServer = lobbyState == "Queued"
	if isInMatch then
		queuedFromServer = false
	end
	setQueued(queuedFromServer)
end

-- Queue actions ------------------------------------------------------------

-- local function onPlayPressed()
-- 	if isQueued or isInMatch then return end
-- 	print("LobbyController: Requesting join queue")
-- 	getRemote(RemoteIndex.RequestJoinQueue):FireServer()
-- 	setQueued(true)
-- end

local function onPlayPressed()

	print("Play pressed")
	print("isQueued =", isQueued)
	print("isInMatch =", isInMatch)

	if isQueued or isInMatch then
		print("Blocked from joining")
		return
	end

	print("Firing RequestJoinQueue")

	getRemote(RemoteIndex.RequestJoinQueue):FireServer()

	setQueued(true)

end

local function onCancelPressed()
	if not isQueued then return end
	print("LobbyController: Requesting leave queue")
	getRemote(RemoteIndex.RequestLeaveQueue):FireServer()
	setQueued(false)
end

-- Remote listeners ---------------------------------------------------------

--- UpdateLobbyStatus — keeps the status board current
local function onUpdateLobbyStatus(payload)
	if not payload then return end
	if not isInMatch then
		syncLobbyStateFromServer()
	end
	LobbyUI:UpdateStatus(payload)

	-- Update the in-game timer
	if payload.state == "Playing" then
	-- 	UIManager:SetTimer(payload.timeLeft)
	-- 	UIManager:SetFrozenPlayers(
	-- 	payload.frozenRunners,
	-- 	payload.remainingRunners
	-- )
		UIManager:UpdateRoundInfo(payload)
	end

	-- if payload.hunterName then
	-- 	UIManager:SetHunterName(payload.hunterName)
	-- end

	-- UIManager:SetRunnerCount(payload.aliveRunners)
end

--- RoundStarting — intermission has begun for queued players
local function onRoundStarting(seconds: number)
	print(string.format("LobbyController: Round starting in %ds!", seconds))
	setQueued(true)
	LobbyUI:ShowCountdown(seconds)
end

--- TeleportToArena — round has officially started, switch to arena HUD
-- local function onTeleportToArena(hunterName: string)
-- 	print("LobbyController: Match started. Switching to arena HUD.")
-- 	isInMatch = true
-- 	isQueued  = false
-- 	LobbyUI:SetQueued(false)
-- 	UIManager:ShowGame()
-- 	-- TODO: enable arena HUD when it is implemented
-- end

local function onTeleportToArena(data)
	isInMatch = true
	isQueued  = false
	LobbyUI:SetQueued(false)
	UIManager:ShowGame()
	print(data)
	UIManager:SetRole(data.role)
	UIManager:SetTimer(data.roundTime)

end

--- ReturnToLobby — round over, restore lobby UI
local function onReturnToLobby()
	print("LobbyController: Returning to lobby.")
	isInMatch = false
	setQueued(false)
	LobbyUI:SetQueued(false)
	UIManager:ShowLobby()
end

--- ShowWinnerScreen — show winner + rewards overlay
local function onShowWinnerScreen(info)
	if not info then info = {} end
	local winnerTeam = info.winnerTeam or info.winner or "Unknown"
	local hunterName = info.hunterName or "Unknown"
	print(string.format("LobbyController: Winner screen — %s", winnerTeam))
	LobbyUI:ShowWinnerScreen({
		winnerTeam = winnerTeam,
		hunterName = hunterName,
		rewardPreview = info.rewardPreview,
	})
end

local function onNotifyPlayer(message)
	if not message then return end
	UIManager:ShowNotification(message, GameConfig.Game.NotificationDuration)
end

-- Init ---------------------------------------------------------------------

function LobbyController:Init()
	print("LobbyController Initializing...")

	-- Init Lobby
	LobbyUI:Init()
	UIManager:ShowLobby()
	LobbyUI.OnPlayPressed   = onPlayPressed
	LobbyUI.OnCancelPressed = onCancelPressed

	-- Wire up server → client remotes
	getRemote(RemoteIndex.UpdateLobbyStatus).OnClientEvent:Connect(onUpdateLobbyStatus)
	getRemote(RemoteIndex.RoundStarting).OnClientEvent:Connect(onRoundStarting)
	getRemote(RemoteIndex.TeleportToArena).OnClientEvent:Connect(onTeleportToArena)
	getRemote(RemoteIndex.ReturnToLobby).OnClientEvent:Connect(onReturnToLobby)
	getRemote(RemoteIndex.ShowWinnerScreen).OnClientEvent:Connect(onShowWinnerScreen)
	getRemote(RemoteIndex.NotifyPlayer).OnClientEvent:Connect(onNotifyPlayer)

	-- If the player joins mid-round their LobbyState attribute will be InLobby.
	-- The attribute is replicated by the server so we just need to show the UI.
	local lobbyState = LocalPlayer:GetAttribute("LobbyState")
	if lobbyState == "InMatch" then
		-- Rare edge-case: player somehow has InMatch on join (shouldn't happen)
		isInMatch = true
		LobbyUI:SetQueued(false)
		UIManager:ShowLobby()
	else
		syncLobbyStateFromServer()
	end
end

return LobbyController
