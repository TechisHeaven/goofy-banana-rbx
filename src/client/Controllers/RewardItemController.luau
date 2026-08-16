local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local RemoteIndex =
	require(
		Shared.Remotes.RemoteIndex
	)

local Remotes =
	Shared:WaitForChild("Remotes")

local RewardItemUI =
	require(
		script.Parent.Parent.UI.RewardItemUI
	)

local RewardItemController = {}

------------------------------------------------
-- Init
------------------------------------------------

function RewardItemController:Init()

	print(
		"RewardItemController Initialized"
	)

	RewardItemUI:Init()

	local RewardReceived =
		Remotes:WaitForChild(
			RemoteIndex.Events.RewardReceived
		)

	RewardReceived.OnClientEvent:Connect(
		function(rewards)

			if not rewards then
				return
			end

			RewardItemUI:ShowRewards(
				rewards
			)

		end
	)

end

return RewardItemController