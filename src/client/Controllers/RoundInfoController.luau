local RoundInfoController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events

local Remotes =
	Shared:WaitForChild("Remotes")

local RoundInfo =
	Remotes:WaitForChild(
		RemoteIndex.RoundInfo
	)

local RoundInfoUI = require(script.Parent.Parent.UI.RoundInfoUI)


function RoundInfoController:Init()
    RoundInfo.OnClientEvent:Connect(function(data)


        RoundInfoUI:SetMode(data.DisplayName or "Classic Mode")
        -- Example:
        -- RoundUI.Mode.Text = data.DisplayName

    end)
end


return RoundInfoController