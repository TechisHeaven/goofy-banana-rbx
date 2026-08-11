local ServerStorage = game:GetService("ServerStorage")
local Players 	 = game:GetService("Players")
local ProfileManager = {}

local PlayerProfiles =
	require(ServerStorage.Data.PlayerProfiles)

local InventoryTemplate =
	require(ServerStorage.Data.InventoryTemplate)



function ProfileManager:RegisterPlayer(player)
	print("Registering player profile for",player.Name)
	PlayerProfiles[player] = {
		Coins = 10000,
		XP = 110,
		Level = 1,
		Inventory = InventoryTemplate.Create(),
		Tasks = {
			Daily = {
				Version = "",
				Tasks = {},
			},

			Weekly = {
				Version = "",
				Tasks = {},
			},

			Overall = {},
		},
	}

end

function ProfileManager:GetProfile(player)
	return PlayerProfiles[player]
end


function ProfileManager:RemovePlayer(player)
	PlayerProfiles[player] = nil
end


function ProfileManager:Init()

	print("ProfileManager Initializing...")
	-- Register players who are already connected
	for _, player in pairs(Players:GetPlayers()) do
		if not PlayerProfiles[player] then
			self:RegisterPlayer(player)
		end
	end

	Players.PlayerAdded:Connect(function(player)
		self:RegisterPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:RemovePlayer(player)
	end)

end


return ProfileManager