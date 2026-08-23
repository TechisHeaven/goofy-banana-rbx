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
    Infected = "Infected"
}

Enums.Team = {
    Hunter = "Hunter",
    Runner = "Runner",
    Infected = "Infected",
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


Enums.Modes = {
    ClassicFreeze = "ClassicFreeze",
    MarkedHunt = "MarkedHunt",
    Infected = "Infected"
}

return Enums