local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events

local Remotes =
	Shared.Remotes

local InfectedPlayerChanged =
	Remotes:WaitForChild(
		RemoteIndex.InfectedPlayerChanged
	)

local InfectedController = {}

local Highlights = {}

------------------------------------------------
-- SHOW
------------------------------------------------

function InfectedController:Show(player)

	if not player then
		return
	end

	if Highlights[player] then
		return
	end

	local character =
		player.Character

	if not character then
		return
	end

	local highlight =
		Instance.new("Highlight")

	highlight.Name =
		"InfectedHighlight"

	highlight.Adornee =
		character

	highlight.FillColor =
		Color3.fromRGB(
			70,
			255,
			100
		)

	highlight.OutlineColor =
		Color3.fromRGB(
			40,
			255,
			80
		)

	highlight.FillTransparency = 0.8
	highlight.OutlineTransparency = 0

	highlight.DepthMode =
		Enum.HighlightDepthMode.Occluded

	highlight.Parent =
		character

	Highlights[player] =
		highlight

end

------------------------------------------------
-- CLEAR
------------------------------------------------

function InfectedController:Clear(player)

	------------------------------------------------
	-- Clear everything
	------------------------------------------------

	if not player then

		for target, highlight in pairs(Highlights) do

			if highlight then
				highlight:Destroy()
			end

			Highlights[target] = nil

		end

		return
	end

	------------------------------------------------
	-- Clear one player
	------------------------------------------------

	local highlight =
		Highlights[player]

	if highlight then

		highlight:Destroy()

		Highlights[player] = nil

	end

end


function  InfectedController:Init()
    ------------------------------------------------
    -- REMOTE
    ------------------------------------------------

    InfectedPlayerChanged.OnClientEvent:Connect(
        function(player, infected)

            if infected then

                InfectedController:Show(player)

            else

                InfectedController:Clear(player)

            end

        end
    )

    ------------------------------------------------
    -- PLAYER REMOVED
    ------------------------------------------------

    Players.PlayerRemoving:Connect(
        function(player)

            InfectedController:Clear(player)

        end
    ) 
end

return InfectedController