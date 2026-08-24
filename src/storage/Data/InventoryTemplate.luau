local InventoryTemplate = {}

function InventoryTemplate.Create()

	return {

		Owned = {
			Skins = {
				SleepyBanana = true,
				CoolBanana = true,
			},

			BananaSkins = {
				SleepyBanana = true,
				GalaxyBanana = true
			},

			VictoryPoses = {
				Dance01 = true,
				Dance02 = true,
			},
			RescueEffects = {
			},
		},

		Equipped = {
			Skins = "SleepyBanana",
			BananaSkins = "GalaxyBanana",
			RescueEffects = "",
			VictoryPoses = "Dance01",
		}

	}

end

return InventoryTemplate