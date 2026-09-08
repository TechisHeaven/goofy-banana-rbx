local SoundUtils = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

local Debris = game:GetService("Debris")

------------------------------------------------
-- PLAY SOUND
------------------------------------------------

function SoundUtils:PlaySound(
	sound,
	parent,
	duration,
	properties
)

	if not sound then
		warn("[SoundUtils] No sound provided")
		return nil
	end

	------------------------------------------------
	-- VALIDATE
	------------------------------------------------

	if not sound:IsA("Sound") then
		warn(
			"[SoundUtils] Instance is not a Sound:",
			sound
		)

		return nil
	end

	------------------------------------------------
	-- DEFAULT PARENT
	------------------------------------------------

	parent =
		parent
		or game:GetService("SoundService")

	------------------------------------------------
	-- CLONE
	------------------------------------------------

	local soundClone =
		sound:Clone()

	soundClone.Name =
		sound.Name .. "_Playing"

	------------------------------------------------
	-- PROPERTIES
	------------------------------------------------

	if properties then

		for property, value in pairs(properties) do

			local success, errorMessage =
				pcall(
					function()
						soundClone[property] = value
					end
				)

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
	-- RESET PLAYBACK STATE
	------------------------------------------------

	soundClone.TimePosition = 0
	soundClone.Playing = false

	------------------------------------------------
	-- PARENT
	------------------------------------------------

	soundClone.Parent = parent


	------------------------------------------------
	-- PLAY
	------------------------------------------------

	soundClone:Play()

	------------------------------------------------
	-- CLEANUP
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

	else

		soundClone.Ended:Once(
			function()

				if soundClone
					and soundClone.Parent then

					soundClone:Destroy()

				end

			end
		)

	end

	------------------------------------------------
	-- IMPORTANT
	------------------------------------------------

	return soundClone

end

return SoundUtils