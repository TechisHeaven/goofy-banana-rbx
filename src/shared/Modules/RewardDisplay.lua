local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local ShopConfig =
	require(Shared.Config.ShopConfig)

local RewardDisplay = {}

------------------------------------------------
-- Fixed reward images
------------------------------------------------

local REWARD_IMAGES = {

	Coins = "rbxassetid://106584451826934",

	XP = "rbxassetid://103529518875395",

}

------------------------------------------------
-- Find item image
------------------------------------------------

function RewardDisplay:GetItemImage(
	category,
	itemId
)

	if not category or not itemId then
		return ""
	end

	local categoryData =
		ShopConfig.Categories[category]

	if not categoryData then
		return ""
	end

	for _, item in ipairs(
		categoryData.Items or {}
	) do

		if item.Id == itemId then

			return item.Image or ""

		end

	end

	return ""

end

------------------------------------------------
-- Get reward display
------------------------------------------------

function RewardDisplay:GetRewardDisplay(reward)

	if not reward then
		return nil
	end

	------------------------------------------------
	-- Coins
	------------------------------------------------

	if reward.Coins then

		return {
			Type = "Coins",
			Name = reward.Name,
			Value = reward.Coins,
			Image = REWARD_IMAGES.Coins,
		}

	end

	------------------------------------------------
	-- XP
	------------------------------------------------

	if reward.XP then

		return {
			Type = "XP",
			Value = reward.XP,
			Name = reward.Name,
			Image = REWARD_IMAGES.XP,
		}

	end

	------------------------------------------------
	-- Skin
	------------------------------------------------

	if reward.Skin then

		return {
			Type = "Skin",
			Name = reward.Name,
			Id = reward.Skin,

			Image =
				self:GetItemImage(
					"Skins",
					reward.Skin
				),
		}

	end

	------------------------------------------------
	-- Banana Skin
	------------------------------------------------

	if reward.BananaSkin then

		return {
			Type = "BananaSkin",
			Name = reward.Name,
			Id = reward.BananaSkin,

			Image =
				self:GetItemImage(
					"BananaSkins",
					reward.BananaSkin
				),
		}

	end

	------------------------------------------------
	-- Victory Pose
	------------------------------------------------

	if reward.VictoryPose then

		return {
			Type = "VictoryPose",
			Name = reward.Name,
			Id = reward.VictoryPose,

			Image =
				self:GetItemImage(
					"VictoryPoses",
					reward.VictoryPose
				),
		}

	end

	------------------------------------------------
	-- Rescue Effect
	------------------------------------------------

	if reward.RescueEffect then

		return {
			Type = "RescueEffect",
			Name = reward.Name,
			Id = reward.RescueEffect,

			Image =
				self:GetItemImage(
					"RescueEffects",
					reward.RescueEffect
				),
		}

	end

	return nil

end


return RewardDisplay