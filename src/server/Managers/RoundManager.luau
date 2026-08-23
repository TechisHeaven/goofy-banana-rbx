local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local GameConfig = require(Shared.GameConfig)
local Enums = require(Shared.Enums)

local PlayerManager = require(script.Parent.PlayerManager)
local SpawnManager = require(script.Parent.SpawnManager)
local FreezeManager = require(script.Parent.FreezeManager)
local LobbyManager = require(script.Parent.LobbyManager)
local RoundEventManager = require(script.Parent.RoundEventManager)
local CursorController = require(Shared.Modules.CursorModule)
local VictoryManager = require(script.Parent.VictoryManager)
local NotificationManager = require(script.Parent.NotificationManager)
local RoundStatsManager = require(script.Parent.RoundStatsManager)
local GameplayItemManager =
	require(script.Parent.GameplayItemManager)

local TaskManager = require(script.Parent.TaskManager)
local TaskEvents = require(Shared.EnumsEvents.TaskEvents)

local CoinManager = require(script.Parent.CoinManager)
local GamemodeManager =
	require(script.Parent.GamemodeManager)

local PromptUtil =
	require(
		Shared.Utils.PromptUtil
	)

	
local RoundManager = {}

------------------------------------------------
-- State
------------------------------------------------

RoundManager.CurrentState = Enums.RoundState.Waiting
RoundManager.LastWinner = nil
RoundManager.TimeRemaining = 0
RoundManager.CurrentHunter = nil



------------------------------------------------
-- Gamemode Context
------------------------------------------------

function RoundManager:GetGamemodeContext()

	return {
		RoundManager = self,

		Players = self.RoundPlayers,

		Hunter = self.CurrentHunter,

		PlayerManager = PlayerManager,
		FreezeManager = FreezeManager,
		RoundStatsManager = RoundStatsManager,
		RoundEventManager = RoundEventManager,
	}

end


------------------------------------------------
-- Waiting
------------------------------------------------

function RoundManager:WaitForPlayers()

	self.CurrentState = Enums.RoundState.Waiting

	LobbyManager:UpdateMatchStatus(
		Enums.RoundState.Waiting,
		0
	)

	local minimumPlayers =
		GameConfig.Round.MinimumPlayers

	while LobbyManager:GetQueueCount() < minimumPlayers do
		task.wait(1)
	end

end

------------------------------------------------
-- Intermission
------------------------------------------------

function RoundManager:RunIntermission()

	self.CurrentState =
		Enums.RoundState.Intermission

	local duration =
		GameConfig.Round.IntermissionTime

	for i = duration, 1, -1 do

		LobbyManager:UpdateMatchStatus(
			Enums.RoundState.Intermission,
			i
		)

		task.wait(1)

	end

	local players =
		LobbyManager:GetQueue()

	if #players < GameConfig.Round.MinimumPlayers then
		return false
	end

	self.RoundPlayers = players

	return true

end

------------------------------------------------
-- Start Round
------------------------------------------------

function RoundManager:StartRound()

	self.CurrentState =
		Enums.RoundState.Starting

	LobbyManager:UpdateMatchStatus(
		Enums.RoundState.Starting,
		0
	)

	LobbyManager:SetInMatch(
		self.RoundPlayers
	)
	for _, player in ipairs(self.RoundPlayers) do
		-- Remove it Later
		GameplayItemManager:Give(
			player,
			"Banana"
		)

		-- GameplayItemManager:Select(
		-- 	player,
		-- 	"Banana"
		-- )

	end
	self.CurrentHunter =
		self:SelectHunter(
			self.RoundPlayers
		)

	self:AssignTeams(
		self.RoundPlayers,
		self.CurrentHunter
	)

	SpawnManager:TeleportPlayers(
		self.RoundPlayers,
		self.CurrentHunter
	)

	FreezeManager:ApplyHunterCooldown(
		self.CurrentHunter,
		GameConfig.Hunter.CooldownTime
	)

	LobbyManager:FireTeleportToArena(
		self.RoundPlayers,
		self.CurrentHunter
	)

	CursorController:EnterGameplay()

	NotificationManager:Broadcast(
		"Round Started!",
		Enums.NotificationTarget.Gameplay
	)

	------------------------------------------------
	-- Initialize round stats
	------------------------------------------------

	RoundStatsManager:StartRound(
		self.RoundPlayers,
		self.CurrentHunter
	)

	------------------------------------------------
	-- Start coins
	------------------------------------------------

	CoinManager:StartRound()

	------------------------------------------------
	-- Reset round state
	------------------------------------------------

	self.LastWinner = nil
	self.VictoryPlayer = nil

	self.TimeRemaining =
		GameConfig.Round.RoundTime

	GamemodeManager:StartRound(
		self:GetGamemodeContext()
	)
end

------------------------------------------------
-- Run Round
------------------------------------------------

