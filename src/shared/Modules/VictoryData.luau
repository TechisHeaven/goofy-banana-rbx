local VictoryData = {}

function VictoryData.new(winner, poseName)
	return {
		Winner = winner,
		Pose = poseName or "Default",
	}
end

return VictoryData