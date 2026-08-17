local AttachmentModule = {}

------------------------------------------------
-- Prepare visual
------------------------------------------------

local function PreparePart(part)

	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true

end

------------------------------------------------
-- Get main part
------------------------------------------------

local function GetMainPart(visual)

	if visual:IsA("BasePart") then
		return visual
	end

	if visual:IsA("Model") then

		if visual.PrimaryPart then
			return visual.PrimaryPart
		end

		local main =
			visual:FindFirstChild("Main", true)

		if main and main:IsA("BasePart") then
			return main
		end

		local handle =
			visual:FindFirstChild("Handle", true)

		if handle and handle:IsA("BasePart") then
			return handle
		end

	end

	return nil

end

------------------------------------------------
-- Attach
------------------------------------------------

function AttachmentModule:Attach(
	character,
	visual,
	attachTo,
	attachmentName,
	offset
)

	if not character then
		return false
	end

	if not visual then
		return false
	end

	local bodyPart =
		character:FindFirstChild(
			attachTo
		)

	if not bodyPart then

		warn(
			"[AttachmentModule] Missing body part:",
			attachTo
		)

		return false
	end

	local attachment =
		bodyPart:FindFirstChild(
			attachmentName
		)

	if not attachment then

		warn(
			"[AttachmentModule] Missing attachment:",
			attachmentName,
			"on",
			attachTo
		)

		return false
	end

	------------------------------------------------
	-- Prepare all parts
	------------------------------------------------

	if visual:IsA("BasePart") then

		PreparePart(visual)

	else

		for _, object in ipairs(
			visual:GetDescendants()
		) do

			if object:IsA("BasePart") then
				PreparePart(object)
			end

		end

	end

	------------------------------------------------
	-- Find main part
	------------------------------------------------

	local main =
		GetMainPart(visual)

	if not main then

		warn(
			"[AttachmentModule] No BasePart in:",
			visual.Name
		)

		return false
	end

	------------------------------------------------
	-- Position
	------------------------------------------------

	main.CFrame =
		attachment.WorldCFrame
		* (
			offset
			or CFrame.identity
		)

	------------------------------------------------
	-- Attach
	------------------------------------------------

	local weld =
		Instance.new("WeldConstraint")

	weld.Name =
		"CosmeticAttachment"

	weld.Part0 =
		bodyPart

	weld.Part1 =
		main

	weld.Parent =
		main

	return true

end

------------------------------------------------
-- Remove one visual
------------------------------------------------

function AttachmentModule:Remove(
	visual
)

	if not visual then
		return
	end

	visual:Destroy()

end

return AttachmentModule