local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local RemoteIndex =
    require(Shared.Remotes.RemoteIndex).Events

local Remotes = Shared.Remotes

local NotificationUI =
    require(script.Parent.Parent.UI.NotificationUI)

local NotificationController = {}

function NotificationController:Init()

    Remotes:WaitForChild(RemoteIndex.NotifyPlayer)
        .OnClientEvent
        :Connect(function(data)

            NotificationUI:ShowNotification(data)

        end)

end

return NotificationController