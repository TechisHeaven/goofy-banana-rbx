local ServerStorage = game:GetService("ServerStorage")
local Players 	 = game:GetService("Players")
local ProfileManager = {}

local PlayerProfiles =
	require(ServerStorage.Data.PlayerProfiles)


function ProfileManager:GetProfile(player)
	return PlayerProfiles[player]
end


function ProfileManager:RemovePlayer(player)
	PlayerProfiles:RemovePlayer(player)
end

function ProfileManager:Init()

	print("ProfileManager Initializing...")
	-- Register players who are already connected
	for _, player in pairs(Players:GetPlayers()) do
		if not PlayerProfiles[player] then
			PlayerProfiles:RegisterPlayer(player)
		end
	end

	Players.PlayerAdded:Connect(function(player)
		PlayerProfiles:RegisterPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		PlayerProfiles:RemovePlayer(player)
	end)

end


return ProfileManager