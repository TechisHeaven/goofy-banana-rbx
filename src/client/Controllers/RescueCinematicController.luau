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
			------------------------------------------------
			-- PLAY
		

			if action == "Start" then
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
				if currentCinematic then

					currentCinematic.Cleanup()

					currentCinematic = nil

				end

			end

		end
	)
end

return RescueCinematicController