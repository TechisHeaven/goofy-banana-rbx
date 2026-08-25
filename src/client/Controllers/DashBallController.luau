local DashBallController = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

local Players =
	game:GetService("Players")

local UserInputService =
	game:GetService("UserInputService")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- PLAYER
------------------------------------------------

local player =
	Players.LocalPlayer

------------------------------------------------
-- REMOTE
------------------------------------------------
local Shared = ReplicatedStorage.Shared
local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events

local Remotes = Shared.Remotes
local DashBall =
	Remotes:WaitForChild(RemoteIndex.DashBall)

------------------------------------------------
-- STATE
------------------------------------------------

local initialized = false

local function HasEquippedDashBall()

	local character =
		player.Character

	if not character then
		return false
	end

	return character:GetAttribute(
		"HeldItemId"
	) == "DashBall"

end


------------------------------------------------
-- INIT
------------------------------------------------

function DashBallController:Init()

	if initialized then
		return
	end

	initialized = true

	------------------------------------------------
	-- LEFT CLICK
	------------------------------------------------

	UserInputService.InputBegan:Connect(
		function(input, gameProcessed)

			if gameProcessed then
				return
			end

			if input.UserInputType
				~= Enum.UserInputType.MouseButton1 then

				return
			end

			if not HasEquippedDashBall() then
				return
			end
			------------------------------------------------
			-- ASK SERVER TO THROW
			------------------------------------------------
			DashBall:FireServer(
				"Throw"
			)

		end
	)

	print(
		"[DashBallController] Initialized"
	)

end

return DashBallController