local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local Shared      = ReplicatedStorage:WaitForChild("Shared")
local GameConfig  = require(Shared.GameConfig)
local Enums       = require(Shared.Enums)

local PlayerManager = require(script.Parent.PlayerManager)
local SpawnManager  = require(script.Parent.SpawnManager)
local FreezeManager = require(script.Parent.FreezeManager)
local LobbyManager  = require(script.Parent.LobbyManager)

local RoundManager = {}

RoundManager.CurrentState = Enums.RoundState.Waiting
RoundManager.LastWinner   = nil  -- "Hunter" | "Runners" | nil (set before Ending)

-- ─── Game Loop ───────────────────────────────────────────────────────────────

function RoundManager:StartGameLoop()
	task.spawn(function()
		while true do

			-- ── 1. WAITING — hold until enough players are queued ──────────────
			RoundManager.CurrentState = Enums.RoundState.Waiting
			LobbyManager:UpdateMatchStatus(Enums.RoundState.Waiting, 0)

			local minPlayers = GameConfig.Round.MinimumPlayers

			while LobbyManager:GetQueueCount() < minPlayers do
				task.wait(1)
			end

			-- ── 2. INTERMISSION — countdown ────────────────────────────────────
			RoundManager.CurrentState = Enums.RoundState.Intermission

			local intermissionTime = GameConfig.Round.IntermissionTime
			for i = intermissionTime, 1, -1 do
				LobbyManager:UpdateMatchStatus(Enums.RoundState.Intermission, i)
				task.wait(1)
			end

			-- Snapshot the queue at the moment the countdown finishes.
			-- Players who cancelled during countdown won't be here.
			local roundPlayers = LobbyManager:GetQueue()
			if #roundPlayers < minPlayers then
				print("RoundManager: Queue dropped below minimum during intermission — resetting.")
				continue
			end

			-- ── 2.5. STARTING — assign teams, teleport ─────────────────────────
			RoundManager.CurrentState = Enums.RoundState.Starting
			LobbyManager:UpdateMatchStatus(Enums.RoundState.Starting, 0)

			-- Lock in the round players (clears the queue, marks them InMatch)
			LobbyManager:SetInMatch(roundPlayers)

			-- Pick a random hunter
			local hunterIndex = math.random(1, #roundPlayers)
			local hunter      = roundPlayers[hunterIndex]
			local hunterName  = hunter and hunter.Name or "Unknown"

			local runnerNames = {}
			for _, player in ipairs(roundPlayers) do
				if player == hunter then
					PlayerManager:SetTeam(player, Enums.Team.Hunter)
				else
					PlayerManager:SetTeam(player, Enums.Team.Runner)
					table.insert(runnerNames, player.Name)
				end
			end

			print(string.format("Hunter: %s", hunter.Name))
			print("Runners:")
			for _, name in ipairs(runnerNames) do print(" ", name) end

			-- Teleport everyone to the arena
			SpawnManager:TeleportPlayers(roundPlayers, hunter)
			FreezeManager:ApplyHunterCooldown(hunter, (GameConfig.Hunter and GameConfig.Hunter.CooldownTime) or 4)
			LobbyManager:FireTeleportToArena(roundPlayers, hunterName)
			-- ── 3. PLAYING — run the round timer ───────────────────────────────
			RoundManager.CurrentState = Enums.RoundState.Playing
			RoundManager.LastWinner   = nil
			print("Round Started")

			local roundTime = GameConfig.Round.RoundTime
			local elapsed   = 0

			while elapsed < roundTime and RoundManager.CurrentState == Enums.RoundState.Playing do
				task.wait(1)
				elapsed = elapsed + 1
				LobbyManager:UpdateMatchStatus(Enums.RoundState.Playing, roundTime - elapsed)
			end

			-- If the state is still Playing when the timer expires, runners survived
			if RoundManager.CurrentState == Enums.RoundState.Playing then
				RoundManager.LastWinner   = "Runners"
				RoundManager.CurrentState = Enums.RoundState.Ending
			end

			-- ── 4. ENDING ──────────────────────────────────────────────────────
			RoundManager.CurrentState = Enums.RoundState.Ending
			LobbyManager:UpdateMatchStatus(Enums.RoundState.Ending, 0)
			print("Round Ended — winner:", RoundManager.LastWinner or "Unknown")

			-- Unfreeze everyone in the match
			FreezeManager:UnfreezeAll()

			-- Show winner screen to in-match players
			local rewardPreview = RoundManager.LastWinner == "Hunter"
				and "XP +15\nCoins +8"
				or "XP +20\nCoins +12"
			LobbyManager:FireWinnerScreen(RoundManager.LastWinner or "Unknown", hunterName, rewardPreview)

			-- Wait for the end screen to display
			local endTime = GameConfig.Round.EndTime or 5
			task.wait(endTime)

			-- Collect in-match players before returning them
			local inMatchPlayers = LobbyManager:GetInMatchPlayers()

			-- Return all in-match players to lobby (resets state, teleports, fires remote)
			LobbyManager:ReturnAllToLobby(inMatchPlayers)

			-- Auto-requeue those players after a short delay
			LobbyManager:AutoRequeue(inMatchPlayers)

			-- Small buffer before the next waiting phase
			local postDelay = (GameConfig.Lobby and GameConfig.Lobby.PostRoundReturnDelay) or 3
			task.wait(postDelay)

		end -- while true
	end) -- task.spawn
end

-- ─── Win condition check ─────────────────────────────────────────────────────

function RoundManager:CheckWinCondition()
	if self.CurrentState ~= Enums.RoundState.Playing then return end

	-- Only count players currently in the match
	local inMatchPlayers = LobbyManager:GetInMatchPlayers()
	local totalRunners   = 0
	local aliveRunners   = 0

	for _, player in ipairs(inMatchPlayers) do
		if PlayerManager:GetTeam(player) == Enums.Team.Runner then
			totalRunners = totalRunners + 1
			if PlayerManager:GetState(player) == Enums.PlayerState.Alive then
				aliveRunners = aliveRunners + 1
			end
		end
	end

	print(string.format("RoundManager: Win check — %d/%d runners alive.", aliveRunners, totalRunners))

	if totalRunners > 0 and aliveRunners == 0 then
		print("RoundManager: Hunter wins! All runners frozen.")
		self.LastWinner = "Hunter"
		self:EndRoundEarly()
	end
end

function RoundManager:EndRoundEarly()
	if self.CurrentState == Enums.RoundState.Playing then
		self.CurrentState = Enums.RoundState.Ending
	end
end

-- ─── Init ─────────────────────────────────────────────────────────────────────

function RoundManager:Init()
	print("RoundManager Initializing...")

	-- Re-check win condition whenever a player leaves
	Players.PlayerRemoving:Connect(function(_player)
		self:CheckWinCondition()
	end)

	self:StartGameLoop()
end

return RoundManager