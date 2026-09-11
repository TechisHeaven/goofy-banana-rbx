local ContentProvider = game:GetService("ContentProvider")

local AssetLoader = {}

------------------------------------------------
-- STATE
------------------------------------------------

local CriticalModules = {}
local BackgroundModules = {}

local Initialized = false

------------------------------------------------
-- MODULE CREATION
------------------------------------------------

local function GetModule(modules, name)
	local module = modules[name]

	if not module then
		module = {
			Name = name,
			Assets = {},
			Lookup = {},
		}

		modules[name] = module
	end

	return module
end

------------------------------------------------
-- UNIQUE ASSET
------------------------------------------------

local function AddUnique(module, asset)
	if not asset then
		return
	end

	local key

	if typeof(asset) == "Instance" then
		key = asset
	else
		key = tostring(asset)
	end

	if module.Lookup[key] then
		return
	end

	module.Lookup[key] = true

	table.insert(
		module.Assets,
		asset
	)
end

------------------------------------------------
-- ADD INSTANCE ASSET
------------------------------------------------

local function AddInstanceAsset(
	modules,
	moduleName,
	asset
)
	local module =
		GetModule(
			modules,
			moduleName
		)

	AddUnique(
		module,
		asset
	)
end

------------------------------------------------
-- ADD ASSET ID
------------------------------------------------

local function AddAssetId(
	modules,
	moduleName,
	assetId,
	assetType
)
	if not assetId or assetId == "" then
		return
	end

	------------------------------------------------
	-- IMAGE
	------------------------------------------------

	if assetType == "Image" then
		local image =
			Instance.new("ImageLabel")

		image.Name =
			"PreloadImage"

		image.Image =
			assetId

		image.Size =
			UDim2.fromOffset(1, 1)

		image.BackgroundTransparency = 1
		image.Visible = true

		AddInstanceAsset(
			modules,
			moduleName,
			image
		)

		return
	end

	------------------------------------------------
	-- SOUND
	------------------------------------------------

	if assetType == "Sound" then
		local sound =
			Instance.new("Sound")

		sound.Name =
			"PreloadSound"

		sound.SoundId =
			assetId

		AddInstanceAsset(
			modules,
			moduleName,
			sound
		)

		return
	end

	------------------------------------------------
	-- DEFAULT IMAGE
	------------------------------------------------

	local image =
		Instance.new("ImageLabel")

	image.Name =
		"PreloadAsset"

	image.Image =
		assetId

	image.Size =
		UDim2.fromOffset(1, 1)

	image.BackgroundTransparency = 1
	image.Visible = true

	AddInstanceAsset(
		modules,
		moduleName,
		image
	)
end

------------------------------------------------
-- INSTANCE SCANNER
------------------------------------------------

local function CollectInstanceAssets(
	root,
	modules,
	moduleName
)
	if not root then
		return
	end

	local function Process(instance)

		------------------------------------------------
		-- IMAGES
		------------------------------------------------

		if instance:IsA("ImageLabel")
			or instance:IsA("ImageButton") then

			if instance.Image ~= "" then
				AddInstanceAsset(
					modules,
					moduleName,
					instance
				)
			end

		------------------------------------------------
		-- DECALS / TEXTURES
		------------------------------------------------

		elseif instance:IsA("Decal")
			or instance:IsA("Texture") then

			if instance.Texture ~= "" then
				AddInstanceAsset(
					modules,
					moduleName,
					instance
				)
			end

		------------------------------------------------
		-- MESHPART
		------------------------------------------------

		elseif instance:IsA("MeshPart") then

			AddInstanceAsset(
				modules,
				moduleName,
				instance
			)

		------------------------------------------------
		-- SPECIAL MESH
		------------------------------------------------

		elseif instance:IsA("SpecialMesh") then

			AddInstanceAsset(
				modules,
				moduleName,
				instance
			)

		------------------------------------------------
		-- PARTICLES
		------------------------------------------------

		elseif instance:IsA("ParticleEmitter") then

			if instance.Texture ~= "" then
				AddInstanceAsset(
					modules,
					moduleName,
					instance
				)
			end

		------------------------------------------------
		-- TRAILS
		------------------------------------------------

		elseif instance:IsA("Trail") then

			if instance.Texture ~= "" then
				AddInstanceAsset(
					modules,
					moduleName,
					instance
				)
			end

		------------------------------------------------
		-- BEAMS
		------------------------------------------------

		elseif instance:IsA("Beam") then

			if instance.Texture ~= "" then
				AddInstanceAsset(
					modules,
					moduleName,
					instance
				)
			end

		------------------------------------------------
		-- SOUNDS
		------------------------------------------------

		elseif instance:IsA("Sound") then

			if instance.SoundId ~= "" then
				AddInstanceAsset(
					modules,
					moduleName,
					instance
				)
			end

		------------------------------------------------
		-- ANIMATIONS
		------------------------------------------------

		elseif instance:IsA("Animation") then

			if instance.AnimationId ~= "" then
				AddInstanceAsset(
					modules,
					moduleName,
					instance
				)
			end
		end
	end

	------------------------------------------------
	-- ROOT
	------------------------------------------------

	Process(root)

	------------------------------------------------
	-- DESCENDANTS
	------------------------------------------------

	for _, descendant in ipairs(
		root:GetDescendants()
	) do
		Process(descendant)
	end
