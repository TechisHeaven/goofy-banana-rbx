local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local Remotes =
	Shared:WaitForChild("Remotes")

local RemoteIndex =
	require(
		Shared.Remotes.RemoteIndex
	)

local RewardReceived =
	Remotes:WaitForChild(
		RemoteIndex.Events.RewardReceived
	)

local RewardDisplay =
	require(
		Shared.Modules.RewardDisplay
	)

local RewardManager = {}

------------------------------------------------
-- Send one reward
------------------------------------------------

function RewardManager:SendReward(
	player,
	reward
)

	if not player or not reward then
		return
	end

	local display =
		RewardDisplay:GetRewardDisplay(
			reward
		)

	if not display then
		return
	end

	RewardReceived:FireClient(
		player,
		{
			display
		}
	)

end

function RewardManager:SendInventoryItem(
	player,
	category,
	itemId
)

	local categoryMap = {

		Skins = "Skin",
		Heads = "Head",
		BananaSkins = "BananaSkin",
		VictoryPoses = "VictoryPose",
		RescueEffects = "RescueEffect",

	}

	local rewardType =
		categoryMap[category]

	if not rewardType then

		warn(
			"[RewardManager] Unknown category:",
			category
		)

		return

	end

	self:SendReward(
		player,
		{
			[rewardType] = itemId
		}
	)

end

------------------------------------------------
-- Send multiple rewards
------------------------------------------------

function RewardManager:SendRewards(
	player,
	rewards
)

	if not player or not rewards then
		return
	end

	local displays = {}

	for _, reward in ipairs(rewards) do

		local display =
			RewardDisplay:GetRewardDisplay(
				reward
			)

		if display then

			table.insert(
				displays,
				display
			)

		end

	end

	if #displays == 0 then
		return
	end

	RewardReceived:FireClient(
		player,
		displays
	)

end

return RewardManager