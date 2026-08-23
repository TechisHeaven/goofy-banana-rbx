local HelpSignalUI = {}

------------------------------------------------
-- UI
------------------------------------------------

local Players =
	game:GetService("Players")

local PlayerGui =
	Players.LocalPlayer:WaitForChild("PlayerGui")

local GameGui =
	PlayerGui:WaitForChild("GameGui")

local HelpFrame =
	GameGui:WaitForChild("Help")
local Label = HelpFrame:WaitForChild("Label")


------------------------------------------------
-- UI
------------------------------------------------

function HelpSignalUI:SetCooldown(remaining)

	Label.Text =
		"HELP\n"
		.. remaining

end

function HelpSignalUI:SetReady()
	Label.Text = "HELP"
end

return HelpSignalUI