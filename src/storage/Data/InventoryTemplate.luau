local InventoryTemplate = {}

function InventoryTemplate.Create()

	return {

		Owned = {
			Skins = {
				HealerLordBanana = true,
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
			Skins = "HealerLordBanana",
			BananaSkins = "GalaxyBanana",
			RescueEffects = "",
			VictoryPoses = "Dance01",
		}

	}

end

return InventoryTemplate