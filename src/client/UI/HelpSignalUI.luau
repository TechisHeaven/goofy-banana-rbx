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
local Cooldown = HelpFrame:WaitForChild("Cooldown")

------------------------------------------------
-- UI
------------------------------------------------

function HelpSignalUI:SetCooldown(remaining)

	Cooldown.Text = remaining .. 's'

end

function HelpSignalUI:SetReady()
	Cooldown.Text = ""
end

return HelpSignalUI