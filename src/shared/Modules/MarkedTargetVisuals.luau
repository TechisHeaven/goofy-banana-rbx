local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local HighlightVisual =
	require(
		Shared
			:WaitForChild("Modules")
			:WaitForChild("HighlightVisual")
	)

local MarkerUtil =
	require(
		Shared
			:WaitForChild("Utils")
			:WaitForChild("MarkerUtil")
	)

local MarkedTargetVisuals = {}

------------------------------------------------
-- STATE
------------------------------------------------

MarkedTargetVisuals.CurrentTarget = nil
MarkedTargetVisuals.CurrentCharacter = nil
MarkedTargetVisuals.Highlight = nil
MarkedTargetVisuals.NameTag = nil

------------------------------------------------
-- CONFIGURATION
------------------------------------------------

local HIGHLIGHT_SETTINGS = {

	FillColor = Color3.fromRGB(
		255,
		50,
		50
	),

	OutlineColor = Color3.fromRGB(
		255,
		255,
		255
	),

	FillTransparency = 0.5,

	OutlineTransparency = 0,

	DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop,

}

------------------------------------------------
-- NAME TAG SETTINGS
------------------------------------------------

local NAME_TAG_SETTINGS = {

	Name = "MarkedTargetNameTag",

	Text = "MARKED",

	TextColor =
		Color3.fromRGB(
			255,
			200,
			50
		),

	TextSize = 20,

	Size =
		UDim2.fromOffset(
			140,
			45
		),

	StudsOffset =
		Vector3.new(
			0,
			3,
			0
		),

	AlwaysOnTop = true,

	MaxDistance = 999999,

}

------------------------------------------------
-- CLEAR
------------------------------------------------

function MarkedTargetVisuals:Clear()

	------------------------------------------------
	-- Remove highlight
	------------------------------------------------

	if self.CurrentCharacter then

		HighlightVisual.Remove(
			self.CurrentCharacter
		)

		------------------------------------------------
		-- Remove name tag
		------------------------------------------------

		MarkerUtil.Remove(
			self.CurrentCharacter,
			NAME_TAG_SETTINGS.Name
		)

	end

	------------------------------------------------
	-- Reset state
	------------------------------------------------

	self.CurrentTarget = nil
	self.CurrentCharacter = nil
	self.Highlight = nil
	self.NameTag = nil

end

------------------------------------------------
-- SHOW
------------------------------------------------

function MarkedTargetVisuals:Show(
	player
)

	if not player then
		return
	end

	------------------------------------------------
	-- Clear previous target
	------------------------------------------------

	self:Clear()

	self.CurrentTarget =
		player

	------------------------------------------------
	-- Character
	------------------------------------------------

	local character =
		player.Character

	if not character then

		warn(
			"[MarkedTargetVisuals] Character not found:",
			player.Name
		)

		return

	end

	self.CurrentCharacter =
		character

	------------------------------------------------
	-- Highlight
	------------------------------------------------

	self.Highlight =
		HighlightVisual.Create(
			character,
			HIGHLIGHT_SETTINGS
		)

	------------------------------------------------
	-- Name tag
	------------------------------------------------

	self.NameTag =
		MarkerUtil.Create(
			character,
			NAME_TAG_SETTINGS
		)

	------------------------------------------------
	-- Debug
	------------------------------------------------

	print(
		"[MarkedTargetVisuals] Showing target:",
		player.Name
	)

end

------------------------------------------------
-- HIDE
------------------------------------------------

function MarkedTargetVisuals:Hide()

	self:Clear()

	print(
		"[MarkedTargetVisuals] Hidden"
	)

end

return MarkedTargetVisuals