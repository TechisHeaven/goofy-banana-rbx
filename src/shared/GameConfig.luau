return {

    Round = {
        MinimumPlayers = 1,
        IntermissionTime = 10,
        RoundTime = 60,
        EndTime = 5,
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

}
