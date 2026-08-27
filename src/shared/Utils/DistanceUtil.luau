-- DistanceUtil.lua

local DistanceUtil = {}

function DistanceUtil:GetDistance(
	part0: BasePart,
	part1: BasePart
): number
	if not part0
		or not part1
		or not part0.Parent
		or not part1.Parent then

		return nil
	end

	local rootA =
		part0:FindFirstChild("HumanoidRootPart")

	local rootB =
		part1:FindFirstChild("HumanoidRootPart")
	if not rootA
		or not rootB
		or not rootA:IsA("BasePart")
		or not rootB:IsA("BasePart") then
			
		return nil
	end


	return (
		part0.Position - part1.Position
	).Magnitude

end


------------------------------------------------
-- DISTANCE CHECK
------------------------------------------------

function DistanceUtil.IsWithinDistance(
	characterA: Model,
	characterB: Model,
	maxDistance: number
): boolean

	local distance =
		DistanceUtil.GetDistance(
			characterA,
			characterB
		)
	if distance == nil then
		return false
	end

	return distance <= maxDistance
end

return DistanceUtil