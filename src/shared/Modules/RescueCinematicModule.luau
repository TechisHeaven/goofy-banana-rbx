local RescueCinematicController = {}
local ContentProvider =
	game:GetService("ContentProvider")
------------------------------------------------
-- SERVICES
------------------------------------------------

local RunService =
	game:GetService("RunService")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- FOLDERS
------------------------------------------------

local RescueAnimations =
	ReplicatedStorage:WaitForChild(
		"RescueAnimations"
	)
local AnimationEffectManager =
	require(
		ReplicatedStorage.Shared.Modules.AnimationEffectManager
	)
------------------------------------------------
-- PLAY
------------------------------------------------

function RescueCinematicController:Play(
	character,
	effectName,
	options
)

	options = options or {}

	local resetCamera =
		options.ResetCamera == true

	local targetFOV =
		options.FOV or 70


	if not character then
		return nil
	end
	print(effectName)

	effectName =
		effectName or "DefaultPunch"
	------------------------------------------------
	-- EFFECT FOLDER
	------------------------------------------------

	local effectFolder =
		RescueAnimations:FindFirstChild(
			effectName
		)

	if not effectFolder then

		warn(
			"[RescueCinematicController] Effect not found:",
			effectName
		)

		return nil
	end

	------------------------------------------------
	-- CHARACTER
	------------------------------------------------

	local humanoid =
		character:FindFirstChildOfClass(
			"Humanoid"
		)

	if not humanoid then

		warn(
			"[RescueCinematicController] Humanoid not found"
		)

		return nil
	end

	local animator =
		humanoid:FindFirstChildOfClass(
			"Animator"
		)

	if not animator then

		animator =
			Instance.new("Animator")

		animator.Parent =
			humanoid

	end

	------------------------------------------------
	-- ANIMATION
	------------------------------------------------

	local animation =
		effectFolder:FindFirstChild(
			"Animation"
		)

	if not animation then

		warn(
			"[RescueCinematicController] Animation missing:",
			effectName
		)

		return nil
	end

	------------------------------------------------
	-- CAMERA ANIMATION
	------------------------------------------------

	local cameraAnimation =
		effectFolder:FindFirstChild(
			"Cam"
		)
	if not cameraAnimation then

		warn(
			"[RescueCinematicController] Cam missing:",
			effectName
		)

		return nil
	end

	------------------------------------------------
	-- CAMERA RIG
	------------------------------------------------

	local cameraRigTemplate =
		RescueAnimations:FindFirstChild(
			"CameraRig"
		)

	if not cameraRigTemplate then

		warn(
			"[RescueCinematicController] CameraRig missing"
		)

		return nil
	end

	local cameraRig =
		cameraRigTemplate:Clone()

	local cameraPart =
		cameraRig:FindFirstChild(
			"Cam"
		)

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
			"[RescueCinematicController] Invalid CameraRig"
		)

		cameraRig:Destroy()

		return nil
	end

	------------------------------------------------
	-- CAMERA ANIMATOR
	------------------------------------------------

	-- local cameraAnimator =
	-- 	animationController:FindFirstChildOfClass(
	-- 		"Animator"
	-- 	)

	-- if not cameraAnimator then

	-- 	cameraAnimator =
	-- 		Instance.new("Animator")

	-- 	cameraAnimator.Parent =
	-- 		animationController

	-- end

	------------------------------------------------
	-- LOAD TRACKS
	------------------------------------------------

	local characterTrack =
		animator:LoadAnimation(
			animation
		)
	------------------------------------------------
	-- BIND RESCUE VFX / SOUNDS
	------------------------------------------------

	local vfxBinding =
		AnimationEffectManager:Bind(
			character,
			characterTrack,
			effectFolder
		)
    -- ------------------------------------------------
    -- -- PRELOAD CAMERA ANIMATION
    -- ------------------------------------------------
	characterTrack.Priority =
		Enum.AnimationPriority.Action

	-- cameraTrack.Priority =
	-- 	Enum.AnimationPriority.Action

	characterTrack.Looped =
		false

	-- cameraTrack.Looped =
	-- 	false

	------------------------------------------------
	-- POSITION CAMERA RIG
	------------------------------------------------

	local hrp =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not hrp then

		cameraRig:Destroy()

		return nil
	end
	characterTrack:Play(0)

    cameraRig:PivotTo(
        hrp.CFrame
    )
	------------------------------------------------
