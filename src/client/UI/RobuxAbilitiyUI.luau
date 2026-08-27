local Players = game:GetService("Players")

local player = Players.LocalPlayer

local playerGui = player:WaitForChild("PlayerGui")
local GameGui = playerGui:WaitForChild("GameGui")
local AbilityFrame = GameGui:WaitForChild("AbilityFrame")
local Button = AbilityFrame:WaitForChild("Button")

------------------------------------------------
-- UI
------------------------------------------------

local AbilityUI = {}

AbilityUI.OnRevealPressed = nil

------------------------------------------------
-- HUNTER VISIBILITY
------------------------------------------------

local function UpdateRevealButton()

	local isHunter =
		player:GetAttribute("Team") == "Hunter"

	Button.Visible = isHunter

end

------------------------------------------------
-- INIT
------------------------------------------------

function AbilityUI:Init()

	UpdateRevealButton()

	player:GetAttributeChangedSignal("Team"):Connect(
		UpdateRevealButton
	)

	------------------------------------------------
	-- BUTTON
	------------------------------------------------

	Button.Activated:Connect(function()

		if player:GetAttribute("Team") ~= "Hunter" then
			return
		end

		if self.OnRevealPressed then
			self.OnRevealPressed()
		end

	end)

end

return AbilityUI