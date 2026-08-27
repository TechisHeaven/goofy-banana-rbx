local CharacterAppearanceManager = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------------------------
-- SHARED
------------------------------------------------

local Shared = ReplicatedStorage:WaitForChild("Shared")

local MarkerUtil =
	require(
		Shared.Utils.MarkerUtil
	)

------------------------------------------------
-- CONFIG
------------------------------------------------

local NAME_TAG_SETTINGS = {

	------------------------------------------------
	-- Billboard
	------------------------------------------------

	Name = "PlayerNameTag",

	Size = UDim2.fromOffset(
		180,
		40
	),

	StudsOffset = Vector3.new(
		0,
		3.2,
		0
	),

	AlwaysOnTop = true,

	MaxDistance = 50,

	------------------------------------------------
	-- Text
	------------------------------------------------

	Text = function(player)

		return player.DisplayName

	end,

}

------------------------------------------------
-- BODY SCALE
------------------------------------------------
-- These values are identical for everybody.
--
-- Height = normal
-- Width  = slightly thick
-- Depth  = slightly thick
-- Head   = normal
--
-- BodyType = 0 means classic/blockier R15.
-- Proportion = 0 keeps the body from becoming
-- too narrow/slender.
------------------------------------------------

local BODY_SCALE = {

	HeightScale = 1,

	WidthScale = 1.08,

	DepthScale = 1.08,

	HeadScale = 1,

	BodyTypeScale = 0,

	ProportionScale = 0,

}

------------------------------------------------
-- APPLY SCALE
------------------------------------------------

local function ApplyBodyScale(
	character
)

	local humanoid =
		character:FindFirstChildOfClass(
			"Humanoid"
		)

	if not humanoid then
		return false
	end

	------------------------------------------------
	-- Make sure this is R15
	------------------------------------------------

	if humanoid.RigType ~= Enum.HumanoidRigType.R15 then

		warn(
			"[CharacterAppearanceManager] Character is not R15:",
			character.Name
		)

		return false

	end

	------------------------------------------------
	-- Existing scale objects
	------------------------------------------------

	local heightScale =
		humanoid:FindFirstChild(
			"BodyHeightScale"
		)

	local widthScale =
		humanoid:FindFirstChild(
			"BodyWidthScale"
		)

	local depthScale =
		humanoid:FindFirstChild(
			"BodyDepthScale"
		)

	local headScale =
		humanoid:FindFirstChild(
			"HeadScale"
		)

	local bodyTypeScale =
		humanoid:FindFirstChild(
			"BodyTypeScale"
		)

	local proportionScale =
		humanoid:FindFirstChild(
			"BodyProportionScale"
		)

	------------------------------------------------
	-- Apply identical values
	------------------------------------------------

	if heightScale then
		heightScale.Value =
			BODY_SCALE.HeightScale
	end

	if widthScale then
		widthScale.Value =
			BODY_SCALE.WidthScale
	end

	if depthScale then
		depthScale.Value =
			BODY_SCALE.DepthScale
	end

	if headScale then
		headScale.Value =
			BODY_SCALE.HeadScale
	end

	if bodyTypeScale then
		bodyTypeScale.Value =
			BODY_SCALE.BodyTypeScale
	end

	if proportionScale then
		proportionScale.Value =
			BODY_SCALE.ProportionScale
	end

	return true

end

------------------------------------------------
-- CREATE NAME TAG
------------------------------------------------

local function CreateNameTag(
	character,
	player
)

	------------------------------------------------
	-- Remove old one
	------------------------------------------------

	local old =
		character:FindFirstChild(
			"PlayerNameTag"
		)

	if old then
		old:Destroy()
	end

	------------------------------------------------
	-- Create settings
	------------------------------------------------

	local settings =
		table.clone(
			NAME_TAG_SETTINGS
		)

	settings.Text =
		player.DisplayName

	------------------------------------------------
	-- Create
	------------------------------------------------

	local nameTag =
		MarkerUtil.Create(
			character,
			settings
		)

	return nameTag

end

------------------------------------------------
-- SETUP CHARACTER
------------------------------------------------

function CharacterAppearanceManager:Setup(
	player,
	character
)

	if not character then
		return
	end

	------------------------------------------------
	-- Wait for humanoid
	------------------------------------------------

	local humanoid =
		character:WaitForChild(
			"Humanoid",
			10
		)

	if not humanoid then
		return
	end

	------------------------------------------------
	-- Apply standard R15 proportions
	------------------------------------------------

	ApplyBodyScale(
		character
	)

	------------------------------------------------
	-- Create consistent name tag
	------------------------------------------------

	local nameTag =
		CreateNameTag(
			character,
			player
		)

	------------------------------------------------
	-- Keep reference
	------------------------------------------------

	self.NameTags =
		self.NameTags or {}

	self.NameTags[player] =
		nameTag

end

------------------------------------------------
-- INIT
------------------------------------------------

function CharacterAppearanceManager:Init()

	self.NameTags = {}

	------------------------------------------------
	-- Existing players
	------------------------------------------------

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if player.Character then

			task.spawn(
				function()

					self:Setup(
						player,
						player.Character
					)

				end
			)

		end

		player.CharacterAdded:Connect(
			function(character)

				self:Setup(
					player,
					character
				)

			end
		)

	end

	------------------------------------------------
	-- New players
	------------------------------------------------

	Players.PlayerAdded:Connect(
		function(player)

			player.CharacterAdded:Connect(
				function(character)

					self:Setup(
						player,
						character
					)

				end
			)

		end
	)

	------------------------------------------------
	-- Cleanup
	------------------------------------------------

	Players.PlayerRemoving:Connect(
		function(player)

			self.NameTags[player] =
				nil

		end
	)

	print(
		"[CharacterAppearanceManager] Initialized"
	)

end

return CharacterAppearanceManager