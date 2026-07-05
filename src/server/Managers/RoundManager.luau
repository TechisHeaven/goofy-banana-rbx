local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local Enums = require(Shared.Enums)

local PlayerManager = require(script.Parent.PlayerManager)
local SpawnManager = require(script.Parent.SpawnManager)
local FreezeManager = require(script.Parent.FreezeManager)

local RoundManager = {}

RoundManager.CurrentState = Enums.RoundState.Waiting

function RoundManager:StartGameLoop()
	task.spawn(function()
		while true do
			-- 1. Wait until enough players join
			RoundManager.CurrentState = Enums.RoundState.Waiting
			
			local minPlayers = GameConfig.Round.MinimumPlayers
			local currentPlayers = #Players:GetPlayers()
			
			if currentPlayers < minPlayers then
				print(string.format("Waiting for players (%d/%d)...", currentPlayers, minPlayers))
				
				while #Players:GetPlayers() < minPlayers do
					task.wait(1)
				end
			end
			
			-- 2. Start countdown
			RoundManager.CurrentState = Enums.RoundState.Intermission
			local intermissionTime = GameConfig.Round.IntermissionTime
			for i = intermissionTime, 1, -1 do
				print("Round starting in:", i)
				task.wait(1)
			end
			
			-- Double check player count before officially starting
			local activePlayers = Players:GetPlayers()
			if #activePlayers < minPlayers then
				print("Not enough players to start the round, resetting loop.")
			else
				-- 2.5. Starting state (Hunter Selection)
				RoundManager.CurrentState = Enums.RoundState.Starting
				
				local hunterIndex = math.random(1, #activePlayers)
				local hunter = activePlayers[hunterIndex]
				
				local runners = {}
				for _, player in ipairs(activePlayers) do
					if player == hunter then
						PlayerManager:SetTeam(player, Enums.Team.Hunter)
					else
						PlayerManager:SetTeam(player, Enums.Team.Runner)
						table.insert(runners, player.Name)
					end
				end
				
				-- Print teams in the required format
				print(string.format("Hunter: %s", hunter.Name))
				print("")
				print("Runners:")
				for _, name in ipairs(runners) do
					print(name)
				end
				print("")
				
				-- Teleport players to their respective spawn points
				SpawnManager:TeleportPlayers(activePlayers, hunter)
				
				-- 3. Print "Round Started"
				RoundManager.CurrentState = Enums.RoundState.Playing
				print("Round Started")
				
				-- 4. Wait 120 seconds
				print("Round will end in", GameConfig.Round.RoundTime, "seconds")
				local roundTime = GameConfig.Round.RoundTime
				local elapsed = 0
				while elapsed < roundTime and RoundManager.CurrentState == Enums.RoundState.Playing do
					task.wait(1)
					elapsed = elapsed + 1
				end
				
				-- 5. Print "Round Ended"
				RoundManager.CurrentState = Enums.RoundState.Ending
				print("Round Ended")
				
				-- Reset everyone's team/state
				for _, player in ipairs(Players:GetPlayers()) do
					PlayerManager:ResetPlayer(player)
				end
				
				-- Unfreeze all players and restore their states
				FreezeManager:UnfreezeAll()
				
				-- Teleport everyone back to the lobby
				SpawnManager:TeleportToLobby(Players:GetPlayers())
				
				-- End phase wait (cleanup/results time)
				local endTime = GameConfig.Round.EndTime or 5
				task.wait(endTime)
			end
		end
	end)
end

function RoundManager:CheckWinCondition()
	if self.CurrentState ~= Enums.RoundState.Playing then
		return
	end

	local activePlayers = Players:GetPlayers()
	local totalRunners = 0
	local aliveRunners = 0

	for _, player in ipairs(activePlayers) do
		if PlayerManager:GetTeam(player) == Enums.Team.Runner then
			totalRunners = totalRunners + 1
			if PlayerManager:GetState(player) == Enums.PlayerState.Alive then
				aliveRunners = aliveRunners + 1
			end
		end
	end

	print(string.format("RoundManager: Win check - %d/%d runners alive.", aliveRunners, totalRunners))

	if totalRunners > 0 and aliveRunners == 0 then
		print("RoundManager: Hunter wins! All runners have been frozen.")
		self:EndRoundEarly()
	end
end

function RoundManager:EndRoundEarly()
	if self.CurrentState == Enums.RoundState.Playing then
		self.CurrentState = Enums.RoundState.Ending
	end
end

function RoundManager:Init()
	print("RoundManager Initializing...")
	
	-- Connect event listeners to re-check win conditions in case players leave mid-round
	Players.PlayerRemoving:Connect(function(player)
		self:CheckWinCondition()
	end)
	
	self:StartGameLoop()
end

return RoundManager