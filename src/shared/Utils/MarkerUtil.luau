local MarkerUtil = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

local Debris =
	game:GetService("Debris")

------------------------------------------------
-- CONFIG
------------------------------------------------

local DEFAULT_NAME = "PlayerMarker"

------------------------------------------------
-- CREATE MARKER
------------------------------------------------

function MarkerUtil.Create(
	character,
	config
)

	if not character then
		return nil
	end

	local head =
		character:FindFirstChild("Head")

	if not head then
		return nil
	end

	config = config or {}

	------------------------------------------------
	-- Remove existing marker with same name
	------------------------------------------------

	local markerName =
		config.Name
		or DEFAULT_NAME

	local existing =
		head:FindFirstChild(markerName)

	if existing then
		existing:Destroy()
	end

	------------------------------------------------
	-- Billboard
	------------------------------------------------

	local billboard =
		Instance.new("BillboardGui")

	billboard.Name =
		markerName

	billboard.Adornee =
		head

	billboard.AlwaysOnTop =
		config.AlwaysOnTop ~= false

	billboard.Size =
		config.Size
		or UDim2.fromOffset(120, 45)

	billboard.StudsOffset =
		config.StudsOffset
		or Vector3.new(0, 3, 0)

	billboard.MaxDistance =
		config.MaxDistance
		or 200

	billboard.ResetOnSpawn =
		false

	billboard.Parent =
		head

	------------------------------------------------
	-- Container
	------------------------------------------------

	local label =
		Instance.new("TextLabel")

	label.Name =
		"Text"

	label.BackgroundTransparency =
		1

	label.Size =
		UDim2.fromScale(1, 1)

	label.Font =
		config.Font
		or Enum.Font.GothamBold

	label.Text =
		config.Text
		or "MARKER"

	label.TextColor3 =
		config.TextColor
		or Color3.fromRGB(
			255,
			255,
			255
		)

	label.TextSize =
		config.TextSize
		or 20

	label.TextScaled =
		config.TextScaled
		or false

	label.TextStrokeTransparency =
		config.TextStrokeTransparency
		or 0

	label.TextStrokeColor3 =
		config.TextStrokeColor
		or Color3.fromRGB(
			0,
			0,
			0
		)

	label.Parent =
		billboard

	------------------------------------------------
	-- Optional background
	------------------------------------------------

	if config.BackgroundColor then

		label.BackgroundTransparency =
			config.BackgroundTransparency
			or 0

		label.BackgroundColor3 =
			config.BackgroundColor

	end

	------------------------------------------------
	-- Optional corner
	------------------------------------------------

	if config.CornerRadius then

		local corner =
			Instance.new("UICorner")

		corner.CornerRadius =
			config.CornerRadius

		corner.Parent =
			label

	end

	------------------------------------------------
	-- Optional automatic removal
	------------------------------------------------

	if config.Duration then

		Debris:AddItem(
			billboard,
			config.Duration
		)

	end

	return billboard

end

------------------------------------------------
-- REMOVE ONE MARKER
------------------------------------------------

function MarkerUtil.Remove(
	character,
	markerName
)

	if not character then
		return
	end

	local head =
		character:FindFirstChild("Head")

	if not head then
		return
	end

	local marker =
		head:FindFirstChild(
			markerName
			or DEFAULT_NAME
		)

	if marker then
		marker:Destroy()
	end

end

------------------------------------------------
-- REMOVE ALL MARKERS
------------------------------------------------

function MarkerUtil.Clear(
	character
)

	if not character then
		return
	end

	local head =
		character:FindFirstChild("Head")

	if not head then
		return
	end

	for _, child in ipairs(
		head:GetChildren()
	) do

		if child:IsA("BillboardGui") then
			child:Destroy()
		end

	end

end

return MarkerUtil