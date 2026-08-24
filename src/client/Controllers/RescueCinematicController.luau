local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Players =
	game:GetService("Players")

local player =
	Players.LocalPlayer

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local Remotes =
	Shared:WaitForChild("Remotes")

local RescueCinematic =
	Remotes:WaitForChild("RescueCinematic")

local RescueCinematicModule =
	require(
		Shared.Modules.RescueCinematicModule
	)

local currentCinematic = nil
local RescueCinematicController = {}

function RescueCinematicController:Init()
    
------------------------------------------------
-- REMOTE
------------------------------------------------

RescueCinematic.OnClientEvent:Connect(
	function(action, effectName)
		print(action, effectName)
		------------------------------------------------
		-- PLAY
		------------------------------------------------
		print(
			"[CLIENT RESCUE DEBUG]",
			action,
			effectName,
			os.clock()
		)

		if action == "Start" then
			print("[CLIENT] Starting cinematic")
			------------------------------------------------
			-- Cleanup previous
			------------------------------------------------

			if currentCinematic then
				currentCinematic.Cleanup()
				currentCinematic = nil
			end

			local character =
				player.Character

			if not character then
				return
			end
			print(effectName)
			------------------------------------------------
			-- PLAY CINEMATIC
			------------------------------------------------
			currentCinematic =
				RescueCinematicModule:Play(
					character,
					effectName,
					{
						ResetCamera = false
					}
				)

		------------------------------------------------
		-- STOP
		------------------------------------------------

		elseif action == "Stop" then
			print("[CLIENT] Stopping cinematic")
			if currentCinematic then

				currentCinematic.Cleanup()

				currentCinematic = nil

			end

		end

	end
)
end

return RescueCinematicController