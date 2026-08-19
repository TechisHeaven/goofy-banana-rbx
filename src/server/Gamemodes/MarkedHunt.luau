local MarkedHunt = {}

MarkedHunt.Name = "MarkedHunt"
MarkedHunt.DisplayName = "Marked Hunt"


local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local Enums =
	require(Shared.Enums)
local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
local Remotes = Shared.Remotes

------------------------------------------------

local MarkedPlayerChanged =
	Remotes:WaitForChild(RemoteIndex.MarkedPlayerChanged)


local NotificationManager = require(script.Parent.Parent.Managers.NotificationManager)

------------------------------------------------
-- State
------------------------------------------------

local MarkedReward = 500
------------------------------------------------
-- Get Marked Player
------------------------------------------------

function MarkedHunt:GetMarkedPlayer()

	return self.MarkedPlayer

end

------------------------------------------------
-- Is Marked
------------------------------------------------

function MarkedHunt:IsMarked(player)

	return player == self.MarkedPlayer

end


------------------------------------------------
-- Select New Marked Player
------------------------------------------------

function MarkedHunt:SelectNewMarkedPlayer(context)

	local players =
		context.RoundStatsManager:GetActivePlayers()

	local candidates = {}

	for _, player in ipairs(players) do

		------------------------------------------------
		-- Must be a runner
		------------------------------------------------

		local stats =
			context.RoundStatsManager:GetPlayerStats(player)

		if not stats then
			continue
		end

		if stats.Team ~= context.PlayerManager:GetTeam(player) then
			continue
		end

		if stats.Team ~= Enums.Team.Runner then
			continue
		end

		------------------------------------------------
		-- Must still be alive
		------------------------------------------------

		if not stats.Alive then
			continue
		end

		------------------------------------------------
		-- Don't select current target
		------------------------------------------------

		if player == self.MarkedPlayer then
			continue
		end

		table.insert(
			candidates,
			player
		)

	end

	------------------------------------------------
	-- No candidates
	------------------------------------------------

	if #candidates == 0 then

		self.MarkedPlayer = nil

		print(
			"[MarkedHunt] No eligible runner for new marked player"
		)

		return nil

	end

	------------------------------------------------
	-- Select new target
	------------------------------------------------

	self.MarkedPlayer =
		candidates[
			math.random(
				1,
				#candidates
			)
		]

	for _, player in ipairs(players) do
		MarkedPlayerChanged:FireClient(
			player,
			self.MarkedPlayer
		)
		NotificationManager:Send(
			player,
			'<font color="#FF4D4D"><b>'
				.. self.MarkedPlayer.Name
				.. '</b></font>'
				.. ' is now '
				.. '<font color="#FF4D4D"><b>MARKED!</b></font>'
				.. ' Freeze them for '
				.. '<font color="#FFD54A"><b>extra rewards!</b></font>'
		)
	end
	


	print(
		"[MarkedHunt] New Marked Player:",
		self.MarkedPlayer.Name
	)

	return self.MarkedPlayer

end

------------------------------------------------
-- Setup
------------------------------------------------

function MarkedHunt:Setup(context)

	self.MarkedPlayer = nil
end

------------------------------------------------
-- Start
------------------------------------------------

function MarkedHunt:Start(context)
	self:SelectNewMarkedPlayer(context)
end



------------------------------------------------
-- Player Frozen
------------------------------------------------

function MarkedHunt:OnPlayerFrozen(
	context,
	player,
	freezer
)

	if not self:IsMarked(player) then
		return
	end

    local oldMarkedPlayer = player

	print(
		"[MarkedHunt] MARKED PLAYER CAUGHT:",
		oldMarkedPlayer.Name,
		"by:",
		freezer and freezer.Name or "nil"
	)



    ------------------------------------------------
	-- Marked Freeze Reward
	------------------------------------------------

	if freezer then

		context.RoundStatsManager:AddCoins(
			freezer,
			MarkedReward
		)

		print(
			"[MarkedHunt] Marked Freeze Reward:",
			freezer.Name,
			"+",
			MarkedReward
		)

	end


	self.MarkedPlayer = nil

	self:SelectNewMarkedPlayer(context)
end

------------------------------------------------
-- Player Rescued
------------------------------------------------

function MarkedHunt:OnPlayerRescued(
	context,
	player,
	rescuer
)
    if not self:IsMarked(player) then
            return
        end

	print(
		"[MarkedHunt] Player Rescued:",
		player.Name,
		"Current Marked:",
		self.MarkedPlayer
			and self.MarkedPlayer.Name
			or "nil"
	)
end


function MarkedHunt:OnPlayerAdded(context, player)
	print(
		"[MarkedHunt] Late joiner:",
		player.Name
	)
	if not self.MarkedPlayer then
		return
	end

	MarkedPlayerChanged:FireClient(
		player,
		self.MarkedPlayer
	)
	
	print(
		"[MarkedHunt] Sent current marked player to late joiner:",
		player.Name,
		"Marked:",
		self.MarkedPlayer.Name
	)

end

------------------------------------------------
-- Player Removed
------------------------------------------------

function MarkedHunt:OnPlayerRemoved(
	context,
	player
)

	if player == self.MarkedPlayer then

		print(
			"[MarkedHunt] Marked player left:",
			player.Name
		)

		self.MarkedPlayer = nil

	end

end

------------------------------------------------
-- End
------------------------------------------------

function MarkedHunt:End(context)
	
	print(
		"[MarkedHunt] Ending. Marked Player:",
		self.MarkedPlayer
			and self.MarkedPlayer.Name
			or "nil"
	)

	local players =
		context.RoundStatsManager:GetActivePlayers()

	for _, player in ipairs(players) do

		MarkedPlayerChanged:FireClient(
			player,
			nil
		)

	end


end

------------------------------------------------
-- Cleanup
------------------------------------------------

function MarkedHunt:Cleanup(context)

	self.MarkedPlayer = nil
end

return MarkedHunt