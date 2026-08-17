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

local mouse =
	player:GetMouse()

------------------------------------------------
-- REMOTE
------------------------------------------------
local Shared = ReplicatedStorage.Shared
local RemoteIndex =
    require(Shared.Remotes.RemoteIndex).Events

local Remotes = Shared.Remotes


local BananaPeelRequest =
	Remotes:WaitForChild(
		RemoteIndex.BananaPeelRequest
	)
local BananaPeelController= {}
------------------------------------------------
-- INPUT
------------------------------------------------

function BananaPeelController:Init()
UserInputService.InputBegan:Connect(
	function(
		input,
		gameProcessed
	)

		if gameProcessed then
			return
		end

		if input.UserInputType
			~= Enum.UserInputType.MouseButton2 then

			return

		end

		local hit =
			mouse.Hit

		if not hit then
			return
		end

		BananaPeelRequest:FireServer(
			hit.Position
		)

	end
)
end


return BananaPeelController