local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local ServerScriptService = game:GetService("ServerScriptService")
local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
local Remotes = Shared.Remotes


local function getRemote(name)
    return Remotes:WaitForChild(name)
end
------------------------------------------------
local PlayVictoryRemote = getRemote(RemoteIndex.PlayVictory)

local VictoryData = require(
	ReplicatedStorage.Shared.Modules.VictoryData
)

local InventoryManager = require(
	ServerScriptService.Server.Managers.InventoryManager
)


local VictoryManager = {}

function VictoryManager:Init()
	print("[VictoryManager] Initialized")
	-- print(InventoryManager:GetEquipped(Players:GetPlayers()[1], "VictoryPoses"))

	----------------------------------------------------------------
	-- TEST ONLY
	----------------------------------------------------------------

	-- task.spawn(function()
	-- 	while true do
	-- 		task.wait(10)

	-- 		local players = Players:GetPlayers()

	-- 		if #players > 0 then
	-- 			self:Play(players[1])
	-- 		end

	-- 	end
	-- end)
end

function VictoryManager:Play(winnerPlayer)
	if not winnerPlayer then
		return
	end

	print("winner player:", winnerPlayer)
	local equippedPose =
		InventoryManager:GetEquipped(
			winnerPlayer,
			"VictoryPoses"
		) or "Default"

	-------------------------------------------------------
	-- Later this will come from PlayerData
	-------------------------------------------------------

	local data = VictoryData.new(
		winnerPlayer,
		equippedPose
	)

	print("winner player data:", data)
	

	PlayVictoryRemote:FireAllClients(data)
end

return VictoryManager