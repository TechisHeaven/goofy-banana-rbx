local CinematicController = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

local RunService =
	game:GetService("RunService")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- SHARED
------------------------------------------------

local CinematicAnimations =
	ReplicatedStorage:WaitForChild(
		"CinematicAnimations"
	)

------------------------------------------------
-- PLAY CUTSCENE
------------------------------------------------

function CinematicController:Play(
	model,
	folderName,
	options
)

	options = options or {}

	local resetCamera =
		options.ResetCamera ~= false

	local targetFOV =
		options.FOV or 70

	------------------------------------------------
	-- CHARACTER
	------------------------------------------------

	local humanoid =
		model:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		warn(
			"[CinematicController] Humanoid not found"
		)

		return nil
	end

	local animator =
		humanoid:FindFirstChildOfClass("Animator")

	if not animator then

		animator =
			Instance.new("Animator")

		animator.Parent =
			humanoid

	end

	local hrp =
		model:FindFirstChild("HumanoidRootPart")

	if not hrp then
		warn(
			"[CinematicController] HumanoidRootPart not found"
		)

		return nil
	end

	------------------------------------------------
	-- ANIMATION FOLDER
	------------------------------------------------

	local folder =
		CinematicAnimations:FindFirstChild(
			folderName
		)

	if not folder then

		warn(
			"[CinematicController] Animation folder not found:",
			folderName
		)

		return nil
	end

	local humAnim =
		folder:FindFirstChild("Hum")

	local camAnim =
		folder:FindFirstChild("Cam")

	if not humAnim or not camAnim then

		warn(
			"[CinematicController] Hum/Cam animation missing:",
			folderName
		)

		return nil
	end

	------------------------------------------------
	-- SAVE CHARACTER MOVEMENT
	------------------------------------------------

	local oldWalkSpeed =
		humanoid.WalkSpeed

	local oldJumpPower =
		humanoid.JumpPower

	local oldAutoRotate =
		humanoid.AutoRotate

	------------------------------------------------
	-- LOCK CHARACTER
	------------------------------------------------

	local lockCharacter =
	options.LockCharacter == true

	if lockCharacter then
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.AutoRotate = false

		-- Prevent player movement from affecting the cinematic.
		humanoid:SetStateEnabled(
			Enum.HumanoidStateType.Jumping,
			false
		)

		humanoid:SetStateEnabled(
			Enum.HumanoidStateType.Running,
			false
		)

		humanoid:SetStateEnabled(
			Enum.HumanoidStateType.Climbing,
			false
		)

		humanoid:SetStateEnabled(
			Enum.HumanoidStateType.Swimming,
			false
		)
	end

	------------------------------------------------
	-- CAMERA
	------------------------------------------------

	local camera =
		workspace.CurrentCamera

	-- Save the exact camera state before cinematic

	local oldCameraType =
		camera.CameraType

	local oldCameraCFrame =
		camera.CFrame

	local oldCameraFocus =
		camera.Focus

	local oldFOV =
		camera.FieldOfView

	------------------------------------------------
	-- CAMERA RIG
	------------------------------------------------

	local cameraRig =
		CinematicAnimations:WaitForChild(
			"CameraRig"
		):Clone()

	local cameraPart =
		cameraRig:FindFirstChild("Cam")

	local cameraHRP =
		cameraRig:FindFirstChild(
			"HumanoidRootPart"
		)

	local animationController =
		cameraRig:FindFirstChildOfClass(
			"AnimationController"
		)

	if not cameraPart
		or not cameraHRP
		or not animationController then

		warn(
			"[CinematicController] Invalid CameraRig"
		)

		cameraRig:Destroy()

		-- Restore character

		if lockCharacter
			and humanoid
			and humanoid.Parent then

			humanoid.WalkSpeed =
				oldWalkSpeed

			humanoid.JumpPower =
				oldJumpPower

			humanoid.AutoRotate =
				oldAutoRotate
		end
		return nil
	end

	------------------------------------------------
	-- CAMERA ANIMATOR
	------------------------------------------------

	local cameraAnimator =
		animationController:FindFirstChildOfClass(
			"Animator"
		)

	if not cameraAnimator then

		cameraAnimator =
			Instance.new("Animator")

		cameraAnimator.Parent =
			animationController

	end

	cameraRig.Parent =
		workspace

	------------------------------------------------
	-- POSITION CAMERA RIG
	------------------------------------------------

	cameraRig:PivotTo(
		hrp.CFrame
	)

	------------------------------------------------
	-- WELD CAMERA TO CHARACTER
	------------------------------------------------

	local weld =
		Instance.new("WeldConstraint")

	weld.Part0 =
		hrp

	weld.Part1 =
		cameraHRP

	weld.Parent =
		cameraHRP

	------------------------------------------------
	-- LOAD ANIMATIONS
	------------------------------------------------

	local humTrack =
		animator:LoadAnimation(
			humAnim
		)

	local camTrack =
		cameraAnimator:LoadAnimation(
			camAnim
		)

	humTrack.Priority =
		Enum.AnimationPriority.Action

	camTrack.Priority =
		Enum.AnimationPriority.Action

	humTrack.Looped =
		false

	camTrack.Looped =
		false

	------------------------------------------------
	-- CAMERA STATE
	------------------------------------------------

	local lastCameraCFrame =
		cameraPart.CFrame

	local cameraFinished =
		false

	local cleanedUp =
		false

	------------------------------------------------
	-- RENDER CAMERA
	------------------------------------------------

	camera.CameraType =
		Enum.CameraType.Scriptable

	camera.FieldOfView =
		targetFOV

	------------------------------------------------
	-- CAMERA UPDATE
	------------------------------------------------

	local renderConnection

	renderConnection =
		RunService.RenderStepped:Connect(
			function()

				-- Stop forcing the camera once
				-- the camera animation finishes.

				if cameraFinished then
					return
				end

				if not cameraPart
					or not cameraPart.Parent then

					return
				end

				lastCameraCFrame =
					cameraPart.CFrame

				camera.CFrame =
					lastCameraCFrame

				camera.FieldOfView =
					targetFOV

			end
		)

	------------------------------------------------
	-- CAMERA ANIMATION FINISHED
	------------------------------------------------

	local camStoppedConnection

	camStoppedConnection =
		camTrack.Stopped:Connect(
			function()

				cameraFinished =
					true

			end
		)

	------------------------------------------------
	-- START ANIMATIONS
	------------------------------------------------

	humTrack:Play(0)
	camTrack:Play(0)

	------------------------------------------------
	-- CLEANUP
	------------------------------------------------

	local function Cleanup()

		if cleanedUp then
			return
		end

		cleanedUp =
			true

		------------------------------------------------
		-- RESTORE CAMERA
		------------------------------------------------

		if resetCamera then

			-- First restore the camera mode

			camera.CameraType =
				Enum.CameraType.Custom

			-- Restore FOV

			camera.FieldOfView =
				oldFOV

			-- Restore exact previous camera position

			camera.CFrame =
				oldCameraCFrame

			camera.Focus =
				oldCameraFocus

		else

			-- Restore whatever camera mode
			-- existed before the cinematic

			camera.CameraType =
				oldCameraType

			camera.FieldOfView =
				oldFOV

			camera.CFrame =
				lastCameraCFrame

		end
		------------------------------------------------
		-- Stop camera updates FIRST
		------------------------------------------------

		if renderConnection then

			renderConnection:Disconnect()

			renderConnection =
				nil

		end

		------------------------------------------------
		-- Disconnect camera event
		------------------------------------------------

		if camStoppedConnection then

			camStoppedConnection:Disconnect()

			camStoppedConnection =
				nil

		end

		------------------------------------------------
		-- Stop animations
		------------------------------------------------

		if humTrack then

			humTrack:Stop(0)

		end

		if camTrack then

			camTrack:Stop(0)

		end

		------------------------------------------------
		-- Destroy camera rig
		------------------------------------------------

		if cameraRig then

			cameraRig:Destroy()

			cameraRig =
				nil

		end


		------------------------------------------------
		-- RESTORE CHARACTER
		------------------------------------------------

		if lockCharacter
			and humanoid
			and humanoid.Parent then

			humanoid.WalkSpeed = oldWalkSpeed
			humanoid.JumpPower = oldJumpPower
			humanoid.AutoRotate = oldAutoRotate

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Jumping,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Running,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Climbing,
				true
			)

			humanoid:SetStateEnabled(
				Enum.HumanoidStateType.Swimming,
				true
			)
		end

	end

	------------------------------------------------
	-- RETURN
	------------------------------------------------

	return {

		Humanoid =
			humanoid,

		HumTrack =
			humTrack,

		CamTrack =
			camTrack,

		CameraRig =
			cameraRig,

		Cleanup =
			Cleanup,

		GetCameraCFrame =
			function()

				return lastCameraCFrame

			end,

	}

end

return CinematicController