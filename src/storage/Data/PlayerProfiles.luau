local PlayerProfiles = {}
local ServerStorage = game:GetService("ServerStorage")
local InventoryTemplate =
	require(ServerStorage.Data.InventoryTemplate)


function PlayerProfiles:RegisterPlayer(player)
	print("Registering player profile for",player.Name)
	PlayerProfiles[player] = {
		Coins = 10000,
		XP = 220,
		Wins = 0,
		Level = 1,
		Inventory = InventoryTemplate.Create(),
        Settings = {
			MusicVolume = 1,
			MusicEnabled = true,
			FOV = 80,
			RunningFOV = 100,
		},
		
		RedeemedCodes = {},
        
		Tasks = {
			Daily = {
				Version = "",
				Tasks = {
					
				},
			},

			Weekly = {
				Version = "",
				Tasks = {},
			},

			Overall = {},
		},
	}

end


function PlayerProfiles:RemovePlayer(player)
	PlayerProfiles[player] = nil
end


return PlayerProfiles