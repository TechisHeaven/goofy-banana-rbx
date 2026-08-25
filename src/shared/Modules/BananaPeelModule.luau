local BananaPeelModule = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local GameConfig = require(Shared.GameConfig)
------------------------------------------------
-- DEFAULT SETTINGS
------------------------------------------------
local SURFACE_OFFSET = 0.2

BananaPeelModule.Settings = GameConfig.BananaPeel

local PlacementCooldowns = {}
------------------------------------------------
-- VALIDATE POSITION
------------------------------------------------

function BananaPeelModule:IsPositionValid(
	player,
	position
)

	local character =
		player.Character

	if not character then
		return false
	end

	local root =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then
		return false
	end

	local distance =
		(root.Position - position).Magnitude

	if distance >
		self.Settings.MaxPlacementDistance then

		return false

	end

	return true

end

------------------------------------------------
-- GET GROUND POSITION
------------------------------------------------

function BananaPeelModule:GetGroundPosition(
	player,
	position
)

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

	if not self:IsPositionValid(
		player,
		position
	) then

		return nil

	end

	local params =
		RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.FilterDescendantsInstances = {
		character
	}

	local result =
		workspace:Raycast(
			position
				+ Vector3.new(0, 5, 0),

			Vector3.new(0, -15, 0),

			params
		)

	if not result then
		return nil
	end

	return result.Position,
		result.Normal

end
------------------------------------------------
-- PLACE
------------------------------------------------

function BananaPeelModule:Place(
	peel,
	position,
	normal
)

	if not peel or not position then
		return false
	end

	normal =
		normal
		or Vector3.yAxis

	------------------------------------------------
	-- GET CURRENT ROTATION
	------------------------------------------------

	local currentCFrame

	if peel:IsA("Model") then

		currentCFrame =
			peel:GetPivot()

	elseif peel:IsA("BasePart") then

		currentCFrame =
			peel.CFrame

	else

		return false

	end

	------------------------------------------------
	-- KEEP BANANA'S FORWARD DIRECTION
	-- BUT PROJECT IT ONTO THE GROUND
	------------------------------------------------

	local forward =
		currentCFrame.LookVector

	forward =
		forward
		- normal * forward:Dot(normal)

	------------------------------------------------
	-- FALLBACK IF FORWARD IS PARALLEL
	------------------------------------------------

	if forward.Magnitude < 0.01 then

		forward =
			Vector3.new(
				0,
				0,
				-1
			)

		forward =
			forward
			- normal * forward:Dot(normal)

	end

	forward =
		forward.Unit

	------------------------------------------------
	-- BUILD ROTATION
	------------------------------------------------

	local right =
		forward:Cross(normal).Unit

	local correctedForward =
		normal:Cross(right).Unit
	local placementPosition =
	position + normal * SURFACE_OFFSET
	local rotation =
		CFrame.fromMatrix(
		placementPosition,
			right,
			normal,
			-correctedForward
		)
		
	rotation =
		rotation
		* CFrame.Angles(
			math.rad(90),
			0,
			0
		)
	------------------------------------------------
	-- APPLY
	------------------------------------------------

	if peel:IsA("Model") then

		peel:PivotTo(
			rotation
		)

	elseif peel:IsA("BasePart") then

		peel.CFrame =
			rotation

	end

	return true

end

return BananaPeelModule