-- WELD CAMERA RIG
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
-- IMPORTANT
-- PUT RIG IN WORKSPACE BEFORE LOADANIMATION
------------------------------------------------

cameraRig.Parent =
	workspace

------------------------------------------------
-- NOW LOAD CAMERA ANIMATOR
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

local cameraTrack =
	cameraAnimator:LoadAnimation(
		cameraAnimation
	)
	------------------------------------------------
	-- CAMERA
	------------------------------------------------

	local camera =
		workspace.CurrentCamera

	local oldCameraType =
		camera.CameraType

	local oldCameraCFrame =
		camera.CFrame

	
	local cameraFinished =
		false

	local cleanedUp =
		false


	local oldCameraFocus =
		camera.Focus

	local oldFOV =
		camera.FieldOfView
	camera.FieldOfView = targetFOV
	camera.CameraType =
		Enum.CameraType.Scriptable

	------------------------------------------------
	-- CAMERA UPDATE
	------------------------------------------------

	local renderConnection

	renderConnection =
		RunService.RenderStepped:Connect(
			function()
				
			if cameraFinished then
				return
			end

			if not cameraPart
				or not cameraPart.Parent then
				return
			end


			oldCameraCFrame =
				cameraPart.CFrame

			camera.CFrame =
				oldCameraCFrame

			camera.FieldOfView =
				targetFOV
			end
		)
	------------------------------------------------
	-- CAMERA ANIMATION FINISHED
	------------------------------------------------

	local camStoppedConnection

	camStoppedConnection =
		cameraTrack.Stopped:Connect(
			function()

				cameraFinished =
					true

			end
		)
	------------------------------------------------
	-- PLAY
	------------------------------------------------

	cameraTrack:Play(0)


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
		-- STOP CAMERA UPDATE
		------------------------------------------------

		if renderConnection then

			renderConnection:Disconnect()

			renderConnection =
				nil

		end
		------------------------------------------------
		-- DISCONNECT CAMERA FINISHED
		------------------------------------------------

		if camStoppedConnection then

			camStoppedConnection:Disconnect()

			camStoppedConnection =
				nil

		end
		------------------------------------------------
		-- STOP TRACKS
		------------------------------------------------

		if characterTrack then
			characterTrack:Stop(0)
		end

		if cameraTrack then
			cameraTrack:Stop(0)
		end
		if resetCamera then

			------------------------------------------------
			-- Full reset
			------------------------------------------------

			camera.CameraType =
				Enum.CameraType.Custom

			camera.FieldOfView =
				oldFOV

			camera.CFrame =
				oldCameraCFrame

			camera.Focus =
				oldCameraFocus

		else

			------------------------------------------------
			-- Keep cinematic camera position
			-- but return control to Roblox camera
			------------------------------------------------

			camera.CameraType =
				Enum.CameraType.Custom

			camera.FieldOfView =
				oldFOV

			camera.CFrame =
				oldCameraCFrame

		end
			------------------------------------------------
			-- DESTROY CAMERA RIG
			------------------------------------------------

			if cameraRig then

				cameraRig:Destroy()

				cameraRig =
					nil

			end

		
	end

	------------------------------------------------
	-- RETURN CONTROLLER
	------------------------------------------------

	return {

		CharacterTrack =
			characterTrack,

		CameraTrack =
			cameraTrack,

		Cleanup =
			Cleanup,

	}

end

return RescueCinematicController