local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local RemoteIndex = require(Shared.Remotes.RemoteIndex)

local Remotes = Shared:WaitForChild("Remotes")

local UIManager = require(script.Parent.Parent.manager.UImanager)

-- ------------------------------------------------

-- Remotes:WaitForChild(RemoteIndex.RoundStarted).OnClientEvent:Connect(function(data)

--     UIManager:ShowGame()

--     UIManager:SetRole(data.role)

--     UIManager:SetHunterName(data.hunter)

-- end)

------------------------------------------------
Remotes:WaitForChild(RemoteIndex.RoundEnded).OnClientEvent:Connect(function(data)
    UIManager:ShowRoundResult(data)
end)


local RoundController = {}

function RoundController:Init()
    Remotes:WaitForChild(RemoteIndex.RoundEnded).OnClientEvent:Connect(function(data)
        UIManager:ShowRoundResult(data)
    end)

end

return RoundController