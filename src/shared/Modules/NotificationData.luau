local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Enums = require(Shared.Enums)

local NotificationData = {}

function NotificationData.new(message, target, duration)

	return {

		Message = message,

		Target = target or Enums.NotificationTarget.Overlay,

		Duration = duration or 3,
		RichText = true
	}

end

return NotificationData