local PlayerDataService = {}

PlayerDataService.Profiles = {}

function PlayerDataService:SetProfile(player, profile)
	self.Profiles[player] = profile
end

function PlayerDataService:GetProfile(player)
	return self.Profiles[player]
end

function PlayerDataService:RemoveProfile(player)
	self.Profiles[player] = nil
end

return PlayerDataService