return {

    Round = {
        MinimumPlayers = 2,
        IntermissionTime = 10,
        RoundTime = 30,
        EndTime = 10,
        AllowLateJoin = true,
        LateJoinCutoff = 30,
    },

    Rescue = {
        HoldTime = 5,
    },

    Hunter = {
        Count = 1,
        CooldownTime = 2,
    },

    Lobby = {
        PostRoundReturnDelay = 3,   -- seconds after round ends before returning to lobby
        AutoRequeueDelay     = 2,   -- seconds after returning before auto-re-queuing
        StatusUpdateRate     = 1,   -- how often match status is broadcast (seconds)
    },

    Game = {
        ResultScreenDuration = 10,      -- how long to show the result screen (seconds)
        NotificationDuration = 10,      -- how long to show notifications (seconds)
    }

}
