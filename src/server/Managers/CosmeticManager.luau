--!strict

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------------------------
-- MODULES
------------------------------------------------

local ProfileManager = require(
	script.Parent.ProfileManager
)

local AccessoryManager = require(
	script.Parent.AccessoryManager
)

local SkinVisualConfig = require(
	ReplicatedStorage
		.Shared
		.Config
		.SkinVisualConfig
)

------------------------------------------------
-- FOLDERS
------------------------------------------------

local Cosmetics =
	ServerStorage:WaitForChild("Cosmetics")

local SkinsFolder =
	Cosmetics:WaitForChild("Skins")

------------------------------------------------
-- MANAGER
------------------------------------------------

local CosmeticManager = {}
local OriginalTransparency = {}
------------------------------------------------
-- GET PROFILE
------------------------------------------------

local function GetProfile(player)

	return ProfileManager:GetProfile(player)

end

------------------------------------------------
-- GET EQUIPPED SKIN
------------------------------------------------

function CosmeticManager:GetEquippedSkin(player)

	local profile =
		GetProfile(player)

	if not profile then
		return nil
	end

	local inventory =
		profile.Inventory

	if not inventory then
		return nil
	end

	local equipped =
		inventory.Equipped

	if not equipped then
		return nil
	end

	return equipped.Skins

end

------------------------------------------------
-- GET SKIN CONFIG
------------------------------------------------

function CosmeticManager:GetSkinConfig(
	skinId
)

	if not skinId then
		return nil
	end

	return SkinVisualConfig[skinId]

end

------------------------------------------------
-- GET SKIN FOLDER
------------------------------------------------

function CosmeticManager:GetSkinFolder(
	skinId
)

	if not skinId then
		return nil
	end

	return SkinsFolder:FindFirstChild(
		skinId
	)

end


------------------------------------------------
-- SAVE ORIGINAL TRANSPARENCY
------------------------------------------------

local function SaveOriginalTransparency(
	characterPart
)

	if OriginalTransparency[characterPart] == nil then

		OriginalTransparency[characterPart] =
			characterPart.Transparency

	end

end
------------------------------------------------
-- PREPARE SKIN VISUAL
------------------------------------------------

local function PrepareSkinVisual(
	visual
)

	visual.Anchored = false
	visual.CanCollide = false
	visual.CanTouch = false
	visual.CanQuery = false
	visual.Massless = true

end

------------------------------------------------
-- FIND CHARACTER ATTACHMENT
------------------------------------------------

local function GetCosmeticAttachment(
	characterPart
)

	if not characterPart then
		return nil
	end

	local attachment =
		characterPart:FindFirstChild(
			"CosmeticVisual"
		)

	if not attachment then

		warn(
			"[CosmeticManager] Missing CosmeticVisual attachment:",
			characterPart:GetFullName()
		)

		return nil

	end

	if not attachment:IsA("Attachment") then

		warn(
			"[CosmeticManager] CosmeticVisual must be an Attachment:",
			characterPart:GetFullName()
		)

		return nil

	end

	return attachment

end

------------------------------------------------
-- FIND SKIN VISUAL
--
-- Structure:
--
-- Skin
-- └── Parts
--     └── UpperTorso
--         └── UpperTorso
------------------------------------------------

local function GetSkinVisual(
	skinFolder,
	partName,
	visualName
)

	------------------------------------------------
	-- HEAD
	------------------------------------------------

	if partName == "Head" then

		local headFolder =
			skinFolder:FindFirstChild(
				"Head"
			)

		if not headFolder then

			warn(
				"[CosmeticManager] Missing Head folder:",
				skinFolder:GetFullName()
			)

			return nil

		end

		return headFolder:FindFirstChild(
			visualName
		)

	end

	------------------------------------------------
	-- BODY PARTS
	------------------------------------------------

	local partsFolder =
		skinFolder:FindFirstChild(
			"Parts"
		)

	if not partsFolder then

		warn(
			"[CosmeticManager] Missing Parts folder:",
			skinFolder:GetFullName()
		)

		return nil

	end

	local partFolder =
		partsFolder:FindFirstChild(
			partName
		)

	if not partFolder then

		warn(
			"[CosmeticManager] Missing body part folder:",
			partName,
			"inside",
			skinFolder.Name
		)

		return nil

	end

	local visual =
		partFolder:FindFirstChild(
			visualName
		)

	if not visual then

		warn(
			"[CosmeticManager] Missing skin visual:",
			visualName,
			"inside",
			partFolder:GetFullName()
		)

		return nil

	end

	return visual

end

------------------------------------------------
-- WELD SKIN VISUAL
------------------------------------------------
------------------------------------------------
-- SET ORIGINAL PART VISIBILITY
------------------------------------------------

