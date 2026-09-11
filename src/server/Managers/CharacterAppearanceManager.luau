local CharacterAppearanceManager = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

------------------------------------------------
-- SHARED
------------------------------------------------
local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local MarkerUtil =
	require(
		Shared.Utils.MarkerUtil
	)

local Enums = require(Shared.Enums)

local ProfileManager = require(script.Parent.ProfileManager)
------------------------------------------------
-- CONFIG
------------------------------------------------

local NAME_TAG_SETTINGS = {

		------------------------------------------------
	-- Billboard
	------------------------------------------------

	Name = "PlayerNameTag",

	Size = UDim2.fromOffset(
		220,
		55
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

	RichText = true,

	TextColor = Color3.fromRGB(
		255,
		255,
		255
	),

	TextSize = 18,

}



------------------------------------------------
-- BODY SCALE
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
-- CHECK IF PLAYER IS IN A ROUND
------------------------------------------------

local function IsInGame(
	player
)
	return player:GetAttribute("InMatch") == true
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
	-- Don't create tag during a round
	------------------------------------------------
	if IsInGame(player) then
		return nil
	end


	------------------------------------------------
	-- Create settings
	------------------------------------------------

	local settings =
		table.clone(
			NAME_TAG_SETTINGS
		)

	------------------------------------------------
	-- Name + Level + Wins
	------------------------------------------------

	settings.Text =
	"<font color=\"#FFFFFF\">"
	.. player.DisplayName
	.. "</font>"
	.. "\n"
	.. "<font color=\"#55BFFF\">Lv. "
	.. tostring(
		ProfileManager:GetLevel(player)
	)
	.. "</font>"
	.. "  |  "
	.. "<font color=\"#FFD84D\">👑 "
	.. tostring(
		ProfileManager:GetWins(player)
	)
	.. "</font>"

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
-- UPDATE NAME TAG
------------------------------------------------

local function UpdateNameTag(
	self,
	player
)

	local character =
		player.Character
	if not character then
		return
	end
	local shouldShow =
		not IsInGame(player)

		
	local existing =
		character:FindFirstChild(
			"PlayerNameTag"
		)
	------------------------------------------------
	-- Remove existing tag
	------------------------------------------------
	if shouldShow and existing then
		return
	end

	if not shouldShow and not existing then
		return
	end

	if existing then
		existing:Destroy()
	end

	------------------------------------------------
	-- Create only when in lobby
	------------------------------------------------

	local nameTag =
		CreateNameTag(
			character,
			player
		)

	self.NameTags[player] =
		nameTag

end

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

	if humanoid.RigType
		~= Enum.HumanoidRigType.R15
	then

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
	-- Create name tag if in lobby
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
-- REFRESH NAME TAG
------------------------------------------------

function CharacterAppearanceManager:RefreshNameTag(
	player
)

	if not player then
		return
	end
	UpdateNameTag(
		self,
		player
	)

end
------------------------------------------------
-- INIT
------------------------------------------------

function CharacterAppearanceManager:Init()

	self.NameTags = {}

	------------------------------------------------
	-- CURRENCY / PROFILE DATA
	------------------------------------------------

	

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

		------------------------------------------------
		-- Character added
		------------------------------------------------

		player.CharacterAdded:Connect(
			function(character)

				self:Setup(
					player,
					character
				)

			end
		)
		------------------------------------------------
		-- LOBBY STATE CHANGED
		------------------------------------------------

		player:GetAttributeChangedSignal(
			"InMatch"
		):Connect(
			function()

				UpdateNameTag(
					self,
					player
				)

			end
		)

	end



	------------------------------------------------
	-- New players
	------------------------------------------------

	Players.PlayerAdded:Connect(
		function(player)

			------------------------------------------------
			-- Character
			------------------------------------------------

			player.CharacterAdded:Connect(
				function(character)

					self:Setup(
						player,
						character
					)

				end
			)

			------------------------------------------------
			-- LOBBY STATE CHANGED
			------------------------------------------------

			player:GetAttributeChangedSignal(
				"InMatch"
			):Connect(
				function()

					UpdateNameTag(
						self,
						player
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

			self.NameTags[player] = nil
		end
	)



end

return CharacterAppearanceManager