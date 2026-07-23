-- LobbyManager.luau
-- Owns the player queue and lobby state.
-- Creates all RemoteEvent instances at runtime (server-authoritative).
-- Responsibilities:
--   • Track each player's LobbyState (InLobby / Queued / InMatch)
--   • Handle RequestJoinQueue / RequestLeaveQueue from clients
--   • Broadcast UpdateLobbyStatus to all clients
--   • Move players between states when RoundManager asks
--   • Auto-requeue players after a round ends

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local Shared      = ReplicatedStorage:WaitForChild("Shared")
local Enums       = require(Shared.Enums)
local GameConfig  = require(Shared.GameConfig)
local RemoteIndex = require(Shared.Remotes.RemoteIndex)

local SpawnManager  = require(script.Parent.SpawnManager)
local PlayerManager = require(script.Parent.PlayerManager)

local LobbyManager = {}

-- ─── Internal state ──────────────────────────────────────────────────────────

local queue: { Player }          = {}   -- ordered list of queued players
local lobbyStates: {[Player]: string} = {}  -- per-player lobby state
local inMatchSet:  {[Player]: boolean} = {} -- fast lookup for in-match players

-- Cached remote references (filled in Init)
local remotesFolder = nil
local remotes: { [string]: RemoteEvent } = {}

-- Current match status for broadcasting
local matchStatus = {
	state    = Enums.RoundState.Waiting,
	timeLeft = 0,
}

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function getRemote(name: string): RemoteEvent?
	if remotes[name] then return remotes[name] end
	warn("LobbyManager: Remote '" .. name .. "' not cached yet")
	return nil
end

local function isInQueue(player: Player): boolean
	for _, p in ipairs(queue) do
		if p == player then return true end
	end
	return false
end

local function buildStatusPayload()
	local hunterName = "None"
	local aliveRunners = 0
	local frozenRunners = 0
	local totalRunners = 0

	for player, _ in pairs(inMatchSet) do
		if player and player.Parent then
			local team = PlayerManager:GetTeam(player)
			if team == Enums.Team.Hunter then
				hunterName = player.Name
			elseif team == Enums.Team.Runner then
				totalRunners += 1
				local state = PlayerManager:GetState(player)
				if state == Enums.PlayerState.Frozen then
					frozenRunners += 1
				elseif state == Enums.PlayerState.Alive then
					aliveRunners += 1
				end
			end
		end
	end

	return {
		state          = matchStatus.state,
		timeLeft       = matchStatus.timeLeft,
		queueCount     = #queue,
		totalPlayers   = #Players:GetPlayers(),
		hunterName     = hunterName,
		aliveRunners   = aliveRunners,
		frozenRunners  = frozenRunners,
		remainingRunners = totalRunners,
	}
end

-- ─── Public API ──────────────────────────────────────────────────────────────

--- Returns a snapshot copy of the queue (callers must not mutate it).
function LobbyManager:GetQueue(): {Player}
	local copy = {}
	for i, p in ipairs(queue) do copy[i] = p end
	return copy
end

function LobbyManager:GetQueueCount(): number
	return #queue
end

function LobbyManager:IsQueued(player: Player): boolean
	return isInQueue(player)
end

function LobbyManager:GetLobbyState(player: Player): string
	return lobbyStates[player] or Enums.PlayerLobbyState.InLobby
end

--- Returns all players currently in a match.
function LobbyManager:GetInMatchPlayers(): {Player}
	local result = {}
	for player, _ in pairs(inMatchSet) do
		table.insert(result, player)
	end
	return result
end