function RoundManager:RunRound()

	self.CurrentState =
		Enums.RoundState.Playing

	while self.TimeRemaining > 0
		and self.CurrentState
			== Enums.RoundState.Playing do

		task.wait(1)

		self.TimeRemaining -= 1

		------------------------------------------------
		-- Round stats
		------------------------------------------------

		RoundStatsManager:Tick(1)

		------------------------------------------------
		-- TASK:
		-- Survival time
		------------------------------------------------

		for _, player in ipairs(
			LobbyManager:GetInMatchPlayers()
		) do

			------------------------------------------------
			-- Only alive players receive survival progress
			------------------------------------------------

			if
				PlayerManager:GetTeam(player)
					== Enums.Team.Runner
				and
				RoundStatsManager:IsAlive(player)
			then

				TaskManager:AddProgress(
					player,
					TaskEvents.SurvivalSecond,
					1,
					false
				)

			end

		end

		------------------------------------------------
		-- Update round timer
		------------------------------------------------

		LobbyManager:UpdateMatchStatus(
			Enums.RoundState.Playing,
			self.TimeRemaining
		)

	end

	------------------------------------------------
	-- Time expired
	------------------------------------------------

	if self.CurrentState
		== Enums.RoundState.Playing then

		self.LastWinner = "Runners"

		RoundStatsManager:SetWinner(
			"Runners"
		)

	end

end

------------------------------------------------
-- Add Round Tasks
------------------------------------------------

function RoundManager:ProcessRoundTasks(players)

	for _, player in ipairs(players) do

		------------------------------------------------
		-- Every participant played the round
		------------------------------------------------

		TaskManager:AddProgress(
			player,
			TaskEvents.RoundPlayed,
			1,
			false
		)

		------------------------------------------------
		-- Determine team
		------------------------------------------------

		local team =
			PlayerManager:GetTeam(player)

		------------------------------------------------
		-- Round winner
		------------------------------------------------

		if self.LastWinner == "Hunter" then

			if team == Enums.Team.Hunter then

				TaskManager:AddProgress(
					player,
					TaskEvents.RoundWon,
					1,
					false
				)

				TaskManager:AddProgress(
					player,
					TaskEvents.HunterWin,
					1,
					false
				)

			end

		elseif self.LastWinner == "Runners" then

			if team == Enums.Team.Runner then

				TaskManager:AddProgress(
					player,
					TaskEvents.RoundWon,
					1,
					false
				)

				TaskManager:AddProgress(
					player,
					TaskEvents.RunnerWin,
					1,
					false
				)

			end

		end

	end

	------------------------------------------------
	-- Refresh UI once after all updates
	------------------------------------------------

	for _, player in ipairs(players) do

		TaskManager:SendTasks(player)

	end

end

------------------------------------------------
-- End Round
------------------------------------------------

function RoundManager:EndRound()

	self.CurrentState =
		Enums.RoundState.Ending

	GamemodeManager:EndRound(
		self:GetGamemodeContext()
	)

	FreezeManager:UnfreezeAll()

	LobbyManager:UpdateMatchStatus(
		Enums.RoundState.Ending,
		0
	)

	NotificationManager:Broadcast(
		"Round Ended!",
		Enums.NotificationTarget.Gameplay
	)

	------------------------------------------------
	-- Runner alive bonus
	------------------------------------------------

	if self.LastWinner == "Runners" then
		RoundStatsManager:AwardAliveBonus()
	end

	------------------------------------------------
	-- Get players before cleanup
	------------------------------------------------

	local players =
		LobbyManager:GetInMatchPlayers()

	------------------------------------------------
	-- TASKS
	------------------------------------------------

	self:ProcessRoundTasks(
		players
	)

	------------------------------------------------
	-- Determine MVP
	------------------------------------------------

	self.VictoryPlayer =
		self:DetermineVictoryPlayer()

	------------------------------------------------
	-- Victory animation
	------------------------------------------------

	if self.VictoryPlayer then
		print("victoryPlayer", self.VictoryPlayer)
		VictoryManager:Play(
			self.VictoryPlayer,
			players
		)

	end

	task.wait(
		GameConfig.Round.DefaultVictoryWinDuration
	)

	------------------------------------------------
	-- Round ended event
	------------------------------------------------

	if self.CurrentHunter then

		RoundEventManager:FireRoundEnded(
			players,
			{
				winner = self.LastWinner,

				hunter =
					self.CurrentHunter.Name,

				victoryPlayer =
					self.VictoryPlayer
					and self.VictoryPlayer.Name
					or nil,
			}
		)

	end

	task.wait(
		GameConfig.Round.EndTime
	)

end

------------------------------------------------
-- Cleanup
------------------------------------------------

function RoundManager:CleanupRound()

	PromptUtil:ClearAll()
	
	GamemodeManager:Cleanup(
		self:GetGamemodeContext()
	)
	
	CoinManager:StopRound()

	CursorController:EnterLobby()

	RoundStatsManager:ResetRound()

	local players =
		LobbyManager:GetInMatchPlayers()

	for _, player in ipairs(players) do
		
		GameplayItemManager:ClearVisual(
			player
		)
		local item = GameplayItemManager:GetItem(player)
		GameplayItemManager:Remove(player, item)
	end

	LobbyManager:ReturnAllToLobby(
		players
	)

	LobbyManager:AutoRequeue(
		players
	)

	self.CurrentHunter = nil
	self.TimeRemaining = 0
	self.LastWinner = nil
	self.VictoryPlayer = nil
	self.RoundPlayers = nil

	task.wait(
		GameConfig.Lobby.PostRoundReturnDelay
		or 3
	)

