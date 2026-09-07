local SoundConfig = {

	------------------------------------------------
	-- SFX
	------------------------------------------------

	AchievementNotification = {
		Category = "SFX",
		Volume = 1,
	},

	BubblePop = {
		Category = "SFX",
		Volume = 1,
	},

	Chime = {
		Category = "SFX",
		Volume = 1,
	},

	Chimes = {
		Category = "SFX",
		Volume = 1,
	},

	Coin = {
		Category = "SFX",
		Volume = 1,
	},

	CoinClinking = {
		Category = "SFX",
		Volume = 1,
	},

	Freeze = {
		Category = "SFX",
		Volume = 1,
	},

	GameTresure = {
		Category = "SFX",
		Volume = 1,
	},

	Gameover = {
		Category = "SFX",
		Volume = 1,
	},

	GoldCoin = {
		Category = "SFX",
		Volume = 1,
	},

	HeartBeats = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},

	IceCracking = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},

    IceFreezing = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},

    IceShatter = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
     ImpactSlip = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
   
     LightSpell = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
     MessageNotification = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
     Pop = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
     Slide = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
    Success = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
     TimerCountdown = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
    VictorySound = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
     WindGust1 = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
     WindGust2 = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
     Woosh = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
	 ImpactStrong = {
		Category = "SFX",
		Volume = 1,
		Looped = true,
	},
	------------------------------------------------
	-- MUSIC
	------------------------------------------------

	-- Add music here when the actual music
	-- Sound instances are added to ReplicatedStorage.Sounds.

	-- LobbyMusic = {
	-- 	Category = "Music",
	-- 	Volume = 0.5,
	-- 	Looped = true,
	-- },
    IntenseRunSoundMusicBG = {
		Category = "Music",
		Volume = 1,
		Looped = true,
	},

    LobbyMusic = {
		Category = "Music",
		Volume = 0.2,
		Looped = true,
	},

    GameMusic = {
		Category = "Music",
		Volume = 0.8,
		Looped = true,
	},
}

------------------------------------------------
-- DEFAULTS
------------------------------------------------

SoundConfig.Default = {
	Category = "SFX",
	Volume = 1,
	Looped = false,
}

return SoundConfig