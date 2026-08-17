local BananaPeelModule = {}

------------------------------------------------
-- DEFAULT SETTINGS
------------------------------------------------

BananaPeelModule.Settings = {
	MaxPlacementDistance = 12,
	LifeTime = 20,
	SlipDuration = 1.5,
	PlacementCooldown = 10,
}

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
    normal =  normal or Vector3.yAxis
	local rotation =
		CFrame.lookAt(
			position,
			position + normal
		)

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