end

------------------------------------------------
-- ADD ROOT
------------------------------------------------

function AssetLoader:AddRoot(
	root,
	moduleName,
	isCritical
)
	if not root then
		warn(
			"[AssetLoader] Missing root for:",
			moduleName
		)

		return
	end

	local modules

	if isCritical then
		modules = CriticalModules
	else
		modules = BackgroundModules
	end

	CollectInstanceAssets(
		root,
		modules,
		moduleName
	)
end

------------------------------------------------
-- SHOP CONFIG
------------------------------------------------

function AssetLoader:AddShopConfig(
	shopConfig,
	isCritical
)
	if not shopConfig then
		warn(
			"[AssetLoader] Missing ShopConfig"
		)

		return
	end

	local modules

	if isCritical then
		modules = CriticalModules
	else
		modules = BackgroundModules
	end

	local module =
		GetModule(
			modules,
			"Shop"
		)

	for _, category in pairs(
		shopConfig.Categories or {}
	) do

		for _, item in ipairs(
			category.Items or {}
		) do

			if item.Image
				and item.Image ~= "" then

				AddAssetId(
					modules,
					"Shop",
					item.Image,
					"Image"
				)
			end
		end
	end

	
end

------------------------------------------------
-- ADD ASSET ID
------------------------------------------------

function AssetLoader:AddAsset(
	moduleName,
	assetId,
	assetType,
	isCritical
)
	local modules

	if isCritical then
		modules = CriticalModules
	else
		modules = BackgroundModules
	end

	AddAssetId(
		modules,
		moduleName,
		assetId,
		assetType
	)
end

------------------------------------------------
-- PRELOAD MODULE
------------------------------------------------

------------------------------------------------
-- PRELOAD MODULE
------------------------------------------------

local function LoadModule(
	module,
	onProgress
)
	local assets =
		module.Assets

	local total =
		#assets

	if total == 0 then

		if onProgress then

			onProgress(
				module.Name,
				1,
				0,
				0
			)

		end

		return
	end

	------------------------------------------------
	-- BATCH SIZE
	------------------------------------------------

	local BATCH_SIZE = 10

	local completed = 0

	------------------------------------------------
	-- LOAD IN BATCHES
	------------------------------------------------

	for startIndex = 1, total, BATCH_SIZE do

		local batch = {}

		local endIndex =
			math.min(
				startIndex + BATCH_SIZE - 1,
				total
			)

		for index = startIndex, endIndex do

			table.insert(
				batch,
				assets[index]
			)

		end

		------------------------------------------------
		-- PRELOAD BATCH
		------------------------------------------------

		local success, errorMessage =
			pcall(function()

				ContentProvider:PreloadAsync(
					batch
				)

			end)

		if not success then

			warn(
				"[AssetLoader] Failed:",
				module.Name,
				errorMessage
			)

		end

		------------------------------------------------
		-- PROGRESS
		------------------------------------------------

		completed = endIndex

		if onProgress then

			onProgress(
				module.Name,
				completed / total,
				completed,
				total
			)

		end

		------------------------------------------------
		-- SMALL YIELD
		------------------------------------------------

		task.wait()

	end

	------------------------------------------------
	-- DESTROY TEMPORARY ASSETS
	------------------------------------------------

	for _, asset in ipairs(assets) do

		if asset.Name == "PreloadImage"
			or asset.Name == "PreloadSound"
			or asset.Name == "PreloadAsset" then

			asset:Destroy()

		end

	end
end

------------------------------------------------
-- LOAD MODULE GROUP
------------------------------------------------

local function LoadModules(
	modules,
	onProgress
)
	for _, module in pairs(modules) do

		LoadModule(
			module,
			onProgress
		)

	end
end

------------------------------------------------
-- CRITICAL
------------------------------------------------

function AssetLoader:LoadCritical(
	onProgress
)
	print(
		"[AssetLoader] Loading critical modules..."
	)

	LoadModules(
		CriticalModules,
		onProgress
	)

	print(
		"[AssetLoader] Critical loading complete"
	)
end

------------------------------------------------
-- BACKGROUND
------------------------------------------------

function AssetLoader:LoadBackground(
	onProgress
)
	print(
		"[AssetLoader] Loading background modules..."
	)

	LoadModules(
		BackgroundModules,
		onProgress
	)

	print(
		"[AssetLoader] Background loading complete"
	)
end

------------------------------------------------
-- COUNTS
------------------------------------------------

function AssetLoader:GetModuleCount(
	isCritical
)
	local modules =
		isCritical
		and CriticalModules
		or BackgroundModules

	local count = 0

	for _ in pairs(modules) do
		count += 1
	end

	return count
end

------------------------------------------------
-- INIT
------------------------------------------------

function AssetLoader:Init()
	if Initialized then
		return
	end

	Initialized = true

	print(
		"[AssetLoader] Initialized"
	)
end

return AssetLoader