local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local RemoteIndex = require(Shared.Remotes.RemoteIndex)
local Remotes = Shared.Remotes

------------------------------------------------

local PlayVictoryRemote = Remotes:WaitForChild(RemoteIndex.PlayVictory)

local VictoryData = require(
	ReplicatedStorage.Shared.Modules.VictoryData
)

local VictoryManager = {}

function VictoryManager:Init()
	print("[VictoryManager] Initialized")

	----------------------------------------------------------------
	-- TEST ONLY
	----------------------------------------------------------------

	task.spawn(function()
		task.wait(5)

		local players = Players:GetPlayers()
		if #players == 0 then
			return
		end

		self:Play(players[1])
	end)
end

function VictoryManager:Play(winnerPlayer)
	if not winnerPlayer then
		return
	end

	-------------------------------------------------------
	-- Later this will come from PlayerData
	-------------------------------------------------------

	local equippedPose = "Default2"

	local data = VictoryData.new(
		winnerPlayer,
		equippedPose
	)

	PlayVictoryRemote:FireAllClients(data)
end

return VictoryManager