local function SetOriginalPartVisibility(
	characterPart,
	mode
)
	SaveOriginalTransparency(
		characterPart
	)

	------------------------------------------------
	-- Overlay
	--
	-- Keep the original body visible.
	------------------------------------------------

	if mode == "Overlay" then

		characterPart.Transparency = 0

		return
	end

	------------------------------------------------
	-- ReplaceVisual / default
	--
	-- Keep the real R15 part alive but hide it.
	------------------------------------------------

	characterPart.Transparency = 1

end
------------------------------------------------
-- WELD SKIN VISUAL
------------------------------------------------

local function WeldSkinVisual(
	character,
	characterPart,
	source,
	offset,
	mode
)

	if not source:IsA("BasePart") then

		warn(
			"[CosmeticManager] Skin visual must be BasePart:",
			source:GetFullName()
		)

		return nil
	end

	local attachment =
		GetCosmeticAttachment(
			characterPart
		)

	if not attachment then
		return nil
	end

	------------------------------------------------
	-- Clone
	------------------------------------------------

	local visual =
		source:Clone()

	visual.Name = "SkinVisual"

	visual:SetAttribute(
		"CosmeticVisual",
		true
	)

	visual:SetAttribute(
		"CosmeticMode",
		mode or "ReplaceVisual"
	)

	------------------------------------------------
	-- Prepare
	------------------------------------------------

	PrepareSkinVisual(
		visual
	)

	visual.Parent =
		character

	------------------------------------------------
	-- DEFAULT MODE
	------------------------------------------------

	mode =
		mode
		or "ReplaceVisual"

	------------------------------------------------
	-- OFFSET
	------------------------------------------------

	offset =
		offset
		or CFrame.new()

	------------------------------------------------
	-- IMPORTANT
	--
	-- Attachment rotation is ignored.
	-- Character part rotation controls the skin.
	------------------------------------------------

	local attachmentPosition =
		attachment.Position

	------------------------------------------------
	-- POSITION VISUAL
	------------------------------------------------

	visual.CFrame =
		characterPart.CFrame
		* CFrame.new(
			attachmentPosition
		)
		* offset

	------------------------------------------------
	-- WELD
	------------------------------------------------

	local weld =
		Instance.new("Weld")

	weld.Name =
		"CosmeticVisualWeld"

	weld.Part0 =
		characterPart

	weld.Part1 =
		visual

	weld.C0 =
		CFrame.new(
			attachmentPosition
		)
		* offset

	weld.C1 =
		CFrame.new()

	weld.Parent =
		visual

	------------------------------------------------
	-- ORIGINAL PART VISIBILITY
	------------------------------------------------

	SetOriginalPartVisibility(
		characterPart,
		mode
	)

	return visual

end

------------------------------------------------
-- CLEAR SKIN VISUALS
------------------------------------------------

function CosmeticManager:ClearSkin(
	character
)

	if not character then
		return
	end

	for _, object in ipairs(
		character:GetDescendants()
	) do

		if object:GetAttribute(
			"CosmeticVisual"
		) == true then

			object:Destroy()

		end

	end

	------------------------------------------------
	-- Restore original body parts
	------------------------------------------------

	for part, transparency in pairs(
		OriginalTransparency
	) do

		if part
			and part.Parent == character
		then

			part.Transparency =
				transparency

		end

	end

	------------------------------------------------
	-- Clear saved data
	------------------------------------------------

	for part in pairs(
		OriginalTransparency
	) do

		if not part
			or part.Parent == nil
		then

			OriginalTransparency[part] =
				nil

		end

	end

end

------------------------------------------------
-- APPLY ONE VISUAL
------------------------------------------------

