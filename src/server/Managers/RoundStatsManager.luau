local RoundStatsManager = {}

local Round = {}

local PlayerStats = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local Enums = require(Shared.Enums)

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events


local Remotes = Shared.Remotes

------------------------------------------------

local RoundStatsUpdate =
	Remotes:WaitForChild(RemoteIndex.RoundStatsUpdate)



function RoundStatsManager:StartRound(players, hunter)

    table.clear(PlayerStats)

    Round = {

        State = Enums.RoundState.Playing,

        Hunter = hunter,

        Winner = nil,

        StartTime = tick(),

        EndTime = 0,

        TotalPlayers = #players,

        TotalRunners = #players - 1,

        AliveRunners = #players - 1,

        FrozenRunners = 0,

    }

    for _, player in ipairs(players) do

        PlayerStats[player] = {

            Team = player == hunter
                and Enums.Team.Hunter
                or Enums.Team.Runner,

			OriginalTeam = player == hunter
				and Enums.Team.Hunter
				or Enums.Team.Runner,

            Alive = player ~= hunter,

            Frozen = false,

            Coins = 0,
            BananasCollected = 0,

            SurvivalTime = 0,
            
            Rescues = 0,
            FrozenPlayers = 0,

            Falls = 0,

            MVPScore = 0,
        }

    end

end

function RoundStatsManager:EndRound()
	if Round.State == Enums.RoundState.Ending then
		return
	end

	Round.State =	Enums.RoundState.Ending
	Round.EndTime =  tick()
end

function RoundStatsManager:ResetRound()

    table.clear(PlayerStats)

    table.clear(Round)

end


function RoundStatsManager:GetOriginalTeam(player)

    local stats = PlayerStats[player]

    if not stats then
        return nil
    end

    return stats.OriginalTeam

end


function RoundStatsManager:GetPlayerStats(player)
    return PlayerStats[player]
end


function RoundStatsManager:GetRound()

    return Round

end


function RoundStatsManager:ShouldShowFrozenUI()

	return Round.AliveRunners >= 2

end

function RoundStatsManager:AddMVPScore(player, amount)

	local stats = PlayerStats[player]

	if not stats then
		return
	end

	stats.MVPScore += amount

end


function RoundStatsManager:AddCoins(player, amount)

    local stats = PlayerStats[player]

    if not stats then
        return
    end

    stats.Coins += amount
    stats.MVPScore += amount

	RoundStatsUpdate:FireClient(
		player,
		"Coins",
		stats.Coins,
		amount
	)
end

function RoundStatsManager:AddFrozenPlayer(player)

	local stats = PlayerStats[player]
	if not stats then
		return
	end

	stats.FrozenPlayers += 1
	stats.MVPScore += 200
end

-- Later Joiners Logic 
function RoundStatsManager:AddLateJoiner(player)

	PlayerStats[player] = {
		OriginalTeam = Enums.Team.Runner,

		Team = Enums.Team.Runner,

		Alive = true,

		Frozen = false,

		Coins = 0,

		BananasCollected = 0,

		SurvivalTime = 0,

		Rescues = 0,

		FrozenPlayers = 0,

		MVPScore = 0,

	}

	Round.TotalPlayers += 1
	Round.TotalRunners += 1
	Round.AliveRunners += 1

end

function RoundStatsManager:GetActivePlayers()

	local players = {}

	for player, stats in pairs(PlayerStats) do

		if stats then
			table.insert(players, player)
		end

	end

	return players

end



function RoundStatsManager:RemovePlayer(player)

	local stats = PlayerStats[player]

	if not stats then
		return
	end

	if stats.Team == Enums.Team.Runner then

		Round.TotalRunners -= 1

		if stats.Alive then
			Round.AliveRunners -= 1
		else
			Round.FrozenRunners -= 1
		end

	end

	Round.TotalPlayers -= 1

	PlayerStats[player] = nil

end


