local ServerStorage =
	game:GetService("ServerStorage")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- CONFIG
------------------------------------------------

local AttachmentModule =
	require(
		ReplicatedStorage.Shared.Modules.AttachmentModule
	)

local AccessoryConfig =
	require(
		ReplicatedStorage
			.Shared
			.Config
			.AccessoryConfig
	)

------------------------------------------------
-- FOLDER
------------------------------------------------

local AccessoriesFolder =
	ServerStorage
		:WaitForChild("Cosmetics")
		:WaitForChild("Accessories")

------------------------------------------------
-- MANAGER
------------------------------------------------

local AccessoryManager = {}

------------------------------------------------
-- REMOVE ACCESSORIES
------------------------------------------------

function AccessoryManager:Clear(
	character
)

	for _, object in ipairs(
		character:GetDescendants()
	) do

		if object:GetAttribute(
			"CosmeticAccessory"
		) == true then

			object:Destroy()

		end

	end

end

------------------------------------------------
-- EQUIP
------------------------------------------------

function AccessoryManager:Equip(
	player,
	accessoryId
)

	local character =
		player.Character

	if not character then
		return false
	end

	------------------------------------------------
	-- Config
	------------------------------------------------

	local config =
		AccessoryConfig[accessoryId]

	if not config then

		warn(
			"[AccessoryManager] Missing config:",
			accessoryId
		)

		return false

	end

	------------------------------------------------
	-- Find accessory folder
	------------------------------------------------

	local accessoryFolder =
		AccessoriesFolder:FindFirstChild(
			accessoryId
		)

	if not accessoryFolder then

		warn(
			"[AccessoryManager] Missing accessory folder:",
			accessoryId
		)

		return false

	end

	------------------------------------------------
	-- Find actual model
	------------------------------------------------

	local source =
		accessoryFolder:FindFirstChild(
			config.Model
		)

	if not source then

		warn(
			"[AccessoryManager] Missing model:",
			config.Model,
			"inside",
			accessoryId
		)

		return false

	end

	------------------------------------------------
	-- Clone
	------------------------------------------------

	local visual =
		source:Clone()

	visual.Name =
		"EquippedAccessory"

	visual:SetAttribute(
		"CosmeticAccessory",
		true
	)

	visual.Parent =
		character

	------------------------------------------------
	-- Universal attachment
	------------------------------------------------

	local success =
		AttachmentModule:Attach(
			character,
			visual,
			config.AttachTo,
			config.Attachment,
			config.Offset
		)

	if not success then

		warn(
			"[AccessoryManager] Failed to attach:",
			accessoryId
		)

		visual:Destroy()

		return false

	end

	------------------------------------------------
	-- Done
	------------------------------------------------

	print(
		"[AccessoryManager] Equipped:",
		accessoryId,
		"on",
		config.AttachTo
	)

	return true

end

------------------------------------------------
-- UNEQUIP
------------------------------------------------

function AccessoryManager:Unequip(
	player
)

	local character =
		player.Character

	if not character then
		return
	end

	self:Clear(character)

	print(
		"[AccessoryManager] Unequipped"
	)

end

return AccessoryManager