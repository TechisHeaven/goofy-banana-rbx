local TaskConfig = {}
local TaskEvents =
	require(script.Parent.Parent.Enums.TaskEvents)
------------------------------------------------
-- Settings
------------------------------------------------

TaskConfig.DailyCount = 3
TaskConfig.WeeklyCount = 3

------------------------------------------------
-- Difficulty
------------------------------------------------

TaskConfig.Difficulty = {

	Easy = {
		Weight = 50,
	},

	Medium = {
		Weight = 35,
	},

	Hard = {
		Weight = 15,
	},

}

------------------------------------------------
-- DAILY TASK POOL
------------------------------------------------

TaskConfig.Daily = {

	{
		Id = "DailyCollectCoins",
		Name = "Coin Hunter",
		Description = "Collect 100 coins during rounds.",
		Event = TaskEvents.CoinCollected,
		Target = 100,
		Difficulty = "Easy",

		Reward = {
			Coins = 250,
		},
	},

	{
		Id = "DailyCollectCoinsMedium",
		Name = "Coin Collector",
		Description = "Collect 300 coins during rounds.",
		Event = TaskEvents.CoinCollected,
		Target = 300,
		Difficulty = "Medium",

		Reward = {
			Coins = 600,
		},
	},

	{
		Id = "DailyCollectCoinsHard",
		Name = "Coin Master",
		Description = "Collect 750 coins during rounds.",
		Event = TaskEvents.CoinCollected,
		Target = 750,
		Difficulty = "Hard",

		Reward = {
			Coins = 1500,
		},
	},

	------------------------------------------------
	-- RESCUES
	------------------------------------------------

	{
		Id = "DailyRescue",
		Name = "Rescuer",
		Description = "Rescue 2 players.",
		Event = TaskEvents.PlayerRescued,
		Target = 2,
		Difficulty = "Easy",

		Reward = {
			Coins = 300,
		},
	},

	{
		Id = "DailyRescueHard",
		Name = "Heroic Rescue",
		Description = "Rescue 5 players.",
		Event = TaskEvents.PlayerRescued,
		Target = 5,
		Difficulty = "Hard",

		Reward = {
			Coins = 1200,
		},
	},

	------------------------------------------------
	-- SURVIVAL
	------------------------------------------------

	{
		Id = "DailySurvive",
		Name = "Survivor",
		Description = "Survive for 180 seconds.",
		Event = TaskEvents.SurvivalSecond,
		Target = 180,
		Difficulty = "Medium",

		Reward = {
			Coins = 500,
		},
	},

	------------------------------------------------
	-- FROZEN PLAYERS
	------------------------------------------------

	{
		Id = "DailyFreeze",
		Name = "Freezer",
		Description = "Freeze 5 players.",
		Event =TaskEvents.PlayerFrozen,
		Target = 5,
		Difficulty = "Medium",

		Reward = {
			Coins = 600,
		},
	},

	{
		Id = "DailyFreezeHard",
		Name = "Ice Cold",
		Description = "Freeze 10 players.",
		Event =TaskEvents.PlayerFrozen,
		Target = 10,
		Difficulty = "Hard",

		Reward = {
			Coins = 1500,
		},
	},

	------------------------------------------------
	-- WINS
	------------------------------------------------

	{
		Id = "DailyWin",
		Name = "Winner",
		Description = "Win 1 round.",
		Event = TaskEvents.RoundWon,
		Target = 1,
		Difficulty = "Medium",

		Reward = {
			Coins = 750,
		},
	},

}

------------------------------------------------
-- WEEKLY TASK POOL
------------------------------------------------

TaskConfig.Weekly = {

	{
		Id = "WeeklyCollectCoins",
		Name = "Big Collector",
		Description = "Collect 2000 coins.",
		Event = TaskEvents.CoinCollected,
		Target = 2000,
		Difficulty = "Medium",

		Reward = {
			Coins = 3000,
		},
	},

	{
		Id = "WeeklyRescue",
		Name = "Guardian",
		Description = "Rescue 15 players.",
		Event = TaskEvents.PlayerRescued,
		Target = 15,
		Difficulty = "Hard",

		Reward = {
			Coins = 4000,
		},
	},

	{
		Id = "WeeklyFreeze",
		Name = "Hunter's Path",
		Description = "Freeze 25 players.",
		Event =TaskEvents.PlayerFrozen,
		Target = 25,
		Difficulty = "Hard",

		Reward = {
			Coins = 5000,
		},
	},

	{
		Id = "WeeklySurvive",
		Name = "Endurance",
		Description = "Survive for 1200 seconds.",
		Event = TaskEvents.SurvivalSecond,
		Target = 1200,
		Difficulty = "Hard",

		Reward = {
			Coins = 5000,
		},
	},

	{
		Id = "WeeklyWins",
		Name = "Champion",
		Description = "Win 5 rounds.",
		Event = TaskEvents.RoundWon,
		Target = 5,
		Difficulty = "Hard",

		Reward = {
			Coins = 6000,
		},
	},

}

------------------------------------------------
-- OVERALL / PERMANENT MISSIONS
------------------------------------------------

TaskConfig.Overall = {

	{
		Id = "OverallCollectCoins",
		Name = "Coin Legend",
		Description = "Collect 50,000 coins.",
		Event = TaskEvents.CoinCollected,
		Target = 50000,

		Reward = {
			Coins = 10000,
		},
	},

	{
		Id = "OverallRescues",
		Name = "Master Rescuer",
		Description = "Rescue 100 players.",
		Event = TaskEvents.PlayerRescued,
		Target = 100,

		Reward = {
			Coins = 15000,
		},
	},

	{
		Id = "OverallFrozen",
		Name = "Ultimate Hunter",
		Description = "Freeze 250 players.",
		Event =TaskEvents.PlayerFrozen,
		Target = 250,

		Reward = {
			Coins = 20000,
		},
	},

	{
		Id = "OverallSurvival",
		Name = "Unstoppable",
		Description = "Survive for 10,000 seconds.",
		Event = TaskEvents.SurvivalSecond,
		Target = 10000,

		Reward = {
			Coins = 25000,
		},
	},

	{
		Id = "OverallWins",
		Name = "Champion of the Arena",
		Description = "Win 50 rounds.",
		Event = TaskEvents.RoundWon,
		Target = 50,

		Reward = {
			Coins = 50000,
		},
	},

}

return TaskConfig