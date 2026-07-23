local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Enums = require(Shared.Enums)

local PlayerManager = {}
local playersData = {} -- Map of Player -> { Team: string, State: string }

-- Registers a player with initial default values
function PlayerManager:RegisterPlayer(player: Player)
	if playersData[player] then
		return
	end
	
	playersData[player] = {
		Team = Enums.Team.Runner,
		State = Enums.PlayerState.Alive
	}
	
	player:SetAttribute("Team", Enums.Team.Runner)
	player:SetAttribute("State", Enums.PlayerState.Alive)
	player:SetAttribute("LobbyState", Enums.PlayerLobbyState.InLobby)
	
	print(string.format("PlayerManager: Registered %s", player.Name))
end

-- Cleans up a player's session data
function PlayerManager:RemovePlayer(player: Player)
	if playersData[player] then
		playersData[player] = nil
		print(string.format("PlayerManager: Removed %s", player.Name))
	end
end

-- Sets a player's team
function PlayerManager:SetTeam(player: Player, team: string)
	local data = playersData[player]
	if data then
		data.Team = team
		player:SetAttribute("Team", team)
		print(string.format("PlayerManager: Set %s's team to %s", player.Name, team))
	else
		warn(string.format("PlayerManager: Attempted to set team for unregistered player %s", player.Name))
	end
end

-- Returns a player's team, or nil if not registered
function PlayerManager:GetTeam(player: Player): string?
	local data = playersData[player]
	return data and data.Team
end

-- Sets a player's round-specific state (Alive, Frozen, Rescuing)
function PlayerManager:SetState(player: Player, state: string)
	local data = playersData[player]
	if data then
		data.State = state
		player:SetAttribute("State", state)
		print(string.format("PlayerManager: Set %s's state to %s", player.Name, state))
	else
		warn(string.format("PlayerManager: Attempted to set state for unregistered player %s", player.Name))
	end
end

-- Returns a player's round-specific state, or nil if not registered
function PlayerManager:GetState(player: Player): string?
	local data = playersData[player]
	return data and data.State
end

-- Resets player state and team to default valus
function PlayerManager:ResetPlayer(player: Player)
	local data = playersData[player]
	if data then
		data.Team = Enums.Team.Runner
		data.State = Enums.PlayerState.Alive
		player:SetAttribute("Team", Enums.Team.Runner)
		player:SetAttribute("State", Enums.PlayerState.Alive)
		player:SetAttribute("LobbyState", Enums.PlayerLobbyState.InLobby)
		print(string.format("PlayerManager: Reset %s to Runner / Alive / InLobby", player.Name))
	else
		-- If they aren't registered for some reason, register them
		self:RegisterPlayer(player)
	end
end

function PlayerManager:Init()
	print("PlayerManager Initializing...")
	
	-- Connect event listeners
	Players.PlayerAdded:Connect(function(player)
		self:RegisterPlayer(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		self:RemovePlayer(player)
	end)
	
	-- Register any players already in the server (e.g. play testing / late loading)
	for _, player in ipairs(Players:GetPlayers()) do
		self:RegisterPlayer(player)
	end
end

return PlayerManager