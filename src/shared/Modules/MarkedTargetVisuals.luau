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

local MarkedTargetVisuals = {}

------------------------------------------------
-- State
------------------------------------------------

MarkedTargetVisuals.CurrentTarget = nil
MarkedTargetVisuals.CurrentCharacter = nil
MarkedTargetVisuals.Highlight = nil
MarkedTargetVisuals.NameTag = nil

------------------------------------------------
-- Configuration
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
-- Remove Name Tag
------------------------------------------------

local function removeNameTag(character)

	if not character then
		return
	end

	local tag =
		character:FindFirstChild(
			"MarkedTargetNameTag"
		)

	if tag then
		tag:Destroy()
	end

end

------------------------------------------------
-- Create Name Tag
------------------------------------------------

local function createNameTag(
	character,
	player
)

	local head =
		character:FindFirstChild("Head")

	if not head then
		return nil
	end

	removeNameTag(character)

	------------------------------------------------
	-- Billboard
	------------------------------------------------

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		"MarkedTargetNameTag"

	billboard.Adornee =
		head

	billboard.Size =
		UDim2.fromScale(5, 1)

	billboard.StudsOffset =
		Vector3.new(0, 3, 0)

	billboard.AlwaysOnTop = true

	billboard.Parent =
		character

	------------------------------------------------
	-- Text
	------------------------------------------------

	local label =
		Instance.new("TextLabel")

	label.Name =
		"Name"

	label.Size =
		UDim2.fromScale(1, 1)

	label.BackgroundTransparency = 1

	label.Text =
		player.DisplayName

	label.TextColor3 =
		Color3.fromRGB(
			255,
			70,
			70
		)

	label.TextStrokeColor3 =
		Color3.fromRGB(
			0,
			0,
			0
		)

	label.TextStrokeTransparency = 0.25

	label.Font =
		Enum.Font.GothamBold

	label.TextScaled = true
	label.TextSize = 18

	label.Parent =
		billboard

	return billboard

end

------------------------------------------------
-- Clear
------------------------------------------------

function MarkedTargetVisuals:Clear()

	------------------------------------------------
	-- Remove highlight
	------------------------------------------------

	if self.CurrentCharacter then

		HighlightVisual.Remove(
			self.CurrentCharacter
		)

		removeNameTag(
			self.CurrentCharacter
		)

	end

	------------------------------------------------
	-- Reset
	------------------------------------------------

	self.CurrentTarget = nil
	self.CurrentCharacter = nil
	self.Highlight = nil
	self.NameTag = nil

end

------------------------------------------------
-- Show
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
		createNameTag(
			character,
			player
		)

	print(
		"[MarkedTargetVisuals] Showing target:",
		player.Name
	)

end

------------------------------------------------
-- Hide
------------------------------------------------

function MarkedTargetVisuals:Hide()

	self:Clear()

	print(
		"[MarkedTargetVisuals] Hidden"
	)

end

return MarkedTargetVisuals