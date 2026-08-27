local ItemPickupDropModule = {}

local BallsFolder =
	workspace:WaitForChild("Balls")
------------------------------------------------
-- GET HAND
------------------------------------------------

local function GetHand(character)

	if not character then
		return nil
	end

	return character:FindFirstChild("RightHand")
		or character:FindFirstChild("Right Arm")

end

------------------------------------------------
-- GET MAIN PART
------------------------------------------------

function ItemPickupDropModule:GetMainPart(item)

	if not item then
		return nil
	end

	if item:IsA("BasePart") then
		return item
	end

	if item:IsA("Model") then

		if item.PrimaryPart then
			return item.PrimaryPart
		end

		local main =
			item:FindFirstChild(
				"Main",
				true
			)

		if main and main:IsA("BasePart") then
			return main
		end

		local handle =
			item:FindFirstChild(
				"Handle",
				true
			)

		if handle and handle:IsA("BasePart") then
			return handle
		end

	end

	return nil

end

------------------------------------------------
-- PREPARE FOR EQUIP
------------------------------------------------

function ItemPickupDropModule:PrepareForEquip(item)

	for _, object in ipairs(
		item:GetDescendants()
	) do

		if object:IsA("BasePart") then

			object.Anchored = false
			object.CanCollide = false
			object.CanTouch = false
			object.CanQuery = false
			object.Massless = true
		end
	end

	if item:IsA("BasePart") then

		item.Anchored = false
		item.CanCollide = false
		item.CanTouch = false
		item.CanQuery = false
		item.Massless = true

	end

end

------------------------------------------------
-- PREPARE FOR DROP
------------------------------------------------

function ItemPickupDropModule:PrepareForDrop(
	item
)

	if not item then
		return
	end

	for _, object in ipairs(
		item:GetDescendants()
	) do

		if object:IsA("BasePart") then

			object.Anchored = false
			object.CanCollide = true
			object.CanTouch = true
			object.CanQuery = true
			object.Massless = true

		end

	end

	if item:IsA("BasePart") then

		item.Anchored = false
		item.CanCollide = true
		item.CanTouch = true
		item.CanQuery = true
		item.Massless = true

	end

end

------------------------------------------------
-- EQUIP
------------------------------------------------

function ItemPickupDropModule:Equip(
	character,
	item,
	offset,
	itemId
)

	if not character or not item then
		return nil
	end

	local hand =
		GetHand(character)

	if not hand then

		warn(
			"[ItemPickupDropModule] Hand not found"
		)

		return nil

	end

	local main =
		self:GetMainPart(item)

	if not main then

		warn(
			"[ItemPickupDropModule] Main part not found"
		)

		return nil

	end

	------------------------------------------------
	-- PREPARE
	------------------------------------------------

	self:PrepareForEquip(item)

	------------------------------------------------
	-- PARENT
	------------------------------------------------

	item.Parent =
		character

	------------------------------------------------
	-- POSITION
	------------------------------------------------

	offset =
		offset
		or CFrame.new(
			0,
			-0.5,
			-1
		)

	if item:IsA("Model") then

		item:PivotTo(
			hand.CFrame * offset
		)

	else

		item.CFrame =
			hand.CFrame * offset

	end

	------------------------------------------------
	-- WELD
	------------------------------------------------

	local weld =
		Instance.new("WeldConstraint")

	weld.Name =
		"ItemHandWeld"

	weld.Part0 =
		hand

	weld.Part1 =
		main

	weld.Parent =
		main

	if itemId then

		character:SetAttribute(
			"HeldItemId",
			itemId
		)

	end

	------------------------------------------------
	-- RETURN HANDLE
	------------------------------------------------

	return {
		Item = item,
		MainPart = main,
		Hand = hand,
		Weld = weld,
	}

end

------------------------------------------------
-- UNEQUIP
------------------------------------------------

function ItemPickupDropModule:Unequip(
	equipped
)

	if not equipped then
		return nil
	end

	if equipped.Weld then

		equipped.Weld:Destroy()

		equipped.Weld = nil

	end

	return equipped.Item

end



------------------------------------------------
-- DROP
------------------------------------------------

