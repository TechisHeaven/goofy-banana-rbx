local VictoryAnimations = {}

VictoryAnimations.Default = "rbxassetid://88700548846685"

VictoryAnimations.Poses = {
    Dance01 = "rbxassetid://88700548846685",
    Dance02 = "rbxassetid://76677104682883",
    Flex = "rbxassetid://345678",
    Dab = "rbxassetid://456789",
    Cheer = "rbxassetid://0",
	Laugh = "rbxassetid://0",
}

function VictoryAnimations:GetAnimationId(poseName)
	return self.Poses[poseName] or self.Default
end


return VictoryAnimations