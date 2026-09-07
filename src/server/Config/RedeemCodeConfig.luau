local RedeemCodeConfig = {

	------------------------------------------------
	-- EXAMPLE: SINGLE USE PER PLAYER
	------------------------------------------------

	BANANA = {
		-- Single player can redeem this code only once.
		UseType = "OncePerPlayer",
		-- Optional expiration.
		-- nil = never expires.
		ExpiresAt = nil,
		Rewards = {
			{
				Coins = 500,
			},
			{
				Skin = "JackLantern",
			},
		},
	},

	------------------------------------------------
	-- EXAMPLE: MULTIPLE USE
	------------------------------------------------

	UPDATE2026 = {
		-- Player can redeem this every time
		-- they enter the code.
		UseType = "Unlimited",
		ExpiresAt = nil,
		Rewards = {
			{
				Coins = 100,
			},
		},
	},
	------------------------------------------------
	-- EXAMPLE: MULTIPLE DIFFERENT ITEMS
	------------------------------------------------
	GOOFY = {
		UseType = "OncePerPlayer",
		ExpiresAt = nil,
		Rewards = {
			{
				Skin = "GalaxyBanana",
			},
		},
	},

}

return RedeemCodeConfig