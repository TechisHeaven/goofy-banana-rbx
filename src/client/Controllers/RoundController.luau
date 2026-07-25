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
print("roundcontroller initialized")
Remotes:WaitForChild(RemoteIndex.RoundEnded).OnClientEvent:Connect(function(data)
	print("RoundController: Round ended event received to Show UI")
    UIManager:ShowRoundResult(data)

end)


local RoundController = {}

function RoundController:Init()

    print("RoundController Initializing...")

    Remotes:WaitForChild(RemoteIndex.RoundEnded).OnClientEvent:Connect(function(data)

        print("RoundController: RoundEnded received")
        print(data)

        UIManager:ShowRoundResult(data)

    end)

end

return RoundController