--- Moves a player from InLobby → Queued.
function LobbyManager:AddToQueue(player: Player)
	if lobbyStates[player] ~= Enums.PlayerLobbyState.InLobby then return end

	lobbyStates[player] = Enums.PlayerLobbyState.Queued
	player:SetAttribute("LobbyState", Enums.PlayerLobbyState.Queued)
	table.insert(queue, player)
	print(string.format("LobbyManager: %s joined queue (%d queued)", player.Name, #queue))
	self:BroadcastStatus()
end

--- Moves a player from Queued → InLobby.
function LobbyManager:RemoveFromQueue(player: Player)
	-- Mid-match departures are handled by RoundManager; skip silently.
	if inMatchSet[player] then return end

	for i, p in ipairs(queue) do
		if p == player then table.remove(queue, i) break end
	end

	if player and player.Parent then
		lobbyStates[player] = Enums.PlayerLobbyState.InLobby
		player:SetAttribute("LobbyState", Enums.PlayerLobbyState.InLobby)
	end
	print(string.format("LobbyManager: %s left queue (%d queued)", player.Name, #queue))
	self:BroadcastStatus()
end

--- Snapshot the queue, move all those players to InMatch, clear the queue.
--- Called by RoundManager right before teleporting players to the arena.
function LobbyManager:SetInMatch(players: {Player})
	queue = {}
	for _, player in ipairs(players) do
		inMatchSet[player]  = true
		lobbyStates[player] = Enums.PlayerLobbyState.InMatch
		player:SetAttribute("LobbyState", Enums.PlayerLobbyState.InMatch)
	end
	self:BroadcastStatus()
end

--- Returns all in-match players to lobby:
---   resets PlayerManager state, teleports, fires ReturnToLobby remote.
function LobbyManager:ReturnAllToLobby(players: {Player})
	for _, player in ipairs(players) do
		inMatchSet[player] = nil
		if player and player.Parent then
			PlayerManager:ResetPlayer(player)
			lobbyStates[player] = Enums.PlayerLobbyState.InLobby
			player:SetAttribute("LobbyState", Enums.PlayerLobbyState.InLobby)

			local re = getRemote(RemoteIndex.ReturnToLobby)
			if re then re:FireClient(player) end
		end
	end

	SpawnManager:TeleportToLobby(players)
	self:BroadcastStatus()
end

--- Auto-re-queues players after a short delay (auto-ready behaviour).
--- Only re-queues a player if they are still in the game and in InLobby state.
function LobbyManager:AutoRequeue(players: {Player})
	local delay = (GameConfig.Lobby and GameConfig.Lobby.AutoRequeueDelay) or 2
	task.delay(delay, function()
		for _, player in ipairs(players) do
			if player and player.Parent
				and lobbyStates[player] == Enums.PlayerLobbyState.InLobby
			then
				self:AddToQueue(player)
			end
		end
	end)
end

--- Fires ShowWinnerScreen to all in-match players.
function LobbyManager:FireWinnerScreen(winner: string, hunterName: string?, rewardPreview: string?)
	local re = getRemote(RemoteIndex.ShowWinnerScreen)
	if not re then return end
	local data = {
		winnerTeam = winner,
		hunterName = hunterName or "Unknown",
		winner = winner,
		rewardPreview = rewardPreview or "XP +15\nCoins +8",
	}
	for player, _ in pairs(inMatchSet) do
		if player and player.Parent then
			re:FireClient(player, data)
		end
	end
end

--- Updates the cached match status and broadcasts to all clients.
function LobbyManager:UpdateMatchStatus(state: string, timeLeft: number)
	matchStatus.state    = state
	matchStatus.timeLeft = timeLeft
	self:BroadcastStatus()
end

--- Broadcasts the current match status to every connected client.
function LobbyManager:BroadcastStatus()
	local re = getRemote(RemoteIndex.UpdateLobbyStatus)
	if not re then return end
	re:FireAllClients(buildStatusPayload())
end

-- ─── Internal lifecycle ───────────────────────────────────────────────────────

local function onPlayerAdded(player: Player)
	lobbyStates[player] = Enums.PlayerLobbyState.InLobby
	player:SetAttribute("LobbyState", Enums.PlayerLobbyState.InLobby)
	print(string.format("LobbyManager: %s registered (InLobby)", player.Name))

	-- Send them the current status immediately
	task.defer(function()
		local re = getRemote(RemoteIndex.UpdateLobbyStatus)
		if re then re:FireClient(player, buildStatusPayload()) end
	end)
end

local function onPlayerRemoving(player: Player)
	for i, p in ipairs(queue) do
		if p == player then table.remove(queue, i) break end
	end
	inMatchSet[player]  = nil
	lobbyStates[player] = nil
	print(string.format("LobbyManager: %s removed", player.Name))
	LobbyManager:BroadcastStatus()
end

-- ─── Init ─────────────────────────────────────────────────────────────────────

function LobbyManager:Init()
	print("LobbyManager Initializing...")

	local shared = ReplicatedStorage:WaitForChild("Shared")
	remotesFolder = shared:WaitForChild("Remotes")

	-- Cache (or create) each RemoteEvent listed in RemoteIndex
	for _, name in pairs(RemoteIndex) do
		local existing = remotesFolder:FindFirstChild(name)
		if existing and existing:IsA("RemoteEvent") then
			remotes[name] = existing
		else
			local re   = Instance.new("RemoteEvent")
			re.Name    = name
			re.Parent  = remotesFolder
			remotes[name] = re
		end
	end

	-- Client → server: player pressed Play
	remotes[RemoteIndex.RequestJoinQueue].OnServerEvent:Connect(function(player)
		print(string.format("LobbyManager: RequestJoinQueue from %s", player.Name))
		self:AddToQueue(player)
	end)

	-- Client → server: player cancelled queue
	remotes[RemoteIndex.RequestLeaveQueue].OnServerEvent:Connect(function(player)
		print(string.format("LobbyManager: RequestLeaveQueue from %s", player.Name))
		self:RemoveFromQueue(player)
	end)

	-- Player lifecycle
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	-- Register anyone already in the server (play-testing / late loading)
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end

	-- Recurring status broadcast so the match timer ticks on clients
	task.spawn(function()
		local rate = (GameConfig.Lobby and GameConfig.Lobby.StatusUpdateRate) or 1
		while true do
			task.wait(rate)
			self:BroadcastStatus()
		end
	end)
end

return LobbyManager