end

------------------------------------------------
-- Select Hunter
------------------------------------------------

function RoundManager:SelectHunter(players)

	local index =
		math.random(#players)

	return players[index]

end

------------------------------------------------
-- Assign Teams
------------------------------------------------

function RoundManager:AssignTeams(
	players,
	hunter
)

	for _, player in ipairs(players) do

		if player == hunter then

			PlayerManager:SetTeam(
				player,
				Enums.Team.Hunter
			)

		else

			PlayerManager:SetTeam(
				player,
				Enums.Team.Runner
			)

		end

	end

end

------------------------------------------------
-- Determine MVP
------------------------------------------------

function RoundManager:DetermineVictoryPlayer()

	if self.CurrentMode == "Infected" then
		return RoundStatsManager:GetMVP()
	end

	if self.LastWinner == "Hunter" then
		return self.CurrentHunter
	end
	return RoundStatsManager:GetMVP()

end

------------------------------------------------
-- Game Loop
------------------------------------------------

function RoundManager:StartGameLoop()

	task.spawn(function()

		while true do

			self:WaitForPlayers()

			if not self:RunIntermission() then
				continue
			end

			self:StartRound()

			self:RunRound()

			self:EndRound()

			self:CleanupRound()

		end

	end)

end

------------------------------------------------
-- Win Condition
------------------------------------------------

function RoundManager:CheckWinCondition()

	if self.CurrentState
		~= Enums.RoundState.Playing then

		return

	end

	local aliveRunners =
		RoundStatsManager:GetAliveRunners()

	if aliveRunners == 0 then

		print(
			"Hunter wins!"
		)

		self.LastWinner =
			"Hunter"

		RoundStatsManager:SetWinner(
			"Hunter"
		)

		------------------------------------------------
		-- Instant slow motion
		------------------------------------------------

		local players =
			LobbyManager:GetInMatchPlayers()

		RoundEventManager:FireSlowMo(
			players,
			{
				Duration =
					GameConfig.Game.DefaultSlowMoDuration,

				Speed =
					GameConfig.Game.DefaultSlowMoSpeed,

				FOV =
					GameConfig.Game.DefaultSlowMoFOV,
			}
		)

		task.wait(GameConfig.Game.DefaultSlowMoDuration)
		------------------------------------------------
		-- End immediately
		------------------------------------------------

		self:EndRoundEarly()

	end

end

------------------------------------------------
-- End Round Early
------------------------------------------------

function RoundManager:EndRoundEarly()

	if self.CurrentState
		== Enums.RoundState.Playing then

		self.CurrentState =
			Enums.RoundState.Ending

	end

end

------------------------------------------------
-- Late Join
------------------------------------------------

function RoundManager:CanLateJoin()

	if not GameConfig.Round.AllowLateJoin then
		return false
	end

	if self.CurrentState
		~= Enums.RoundState.Playing then

		return false

	end

	return self.TimeRemaining
		> GameConfig.Round.LateJoinCutoff

end

------------------------------------------------
-- Add Late Joiner
------------------------------------------------

function RoundManager:AddLateJoiner(player)

	PlayerManager:SetTeam(
		player,
		Enums.Team.Runner
	)

	RoundStatsManager:AddLateJoiner(
		player
	)

	GamemodeManager:OnPlayerAdded(
		self:GetGamemodeContext(),
		player
	)
	
	TaskManager:PlayerLoaded(
		player
	)

	PlayerManager:ResetPlayer(
		player
	)

	LobbyManager:SetPlayerInMatch(
		player
	)

	GameplayItemManager:Give(
		player,
		"Banana"
	)

	SpawnManager:SpawnRunner(
		player
	)

	LobbyManager:FireTeleportToArena(
		{ player },
		self.CurrentHunter
	)

	
end

------------------------------------------------
-- Init
------------------------------------------------

function RoundManager:Init()

	print(
		"RoundManager Initializing..."
	)

	------------------------------------------------
	-- Join request
	------------------------------------------------

	LobbyManager.OnJoinRequest =
		function(player)

			if self:CanLateJoin() then

				self:AddLateJoiner(
					player
				)

			else

				LobbyManager:AddToQueue(
					player
				)

			end

		end

	------------------------------------------------
	-- Player leaving
	------------------------------------------------

	Players.PlayerRemoving:Connect(
		function(player)
			GamemodeManager:OnPlayerRemoved(
				self:GetGamemodeContext(),
				player
			)
			RoundStatsManager:RemovePlayer(
				player
			)

			self:CheckWinCondition()

		end
	)

	------------------------------------------------
	-- Start
	------------------------------------------------

	self:StartGameLoop()

end

return RoundManager