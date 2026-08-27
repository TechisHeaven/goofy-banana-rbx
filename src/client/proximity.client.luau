local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local CustomProximityTemplate =
	ReplicatedStorage.ProximityPrompt:WaitForChild("CustomProximity")

------------------------------------------------
-- PROMPT SHOWN
------------------------------------------------

local function IsRescuePrompt(prompt)
	return prompt:GetAttribute("RescuePrompt") == true
end


ProximityPromptService.PromptShown:Connect(
	function(promptInstance: ProximityPrompt)

		if promptInstance.Style
			== Enum.ProximityPromptStyle.Default then

			return
		end

		if IsRescuePrompt(promptInstance) then

			------------------------------------------------
			-- CURRENT PLAYER MUST BE RUNNER
			------------------------------------------------

			if player:GetAttribute("Team") ~= "Runner" then
				return
			end

			------------------------------------------------
			-- FIND TARGET CHARACTER
			------------------------------------------------

			local targetCharacter =
				promptInstance:FindFirstAncestorOfClass("Model")

			if not targetCharacter then
				return
			end

			local targetPlayer =
				Players:GetPlayerFromCharacter(targetCharacter)

			if not targetPlayer then
				return
			end

			if targetPlayer == player then
				return
			end

			------------------------------------------------
			-- TARGET MUST ALSO BE RUNNER
			------------------------------------------------

			if targetPlayer:GetAttribute("Team") ~= "Runner" then
				return
			end


		end

		local customProximity =
			CustomProximityTemplate:Clone()

		customProximity.ObjectText.Text =
			promptInstance.ObjectText

		customProximity.ActionText.Text =
			"["
			.. promptInstance.KeyboardKeyCode.Name
			.. "]"

		------------------------------------------------
		-- HOLD BAR
		------------------------------------------------

		local holdBar =
			customProximity:FindFirstChild("HoldBar")

		if holdBar then
			holdBar.Size =
				UDim2.new(0, 0, 0, 3)
		end

		customProximity.Parent =
			promptInstance.Parent

		------------------------------------------------
		-- HOLD START
		------------------------------------------------

		local holdBeganConnection =
			promptInstance.PromptButtonHoldBegan:Connect(
				function()

					if not holdBar then
						return
					end

					local tween =
						game:GetService("TweenService"):Create(
							holdBar,
							TweenInfo.new(
								promptInstance.HoldDuration,
								Enum.EasingStyle.Linear
							),
							{
								Size = UDim2.new(
									1,
									0,
									0,
									3
								)
							}
						)

					tween:Play()

				end
			)

		------------------------------------------------
		-- HOLD END / CANCEL
		------------------------------------------------

		local holdEndedConnection =
			promptInstance.PromptButtonHoldEnded:Connect(
				function()

					if not holdBar then
						return
					end

					local tween =
						game:GetService("TweenService"):Create(
							holdBar,
							TweenInfo.new(
								0.08,
								Enum.EasingStyle.Quad,
								Enum.EasingDirection.Out
							),
							{
								Size = UDim2.new(
									0,
									0,
									0,
									3
								)
							}
						)

					tween:Play()

				end
			)

		------------------------------------------------
		-- HIDDEN
		------------------------------------------------

		promptInstance.PromptHidden:Once(
			function()

				if holdBeganConnection then
					holdBeganConnection:Disconnect()
				end

				if holdEndedConnection then
					holdEndedConnection:Disconnect()
				end

				if customProximity then
					customProximity:Destroy()
				end

			end
		)

	end
)