local InventoryTemplate = {}

function InventoryTemplate.Create()

	return {

		Owned = {
			Skins = {
				-- SleepyBanana = true,
				CoolBanana = true,
			},

			BananaSkins = {
				RainbowPeel = true,
			},

			VictoryPoses = {
				Dance01 = true,
				Dance02 = true,
			},
			RescueEffects = {
				Snow = true,
			},
		},

		Equipped = {
			Skins = "CoolBanana",
			BananaSkins = "RainbowPeel",
			RescueEffects = "Snow",
			VictoryPoses = "Dance01",
		}

	}

end

return InventoryTemplate