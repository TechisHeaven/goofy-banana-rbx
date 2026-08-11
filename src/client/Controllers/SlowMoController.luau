local UserInputService =
	game:GetService("UserInputService")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local SlowMo =
	require(
		ReplicatedStorage.Shared.Modules.SlowMoModule
	)

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
----------------------------------------------------

local Remotes = Shared:WaitForChild("Remotes")

local function getRemote(name: RemoteEvent)

	return Remotes:WaitForChild(name)

end



local SlowMoController = {}
------------------------------------------------
-- TEST
------------------------------------------------


----------------------------------------------------

function SlowMoController:Init()

	print("SlowMoController Initialized")
    getRemote(RemoteIndex.StartSlowMo)
	.OnClientEvent
	:Connect(function(data)
		print("slow mo client", data)
		SlowMo:Start({
			Duration = data.Duration or 3,
			Speed = data.Speed or 0.35,
			FOV = data.FOV or 70,
		})

	end)

end


return SlowMoController