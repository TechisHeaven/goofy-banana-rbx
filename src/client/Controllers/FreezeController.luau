local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local RemoteIndex = require(Shared.Remotes.RemoteIndex)

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
end

return FreezeController
