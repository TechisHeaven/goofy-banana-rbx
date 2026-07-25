local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local RemoteIndex = require(Shared.Remotes.RemoteIndex)
local Enums = require(Shared.Enums)

local PlayerManager = require(script.Parent.PlayerManager)

local RoundEventManager = {}

local RemotesFolder = Shared:WaitForChild("Remotes")


-- Cached remote references (filled in Init)
local remotes: { [string]: RemoteEvent } = {}

-- local function getRemote(name: string): RemoteEvent?
-- 	if remotes[name] then return remotes[name] end
-- 	warn("LobbyManager: Remote '" .. name .. "' not cached yet")
-- 	return nil
-- end


local function getRemote(name)
    return RemotesFolder:WaitForChild(name)
end

------------------------------------------------
function RoundEventManager:Init()

    for _, name in pairs(RemoteIndex) do

        local remote = RemotesFolder:FindFirstChild(name)

        if remote then
            remotes[name] = remote
        end

    end

end



function RoundEventManager:FireRoundEnded(players,data)
    local RoundEndedRemote = getRemote(RemoteIndex.RoundEnded)

    for _,player in ipairs(players) do

        local team = PlayerManager:GetTeam(player)

        local won =
            (data.winner == "Hunter" and team == Enums.Team.Hunter)
            or
            (data.winner == "Runners" and team == Enums.Team.Runner)
        RoundEndedRemote:FireClient(player,{

            won = won,

            role = team,

            winner = data.winner,

            hunter = data.hunter,

            reward = data.reward,

            stats = data.stats,

        })

    end

end

------------------------------------------------

return RoundEventManager