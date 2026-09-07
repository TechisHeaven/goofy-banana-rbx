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

	end

	------------------------------------------------
	-- Reset state
	------------------------------------------------

	self.CurrentTarget = nil
	self.CurrentCharacter = nil
	self.Highlight = nil

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