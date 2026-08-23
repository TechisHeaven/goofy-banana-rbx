local Players =
	game:GetService("Players")

local ServerStorage =
	game:GetService("ServerStorage")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- MODULES
------------------------------------------------

local ProfileManager =
	require(
		script.Parent.ProfileManager
	)
local AccessoryManager = require(script.Parent.AccessoryManager)

	
local SkinVisualConfig =
	require(
		ReplicatedStorage
			.Shared
			.Config
			.SkinVisualConfig
	)

local BananaSkinVisualConfig =
	require(
		ReplicatedStorage
			.Shared
			.Config
			.BananaSkinVisualConfig
	)

------------------------------------------------
-- FOLDERS
------------------------------------------------

local Cosmetics =
	ServerStorage:WaitForChild("Cosmetics")

local SkinsFolder =
	Cosmetics:WaitForChild("Skins")
local BananaSkinsFolder =
	Cosmetics:WaitForChild("BananaSkins")
------------------------------------------------
-- MANAGER
------------------------------------------------

local CosmeticManager = {}

------------------------------------------------
-- ORIGINAL CHARACTER DATA
--
-- This is runtime-only.
-- It is NOT saved to Profile.
------------------------------------------------

local OriginalCharacters = {}

------------------------------------------------
-- PROFILE
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
-- SAVE ORIGINAL CHARACTER APPEARANCE
------------------------------------------------

function CosmeticManager:CaptureCharacter(
	player,
	character
)

	------------------------------------------------
	-- Don't capture the already modified character
	------------------------------------------------

	if OriginalCharacters[player] then

		if OriginalCharacters[player].Character
			== character then

			return

		end

	end

	------------------------------------------------
	-- Snapshot
	------------------------------------------------

	local snapshot = {
		Character = character,

		Parts = {},

		Decals = {},

		Textures = {},

		SurfaceAppearances = {},
	}

	------------------------------------------------
	-- Capture ALL descendants
	------------------------------------------------

	for _, object in ipairs(
		character:GetDescendants()
	) do

		------------------------------------------------
		-- BaseParts
		------------------------------------------------

		if object:IsA("BasePart") then

			snapshot.Parts[object] = {

				Color =
					object.Color,

				Material =
					object.Material,

				Transparency =
					object.Transparency,

				Reflectance =
					object.Reflectance,

			}

			------------------------------------------------
			-- MeshPart
			------------------------------------------------

			if object:IsA("MeshPart") then

				snapshot.Parts[object].TextureID =
					object.TextureID

			end

		------------------------------------------------
		-- Decals
		------------------------------------------------

		elseif object:IsA("Decal") then

			snapshot.Decals[object] = {

				Transparency =
					object.Transparency,

				Color3 =
					object.Color3,

			}

		------------------------------------------------
		-- Textures
		------------------------------------------------

		elseif object:IsA("Texture") then

			snapshot.Textures[object] = {

				Transparency =
					object.Transparency,

				Color3 =
					object.Color3,

			}

		------------------------------------------------
		-- SurfaceAppearance
		------------------------------------------------

		elseif object:IsA("SurfaceAppearance") then

			snapshot.SurfaceAppearances[object] = {

				ColorMap =
					object.ColorMap,

				MetalnessMap =
					object.MetalnessMap,

				NormalMap =
					object.NormalMap,

				RoughnessMap =
					object.RoughnessMap,

			}

		end

	end

	OriginalCharacters[player] =
		snapshot

end

------------------------------------------------
-- RESTORE ORIGINAL CHARACTER
------------------------------------------------

