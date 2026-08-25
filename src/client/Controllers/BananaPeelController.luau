local Players =
	game:GetService("Players")

local UserInputService =
	game:GetService("UserInputService")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local RunService =
	game:GetService("RunService")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
------------------------------------------------
-- PLAYER
------------------------------------------------

local player =
	Players.LocalPlayer

local mouse =
	player:GetMouse()
local BananaUI = require(script.Parent.Parent.UI.BananaUI)
------------------------------------------------
-- REMOTE
------------------------------------------------

local Shared =
	ReplicatedStorage.Shared

local RemoteIndex =
	require(
		Shared.Remotes.RemoteIndex
	).Events

local Remotes =
	Shared.Remotes

local BananaPeelRequest =
	Remotes:WaitForChild(
		RemoteIndex.BananaPeelRequest
	)

------------------------------------------------
-- CONTROLLER
------------------------------------------------

local BananaPeelController = {}

------------------------------------------------
-- SETTINGS
------------------------------------------------

local MARKER_SIZE = 2.5
local MARKER_THICKNESS = 0.04
local MARKER_OFFSET = 0.02

local MAX_DISTANCE = 12

------------------------------------------------
-- STATE
------------------------------------------------

local initialized = false

local marker = nil

local currentPosition = nil

local currentNormal = nil

------------------------------------------------
-- CHECK BANANA
------------------------------------------------

local function HasEquippedBanana()

	local character =
		player.Character

	if not character then
		return false
	end

	return character:GetAttribute(
		"HeldItemId"
	) == "Banana"

end



------------------------------------------------
-- CREATE MARKER
------------------------------------------------

local function CreateMarker()
	if marker then
		return
	end

	marker =
		Instance.new("Part")

	marker.Name =
		"BananaPlacementMarker"

	marker.Shape =
		Enum.PartType.Cylinder

	marker.Size =
		Vector3.new(
			MARKER_THICKNESS,
			MARKER_SIZE,
			MARKER_SIZE
		)

	marker.Anchored =
		true

	marker.CanCollide =
		false

	marker.CanTouch =
		false

	marker.CanQuery =
		false

	marker.CastShadow =
		false

	marker.Material =
		Enum.Material.Neon

	marker.Transparency =
		0.45

	marker.Parent =
		workspace


end

------------------------------------------------
-- DESTROY MARKER
------------------------------------------------

local function DestroyMarker()
	if marker then

		marker:Destroy()

		marker =
			nil

	end

	currentPosition =
		nil

	currentNormal =
		nil

end


------------------------------------------------
-- WATCH HELD ITEM
------------------------------------------------

local function SetupCharacter(character)

	character:GetAttributeChangedSignal(
		"HeldItemId"
	):Connect(
		function()

			local heldItemId =
				character:GetAttribute(
					"HeldItemId"
				)

			if heldItemId ~= "Banana" or heldItemId == nil then

				DestroyMarker()

			end

		end
	)

end


------------------------------------------------
-- RAYCAST
------------------------------------------------

local function GetPlacementPosition()

	local character =
		player.Character

	if not character then
		return nil
	end

	local root =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then
		return nil
	end

	------------------------------------------------
	-- MOUSE RAY
	------------------------------------------------

	local camera =
		workspace.CurrentCamera

	if not camera then
		return nil
	end

	local mousePosition =
		UserInputService:GetMouseLocation()

	local ray =
		camera:ViewportPointToRay(
			mousePosition.X,
			mousePosition.Y
		)

	------------------------------------------------
	-- RAYCAST PARAMS
	------------------------------------------------

	local params =
		RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances = {
		character,
		marker
	}

	------------------------------------------------
	-- RAYCAST
	------------------------------------------------

	local result =
		workspace:Raycast(
			ray.Origin,
			ray.Direction * 500,
			params
		)

	if not result then
		return nil
	end

	------------------------------------------------
	-- DISTANCE CHECK
	------------------------------------------------

	local distance =
		(
			root.Position
			- result.Position
		).Magnitude

	if distance > MAX_DISTANCE then
		return nil
	end

	return result.Position,
		result.Normal

end

------------------------------------------------
-- UPDATE MARKER
------------------------------------------------

local function UpdateMarker()

	if not HasEquippedBanana() then

		DestroyMarker()

		return

	end

	CreateMarker()

	local position,
		normal =
		GetPlacementPosition()

	if not position
		or not normal then

		marker.Transparency =
			1

		currentPosition =
			nil

		currentNormal =
			nil

		return

	end

	------------------------------------------------
	-- STORE
	------------------------------------------------

	currentPosition =
		position

	currentNormal =
		normal

	------------------------------------------------
	-- MARKER ROTATION
	------------------------------------------------

	-- Cylinder's X axis is its thickness axis.
	-- We align that axis with the surface normal.

	local normalUnit =
		normal.Unit

	-- Pick a stable direction on the surface.
	local reference =
		Vector3.new(0, 1, 0)

	-- If the surface is almost vertical,
	-- use another reference direction.
	if math.abs(
		normalUnit:Dot(reference)
	) > 0.98 then

		reference =
			Vector3.new(0, 0, 1)

	end

	local surfaceForward =
		(reference
			- normalUnit
				* reference:Dot(normalUnit)
		).Unit

	local surfaceRight =
		normalUnit:Cross(
			surfaceForward
		).Unit

	local markerCFrame =
		CFrame.fromMatrix(
			position
				+ normalUnit * MARKER_OFFSET,

			normalUnit,
			surfaceRight,
			-surfaceForward
		)

	------------------------------------------------
	-- APPLY
	------------------------------------------------

	marker.CFrame =
		markerCFrame

	marker.Transparency =
		0.45

end

------------------------------------------------
-- INIT
------------------------------------------------

function BananaPeelController:Init()

	if initialized then
		return
	end

	initialized =
		true
	BananaUI:Init()

	if player.Character then
		SetupCharacter(
			player.Character
		)
	end

	player.CharacterAdded:Connect(
		function(character)

			DestroyMarker()

			SetupCharacter(
				character
			)

		end
	)
	------------------------------------------------
	-- MARKER UPDATE
	------------------------------------------------

	RunService.RenderStepped:Connect(
		function()
			UpdateMarker()
		end
	)

	------------------------------------------------
	-- RIGHT CLICK
	------------------------------------------------

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

			------------------------------------------------
			-- MUST HAVE BANANA
			------------------------------------------------
			if not HasEquippedBanana() then
				return
			end

			if BananaUI:IsOnCooldown() then
				return
			end
			------------------------------------------------
			-- MUST HAVE VALID POSITION
			------------------------------------------------
			if not currentPosition then
				return
			end

			------------------------------------------------
			-- PLACE
			------------------------------------------------

			BananaPeelRequest:FireServer(
				currentPosition
			)


			BananaUI:StartCooldown(
				GameConfig.BananaPeel.PlacementCooldown
			)

		end
	)

	print(
		"[BananaPeelController] Initialized"
	)

end

return BananaPeelController