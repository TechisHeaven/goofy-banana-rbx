-- -- RemoteIndex.luau
-- -- Central registry of all RemoteEvent / RemoteFunction names shared between
-- -- server and client. Any change to a name is made here once.

-- local RemoteIndex = {}

-- -- client → server
-- RemoteIndex.RequestJoinQueue  = "RequestJoinQueue"   -- player pressed Play
-- RemoteIndex.RequestLeaveQueue = "RequestLeaveQueue"  -- player cancelled queue

-- -- server → client(s)
-- RemoteIndex.UpdateLobbyStatus = "UpdateLobbyStatus"  -- match-status board data
-- RemoteIndex.RoundStarting     = "RoundStarting"      -- intermission countdown began
-- RemoteIndex.TeleportToArena   = "TeleportToArena"    -- round started, go to arena
-- RemoteIndex.ReturnToLobby     = "ReturnToLobby"      -- round over, back to lobby
-- RemoteIndex.ShowWinnerScreen  = "ShowWinnerScreen"   -- winner + rewards info
-- RemoteIndex.NotifyPlayer      = "NotifyPlayer"       -- toast-style in-game notification
-- RemoteIndex.OnJoinRequest = "OnJoinRequest"       -- server → host: player requested to join
-- RemoteIndex.RoundStarted = "RoundStarted"        -- server -> client: round has started
-- RemoteIndex.RoundEnded = "RoundEnded"          -- server -> client: round has ended
-- RemoteIndex.PlayerFrozen = "PlayerFrozen"
-- RemoteIndex.RequestDailyReward = "RequestDailyReward"
-- RemoteIndex.UpdateDailyReward = "UpdateDailyReward"
-- RemoteIndex.GetDailyReward = "GetDailyReward"
-- RemoteIndex.RequestEquip = "RequestEquip"
-- RemoteIndex.UpdateInventory = "UpdateInventory"
-- RemoteIndex.RequestUnequip = "RequestUnequip"
-- RemoteIndex.PlayVictory = "PlayVictory"

-- -- Remote Functions
-- RemoteIndex.GetShopItems = "GetShopItems" -- Server -> Client: Get the shop items for a specific category
-- RemoteIndex.RequestPurchase = "RequestPurchase" -- Client -> Server: Request to purchase an item from the shop

-- return RemoteIndex



local RemoteIndex = {}

RemoteIndex.Events = {

	RequestJoinQueue = "RequestJoinQueue",
	RequestLeaveQueue = "RequestLeaveQueue",

	UpdateLobbyStatus = "UpdateLobbyStatus",
	RoundStarting = "RoundStarting",
	TeleportToArena = "TeleportToArena",
	ReturnToLobby = "ReturnToLobby",
	ShowWinnerScreen = "ShowWinnerScreen",
	NotifyPlayer = "NotifyPlayer",

	OnJoinRequest = "OnJoinRequest",
	RoundStarted = "RoundStarted",
	RoundEnded = "RoundEnded",

	PlayerFrozen = "PlayerFrozen",

	RequestDailyReward = "RequestDailyReward",
	UpdateDailyReward = "UpdateDailyReward",

	RequestEquip = "RequestEquip",
	RequestUnequip = "RequestUnequip",
	UpdateInventory = "UpdateInventory",

	-- Animations Emote
	PlayVictory = "PlayVictory",
	HunterEntry = "HunterEntry",
	---------
	GetDailyReward = "GetDailyReward",

 	UpdateCurrency = "UpdateCurrency",
	
	PromptProductPurchase = "PromptProductPurchase",

	FreezeCooldown = "FreezeCooldown",

	StartSlowMo = "StartSlowMo",

	UpdateTasks = "UpdateTasks",

	LevelUp = "LevelUp",
	RewardReceived="RewardReceived",

	GameplayItemState = "GameplayItemState",

	GameplayItemRequest = "GameplayItemRequest",

	BananaPeelRequest = "BananaPeelRequest",
	RoundStatsUpdate = "RoundStatsUpdate",

	MarkedPlayerChanged = "MarkedPlayerChanged",

	InfectedPlayerChanged = "InfectedPlayerChanged",

	RoundInfo = "RoundInfo",

	HelpSignal = "HelpSignal",
	RescueCinematic = "RescueCinematic",
	RescueRemote = "RescueRemote",
}

RemoteIndex.Functions = {


	GetShopItems = "GetShopItems",
	GetInventoryItems = "GetInventoryItems",

	RequestPurchase = "RequestPurchase",

	ClaimTask = "ClaimTask",

	GetTasks = "GetTasks",
}

return RemoteIndex