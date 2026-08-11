local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players           = game:GetService("Players")

local Shared      = ReplicatedStorage:WaitForChild("Shared")
local GameConfig  = require(Shared.GameConfig)
local Enums       = require(Shared.Enums)

local PlayerManager = require(script.Parent.PlayerManager)
local SpawnManager  = require(script.Parent.SpawnManager)
local FreezeManager = require(script.Parent.FreezeManager)
local LobbyManager  = require(script.Parent.LobbyManager)
local RoundEventManager = require(script.Parent.RoundEventManager)
local CursorController = require(Shared.Modules.CursorModule)
local VictoryManager = require(script.Parent.VictoryManager)
local NotificationManager = require(script.Parent.NotificationManager)
local RoundStatsManager = require(script.Parent.RoundStatsManager)
local TaskManager = require(script.Parent.TaskManager)
local TaskEvents = require(Shared.Enums.TaskEvents)
local CoinManager =
	require(script.Parent.CoinManager)

local RoundManager = {}
	
RoundManager.CurrentState = Enums.RoundState.Waiting
RoundManager.LastWinner   = nil  -- "Hunter" | "Runners" | nil (set before Ending)
RoundManager.TimeRemaining = 0
RoundManager.CurrentHunter = nil


function RoundManager:WaitForPlayers()

	self.CurrentState = Enums.RoundState.Waiting

	LobbyManager:UpdateMatchStatus(
		Enums.RoundState.Waiting,
		0
	)

	local minimumPlayers = GameConfig.Round.MinimumPlayers

	while LobbyManager:GetQueueCount() < minimumPlayers do
		task.wait(1)
	end

end

function RoundManager:RunIntermission()

	self.CurrentState = Enums.RoundState.Intermission

	local duration = GameConfig.Round.IntermissionTime

	for i = duration,1,-1 do

		LobbyManager:UpdateMatchStatus(
			Enums.RoundState.Intermission,
			i
		)

		task.wait(1)

	end

	local players = LobbyManager:GetQueue()

	if #players < GameConfig.Round.MinimumPlayers then
		return false
	end

	self.RoundPlayers = players

	return true
end

function RoundManager:StartRound()

	self.CurrentState = Enums.RoundState.Starting

	LobbyManager:UpdateMatchStatus(
		Enums.RoundState.Starting,
		0
	)

	LobbyManager:SetInMatch(self.RoundPlayers)


	self.CurrentHunter =
		self:SelectHunter(self.RoundPlayers)

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

	--- Round Stats Manager Call to Track Data About Round
	RoundStatsManager:StartRound(
    self.RoundPlayers,
    self.CurrentHunter
	)
	CoinManager:StartRound()


	self.LastWinner = nil
	self.VictoryPlayer = nil
	self.TimeRemaining = GameConfig.Round.RoundTime

end


function RoundManager:RunRound()

	self.CurrentState = Enums.RoundState.Playing

	while self.TimeRemaining > 0
		and self.CurrentState == Enums.RoundState.Playing do

		task.wait(1)

		self.TimeRemaining -= 1
		RoundStatsManager:Tick(1)
		for _, player in ipairs(
			LobbyManager:GetInMatchPlayers()
		) do

			if RoundStatsManager:IsAlive(player) then

				TaskManager:AddProgress(
					player,
					TaskEvents.SurvivalSecond,
					1,
					false
				)

			end

		end
		LobbyManager:UpdateMatchStatus(
			Enums.RoundState.Playing,
			self.TimeRemaining
		)

	end

	if self.CurrentState == Enums.RoundState.Playing then

		self.LastWinner = "Runners"
		RoundStatsManager:SetWinner("Runners")

	end

end

function RoundManager:EndRound()

	self.CurrentState = Enums.RoundState.Ending
	FreezeManager:UnfreezeAll()

	LobbyManager:UpdateMatchStatus(
		Enums.RoundState.Ending,
		0
	)

	NotificationManager:Broadcast(
		"Round Ended!",
		Enums.NotificationTarget.Gameplay
	)
	if self.LastWinner == Enums.Team.Runner then
		RoundStatsManager:AwardAliveBonus()
	end

	self.VictoryPlayer =
		self:DetermineVictoryPlayer()
	------------------------------------------------
	-- Get players BEFORE cleanup
	------------------------------------------------

	-- local players =
	-- 	LobbyManager:GetInMatchPlayers()
	-- ------------------------------------------------
	-- -- SLOW MOTION
	-- ------------------------------------------------

	-- RoundEventManager:FireSlowMo(
	-- 	players,
	-- 	{
	-- 		Duration = GameConfig.Game.DefaultSlowMoDuration,
	-- 		Speed = GameConfig.Game.DefaultSlowMoSpeed,
	-- 		FOV = GameConfig.Game.DefaultSlowMoFOV,
	-- 	}
	-- )

	-- ------------------------------------------------
	-- -- Let slow motion play
	-- ------------------------------------------------

	-- task.wait(GameConfig.Game.DefaultSlowMoDuration)


	VictoryManager:Play(
		self.VictoryPlayer
	)

	task.wait(
		GameConfig.Round.DefaultVictoryWinDuration
	)

	local players =
		LobbyManager:GetInMatchPlayers()

	RoundEventManager:FireRoundEnded(
		players,
		{
			winner = self.LastWinner,
			hunter = self.CurrentHunter.Name,
			victoryPlayer = self.VictoryPlayer.Name,
		}
	)

	task.wait(GameConfig.Round.EndTime)