function CosmeticManager:RestoreCharacter(
	player
)

	local snapshot =
		OriginalCharacters[player]

	if not snapshot then
		return
	end

	local character =
		player.Character

	if not character then
		return
	end

	------------------------------------------------
	-- Make sure this snapshot belongs
	-- to the current character
	------------------------------------------------

	if snapshot.Character ~= character then
		return
	end

	------------------------------------------------
	-- Restore Parts
	------------------------------------------------

	for object, properties in pairs(
		snapshot.Parts
	) do

		if object
			and object.Parent then

			object.Color =
				properties.Color

			object.Material =
				properties.Material

			object.Transparency =
				properties.Transparency

			object.Reflectance =
				properties.Reflectance

			if object:IsA("MeshPart")
				and properties.TextureID then

				object.TextureID =
					properties.TextureID

			end

		end

	end

	------------------------------------------------
	-- Restore Decals
	------------------------------------------------

	for object, properties in pairs(
		snapshot.Decals
	) do

		if object
			and object.Parent then

			object.Transparency =
				properties.Transparency

			object.Color3 =
				properties.Color3

		end

	end

	------------------------------------------------
	-- Restore Textures
	------------------------------------------------

	for object, properties in pairs(
		snapshot.Textures
	) do

		if object
			and object.Parent then

			object.Transparency =
				properties.Transparency

			object.Color3 =
				properties.Color3

		end

	end

	------------------------------------------------
	-- Restore SurfaceAppearance
	------------------------------------------------

	for object, properties in pairs(
		snapshot.SurfaceAppearances
	) do

		if object
			and object.Parent then

			object.ColorMap =
				properties.ColorMap

			object.MetalnessMap =
				properties.MetalnessMap

			object.NormalMap =
				properties.NormalMap

			object.RoughnessMap =
				properties.RoughnessMap

		end

	end

end

------------------------------------------------
-- REMOVE ALL COSMETIC VISUALS
------------------------------------------------

function CosmeticManager:ClearCosmeticVisuals(
	character
)

	for _, object in ipairs(
		character:GetDescendants()
	) do

		if object:GetAttribute(
			"CosmeticVisual"
		) == true then

			object:Destroy()

		end

	end

end

------------------------------------------------
-- PREPARE COSMETIC PART
------------------------------------------------

local function PreparePart(part)

	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true

end

------------------------------------------------
-- APPLY BODY COLOR
------------------------------------------------

function CosmeticManager:ApplyBodyColor(
	character,
	color
)

	if not color then
		return
	end

	for _, object in ipairs(
		character:GetChildren()
	) do

		if object:IsA("BasePart")
			and object.Name ~= "HumanoidRootPart" then

			object.Color =
				color

		end

	end

end
------------------------------------------------
-- HIDE ORIGINAL BODY PART
------------------------------------------------

local function HideOriginalPart(part)

	if not part then
		return
	end

	part.Transparency = 1

	for _, object in ipairs(part:GetChildren()) do

		if object:IsA("Decal")
			or object:IsA("Texture") then

			object.Transparency = 1

		end

	end

end

------------------------------------------------
-- APPLY COSMETIC BODY PART
------------------------------------------------

