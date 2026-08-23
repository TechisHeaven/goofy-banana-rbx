local SoundUtils = {}

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local SoundsFolder =
	ReplicatedStorage:WaitForChild("Sounds")

------------------------------------------------
-- PLAY SOUND
------------------------------------------------

function SoundUtils:PlaySound(
	sound,
	parent,
	duration
)

	if not sound or not parent then
		return
	end

	local soundClone

	------------------------------------------------
	-- SOUND INSTANCE
	------------------------------------------------

	if typeof(sound) == "Instance"
		and sound:IsA("Sound") then

		soundClone = sound:Clone()

	------------------------------------------------
	-- STRING SOUND ID
	------------------------------------------------

	elseif typeof(sound) == "string" then

		soundClone =
			Instance.new("Sound")

		soundClone.SoundId =
			sound

		------------------------------------------------
		-- Store template in ReplicatedStorage.Sounds
		------------------------------------------------

		local template =
			Instance.new("Sound")

		template.Name =
			"Sound_" .. tostring(
				math.abs(
					string.byte(
						sound,
						1
					) or 0
				)
			)

		template.SoundId =
			sound

		template.Parent =
			SoundsFolder

		------------------------------------------------
		-- Clone template settings
		------------------------------------------------

		soundClone.SoundId =
			template.SoundId

		template:Destroy()

	else

		warn(
			"[SoundUtils] Invalid sound:",
			sound
		)

		return

	end

	------------------------------------------------
	-- Parent + Play
	------------------------------------------------

	soundClone.Parent =
		parent

	soundClone:Play()

	------------------------------------------------
	-- Custom duration
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

		return

	end

	------------------------------------------------
	-- Automatically remove
	------------------------------------------------

	soundClone.Ended:Once(
		function()

			if soundClone
				and soundClone.Parent then

				soundClone:Destroy()

			end

		end
	)

end

return SoundUtils