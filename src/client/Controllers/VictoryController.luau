local VictoryController = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local VictoryAnimations = require(
	Shared.Modules.VictoryAnimationsModule
)
local AnimsFolder = ReplicatedStorage.CinematicAnimations

local RunService = game:GetService("RunService")

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
local Remotes = Shared:WaitForChild("Remotes")

local function getRemote(name)

	return Remotes:WaitForChild(name)

end

local function GetAnimationFolder(poseName)
	local folder = AnimsFolder:FindFirstChild(poseName)

	if not folder then
		warn(("[VictoryController] Cinematic animation folder '%s' not found."):format(poseName))
		return nil
	end

	return folder
end


function VictoryController:Init()

	getRemote(RemoteIndex.PlayVictory)
		.OnClientEvent
		:Connect(function(data)
		self:Play(data)
	end)
	print("[VictoryManager] Initialized")
end



-- function animPlayer:PlayAnimation(char: Model)
	
-- 	-- Get animator and humanoidrootpart
	
-- 	local hum = char:FindFirstChildOfClass("Humanoid")
-- 	local animator = hum:FindFirstChildOfClass("Animator")
-- 	local hrp = char:FindFirstChild("HumanoidRootPart")
	
-- 	-- Make character unable to move
	
-- 	hum.WalkSpeed = 0
-- 	hum.JumpPower = 0
-- 	hum.AutoRotate = false
	
-- 	-- Gets the camera rig
	
-- 	local camRig = camRig:Clone()
-- 	local camPart = camRig:FindFirstChild("Cam")
-- 	local camHRP = camRig:FindFirstChild("HumanoidRootPart")
-- 	local animationController = camRig:FindFirstChildOfClass("AnimationController")
-- 	local camAnimator = animationController:FindFirstChildOfClass("Animator")
-- 	camRig.Parent = workspace
	
-- 	-- Load the tracks
	
-- 	local humTrack = animator:LoadAnimation(humAnim)
-- 	local camTrack = camAnimator:LoadAnimation(camAnim)
	
-- 	-- Positions the rig correctly
	
-- 	camRig:PivotTo(hrp.CFrame)
	
-- 	-- Weld the two humanoidRootParts together
	
-- 	local weld = Instance.new("WeldConstraint")
-- 	weld.Part0 = hrp
-- 	weld.Part1 = camHRP
-- 	weld.Parent = camHRP
	
-- 	-- Make player's camera follow the rig's camera
	
-- 	local cam = workspace.CurrentCamera
	
-- 	cam.CameraType = Enum.CameraType.Scriptable
	
-- 	local connection: RBXScriptConnection = runService.RenderStepped:Connect(function()

-- 		cam.CFrame = camPart.CFrame

-- 	end)
	
-- 	-- Play the tracks
	
-- 	humTrack:Play(0)
-- 	camTrack:Play(0)
	
-- 	-- Wait for the animation to end
	
-- 	task.wait(humTrack.Length)
	
-- 	-- Return everything to normal
	
-- 	camRig:Destroy()
	
-- 	connection:Disconnect()
	
-- 	cam.CameraType = Enum.CameraType.Custom
	
-- 	hum.WalkSpeed = 16
-- 	hum.JumpPower = 7.2
-- 	hum.AutoRotate = true

	
-- end
function VictoryController:PlayCutScene(model, poseName, options)
	options = options or {}

	local resetCameraAfter = options.ResetCamera ~= false
	local targetFov = options.FOV or 70
	-- Default the camera reset to true if not specified
    if resetCameraAfter == nil then
        resetCameraAfter = true
    end

		-- Get animator and humanoidrootpart
	
	local hum = model:FindFirstChildOfClass("Humanoid")
	local animator = hum:FindFirstChildOfClass("Animator")
	local hrp = model:FindFirstChild("HumanoidRootPart")
	
	-- Make character unable to move
	
	hum.WalkSpeed = 0
	hum.JumpPower = 0
	hum.AutoRotate = false

	
