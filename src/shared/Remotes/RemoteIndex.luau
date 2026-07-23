-- RemoteIndex.luau
-- Central registry of all RemoteEvent / RemoteFunction names shared between
-- server and client. Any change to a name is made here once.

local RemoteIndex = {}

-- client → server
RemoteIndex.RequestJoinQueue  = "RequestJoinQueue"   -- player pressed Play
RemoteIndex.RequestLeaveQueue = "RequestLeaveQueue"  -- player cancelled queue

-- server → client(s)
RemoteIndex.UpdateLobbyStatus = "UpdateLobbyStatus"  -- match-status board data
RemoteIndex.RoundStarting     = "RoundStarting"      -- intermission countdown began
RemoteIndex.TeleportToArena   = "TeleportToArena"    -- round started, go to arena
RemoteIndex.ReturnToLobby     = "ReturnToLobby"      -- round over, back to lobby
RemoteIndex.ShowWinnerScreen  = "ShowWinnerScreen"   -- winner + rewards info
RemoteIndex.NotifyPlayer      = "NotifyPlayer"       -- toast-style in-game notification

return RemoteIndex
