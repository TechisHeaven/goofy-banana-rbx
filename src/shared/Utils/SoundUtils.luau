local SoundUtils = {}

------------------------------------------------
-- PLAY SOUND
------------------------------------------------

function SoundUtils:PlaySound(
	sound,
	parent,
	duration,
	properties
)

	if not sound or not parent then
		return nil
	end

	local soundClone

	------------------------------------------------
	-- SOUND INSTANCE
	------------------------------------------------

	if typeof(sound) == "Instance"
		and sound:IsA("Sound") then

		soundClone = sound:Clone()

	else

		warn(
			"[SoundUtils] Invalid sound:",
			sound
		)

		return nil
	end

	------------------------------------------------
	-- APPLY PROPERTIES
	------------------------------------------------

	if properties then

		for property, value in pairs(properties) do

			local success, errorMessage =
				pcall(function()
					soundClone[property] = value
				end)

			if not success then

				warn(
					"[SoundUtils] Failed to set property:",
					property,
					errorMessage
				)

			end
		end
	end

	------------------------------------------------
	-- PARENT
	------------------------------------------------

	soundClone.Parent = parent

	------------------------------------------------
	-- PLAY
	------------------------------------------------

	soundClone:Play()

	------------------------------------------------
	-- CUSTOM DURATION
	------------------------------------------------

	if duration then

		task.delay(
			duration,
			function()

				if soundClone
					and soundClone.Parent then

					soundClone:Stop()
					soundClone:Destroy()

				end

			end
		)

		return soundClone
	end

	------------------------------------------------
	-- AUTOMATIC CLEANUP
	------------------------------------------------

	soundClone.Ended:Once(
		function()

			if soundClone
				and soundClone.Parent then

				soundClone:Destroy()

			end

		end
	)

	return soundClone
end

return SoundUtils