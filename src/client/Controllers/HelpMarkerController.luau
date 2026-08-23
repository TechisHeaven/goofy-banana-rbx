local HelpMarkerController = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- SHARED
------------------------------------------------

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local MarkerUtil =
	require(
		Shared.Utils.MarkerUtil
	)
local HighlightVisual = require(Shared.Modules.HighlightVisual)
local GameConfig = require(Shared.GameConfig)


local ActiveMarkers = {}
------------------------------------------------
-- CONFIG
------------------------------------------------

local MARKER_NAME =
	"HelpMarker"

local MARKER_DURATION =
	GameConfig.Round.HelpSignalDuration or 5

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

	Duration = MARKER_DURATION
}

local MARKER_SETTINGS ={
			Name = MARKER_NAME,
			Text = "HELP",
			TextColor =
				Color3.fromRGB(
					255,
					80,
					80
				),
			TextSize = 22,
			Size =
				UDim2.fromOffset(
					120,
					45
				),
			StudsOffset =
				Vector3.new(
					0,
					3,
					0
				),
			AlwaysOnTop = true,
			MaxDistance = GameConfig.Round.HelpSignalMaxDistance or 500,
			Duration =
				MARKER_DURATION,
		}
------------------------------------------------
-- SHOW HELP MARKER
------------------------------------------------

function HelpMarkerController:Show(
	player,
	duration
)

	if not player then
		return
	end
	self:Hide(player)

	local character =
		player.Character

	if not character then
		return
	end
	if duration then
		HIGHLIGHT_SETTINGS.Duration = duration
		MARKER_SETTINGS.Duration = duration
	end
	local highlight = HighlightVisual.Create(
			character,
			HIGHLIGHT_SETTINGS
		)
	local marker = MarkerUtil.Create(
		character,
		MARKER_SETTINGS
	)

	local data = {

		Player = player,

		Character = character,

		Highlight = highlight,

		Marker = marker,

		Task = nil,
	}

	ActiveMarkers[player] =
		data

	------------------------------------------------
	-- Automatic expiration
	------------------------------------------------

	if duration and duration > 0 then

		data.Task =
			task.delay(
				duration,
				function()

					-- Make sure this is still
					-- the active marker.

					if ActiveMarkers[player]
						~= data then

						return

					end

					-- This task is already executing,
					-- so don't try to cancel it.

					data.Task = nil

					self:Hide(player)

				end
			)

	end

end

------------------------------------------------
-- REMOVE
------------------------------------------------

function HelpMarkerController:Hide(
	player
)

	if not player then
		return
	end
	local data =
		ActiveMarkers[player]

	if not data then
		return
	end

	------------------------------------------------
	-- Cancel expiration task
	------------------------------------------------

	if data.Task then

		local taskThread = data.Task

		data.Task = nil

		-- Only cancel if the thread is still valid.
		pcall(function()
			task.cancel(taskThread)
		end)
	end


	local character =
		player.Character

	if data.Character then

		HighlightVisual.Remove(
			data.Character
		)

	end
	MarkerUtil.Remove(
		character,
		MARKER_NAME
	)
	ActiveMarkers[player] = nil
end


function HelpMarkerController:Clear()

	for player in pairs(
		ActiveMarkers
	) do

		self:Hide(
			player
		)

	end

	table.clear(
		ActiveMarkers
	)

end

return HelpMarkerController