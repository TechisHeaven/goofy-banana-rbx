local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

------------------------------------------------
-- Modules
------------------------------------------------

local MarkedTargetVisuals =
	require(
		Shared
			:WaitForChild("Modules")
			:WaitForChild("MarkedTargetVisuals")
	)

------------------------------------------------
-- Remotes
------------------------------------------------

local RemotesFolder =
	Shared:WaitForChild("Remotes")

local RemoteIndexData =
	require(
		RemotesFolder
			:WaitForChild("RemoteIndex")
	)

local RemoteIndex =
	RemoteIndexData.Events

local MarkedPlayerChanged =
	RemotesFolder:WaitForChild(
		RemoteIndex.MarkedPlayerChanged
	)

------------------------------------------------
-- Controller
------------------------------------------------

local MarkedTargetController = {}

------------------------------------------------
-- Init
------------------------------------------------

function MarkedTargetController:Init()

	print(
		"[MarkedTargetController] Initialized"
	)

	MarkedPlayerChanged.OnClientEvent:Connect(
		function(markedPlayer)

			if markedPlayer then

				print(
					"[MarkedTargetController] New marked player:",
					markedPlayer.Name
				)

				MarkedTargetVisuals:Show(
					markedPlayer
				)

			else

				print(
					"[MarkedTargetController] Clearing marked player"
				)

				MarkedTargetVisuals:Clear()

			end

		end
	)

end

------------------------------------------------
-- Cleanup
------------------------------------------------

function MarkedTargetController:Cleanup()

	MarkedTargetVisuals:Clear()

	print(
		"[MarkedTargetController] Cleaned up"
	)

end

return MarkedTargetController