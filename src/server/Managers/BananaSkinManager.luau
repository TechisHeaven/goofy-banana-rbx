local ServerStorage =
	game:GetService("ServerStorage")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- CONFIG
------------------------------------------------
print(ReplicatedStorage.Shared.Config)
print(ReplicatedStorage.Shared.Config.BananaSkinVisualConfig)
local BananaSkinVisualConfig = require(ReplicatedStorage.Shared.Config.BananaSkinVisualConfig)

------------------------------------------------
-- MODULES
------------------------------------------------

local ProfileManager =
	require(
		script.Parent.ProfileManager
	)

------------------------------------------------
-- FOLDER
------------------------------------------------

local BananaSkinsFolder =
	ServerStorage
		:WaitForChild("Cosmetics")
		:WaitForChild("BananaSkins")

------------------------------------------------
-- MANAGER
------------------------------------------------

local BananaSkinManager = {}

------------------------------------------------
-- GET PROFILE
------------------------------------------------

local function GetProfile(player)

	return ProfileManager:GetProfile(
		player
	)

end

------------------------------------------------
-- GET EQUIPPED BANANA SKIN
------------------------------------------------

function BananaSkinManager:GetEquipped(
	player
)

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
	print(equipped.BananaSkins)
	return equipped.BananaSkins

end

------------------------------------------------
-- GET CONFIG
------------------------------------------------

function BananaSkinManager:GetConfig(
	skinId
)

	if not skinId then
		return nil
	end

	return BananaSkinVisualConfig[
		skinId
	]

end

------------------------------------------------
-- GET MODEL
------------------------------------------------

function BananaSkinManager:GetModel(
	skinId
)

	local config =
		self:GetConfig(
			skinId
		)

	if not config then

		warn(
			"[BananaSkinManager] Missing config:",
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
			"[BananaSkinManager] Missing skin folder:",
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
			"[BananaSkinManager] Missing model:",
			config.Model,
			"inside",
			skinId
		)

		return nil
	end

	return model

end

------------------------------------------------
-- PREPARE PART
------------------------------------------------

local function PreparePart(
	part
)

	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true

end

------------------------------------------------
-- PREPARE MODEL
------------------------------------------------

local function PrepareModel(
	model
)

	if model:IsA("BasePart") then

		PreparePart(
			model
		)

		return

	end

	for _, object in ipairs(
		model:GetDescendants()
	) do

		if object:IsA("BasePart") then

			PreparePart(
				object
			)

		end

	end

end

------------------------------------------------
-- GET MAIN
------------------------------------------------

local function GetMain(
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
-- CLEAR CURRENT SKIN
------------------------------------------------

function BananaSkinManager:Clear(
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
-- APPLY SKIN
------------------------------------------------

function BananaSkinManager:Apply(
	player,
	bananaVisual,
	skinId
)

	if not bananaVisual then
		return false
	end
	print("BananaSkinManager", skinId)
	------------------------------------------------
	-- Get equipped skin
	------------------------------------------------
	if not skinId then

		skinId =
			self:GetEquipped(
				player
			)

	end


	------------------------------------------------
	-- No skin
	------------------------------------------------

	if not skinId then

		self:Clear(
			bananaVisual
		)

		return true

	end

	------------------------------------------------
	-- Get source
	------------------------------------------------

	local source =
		self:GetModel(
			skinId
		)

	if not source then
		return false
	end

	------------------------------------------------
	-- Find banana main
	------------------------------------------------

	local bananaMain =
		GetMain(
			bananaVisual
		)

	if not bananaMain then

		warn(
			"[BananaSkinManager] Banana has no Main part"
		)

		return false
	end

	------------------------------------------------
	-- Clear old skin
	------------------------------------------------

	self:Clear(
		bananaVisual
	)

	------------------------------------------------
	-- Clone skin
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
	-- Prepare
	------------------------------------------------

	PrepareModel(
		visual
	)

	------------------------------------------------
	-- Find skin main
	------------------------------------------------

	local skinMain =
		GetMain(
			visual
		)

	if not skinMain then

		warn(
			"[BananaSkinManager] Skin has no Main:",
			skinId
		)

		visual:Destroy()

		return false
	end

	------------------------------------------------
	-- Position
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
	-- Weld
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
	-- Hide base Banana
	------------------------------------------------

	if bananaMain ~= skinMain then

		bananaMain.Transparency =
			1

	end

	print(
		"[BananaSkinManager] Applied:",
		skinId
	)

	return true

end

return BananaSkinManager