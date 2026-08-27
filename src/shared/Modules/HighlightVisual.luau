local HighlightVisual = {}

------------------------------------------------
-- Configuration
------------------------------------------------

local DEFAULT_FILL_COLOR = Color3.fromRGB(255, 60, 60)
local DEFAULT_OUTLINE_COLOR = Color3.fromRGB(255, 255, 255)
local DEFAULT_NAME = "MarkedTargetHighlight"
------------------------------------------------
-- Create
------------------------------------------------

function HighlightVisual.Create(
	parent,
	options
)

	if not parent then
		return nil
	end

	options = options or {}

	------------------------------------------------
	-- Remove existing highlight created by us
	------------------------------------------------

	local existing =
		parent:FindFirstChild(DEFAULT_NAME)

	if existing then
		existing:Destroy()
	end

	------------------------------------------------
	-- Create Highlight
	------------------------------------------------

    


	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		options.Name or DEFAULT_NAME

	highlight.Adornee =
		options.Adornee or parent

	highlight.FillColor =
		options.FillColor
		or DEFAULT_FILL_COLOR

	highlight.OutlineColor =
		options.OutlineColor
		or DEFAULT_OUTLINE_COLOR

	highlight.FillTransparency =
		options.FillTransparency or 0.5

	highlight.OutlineTransparency =
		options.OutlineTransparency or 0

	------------------------------------------------
	-- Through walls
	------------------------------------------------

	highlight.DepthMode =
		options.DepthMode
		or Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Parent = parent
	------------------------------------------------
	-- AUTO REMOVE
	------------------------------------------------

	if typeof(options.Duration) == "number"
		and options.Duration > 0 then

		task.delay(
			options.Duration,
			function()

				if highlight
					and highlight.Parent then

					highlight:Destroy()

				end

			end
		)

	end

	return highlight

end

------------------------------------------------
-- Remove
------------------------------------------------

function HighlightVisual.Remove(parent)
	
	if not parent then
		return
	end

	local highlight =
		parent:FindFirstChild(DEFAULT_NAME)
	if highlight then
		highlight:Destroy()
	end

end

------------------------------------------------
-- Update
------------------------------------------------

function HighlightVisual.Update(
	highlight,
	options
)

	if not highlight or not options then
		return
	end

	if options.FillColor then
		highlight.FillColor =
			options.FillColor
	end

	if options.OutlineColor then
		highlight.OutlineColor =
			options.OutlineColor
	end

	if options.FillTransparency ~= nil then
		highlight.FillTransparency =
			options.FillTransparency
	end

	if options.OutlineTransparency ~= nil then
		highlight.OutlineTransparency =
			options.OutlineTransparency
	end

	if options.DepthMode then
		highlight.DepthMode =
			options.DepthMode
	end

end

return HighlightVisual