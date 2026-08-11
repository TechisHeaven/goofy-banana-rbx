return {

    Round = {
        MinimumPlayers = 2,
        IntermissionTime = 10,
        RoundTime = 60,
        EndTime = 10,
        AllowLateJoin = true,
        LateJoinCutoff = 30,
        DefaultVictoryWinDuration = 5,
    },

    Rescue = {
        HoldTime = 3,
    },

    Hunter = {
        Count = 1,
        CooldownTime = 2,
	    FreezeCooldown = 5,
    },

    Lobby = {
        PostRoundReturnDelay = 3,   -- seconds after round ends before returning to lobby
        AutoRequeueDelay     = 2,   -- seconds after returning before auto-re-queuing
        StatusUpdateRate     = 1,   -- how often match status is broadcast (seconds)
    },

    Game = {
        ResultScreenDuration = 10,      -- how long to show the result screen (seconds)
        NotificationDuration = 10,      -- how long to show notifications (seconds)
        FreezeDuration = 5,              -- how long a player is frozen (seconds)
        MaxCoinActive = 3,
        CoinAmount = 50,
        CoinRespawnTime = 3,
        DefaultSlowMoDuration = 3,
        DefaultSlowMoFOV = 70,
        DefaultSlowMoSpeed = 0.35
    }

}
