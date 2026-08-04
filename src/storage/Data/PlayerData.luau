local PlayerDataService = require(script.Parent.PlayerDataService)

local PlayerData = {}

function PlayerData:GetInventory(player)

	local profile = PlayerDataService:GetProfile(player)

	if not profile then
		return nil
	end

	return profile.Inventory
end

function PlayerData:GetEquippedPose(player)

	local inventory = self:GetInventory(player)

	if not inventory then
		return nil
	end

	return inventory.Equipped.VictoryPoses
end

return PlayerData