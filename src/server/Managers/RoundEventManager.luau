local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
local Enums = require(Shared.Enums)

local PlayerManager = require(script.Parent.PlayerManager)
local RoundStatsManager = require(script.Parent.RoundStatsManager)
local CurrencyManager = require(script.Parent.CurrencyManager)
local TaskManager =
	require(script.Parent.TaskManager)

local TaskEvents =
	require(Shared.EnumsEvents.TaskEvents)

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


function RoundEventManager:FireSlowMo(players, data)

	local remote =
		getRemote(RemoteIndex.StartSlowMo)

	for _, player in ipairs(players) do
		remote:FireClient(
			player,
			data
		)

	end

end


function RoundEventManager:FireRoundEnded(players, data)
    local RoundEndedRemote = getRemote(RemoteIndex.RoundEnded)


	local winningTeam

	if data.winner == "Hunter" then

		winningTeam =
			Enums.Team.Hunter

	elseif data.winner == "Runners" then

		winningTeam =
			Enums.Team.Runner

	end


    for _,player in ipairs(players) do

        local team =  RoundStatsManager:GetOriginalTeam(player)
	    local stats = RoundStatsManager:GetPlayerStats(player)


		if not stats then
			continue
		end
    ------------------------------------------------
		-- Determine winner
		------------------------------------------------
        
        local won =
                winningTeam ~= nil
                and team == winningTeam

        if won then

            TaskManager:AddProgress(
                player,
                TaskEvents.WinRound,
                1
            )

        end    

        CurrencyManager:AddResultStats(
            player,
			stats.Coins,
			stats.MVPScore,
			won
        )
     
       
        RoundEndedRemote:FireClient(player,{
            won = won,
            role = team,
            winner = data.winner,
            hunter = data.hunter,
            stats = stats,
        })
    end
    RoundStatsManager:EndRound()

end

------------------------------------------------

return RoundEventManager