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
-- Find shop item
------------------------------------------------

function RewardDisplay:GetItem(category, itemId)

	local categoryData =
		ShopConfig.Categories[category]

	if not categoryData then
		return nil
	end

	for _, item in ipairs(categoryData.Items or {}) do

		if item.Id == itemId then
			return item
		end

	end

	return nil

end

------------------------------------------------
-- Get item display data
------------------------------------------------

function RewardDisplay:GetItemDisplay(category, itemId)

	local item =
		self:GetItem(category, itemId)

	if not item then
		return {
			Id = itemId,
			Category = category,
			Name = tostring(itemId),
			Image = "",
			Rarity = "Common",
		}
	end

	return {
		Id = item.Id,
		Category = category,

		Name =
			item.DisplayName
			or item.Name
			or item.Id,

		Image =
			item.Image
			or "",

		Rarity =
			item.Rarity
			or "Common",

	}
end

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
			Rarity = "Common",
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
			Rarity = "Common",
		}

	end

	------------------------------------------------
	-- Skin
	------------------------------------------------

	local itemTypes = {
		"Skin",
		"BananaSkin",
		"VictoryPose",
		"RescueEffect",
		"Head",
	}

	for _, category in ipairs(itemTypes) do

		local itemId =
			reward[category]

		if itemId then

			local display =
				self:GetItemDisplay(
					category .. "s",
					itemId
				)

			return {
				Type = category,

				Id = itemId,

				Name = display.Name,

				Image = display.Image,

				Rarity = display.Rarity,
			}

		end

	end

	return nil

end


return RewardDisplay