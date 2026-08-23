local VFXUtils = {}
local Debris = game:GetService("Debris")

function VFXUtils:PlayVFX(
	emitter,
	position,
	emitCount
)
    print("PlayVFX", emitter)
	if not emitter then
		return
	end

	local holder =
		Instance.new("Part")

	holder.Name = "HunterEntryVFX"
	holder.Size = Vector3.new(
		0.2,
		0.2,
		0.2
	)

	holder.Anchored = true
	holder.CanCollide = false
	holder.CanTouch = false
	holder.CanQuery = false
	holder.Transparency = 1

	holder.CFrame =
		CFrame.new(position)

	holder.Parent = workspace

	local particle =
		emitter:Clone()

	particle.Parent =
		holder

	particle:Emit(
		emitCount or particle:GetAttribute("EmitCount") or 20
	)

	-- Give particles time to finish.
	local lifetime =
		particle.Lifetime.Max

	Debris:AddItem(
		holder,
		lifetime + 1
	)

end

return VFXUtils