end



function RoundManager:CleanupRound()
	CoinManager:StopRound()

	CursorController:EnterLobby()

	RoundStatsManager:ResetRound()

	local players =
		LobbyManager:GetInMatchPlayers()

	LobbyManager:ReturnAllToLobby(players)

	LobbyManager:AutoRequeue(players)

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

function RoundManager:SelectHunter(players)

	local index = math.random(#players)

	return players[index]

end

function RoundManager:AssignTeams(players,hunter)

	for _,player in ipairs(players) do

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


function RoundManager:DetermineVictoryPlayer()

	if self.LastWinner == Enums.Team.Hunter then
		return self.CurrentHunter
	end

	return RoundStatsManager:GetMVPRunner()
end

-- ─── Game Loop ───────────────────────────────────────────────────────────────

function RoundManager:StartGameLoop()
	task.spawn(function()
		while true do

			-- ── 1. WAITING — hold until enough players are queued ──────────────
			self:WaitForPlayers()

			-- ── 2. INTERMISSION — countdown ────────────────────────────────────

			if not self:RunIntermission() then
				continue
			end


			self:StartRound()

			self:RunRound()

			self:EndRound()

			self:CleanupRound()
		end -- while true
	end) -- task.spawn
end

-- ─── Win condition check ─────────────────────────────────────────────────────

function RoundManager:CheckWinCondition()
	if self.CurrentState ~= Enums.RoundState.Playing then
		return
	end
	local GetAliveRunners = RoundStatsManager:GetAliveRunners()
	if GetAliveRunners == 0 then

		print("Hunter wins!")

		self.LastWinner = "Hunter"

		RoundStatsManager:SetWinner("Hunter")

		------------------------------------------------
		-- INSTANT SLOW MOTION
		------------------------------------------------

		local players =
			LobbyManager:GetInMatchPlayers()

		RoundEventManager:FireSlowMo(
			players,
			{
				Duration = GameConfig.Game.DefaultSlowMoDuration,
				Speed = GameConfig.Game.DefaultSlowMoSpeed,
				FOV = GameConfig.Game.DefaultSlowMoFOV,
			}
		)

		task.wait(GameConfig.Game.DefaultSlowMoDuration)

		self:EndRoundEarly()

	end
end

function RoundManager:EndRoundEarly()
	if self.CurrentState == Enums.RoundState.Playing then
		self.CurrentState = Enums.RoundState.Ending
	end
end

function RoundManager:CanLateJoin()

	if not GameConfig.Round.AllowLateJoin then
		return false
	end

	if self.CurrentState ~= Enums.RoundState.Playing then
		return false
	end

	return self.TimeRemaining > GameConfig.Round.LateJoinCutoff
end

function RoundManager:AddLateJoiner(player)
	PlayerManager:SetTeam(player, Enums.Team.Runner)
	RoundStatsManager:AddLateJoiner(player)
	PlayerManager:ResetPlayer(player)
	LobbyManager:SetPlayerInMatch(player)
	SpawnManager:SpawnRunner(player)
	LobbyManager:FireTeleportToArena({player}, self.CurrentHunter)

end

-- ─── Init ─────────────────────────────────────────────────────────────────────

function RoundManager:Init()
	print("RoundManager Initializing...")

	LobbyManager.OnJoinRequest = function(player)

		if RoundManager:CanLateJoin() then
			RoundManager:AddLateJoiner(player)
		else
			LobbyManager:AddToQueue(player)
		end

	end

	-- Re-check win condition whenever a player leaves
	Players.PlayerRemoving:Connect(function(_player)
		RoundStatsManager:RemovePlayer(_player)
		self:CheckWinCondition()
	end)

	self:StartGameLoop()
end


return RoundManager