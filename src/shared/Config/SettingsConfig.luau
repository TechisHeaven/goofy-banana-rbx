local SettingsConfig = {
	Defaults = {
		MusicEnabled = true,
		MusicVolume = 1,
		FOV = 80,
		RunningFOV = 100,
	},

	Limits = {
		MusicVolume = {
			Min = 0,
			Max = 1,
		},

		FOV = {
			Min = 60,
			Max = 110,
		},
		
		RunningFOV = {
			Min = 70,
			Max = 130,
		},
	},
}

return SettingsConfig