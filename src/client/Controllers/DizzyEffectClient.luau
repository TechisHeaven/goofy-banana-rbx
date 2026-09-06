local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectsFolder = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Modules")
	:WaitForChild("Effects")

local DizzyEffects = require(
	EffectsFolder:WaitForChild("DizzyEffects")
)

local Remotes =
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Remotes")
local RemoteIndex = require(Remotes:WaitForChild("RemoteIndex"))

local DizzyEffectEvent =
	Remotes:WaitForChild(RemoteIndex.Events.DizzyEffect)

local DizzyEffectClient = {}

function DizzyEffectClient:Init()
   DizzyEffectEvent.OnClientEvent:Connect(function(duration)
        DizzyEffects.Play(duration or 2.5)
    end)
end

return DizzyEffectClient