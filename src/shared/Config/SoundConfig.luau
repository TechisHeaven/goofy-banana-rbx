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

	GameTreasure = {
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
		Looped = false,
	},

    IceFreezing = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},

    IceShatter = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
     ImpactSlip = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
   
     LightSpell = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
     MessageNotification = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
     Pop = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
     Slide = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
    Success = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
     TimerCountdown = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
    VictorySound = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
     WindGust1 = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
     WindGust2 = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
     Woosh = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},
	 ImpactStrong = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},

	LandSound = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
	},

	PunchSound = {
		Category = "SFX",
		Volume = 1,
		Looped = false,
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
		Volume = 0.2,
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