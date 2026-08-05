local Enums = {}

Enums.RoundState = {
    Waiting = "Waiting",
    Intermission = "Intermission",
    Starting = "Starting",
    Playing = "Playing",
    Ending = "Ending",
}

Enums.PlayerState = {
    Alive = "Alive",
    Frozen = "Frozen",
    Rescuing = "Rescuing",
}

Enums.Team = {
    Hunter = "Hunter",
    Runner = "Runner",
}

Enums.PlayerLobbyState = {
    InLobby = "InLobby",
    Queued  = "Queued",
    InMatch = "InMatch",
}

Enums.NotificationTarget = {
	Overlay = "Overlay",      -- PopupGui
	Gameplay = "Gameplay",    -- GameGui
    Default = "Overlay",      -- Default to Overlay

}

return Enums