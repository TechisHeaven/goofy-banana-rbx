local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
local FreezeUI = require(script.Parent.Parent.UI.FreezeUI)

local Remotes = Shared:WaitForChild("Remotes")

-- Remotes:WaitForChild(RemoteIndex.PlayerFrozen)
--     .OnClientEvent:Connect(function(data)
--         FreezeUI:Show(data)
--     end)


local FreezeController = {}

function FreezeController:Init()
    Remotes:WaitForChild(RemoteIndex.PlayerFrozen).OnClientEvent:Connect(function(data)
        FreezeUI:Show(data)
    end)

    Remotes:WaitForChild(RemoteIndex.FreezeCooldown).OnClientEvent:Connect(function(cooldown)
       FreezeUI:ShowFreezeCooldown(cooldown)
    end)
end

return FreezeController