function CosmeticManager:ApplyVisual(
	player,
	character,
	partName,
	data
)

	if not partName then
		return nil
	end

	if not data then
		return nil
	end

	------------------------------------------------
	-- Get character part
	------------------------------------------------

	local characterPart =
		character:FindFirstChild(
			partName
		)

	if not characterPart then

		warn(
			"[CosmeticManager] Character part missing:",
			partName
		)

		return nil

	end

	if not characterPart:IsA("BasePart") then

		warn(
			"[CosmeticManager] Character part is not BasePart:",
			partName
		)

		return nil

	end

	------------------------------------------------
	-- Get equipped skin
	------------------------------------------------

	local skinId =
		self:GetEquippedSkin(
			player
		)

	if not skinId then
		return nil
	end

	------------------------------------------------
	-- Get skin folder
	------------------------------------------------

	local skinFolder =
		self:GetSkinFolder(
			skinId
		)

	if not skinFolder then

		warn(
			"[CosmeticManager] Missing skin folder:",
			skinId
		)

		return nil

	end

	------------------------------------------------
	-- Visual name
	------------------------------------------------

	local visualName =
		data.Visual

	if not visualName then

		warn(
			"[CosmeticManager] Missing Visual:",
			partName,
			skinId
		)

		return nil

	end

	------------------------------------------------
	-- Find source
	------------------------------------------------

	local source =
		GetSkinVisual(
			skinFolder,
			partName,
			visualName
		)

	if not source then
		return nil
	end

	------------------------------------------------
	-- OFFSET
	------------------------------------------------

	local offset =
		data.Offset
		or CFrame.new()

	------------------------------------------------
	-- MODE
	------------------------------------------------

	local mode =
		data.Mode
		or "ReplaceVisual"

	------------------------------------------------
	-- WELD
	------------------------------------------------

	local visual =
		WeldSkinVisual(
			character,
			characterPart,
			source,
			offset,
			mode
		)

	if visual then

		print(
			"[CosmeticManager] Applied",
			skinId,
			visualName,
			"to",
			partName
		)

	end

	return visual

end

------------------------------------------------
-- APPLY SKIN
------------------------------------------------

function CosmeticManager:ApplySkin(
	player,
	character,
	skinId
)

	if not player then
		return false
	end

	if not character then
		return false
	end

	if not skinId then
		return false
	end

	------------------------------------------------
	-- Config
	------------------------------------------------

	local config =
		self:GetSkinConfig(
			skinId
		)

	if not config then

		warn(
			"[CosmeticManager] Missing skin config:",
			skinId
		)

		return false

	end

	------------------------------------------------
	-- Clear previous visuals
	------------------------------------------------

	self:ClearSkin(
		character
	)

	------------------------------------------------
	-- Player appearance
	------------------------------------------------

	if config.UsePlayerAppearance == false then

		for _, object in ipairs(
			character:GetChildren()
		) do

			if object:IsA("Accessory")
				or object:IsA("Shirt")
				or object:IsA("Pants")
				or object:IsA("ShirtGraphic")
			then

				object:Destroy()

			end

		end

	end

	------------------------------------------------
	-- BODY VISUALS
	------------------------------------------------

	for partName, data in pairs(
		config.Parts or {}
	) do

		self:ApplyVisual(
			player,
			character,
			partName,
			data
		)

	end

	------------------------------------------------
	-- ACCESSORIES
	------------------------------------------------

	AccessoryManager:Clear(
		character
	)

	for accessoryId, enabled in pairs(
		config.Accessories or {}
	) do

		if enabled then

			AccessoryManager:Equip(
				player,
				accessoryId
			)

		end

	end

	return true

end

------------------------------------------------
-- REFRESH SKIN
------------------------------------------------

function CosmeticManager:RefreshSkin(
	player
)

	local character =
		player.Character

	if not character then
		return false
	end

	local skinId =
		self:GetEquippedSkin(
			player
		)

	------------------------------------------------
	-- No skin
	------------------------------------------------

	if not skinId then

		self:ClearSkin(
			character
		)

		return true

	end

	------------------------------------------------
	-- Apply
	------------------------------------------------

	return self:ApplySkin(
		player,
		character,
		skinId
	)

end

------------------------------------------------
-- REFRESH
------------------------------------------------

function CosmeticManager:Refresh(
	player,
	category
)

	if category == "Skins" then

		self:RefreshSkin(
			player
		)

	end

end

------------------------------------------------
-- CHARACTER SETUP
------------------------------------------------

function CosmeticManager:SetupPlayer(
	player
)

	player.CharacterAdded:Connect(
		function(character)

			character:WaitForChild(
				"Humanoid",
				5
			)

			character:WaitForChild(
				"Head",
				5
			)

			character:WaitForChild(
				"UpperTorso",
				5
			)

			character:WaitForChild(
				"LowerTorso",
				5
			)

			------------------------------------------------
			-- Give StarterCharacter time to finish
			------------------------------------------------

			task.wait(0.2)

			------------------------------------------------
			-- Apply saved skin
			------------------------------------------------

			self:RefreshSkin(
				player
			)

		end
	)

	------------------------------------------------
	-- Existing character
	------------------------------------------------

	if player.Character then

		task.defer(
			function()

				self:RefreshSkin(
					player
				)

			end
		)

	end

end

------------------------------------------------
-- INIT
------------------------------------------------

function CosmeticManager:Init()

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		self:SetupPlayer(
			player
		)

	end

	Players.PlayerAdded:Connect(
		function(player)

			self:SetupPlayer(
				player
			)

		end
	)

end

return CosmeticManager