function CosmeticManager:ApplyPart(
	player,
	character,
	partName,
	cosmeticId,
	folderName
)

	if not partName or not cosmeticId then
		return
	end

	------------------------------------------------
	-- Character part
	------------------------------------------------

	local characterPart =
		character:FindFirstChild(partName)

	if not characterPart then

		warn(
			"[CosmeticManager] Character part missing:",
			partName
		)

		return
	end

	------------------------------------------------
	-- Skin
	------------------------------------------------

	local skinId =
		self:GetEquippedSkin(player)

	if not skinId then
		return
	end

	local skinFolder =
		self:GetSkinFolder(skinId)

	if not skinFolder then
		return
	end

	------------------------------------------------
	-- Cosmetic folder
	------------------------------------------------

	local cosmeticFolder =
		skinFolder:FindFirstChild(folderName)
	if not cosmeticFolder then

		warn(
			"[CosmeticManager] Missing folder:",
			folderName,
			"inside",
			skinId
		)

		return
	end

	------------------------------------------------
	-- Source
	------------------------------------------------

	local source =
		cosmeticFolder:FindFirstChild(cosmeticId)
	if not source then

		warn(
			"[CosmeticManager] Missing cosmetic:",
			cosmeticId,
			"for",
			partName
		)

		return
	end

	------------------------------------------------
	-- Clone
	------------------------------------------------

	local visual =
		source:Clone()

	visual.Name =
		"CosmeticVisual"

	visual:SetAttribute(
		"CosmeticVisual",
		true
	)

	visual.Parent =
		characterPart

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
	-- Find primary part
	------------------------------------------------

	local primary

	if visual:IsA("BasePart") then

		primary = visual

	elseif visual:IsA("Model") then

		primary =
			visual.PrimaryPart

		if not primary then

			primary =
				visual:FindFirstChildWhichIsA(
					"BasePart",
					true
				)

		end

	end

	------------------------------------------------
	-- Invalid visual
	------------------------------------------------

	if not primary then

		warn(
			"[CosmeticManager] No BasePart in:",
			cosmeticId
		)

		visual:Destroy()

		return
	end

	------------------------------------------------
	-- Align
	------------------------------------------------

	if visual:IsA("Model") then

		visual:PivotTo(
			characterPart.CFrame
		)

	else

		visual.CFrame =
			characterPart.CFrame

	end

	------------------------------------------------
	-- Weld
	------------------------------------------------

	local weld =
		Instance.new("WeldConstraint")

	weld.Name =
		"CosmeticWeld"

	weld.Part0 =
		characterPart

	weld.Part1 =
		primary

	weld.Parent =
		primary

	------------------------------------------------
	-- Hide original
	------------------------------------------------

	HideOriginalPart(
		characterPart
	)

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
		return
	end

	local skinId = self:GetEquippedSkin(player)
	------------------------------------------------
	-- Remove previous cosmetic
	------------------------------------------------

	self:ClearCosmeticVisuals(
		character
	)
	if not skinId then
		AccessoryManager:Clear(character)
		-- return
	end
	------------------------------------------------
	-- Restore COMPLETE original character
	------------------------------------------------

	self:RestoreCharacter(
		player
	)

	------------------------------------------------
	-- Get equipped skin
	------------------------------------------------

	local skinId =
		self:GetEquippedSkin(player)

	------------------------------------------------
	-- No skin equipped
	------------------------------------------------

	if not skinId then

		print(
			"[CosmeticManager] No skin equipped:",
			player.Name
		)

		return

	end

	------------------------------------------------
	-- Get config
	------------------------------------------------

	local config =
		self:GetSkinConfig(skinId)

	if not config then

		warn(
			"[CosmeticManager] Missing config:",
			skinId
		)

		return

	end

	------------------------------------------------
	-- Body Color
	------------------------------------------------

	if config.BodyColor then

		self:ApplyBodyColor(
			character,
			config.BodyColor
		)

	end

	------------------------------------------------
    -- HEAD
    ------------------------------------------------

    if config.Head then

        self:ApplyPart(
            player,
            character,
            "Head",
            config.Head,
            "Head"
        )

    end
	------------------------------------------------
	-- IMPORTANT:
	-- Remove accessories from previous skin
	------------------------------------------------
	AccessoryManager:Clear(character)
	------------------------------------------------
	-- ACCESSORIES
	------------------------------------------------

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

    ------------------------------------------------
    -- BODY PARTS
    ------------------------------------------------

    for partName, cosmeticId in pairs(
        config.Parts or {}
    ) do

  
        self:ApplyPart(
            player,
            character,
            partName,
            cosmeticId,
            "Parts"
        )

    end

end


------------------------------------------------
-- BANANA SKINS
------------------------------------------------

function CosmeticManager:GetEquippedBananaSkin(player)

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

	return equipped.BananaSkins

end


------------------------------------------------
-- GET BANANA SKIN CONFIG
------------------------------------------------

function CosmeticManager:GetBananaSkinConfig(
	skinId
)

	if not skinId then
		return nil
	end

	return BananaSkinVisualConfig[skinId]

end


------------------------------------------------
-- GET BANANA SKIN MODEL
------------------------------------------------

function CosmeticManager:GetBananaSkinModel(
	skinId
)

	local config =
		self:GetBananaSkinConfig(
			skinId
		)

	if not config then

		warn(
			"[CosmeticManager] Missing banana skin config:",
			skinId
		)

		return nil
	end

	local skinFolder =
		BananaSkinsFolder:FindFirstChild(
			skinId
		)

	if not skinFolder then

		warn(
			"[CosmeticManager] Missing banana skin folder:",
			skinId
		)

		return nil
	end

	local model =
		skinFolder:FindFirstChild(
			config.Model
		)

	if not model then

		warn(
			"[CosmeticManager] Missing banana skin model:",
			config.Model,
			"inside",
			skinId
		)

		return nil
	end

	return model

end


------------------------------------------------
-- GET MAIN PART
------------------------------------------------

local function GetBananaMain(
	visual
)

	if visual:IsA("BasePart") then
		return visual
	end

	if not visual:IsA("Model") then
		return nil
	end

	if visual.PrimaryPart then
		return visual.PrimaryPart
	end

	local main =
		visual:FindFirstChild(
			"Main",
			true
		)

	if main and main:IsA("BasePart") then
		return main
	end

	return visual:FindFirstChildWhichIsA(
		"BasePart",
		true
	)

end


------------------------------------------------
-- CLEAR BANANA SKIN
------------------------------------------------

