local ItemPickupDropModule = {}

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
			object.Massless = false

		end

	end

	if item:IsA("BasePart") then

		item.Anchored = false
		item.CanCollide = true
		item.CanTouch = true
		item.CanQuery = true
		item.Massless = false

	end

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

	------------------------------------------------
	-- REMOVE FROM HAND
	------------------------------------------------

	self:Unequip(equipped)

	------------------------------------------------
	-- PARENT TO WORKSPACE
	------------------------------------------------

	item.Parent =
		workspace

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

	position =
		position
		or (
			root.Position
			+ root.CFrame.LookVector * 3
			+ Vector3.new(0, 1, 0)
		)

	if item:IsA("Model") then

		item:PivotTo(
			CFrame.new(position)
		)

	else

		item.CFrame =
			CFrame.new(position)

	end

	------------------------------------------------
	-- RESTORE PHYSICS
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