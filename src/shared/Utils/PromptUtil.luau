local PromptUtil = {}

------------------------------------------------
-- REMOVE ALL PROXIMITY PROMPTS
------------------------------------------------

function PromptUtil:ClearAll()

	for _, descendant in ipairs(
		workspace:GetDescendants()
	) do

		if descendant:IsA("ProximityPrompt") then
			descendant:Destroy()
		end

	end

end

------------------------------------------------
-- REMOVE PROMPTS FROM CHARACTER
------------------------------------------------

function PromptUtil:ClearCharacter(character)

	if not character then
		return
	end

	for _, descendant in ipairs(
		character:GetDescendants()
	) do

		if descendant:IsA("ProximityPrompt") then
			descendant:Destroy()
		end

	end

end

return PromptUtil