function CosmeticManager:ClearBananaSkin(
	bananaVisual
)

	if not bananaVisual then
		return
	end

	for _, object in ipairs(
		bananaVisual:GetDescendants()
	) do

		if object:GetAttribute(
			"BananaSkinVisual"
		) == true then

			object:Destroy()

		end

	end

end


------------------------------------------------
-- REFRESH BANANA SKIN
------------------------------------------------

function CosmeticManager:RefreshBananaSkin(
	player,
	bananaVisual
)

	if not bananaVisual then
		return false
	end

	------------------------------------------------
	-- EQUIPPED SKIN
	------------------------------------------------

	local skinId =
		self:GetEquippedBananaSkin(
			player
		)

	------------------------------------------------
	-- CLEAR CURRENT
	------------------------------------------------

	self:ClearBananaSkin(
		bananaVisual
	)

	------------------------------------------------
	-- NO SKIN
	------------------------------------------------

	if not skinId then
		return true
	end

	------------------------------------------------
	-- SOURCE
	------------------------------------------------

	local source =
		self:GetBananaSkinModel(
			skinId
		)

	if not source then
		return false
	end

	------------------------------------------------
	-- BANANA MAIN
	------------------------------------------------

	local bananaMain =
		GetBananaMain(
			bananaVisual
		)

	if not bananaMain then

		warn(
			"[CosmeticManager] Banana has no Main part"
		)

		return false
	end

	------------------------------------------------
	-- CLONE
	------------------------------------------------

	local visual =
		source:Clone()

	visual.Name =
		"BananaSkinVisual"

	visual:SetAttribute(
		"BananaSkinVisual",
		true
	)

	visual.Parent =
		bananaVisual

	------------------------------------------------
	-- PREPARE
	------------------------------------------------

	if visual:IsA("BasePart") then

		PreparePart(
			visual
		)

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
	-- SKIN MAIN
	------------------------------------------------

	local skinMain =
		GetBananaMain(
			visual
		)

	if not skinMain then

		warn(
			"[CosmeticManager] Banana skin has no Main:",
			skinId
		)

		visual:Destroy()

		return false
	end

	------------------------------------------------
	-- POSITION
	------------------------------------------------

	if visual:IsA("Model") then

		visual:PivotTo(
			bananaMain.CFrame
		)

	else

		visual.CFrame =
			bananaMain.CFrame

	end

	------------------------------------------------
	-- WELD
	------------------------------------------------

	local weld =
		Instance.new("WeldConstraint")

	weld.Name =
		"BananaSkinWeld"

	weld.Part0 =
		bananaMain

	weld.Part1 =
		skinMain

	weld.Parent =
		skinMain

	------------------------------------------------
	-- HIDE ORIGINAL BANANA
	------------------------------------------------

	if bananaMain ~= skinMain then
		bananaMain.Transparency = 1
	end

	return true

end


------------------------------------------------
-- UNIVERSAL REFRESH
------------------------------------------------

function CosmeticManager:Refresh(
	player,
	category
)

	if not player then
		return
	end

	if category == "Skins" then

		self:RefreshSkin(
			player
		)

	elseif category == "BananaSkins" then
		
		-- Later
		-- self:RefreshBananaSkin(player)

	elseif category == "RescueEffects" then

		-- Later
		-- self:RefreshRescueEffect(player)

	elseif category == "VictoryPoses" then

		-- Later
		-- self:RefreshVictoryPose(player)

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

			------------------------------------------------
			-- Wait for complete R15 character
			------------------------------------------------

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

			task.wait(0.2)

			------------------------------------------------
			-- Capture DEFAULT CHARACTER
			------------------------------------------------

			self:CaptureCharacter(
				player,
				character
			)

			------------------------------------------------
			-- Apply SAVED skin
			------------------------------------------------

			self:Refresh(
				player,
				"Skins"
			)

		end
	)

	------------------------------------------------
	-- Existing character
	------------------------------------------------

	if player.Character then

		task.defer(
			function()

				self:CaptureCharacter(
					player,
					player.Character
				)

				self:Refresh(
					player,
					"Skins"
				)

			end
		)

	end

end

------------------------------------------------
-- PLAYER REMOVING
------------------------------------------------

Players.PlayerRemoving:Connect(
	function(player)

		OriginalCharacters[player] =
			nil
		
	end
)

------------------------------------------------
-- INIT
------------------------------------------------

function CosmeticManager:Init()

	print(
		"CosmeticManager Initializing..."
	)

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