function ItemPickupDropModule:Drop(
	character,
	equipped,
	position
)

	if not character or not equipped then
		return nil
	end

	local item =
		equipped.Item

	if not item then
		return nil
	end

	-- ------------------------------------------------
	-- -- REMOVE FROM HAND
	-- ------------------------------------------------
	-- self:PrepareForDrop(equipped)
	-- self:Unequip(equipped)

	-- ------------------------------------------------
	-- -- PARENT TO WORKSPACE
	-- ------------------------------------------------

	-- item.Parent =
	-- 	workspace

	------------------------------------------------
	-- POSITION
	------------------------------------------------

	local root =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then
		return nil
	end

	self:PrepareForDrop(item)

	self:Unequip(equipped)

	self:ClearHeldItem(character)

	-- if item == "Banana" then
	-- 	item.Parent = BallsFolder
	-- else
	-- 	item.Parent = workspace
	-- end


	local dropPosition =
		position
		or (
			root.Position
			+ root.CFrame.LookVector * 3
			+ Vector3.new(0, 2, 0)
		)

	if item:IsA("Model") then

		item:PivotTo(
			CFrame.new(dropPosition)
		)

	else

		item.CFrame =
			CFrame.new(dropPosition)

	end

	------------------------------------------------
	-- MAKE SURE ITEM IS ABOVE GROUND
	------------------------------------------------

	local rayParams =
		RaycastParams.new()

	rayParams.FilterType =
		Enum.RaycastFilterType.Exclude

	rayParams.FilterDescendantsInstances = {
		character,
		item
	}

	local rayResult =
		workspace:Raycast(
			dropPosition + Vector3.new(0, 5, 0),
			Vector3.new(0, -15, 0),
			rayParams
		)

	if rayResult then

		local groundY =
			rayResult.Position.Y

		if item:IsA("Model") then

			local boundingCFrame,
				boundingSize =
				item:GetBoundingBox()

			local bottomY =
				boundingCFrame.Position.Y
				- boundingSize.Y / 2

			local correction =
				groundY
				- bottomY
				+ 0.08

			if correction > 0 then

				item:PivotTo(
					item:GetPivot()
					+ Vector3.new(
						0,
						correction,
						0
					)
				)

			end

		elseif item:IsA("BasePart") then

			local bottomY =
				item.Position.Y
				- item.Size.Y / 2

			local correction =
				groundY
				- bottomY
				+ 0.08

			if correction > 0 then

				item.Position +=
					Vector3.new(
						0,
						correction,
						0
					)

			end

		end

	end

	------------------------------------------------
	-- FINAL PHYSICS
	------------------------------------------------

	self:PrepareForDrop(item)

	return item

end



------------------------------------------------
-- HELD ITEM ATTRIBUTES
------------------------------------------------

function ItemPickupDropModule:SetHeldItem(
	character,
	itemId,
	skinId
)

	if not character then
		return false
	end

	if not itemId then
		return false
	end

	------------------------------------------------
	-- UNIVERSAL ITEM STATE
	------------------------------------------------

	character:SetAttribute(
		"HeldItem",
		itemId
	)

	character:SetAttribute(
		"ItemId",
		itemId
	)

	------------------------------------------------
	-- OPTIONAL SKIN
	------------------------------------------------

	if skinId ~= nil then

		character:SetAttribute(
			"HeldItemSkinId",
			skinId
		)

	else

		character:SetAttribute(
			"HeldItemSkinId",
			nil
		)

	end

	return true

end

------------------------------------------------
-- CLEAR HELD ITEM
------------------------------------------------

function ItemPickupDropModule:ClearHeldItem(
	character
)

	if not character then
		return
	end

	character:SetAttribute(
		"HeldItem",
		nil
	)

	character:SetAttribute(
		"ItemId",
		nil
	)

	character:SetAttribute(
		"HeldItemSkinId",
		nil
	)

end

------------------------------------------------
-- CHECK HELD ITEM
------------------------------------------------

function ItemPickupDropModule:HasHeldItem(
	character,
	itemId
)

	if not character then
		return false
	end

	return character:GetAttribute(
		"HeldItem"
	) == itemId

end


------------------------------------------------
-- RETURN
------------------------------------------------

return ItemPickupDropModule