function RoundStatsManager:AwardAliveBonus()

	for _, stats in pairs(PlayerStats) do

		if stats.Team == Enums.Team.Runner and stats.Alive then
			stats.MVPScore += 200
		end

	end

end

function RoundStatsManager:AddBanana(player)

	local stats = PlayerStats[player]

	if not stats then
		return
	end

	stats.BananasCollected += 1
    stats.MVPScore += 25
end

function RoundStatsManager:AddRescue(player)

	local stats = PlayerStats[player]

	stats.Rescues += 1
	stats.MVPScore += 150

end



function RoundStatsManager:GetTopCoins()

	local best = -math.huge

	for _,stats in pairs(PlayerStats) do

		if stats.Coins > best then
			best = stats.Coins
		end

	end

	return best

end

function RoundStatsManager:GetMVP()

	local bestPlayer
	local bestScore = -math.huge

	for player, stats in pairs(PlayerStats) do

		if stats.MVPScore > bestScore then

			bestScore = stats.MVPScore
			bestPlayer = player

		end

	end

	return bestPlayer

end

function RoundStatsManager:GetTopCoinsRunner()

	local bestCoins = -math.huge
	local winners = {}

	for player,stats in pairs(PlayerStats) do

		if stats.Team ~= Enums.Team.Runner then
			continue
		end

		if stats.Coins > bestCoins then

			bestCoins = stats.Coins
			winners = {player}

		elseif stats.Coins == bestCoins then

			table.insert(winners, player)

		end

	end

	if #winners == 0 then
		return nil
	end

	return winners[math.random(#winners)]

end

function RoundStatsManager:IsFrozen(player)

	local stats = PlayerStats[player]

	return stats and stats.Frozen or false

end


function RoundStatsManager:IsAlive(player)

	local stats = PlayerStats[player]

	return stats and stats.Alive or false

end


function RoundStatsManager:IsLastRunner(player)

	local stats = PlayerStats[player]

	return stats
		and stats.Team == Enums.Team.Runner
		and stats.Alive
		and Round.AliveRunners == 1

end



function RoundStatsManager:Freeze(player)

    local stats = PlayerStats[player]

    if not stats or stats.Frozen then
        return
    end
	-- Already frozen, don't count twice
	if stats.Frozen then
		return
	end

    stats.Frozen = true
    stats.Alive = false

    Round.AliveRunners -= 1
    Round.FrozenRunners += 1

end

function RoundStatsManager:Rescue(rescuer, rescued)

   local rescuedStats = PlayerStats[rescued]

	if not rescuedStats then
		return
	end

	-- Already alive
	-- if not rescuedStats.Frozen then
	-- 	return
	-- end


	rescuedStats.Frozen = false
	rescuedStats.Alive = true

	Round.AliveRunners += 1
	Round.FrozenRunners -= 1
	

	local rescuerStats = PlayerStats[rescuer]

	if rescuerStats then

		rescuerStats.Rescues += 1
		rescuerStats.MVPScore += 150

	end

end



function RoundStatsManager:Tick(deltaTime)
   for _, stats in pairs(PlayerStats) do

		-- if stats.Team ~= Enums.Team.Runner then
		-- 	continue
		-- end
		if stats.Alive then
			continue
		end

		stats.SurvivalTime += deltaTime
		
		-- Reward surviving every second
		stats.MVPScore += deltaTime * 2

		if stats.Team == Enums.Team.Runner
			and stats.Alive then

			stats.MVPScore += 300

		end

	end
end


function RoundStatsManager:SetWinner(winner)

	Round.Winner = winner

end



function RoundStatsManager:SetTeam(player, team)

	local stats = PlayerStats[player]

	if not stats then
		return
	end

	stats.Team = team

end



function RoundStatsManager:GetWinner()

	return Round.Winner

end

function RoundStatsManager:GetAliveRunners()
	return Round.AliveRunners
end

function RoundStatsManager:GetFrozenRunners()

	return Round.FrozenRunners

end

function RoundStatsManager:GetRunnerCount()

	return Round.TotalRunners

end

return RoundStatsManager