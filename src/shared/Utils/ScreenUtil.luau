local ScreenUtil = {}

local RunService = game:GetService("RunService")

function ScreenUtil:ScreenShake(intensity, duration, frequency)
	intensity = intensity or 1.2
	duration = duration or 0.45
	frequency = frequency or 0.016

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local elapsed = 0
	local accumulator = 0

	local connection

	connection = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		accumulator += dt

		if elapsed >= duration then
			connection:Disconnect()
			return
		end

		-- Control how often a new shake offset is generated.
		if accumulator < frequency then
			return
		end

		accumulator = 0

		-- Ease out over time.
		local alpha = 1 - (elapsed / duration)
		local strength = intensity * alpha * alpha

		local offset = CFrame.new(
			(math.random() * 2 - 1) * strength,
			(math.random() * 2 - 1) * strength,
			0
		) * CFrame.Angles(
			math.rad((math.random() * 2 - 1) * strength * 0.5),
			math.rad((math.random() * 2 - 1) * strength * 0.5),
			math.rad((math.random() * 2 - 1) * strength * 0.25)
		)

		camera.CFrame = camera.CFrame * offset
	end)
end

return ScreenUtil