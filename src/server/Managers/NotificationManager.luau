local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local RemoteIndex = require(Shared.Remotes.RemoteIndex).Events

local Remotes = Shared.Remotes

local Enums = require(Shared.Enums)
local GameConfig = require(Shared.GameConfig)
local NotifyRemote =
    Remotes:WaitForChild(RemoteIndex.NotifyPlayer)

local NotificationData = require(Shared.Modules.NotificationData)



local NotificationManager = {}

function NotificationManager:Send(player, message, target, duration)

    NotifyRemote:FireClient(player, NotificationData.new(
			message,
			target or Enums.NotificationTarget.Default,
			duration or GameConfig.Game.NotificationDuration
		))

end

function NotificationManager:Broadcast(message, target, duration)

    NotifyRemote:FireAllClients(NotificationData.new(
        message,
        target or Enums.NotificationTarget.Default,
		duration or GameConfig.Game.NotificationDuration
    ))

end


function NotificationManager:BroadcastToRound(
	players,
	message,
	target,
	duration
)



	local notification =
		NotificationData.new(
			message,
			target or Enums.NotificationTarget.Default,
			duration or GameConfig.Game.NotificationDuration
		)

	for _, player in ipairs(players) do

		if player and player.Parent then

			NotifyRemote:FireClient(
				player,
				notification
			)

		end

	end

end

function NotificationManager:Success(player, message)

    NotifyRemote:FireClient(player, NotificationData.new(
        message,
        Enums.NotificationTarget.Default,
        GameConfig.Game.NotificationDuration
    ))

end

function NotificationManager:Error(player, message)

    NotifyRemote:FireClient(player,{
        Message = message,
        Type = "Error",
    })

end

return NotificationManager