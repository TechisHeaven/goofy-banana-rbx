local SpawnManager = {}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Helper function to resolve maps folder and spawn point folders
local function getMapSpawns()
	local mapsFolder = Workspace:FindFirstChild("Maps")
	if not mapsFolder then
		warn("SpawnManager: 'Maps' folder not found in Workspace!")
		return nil, nil
	end

	local activeMap = mapsFolder:FindFirstChild("TrampolinePark")
	if not activeMap then
		-- Fallback to the first child in Maps if TrampolinePark isn't found
		activeMap = mapsFolder:GetChildren()[1]
	end

	if not activeMap then
		warn("SpawnManager: No active map found in Maps folder!")
		return nil, nil
	end

	local hunterSpawnsFolder = activeMap:FindFirstChild("HunterSpawnPoints")
	local runnerSpawnsFolder = activeMap:FindFirstChild("SpawnPoints")

	return hunterSpawnsFolder, runnerSpawnsFolder
end

-- Safely teleport a player, optionally loading their character first
local function teleportPlayer(player: Player, cframe: CFrame)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		-- Load character if it doesn't exist
		player:LoadCharacter()
		character = player.CharacterAdded:Wait()
	end
	
	if character then
		-- Offset slightly upward to prevent spawning inside the spawn part
		character:PivotTo(cframe + Vector3.new(0, 3, 0))
	end
end

-- Teleports active players to their respective spawns
function SpawnManager:TeleportPlayers(activePlayers: {Player}, hunter: Player)
	local hunterSpawnsFolder, runnerSpawnsFolder = getMapSpawns()
	
	if not hunterSpawnsFolder or not runnerSpawnsFolder then
		warn("SpawnManager: Could not locate spawn folders!")
		return
	end

	-- Hunter spawn logic
	local hunterSpawn = hunterSpawnsFolder:FindFirstChild("HunterSpawn")
	if not hunterSpawn then
		-- Fallback to the first child in HunterSpawnPoints
		hunterSpawn = hunterSpawnsFolder:GetChildren()[1]
	end

	if hunterSpawn and hunterSpawn:IsA("BasePart") then
		print(string.format("SpawnManager: Teleporting hunter %s to %s", hunter.Name, hunterSpawn.Name))
		task.spawn(function()
			teleportPlayer(hunter, hunterSpawn.CFrame)
		end)
	else
		warn("SpawnManager: HunterSpawn not found in HunterSpawnPoints!")
	end

	-- Runner spawn logic
	local runnerSpawns = {}
	for _, child in ipairs(runnerSpawnsFolder:GetChildren()) do
		if child:IsA("BasePart") and child.Name:find("RunnerSpawn") then
			table.insert(runnerSpawns, child)
		end
	end

	if #runnerSpawns == 0 then
		warn("SpawnManager: No runner spawn points found in SpawnPoints folder!")
		return
	end

	-- Teleport runners
	for _, player in ipairs(activePlayers) do
		if player ~= hunter then
			local randomSpawn = runnerSpawns[math.random(1, #runnerSpawns)]
			print(string.format("SpawnManager: Teleporting runner %s to %s", player.Name, randomSpawn.Name))
			task.spawn(function()
				teleportPlayer(player, randomSpawn.CFrame)
			end)
		end
	end
end

function SpawnManager:SpawnRunner(player)

	local _, runnerFolder = getMapSpawns()

	local spawns = {}

	for _,spawn in ipairs(runnerFolder:GetChildren()) do

		if spawn:IsA("BasePart") then
			table.insert(spawns,spawn)
		end

	end

	local randomSpawn = spawns[math.random(#spawns)]

	teleportPlayer(player,randomSpawn.CFrame)

end

-- Teleports everyone back to the lobby.
-- Priority: Workspace.Lobby.LobbySpawn → root SpawnLocation → (0, 10, 0) fallback.
function SpawnManager:TeleportToLobby(players: {Player})
	local lobbyCFrame: CFrame

	-- 1. Prefer the dedicated lobby spawn part the designer placed
	local lobbyFolder = Workspace:FindFirstChild("Lobby")
	local lobbySpawn  = lobbyFolder and lobbyFolder:FindFirstChild("LobbySpawn")

	if lobbySpawn and lobbySpawn:IsA("BasePart") then
		lobbyCFrame = lobbySpawn.CFrame
		print(string.format("SpawnManager: Teleporting players to Lobby.LobbySpawn (%s)", lobbySpawn.Name))
	else
		-- 2. Fall back to root SpawnLocation
		local fallback = Workspace:FindFirstChildOfClass("SpawnLocation")
		if fallback and fallback:IsA("BasePart") then
			lobbyCFrame = fallback.CFrame
			print(string.format("SpawnManager: Lobby.LobbySpawn not found, using root SpawnLocation (%s)", fallback.Name))
		else
			-- 3. Hard fallback
			lobbyCFrame = CFrame.new(0, 10, 0)
			warn("SpawnManager: No lobby spawn found — teleporting to (0, 10, 0)")
		end
	end

	for _, player in ipairs(players) do
		task.spawn(function()
			teleportPlayer(player, lobbyCFrame)
		end)
	end
end

function SpawnManager:Init()
	print("SpawnManager Initializing...")
end

return SpawnManager