local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Wait for attributes to replicate
if not LocalPlayer:GetAttribute("Team") then
	LocalPlayer:GetAttributeChangedSignal("Team"):Wait()
end

ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
	-- Only target Rescue prompts
	if prompt.ActionText == "Rescue" then
		-- The prompt is parented to the frozen player's HumanoidRootPart (prompt.Parent).
		-- So the character Model is prompt.Parent.Parent.
		local character = prompt.Parent and prompt.Parent.Parent
		local frozenPlayer = character and Players:GetPlayerFromCharacter(character)
		
		if frozenPlayer then
			local localTeam = LocalPlayer:GetAttribute("Team")
			local localState = LocalPlayer:GetAttribute("State")

			-- Hide/Disable prompt for:
			-- 1. The frozen player themselves (can't rescue self)
			-- 2. Anyone on the Hunter team (can't rescue runners)
			-- 3. Any Runner who is currently frozen (can't rescue others while frozen)
			if frozenPlayer == LocalPlayer or localTeam == "Hunter" or localState == "Frozen" then
				prompt.Enabled = false
			end
		end
	end
end)

print("Client-side Rescue ProximityPrompt filter initialized.")
