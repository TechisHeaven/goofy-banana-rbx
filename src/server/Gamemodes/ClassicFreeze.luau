-- ClassicFreeze.luau
--
-- Base/default gamemode.
--
-- IMPORTANT:
-- Classic Freeze currently uses the existing game systems.
-- This module should NOT duplicate FreezeManager,
-- RoundStatsManager, ScoreManager, etc.
--
-- This module exists so Classic Freeze has a proper
-- gamemode implementation and future modes can follow
-- the same interface.

local ClassicFreeze = {}

ClassicFreeze.Name = "ClassicFreeze"
ClassicFreeze.DisplayName = "Classic Freeze"

------------------------------------------------
-- Setup
------------------------------------------------

function ClassicFreeze:Setup(context)
	-- Nothing special is required yet.
	--
	-- Existing RoundManager systems already prepare:
	-- • players
	-- • hunter
	-- • teams
	-- • spawning
	-- • stats
	-- • gameplay items
end

------------------------------------------------
-- Start
------------------------------------------------

function ClassicFreeze:Start(context)
	-- Classic Freeze uses the existing round behaviour.
	--
	-- Do not duplicate any existing freeze logic here.
end



------------------------------------------------
-- Player Frozen
------------------------------------------------

function ClassicFreeze:OnPlayerFrozen(context, player, freezer)
    print(
		"[ClassicFreeze] OnPlayerFrozen:",
		player.Name,
		"Freezer:",
		freezer and freezer.Name or "nil"
	)
	-- Classic Freeze currently has no additional
	-- mode-specific behaviour.
end

------------------------------------------------
-- Player Rescued
------------------------------------------------

function ClassicFreeze:OnPlayerRescued(
	context,
	player,
	rescuer
)
print(
		"[ClassicFreeze] OnPlayerRescued:",
		player.Name,
		"Rescuer:",
		rescuer and rescuer.Name or "nil"
	)
	-- Future Classic Freeze-specific rescue logic
	-- can go here.
end

------------------------------------------------
-- Player Removed
------------------------------------------------

function ClassicFreeze:OnPlayerRemoved(
	context,
	player
)
	-- Nothing required yet.
end

------------------------------------------------
-- End
------------------------------------------------

function ClassicFreeze:End(context)
	-- Nothing special.
end

------------------------------------------------
-- Cleanup
------------------------------------------------

function ClassicFreeze:Cleanup(context)
	-- Nothing special.
end

return ClassicFreeze