-- return {

--     Rewards = {

--         [1] = { Coins = 50 },
--         [2] = { Coins = 75 },
--         [3] = { Coins = 100 },
--         [4] = { Coins = 100 },
--         [5] = { Coins = 100 },
--         [6] = { Coins = 200 },
--         [7] = { Coins = 300 },
--         [8] = { Coins = 400 },
--         [9] = { Coins = 500 },
--         [10] = {
--             Coins = 1000,
--             Skin = "GalaxyBanana",
--             Head = "GalaxyHead"
--         }

--     },

--     MaxDays = 10,
--     ClaimCooldown = 24 * 60 * 60

-- }

local DailyRewardConfig = {}

-- Seconds between claims
DailyRewardConfig.ClaimCooldown = 24 * 60 * 60

-- Maximum reward day
DailyRewardConfig.MaxDay = 30

-- How many reward cards are visible
DailyRewardConfig.VisibleRewards = 5

----------------------------------------------------
-- Rewards
----------------------------------------------------

DailyRewardConfig.Rewards = {

    [1]  = { Coins = 50 },
    [2]  = { Coins = 75 },
    [3]  = { Coins = 100 },
    [4]  = { Coins = 125 },
    [5]  = { Coins = 150 },

    [6]  = { Coins = 175 },
    [7]  = { Coins = 200 },
    [8]  = { Coins = 250 },
    [9]  = { Coins = 300 },
    [10] = { Coins = 350 },

    [11] = { Coins = 400 },
    [12] = { Coins = 450 },
    [13] = { Coins = 500 },
    [14] = { Coins = 550 },
    [15] = { Coins = 600 },

    [16] = { Coins = 650 },
    [17] = { Coins = 700 },
    [18] = { Coins = 750 },
    [19] = { Coins = 800 },
    [20] = { Coins = 900 },

    [21] = { Coins = 1000 },
    [22] = { Coins = 1100 },
    [23] = { Coins = 1200 },
    [24] = { Coins = 1300 },
    [25] = { Coins = 1500 },

    [26] = { Coins = 1700 },
    [27] = { Coins = 1900 },
    [28] = { Coins = 2100 },
    [29] = { Coins = 2500 },

    ------------------------------------------------
    -- BIG REWARD
    ------------------------------------------------

    [30] = {

        Coins = 5000,

        Skin = "GalaxyBanana",

        Head = "GalaxyHead",

    }

}

----------------------------------------------------

return DailyRewardConfig