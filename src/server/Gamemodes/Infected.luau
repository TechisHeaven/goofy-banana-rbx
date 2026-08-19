local Infected = {}

Infected.Name = "Infected"
Infected.DisplayName = "Infected"
local InfectionReward = 100
local InfectionMVPScore = 500
------------------------------------------------
-- SERVICES
------------------------------------------------

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- SHARED
------------------------------------------------

local Shared =
	ReplicatedStorage:WaitForChild("Shared")



local Enums =
	require(Shared.Enums)

local FreezeModule =
	require(
		Shared.Modules.FreezeModule
	)

local PromptUtil = require(Shared.Utils.PromptUtil)

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events

local Remotes =
	Shared.Remotes

local InfectedPlayerChanged =
	Remotes:WaitForChild(
		RemoteIndex.InfectedPlayerChanged
	)
------------------------------------------------
-- SETUP
------------------------------------------------

function Infected:Setup(context)

	self.InfectedPlayers = {}

	print("[Infected] Setup")

end

------------------------------------------------
-- START
------------------------------------------------

function Infected:Start(context)

	print("[Infected] Started")

end

------------------------------------------------
-- IS INFECTED
------------------------------------------------

function Infected:IsInfected(player)

	return self.InfectedPlayers[player] == true

end

------------------------------------------------
-- IS RUNNER
------------------------------------------------

function Infected:IsRunner(
	context,
	player
)

	return context.PlayerManager:GetTeam(player)
		== Enums.Team.Runner

end

------------------------------------------------
-- INFECT PLAYER
------------------------------------------------

function Infected:InfectPlayer(
	context,
	player,
	infector
)

	if not player
		or not player.Parent then

		return false

	end

	------------------------------------------------
	-- Already infected
	------------------------------------------------

	if self:IsInfected(player) then

		return false

	end

	------------------------------------------------
	-- Must currently be a Runner
	------------------------------------------------

	if not self:IsRunner(
		context,
		player
	) then

		return false

	end

	------------------------------------------------
	-- Mark as infected
	------------------------------------------------

	self.InfectedPlayers[player] = true

	------------------------------------------------
	-- Change PlayerManager team
	------------------------------------------------

	context.PlayerManager:SetTeam(
		player,
		Enums.Team.Hunter
	)

	------------------------------------------------
	-- Change state
	------------------------------------------------

	context.PlayerManager:SetState(
		player,
		Enums.PlayerState.Infected
	)

    self:OnPlayerInfected(
        context,
        player,
        infector
    )


	print(
		"[Infected] Player infected:",
		player.Name,
		"by:",
		infector and infector.Name or "nil"
	)

	------------------------------------------------
	-- Check win condition
	------------------------------------------------

    self:CheckInfectionWin(context)

	return true

end

function Infected:OnPlayerInfected(
	context,
	player,
	infector
)

	print(
		"[Infected] OnPlayerInfected:",
		player.Name
	)

    ------------------------------------------------
    -- INFECTION REWARD
    ------------------------------------------------

    if infector
        and infector.Parent
        and infector ~= player then

        context.RoundStatsManager:AddCoins(
            infector,
            InfectionReward
        )

        context.RoundStatsManager:AddMVPScore(
            infector,
            InfectionMVPScore
        )

        print(
            "[Infected] Infection reward:",
            infector.Name,
            "+",
            InfectionReward,
            "coins / +",
            InfectionMVPScore,
            "MVP"
        )

    end

    for _, viewer in ipairs(
		context.RoundStatsManager:GetActivePlayers()
    ) do

        InfectedPlayerChanged:FireClient(
            viewer,
            player,
            true
        )

    end

    PromptUtil:ClearCharacter(player.Character)
	-- Infected-specific setup goes here.

end


function Infected:GetRemainingRunners(context)

	local count = 0

	for _, player in ipairs(
		context.RoundStatsManager:GetActivePlayers()
	) do

		if self:IsRunner(context, player) then
			count += 1
		end

	end

	return count

end



function Infected:CheckInfectionWin(context)

	local remainingRunners =
		self:GetRemainingRunners(context)

	print(
		"[Infected] Remaining runners:",
		remainingRunners
	)

	if remainingRunners <= 0 then

		print(
			"[Infected] All runners infected!"
		)

		------------------------------------------------
		-- Let RoundManager handle the actual ending
		------------------------------------------------

		context.RoundManager:CheckWinCondition()

	end

end

------------------------------------------------
-- PLAYER FROZEN
------------------------------------------------

function Infected:OnPlayerFrozen(
	context,
	player,
	freezer
)

	print(
		"[Infected] Player Frozen:",
		player.Name,
		"by:",
		freezer and freezer.Name or "nil"
	)

	------------------------------------------------
	-- Only Runner can be infected
	------------------------------------------------

	if not self:IsRunner(
		context,
		player
	) then

		return

	end

	------------------------------------------------
	-- Infect player
	------------------------------------------------

	local infected =
		self:InfectPlayer(
			context,
			player,
			freezer
		)

	------------------------------------------------
	-- Remove normal freeze
	------------------------------------------------
	-- Infected players should NOT stay
	-- frozen like Classic / Marked Hunt.

	if infected
		and player.Character then

		FreezeModule.Unfreeze(
			player.Character
		)

	end

end


------------------------------------------------
-- PLAYER RESCUED
------------------------------------------------

function Infected:OnPlayerRescued(
	context,
	player,
	rescuer
)

	------------------------------------------------
	-- Infected mode does not use rescue.
	------------------------------------------------

	print(
		"[Infected] Rescue ignored:",
		player.Name
	)

end

------------------------------------------------
-- PLAYER ADDED
------------------------------------------------

function Infected:OnPlayerAdded(
	context,
	player
)

	print(
		"[Infected] Player Added:",
		player.Name
	)

end

------------------------------------------------
-- PLAYER REMOVED
------------------------------------------------

function Infected:OnPlayerRemoved(
	context,
	player
)

	self.InfectedPlayers[player] = nil

	print(
		"[Infected] Player Removed:",
		player.Name
	)

	------------------------------------------------
	-- Re-check win condition
	------------------------------------------------
	-- Important if a Runner leaves.

	self:CheckInfectionWin(context)

end

------------------------------------------------
-- END
------------------------------------------------

function Infected:End(context)
    
  

        local players =
		context.RoundStatsManager:GetActivePlayers()

	for _, viewer in ipairs(players) do

		InfectedPlayerChanged:FireClient(
            viewer,
            nil,
            false
        )

	end
	print(
		"[Infected] Ending"
	)

end

------------------------------------------------
-- CLEANUP
------------------------------------------------

function Infected:Cleanup(context)

        local players =
		context.RoundStatsManager:GetActivePlayers()
	for _, player in ipairs(players) do

		InfectedPlayerChanged:FireClient(
			player,
			nil,
			false
		)

	end

	table.clear(
		self.InfectedPlayers
	)
	print(
		"[Infected] Cleanup"
	)

end

return Infected