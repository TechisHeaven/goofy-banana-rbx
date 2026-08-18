local SoundUtils = {}

function SoundUtils:PlaySound(sound, parent, duration)

	if not sound then
		return
	end

	local soundClone = sound:Clone()
	soundClone.Parent = parent
	soundClone:Play()

	------------------------------------------------
	-- Custom duration
	------------------------------------------------

	if duration then

		task.delay(duration, function()

			if soundClone
				and soundClone.Parent then

				soundClone:Stop()
				soundClone:Destroy()

			end

		end)

		return
	end

	------------------------------------------------
	-- Automatically remove when finished
	------------------------------------------------

	soundClone.Ended:Once(function()

		if soundClone
			and soundClone.Parent then

			soundClone:Destroy()

		end

	end)

end

return SoundUtils