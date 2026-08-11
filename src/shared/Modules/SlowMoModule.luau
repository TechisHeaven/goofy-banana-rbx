local SlowMo = {}

local Active = false
local CurrentToken = 0

local Animator
local OriginalFOV
local AnimationConnection

local DEFAULT_DURATION = 3
local DEFAULT_SPEED = 0.35
local DEFAULT_FOV = 70

------------------------------------------------
-- Get Character
------------------------------------------------

local function GetAnimator()

	local player = game.Players.LocalPlayer

	local character =
		player.Character
		or player.CharacterAdded:Wait()

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil
	end

	return humanoid:FindFirstChildOfClass("Animator")
end

------------------------------------------------
-- Start
------------------------------------------------

function SlowMo:Start(options)

	options = options or {}

	local duration =
		options.Duration or DEFAULT_DURATION

	local speed =
		options.Speed or DEFAULT_SPEED

	local fov =
		options.FOV or DEFAULT_FOV

	CurrentToken += 1

	local token = CurrentToken

	------------------------------------------------
	-- Animator
	------------------------------------------------

	Animator = GetAnimator()

	if not Animator then
		return
	end

	------------------------------------------------
	-- Camera
	------------------------------------------------

	local camera =
		workspace.CurrentCamera

	OriginalFOV =
		camera.FieldOfView

	------------------------------------------------
	-- Activate
	------------------------------------------------

	Active = true

	------------------------------------------------
	-- Slow currently playing animations
	------------------------------------------------

	for _, track in ipairs(
		Animator:GetPlayingAnimationTracks()
	) do

		track:AdjustSpeed(speed)

	end

	------------------------------------------------
	-- Slow every new animation
	------------------------------------------------

	AnimationConnection =
		Animator.AnimationPlayed:Connect(
			function(track)

				if Active then
					track:AdjustSpeed(speed)
				end

			end
		)

	------------------------------------------------
	-- Camera
	------------------------------------------------

	camera.FieldOfView = fov

	------------------------------------------------
	-- Stop automatically
	------------------------------------------------

	task.delay(
		duration,
		function()

			if token ~= CurrentToken then
				return
			end

			self:Stop()

		end
	)

end

------------------------------------------------
-- Stop
------------------------------------------------

function SlowMo:Stop()

	CurrentToken += 1

	Active = false

	------------------------------------------------
	-- Disconnect animation listener
	------------------------------------------------

	if AnimationConnection then

		AnimationConnection:Disconnect()
		AnimationConnection = nil

	end

	------------------------------------------------
	-- Restore animations
	------------------------------------------------

	if Animator then

		for _, track in ipairs(
			Animator:GetPlayingAnimationTracks()
		) do

			track:AdjustSpeed(1)

		end

	end

	------------------------------------------------
	-- Restore camera
	------------------------------------------------

	local camera =
		workspace.CurrentCamera

	if camera and OriginalFOV then

		camera.FieldOfView =
			OriginalFOV

	end

	Animator = nil
	OriginalFOV = nil

end

------------------------------------------------
-- Status
------------------------------------------------

function SlowMo:IsActive()

	return Active

end

return SlowMo