-- 	-- Gets the camera rig
	
	local animFolder = GetAnimationFolder(poseName)
	local humAnim = animFolder:WaitForChild("Hum")
	local camAnim = animFolder:WaitForChild("Cam")

	local camRig = AnimsFolder:WaitForChild("CameraRig")

	local camRig = camRig:Clone()
	local camPart = camRig:FindFirstChild("Cam")
	local camHRP = camRig:FindFirstChild("HumanoidRootPart")
	local animationController = camRig:FindFirstChildOfClass("AnimationController")
	local camAnimator = animationController:FindFirstChildOfClass("Animator")
	camRig.Parent = workspace

	
	-- Load the tracks
	
	local humTrack = animator:LoadAnimation(humAnim)
	local camTrack = camAnimator:LoadAnimation(camAnim)
	
	-- Positions the rig correctly
	
	camRig:PivotTo(hrp.CFrame)
	
	-- Weld the two humanoidRootParts together
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = camHRP
	weld.Parent = camHRP
	
	-- Make player's camera follow the rig's camera
	
	local cam = workspace.CurrentCamera
	
	cam.CameraType = Enum.CameraType.Scriptable
	local preFov = cam.FieldOfView
	
	-- Set initial CFrame
    local lastCameraCFrame = camPart.CFrame
    local camAnimFinished = false

    -- Detect when the camera animation completes
    local camStoppedConnection
	local humStoppedConnection

	camStoppedConnection = camTrack.Stopped:Connect(function()
		camAnimFinished = true
	end)

	humStoppedConnection = humTrack.Stopped:Connect(function()
	end)


	local connection: RBXScriptConnection = RunService.RenderStepped:Connect(function()
        -- Only update the target CFrame if the animation is still playing.
        -- This prevents the camera from snapping back when the rig resets.
        if camAnimFinished then
			cam.CFrame = lastCameraCFrame
			return
		end

	lastCameraCFrame = camPart.CFrame
	cam.CFrame = lastCameraCFrame
        cam.FieldOfView = targetFov
    end)

		-- Play the tracks
	humTrack:Play(0)
	camTrack:Play(0)

	-- Wait for the character animation
	humTrack.Stopped:Wait()


	-- Return everything to normal
	
	
	connection:Disconnect()
	camRig:Destroy()
	camStoppedConnection:Disconnect()
	humStoppedConnection:Disconnect()

-- Handle the final camera state based on the 'resetCameraAfter' parameter
    if resetCameraAfter then
        -- Return everything to normal (Player regains control)
        cam.CameraType = Enum.CameraType.Custom
        cam.FieldOfView = preFov
    else
        -- Leave the camera locked exactly where the animation ended
        cam.CameraType = Enum.CameraType.Custom
        cam.CFrame = lastCameraCFrame
        cam.FieldOfView = preFov
    end
	-- END CUSTSCENE
end

function VictoryController:PlayAnimation(model, poseName)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("[VictoryController] Humanoid not found.")
		return nil
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	local animationId = VictoryAnimations:GetAnimationId(poseName)

	
	if animationId == "rbxassetid://0" then
		warn(("[VictoryController] No animation found for pose '%s'"):format(poseName))
		return nil
	end
	
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId

	local track = animator:LoadAnimation(animation)

	track.Priority = Enum.AnimationPriority.Action
	track.Looped = true
	track:Play()

	return track
end



function VictoryController:Play(data)
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()

	local spawnPart = workspace.VictoryStage:WaitForChild("WinnerSpawn")

	-- Allow cloning
	character.Archivable = true
	local clone = character:Clone()
	character.Archivable = false

	clone.Name = "VictoryCharacter"

	for _, obj in ipairs(clone:GetDescendants()) do
		if obj:IsA("LocalScript")
			or obj:IsA("Script")
			or obj:IsA("Tool") then

			obj:Destroy()
		end
	end
local humanoid = clone:WaitForChild("Humanoid")
	local hrp = clone:WaitForChild("HumanoidRootPart")

	local head = clone:WaitForChild("Head")

	local template = ReplicatedStorage.UI:WaitForChild("VictoryNameTag")
	local tag = template:Clone()
	-- Ensure Winner is a string (Player instance -> use Name)
	local winnerName = (type(data.Winner) == "table" and data.Winner.Name) or tostring(data.Winner)
	tag.NameLabel.Text = winnerName ~= "nil" and winnerName or "OG PLAYER"
	tag.TitleLabel.Text = "MVP"

	tag.Parent = head

	-- Make it a display model
	humanoid.AutoRotate = false

	for _, part in ipairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
		end
	end

	clone.Parent = workspace

	-- Teleport after parenting
	local offset = humanoid.HipHeight + hrp.Size.Y / 2
	clone:PivotTo(spawnPart.CFrame * CFrame.new(0, offset, 0))

	-- One frame later, force it again
	task.wait()

	clone:PivotTo(spawnPart.CFrame * CFrame.new(0, offset, 0))

	----------------------------------------------------------------
	-- Play your victory animation here
	----------------------------------------------------------------

	local pose = data.Pose or "Default"

	-- local track = self:PlayAnimation(clone, pose)
	local track = self:PlayCutScene(clone, pose, {ResetCamera = false, FOV = 110})

	task.wait(5)

	if track then
		track:Stop()
	end

	if clone then
		clone:Destroy()
	end
end




return VictoryController