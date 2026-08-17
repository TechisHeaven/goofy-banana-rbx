local SlowMo = {}

local Active = false
local CurrentToken = 0

local Animator
local OriginalFOV
local AnimationConnection
local AnimationLoop

local CurrentSpeed = 0.35

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
-- Apply Slow Motion
------------------------------------------------

local function ApplyAnimationSpeed()

	if not Active then
		return
	end

	if not Animator then
		return
	end

	for _, track in ipairs(
		Animator:GetPlayingAnimationTracks()
	) do

		if track.IsPlaying then

			track:AdjustSpeed(
				CurrentSpeed
			)

		end

	end

end

------------------------------------------------
-- Start
------------------------------------------------

function SlowMo:Start(options)

	options = options or {}

	local duration =
		options.Duration
		or DEFAULT_DURATION

	local speed =
		options.Speed
		or DEFAULT_SPEED

	local fov =
		options.FOV
		or DEFAULT_FOV

	CurrentToken += 1

	local token =
		CurrentToken

	------------------------------------------------
	-- Stop previous SlowMo
	------------------------------------------------

	if Active then
		self:Stop()
	end

	------------------------------------------------
	-- Animator
	------------------------------------------------

	Animator =
		GetAnimator()

	if not Animator then
		return
	end

	------------------------------------------------
	-- Camera
	------------------------------------------------

	local camera =
		workspace.CurrentCamera

	if not camera then
		return
	end

	OriginalFOV =
		camera.FieldOfView

	------------------------------------------------
	-- Settings
	------------------------------------------------

	CurrentSpeed =
		speed

	Active =
		true

	------------------------------------------------
	-- Immediately slow current animations
	------------------------------------------------

	ApplyAnimationSpeed()

	------------------------------------------------
	-- New animations
	------------------------------------------------

	AnimationConnection =
		Animator.AnimationPlayed:Connect(
			function(track)

				if not Active then
					return
				end

				track:AdjustSpeed(
					CurrentSpeed
				)

			end
		)

	------------------------------------------------
	-- Continuously enforce speed
	------------------------------------------------
	-- This handles animations that are
	-- replaced/restarted by Roblox animation
	-- controllers while SlowMo is active.

	AnimationLoop =
		task.spawn(function()

			while Active
				and token == CurrentToken do

				ApplyAnimationSpeed()

				task.wait(0.05)

			end

		end)

	------------------------------------------------
	-- Camera
	------------------------------------------------

	camera.FieldOfView =
		fov

	------------------------------------------------
	-- Automatic stop
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

	Active =
		false

	------------------------------------------------
	-- Disconnect animation listener
	------------------------------------------------

	if AnimationConnection then

		AnimationConnection:Disconnect()

		AnimationConnection =
			nil

	end

	------------------------------------------------
	-- Stop animation loop
	------------------------------------------------

	AnimationLoop =
		nil

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

	if camera
		and OriginalFOV then

		camera.FieldOfView =
			OriginalFOV

	end

	------------------------------------------------
	-- Clear
	------------------------------------------------

	Animator =
		nil

	OriginalFOV =
		nil

	CurrentSpeed =
		DEFAULT_SPEED

end

------------------------------------------------
-- Status
------------------------------------------------

function SlowMo:IsActive()

	return Active

end

return SlowMo