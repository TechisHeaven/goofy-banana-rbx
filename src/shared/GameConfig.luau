return {

    Round = {
        MinimumPlayers = 2,
        IntermissionTime = 10,
        RoundTime = 60,
        EndTime = 5,
        AllowLateJoin = true,
        LateJoinCutoff = 30,
    },

    Rescue = {
        HoldTime = 5,
    },

    Hunter = {
        Count = 1,
        CooldownTime = 4,
    },

    Lobby = {
        PostRoundReturnDelay = 3,   -- seconds after round ends before returning to lobby
        AutoRequeueDelay     = 2,   -- seconds after returning before auto-re-queuing
        StatusUpdateRate     = 1,   -- how often match status is broadcast (seconds)
    },

    Game = {
        NotificationDuration = 10,      -- how long to show notifications (seconds)
    }

}
