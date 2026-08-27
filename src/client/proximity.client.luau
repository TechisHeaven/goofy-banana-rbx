local ProximityPromptService =
	game:GetService("ProximityPromptService")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local CustomProximityTemplate =
	ReplicatedStorage.ProximityPrompt:WaitForChild("CustomProximity")

------------------------------------------------
-- PROMPT SHOWN
------------------------------------------------

ProximityPromptService.PromptShown:Connect(
	function(promptInstance: ProximityPrompt)

		if promptInstance.Style
			== Enum.ProximityPromptStyle.Default then

			return
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