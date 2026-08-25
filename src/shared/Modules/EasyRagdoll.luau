---@module Easy Ragdoll by theonlyflare
---@updated Migrated to Avatar Joint Upgrade (AJU) system

--- Services ---
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--- Module ---
local RagdollModule = {}

--- Constants ---
-- Names of instances created by the ragdoll system, used for cleanup.
local RAGDOLL_INSTANCE_NAMES = {
	["RagdollAttachment"] = true,
	["RagdollConstraint"] = true,
	["ColliderPart"] = true, -- Keep this for cleanup in case old ragdolls had them
}

-- Attribute names used to store original AnimationConstraint values for restoration.
local ORIG_MAX_FORCE_ATTR = "_RagdollOrigMaxForce"
local ORIG_MAX_TORQUE_ATTR = "_RagdollOrigMaxTorque"

--- Helper Functions ---

--[[
	@param character: Model -- The character model to check.
	@return boolean -- True if the character has AnimationConstraints (AJU enabled).
	@brief Checks whether a character was spawned with the Avatar Joint Upgrade.
	If AJU is not enabled, a warning is raised with steps to enable it.
]]
local function checkForAJU(character: Model): boolean
	-- Look for any AnimationConstraint in the character hierarchy
	for _, descendant in pairs(character:GetDescendants()) do
		if descendant:IsA("AnimationConstraint") then
			return true
		end
	end

	-- AJU is not enabled, warn the developer with steps to enable it
	warn(
		[[
		[EasyRagdoll] Avatar Joint Upgrade (AJU) is NOT enabled. 
		
		This ragdoll module requires AJU to function.
		
		To enable AJU, follow these steps:
		
		1. Select 'StarterPlayer' in the Explorer.
		2. In the Properties panel, find 'AvatarJointUpgrade'.
		3. Set it to 'Enabled'.
		4. Playtest or publish your experience.
		
		For more info go to: https://devforum.roblox.com/t/4298561
		]]
	)
	return false
end

--[[
	@param character: Model -- The character model to set camera subject for.
	@param ragdolling: boolean -- True if entering ragdoll, false if exiting.
	@brief Switches the camera subject to the Head during ragdoll to prevent
	camera jitter from HumanoidRootPart spinning, and restores it on unragdoll.
]]
local function updateCameraSubject(character: Model, ragdolling: boolean)
	if not RunService:IsClient() then return end

	local camera = workspace.CurrentCamera
	if not camera then return end

	if ragdolling then
		-- Switch camera to follow the Head instead of the spinning HumanoidRootPart
		local head = character:FindFirstChild("Head")
		if head then
			camera.CameraSubject = head
		end
	else
		-- Restore camera to follow the Humanoid (default behavior)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			camera.CameraSubject = humanoid
		end
	end
end

--[[
	@param character: Model -- The character model to ragdoll.
	@param humanoid: Humanoid -- The humanoid object within the character.
	@brief Disables AnimationConstraints to enable ragdolling.
	With AJU, BallSocketConstraints are already present in the character,
	so we only need to weaken the AnimationConstraints to let physics take over.
]]
local function replaceJoints(character: Model, humanoid: Humanoid)
	-- Necessary for Ragdolling to function properly
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = true

	-- Disable the 'Animate' script to stop character animations
	local animateScript = character:FindFirstChild("Animate")
	if animateScript and animateScript:IsA("LocalScript") then
		animateScript.Enabled = false
	end

	-- Stop all playing animations on the humanoid's animator
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in animator:GetPlayingAnimationTracks() do
			track:Stop()
		end
	end

	-- Iterate through all descendants to find AnimationConstraints
	for _, constraint in pairs(character:GetDescendants()) do
		if constraint:IsA("AnimationConstraint") then
			-- Store original values as attributes so we can restore them later
			constraint:SetAttribute(ORIG_MAX_FORCE_ATTR, constraint.MaxForce)
			constraint:SetAttribute(ORIG_MAX_TORQUE_ATTR, constraint.MaxTorque)

			-- Disable kinematic mode so the joint becomes physics-driven
			constraint.IsKinematic = false

			-- Set force/torque to 0 so the character goes fully limp
			constraint.MaxForce = 0
			constraint.MaxTorque = 0
		end
	end

	humanoid.AutoRotate = false -- Disabling AutoRotate prevents the Character rotating in first person or Shift-Lock
	character:SetAttribute("LastRag", tick()) -- Used for anti-cheats to prevent flying Ragdolls from getting flagged
end

--[[
	@param character: Model -- The character model to unragdoll.
	@param humanoid: Humanoid -- The humanoid object within the character.
	@brief Restores AnimationConstraints to their original kinematic state,
	re-enabling normal character animation and movement.
]]
local function resetJoints(character: Model, humanoid: Humanoid)
	-- Do not unragdoll if the humanoid is dead
	if humanoid.Health < 1 then return end

	-- Snap the HumanoidRootPart back to the torso so the character gets up
	-- where they actually landed, not where the root part drifted to during ragdoll
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
	if rootPart and torso then
		rootPart.CFrame = torso.CFrame
	end

	for _, instance in pairs(character:GetDescendants()) do
		-- Restore AnimationConstraints to their original state
		if instance:IsA("AnimationConstraint") then
			instance.IsKinematic = true

			-- Restore original MaxForce and MaxTorque from saved attributes
			local origForce = instance:GetAttribute(ORIG_MAX_FORCE_ATTR)
			local origTorque = instance:GetAttribute(ORIG_MAX_TORQUE_ATTR)

			if origForce then
				instance.MaxForce = origForce
				instance:SetAttribute(ORIG_MAX_FORCE_ATTR, nil) -- Clean up the attribute
			end

			if origTorque then
				instance.MaxTorque = origTorque
				instance:SetAttribute(ORIG_MAX_TORQUE_ATTR, nil) -- Clean up the attribute
			end
		end

		-- Destroy any legacy ragdoll instances (cleanup for old ragdolls)
		if RAGDOLL_INSTANCE_NAMES[instance.Name] then
			instance:Destroy()
		end
	end

	humanoid.AutoRotate = true

	-- Re-enable the 'Animate' script
	local animateScript = character:FindFirstChild("Animate")
	if animateScript and animateScript:IsA("LocalScript") then
		animateScript.Enabled = true
	end
end

--[[
	@param character: Model -- The character model to push.
	@param magnitude: number -- The magnitude of the push to apply.
	@brief Applies an impulse to the character's HumanoidRootPart or Torso.
]]
local function applyPush(character: Model, magnitude: number)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart and rootPart:IsA("BasePart") then
		-- Apply impulse in the opposite direction of the character's forward vector
	
		rootPart:ApplyImpulse(rootPart.CFrame.LookVector * -magnitude)
	end
end

--- Module Functions ---

--[[
	@param character: Model -- The character model to apply or remove ragdoll from.
	@param value: boolean -- True to ragdoll, false to unragdoll.
	@param applyPushOnRagdoll: boolean? -- Optional: Whether to apply a push when ragdolling. Defaults to false.
	@param pushMagnitude: number? -- Optional: The magnitude of the push if applyPushOnRagdoll is true. Defaults to 100.
	@brief Toggles the ragdoll state of the given character, with an option to apply an extra push.
]]
function RagdollModule.SetRagdoll(character: Model, value: boolean, applyPushOnRagdoll: boolean?, pushMagnitude: number?)
	-- Validate inputs
	if not character then
		warn("RagdollModule.SetRagdoll: No character provided.")
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("RagdollModule.SetRagdoll: Character does not have a Humanoid.")
		return
	end

	-- Check that AJU is enabled on this character
	if not checkForAJU(character) then
		return
	end

	-- Set default optional parameters
	applyPushOnRagdoll = applyPushOnRagdoll or false
	pushMagnitude = pushMagnitude or 100

	if value then -- Ragdoll the character
		replaceJoints(character, humanoid)
		
		-- Fix camera so it follows the Head instead of the spinning HumanoidRootPart
		updateCameraSubject(character, true)
		
		--> Check to see if the module is being called from client/server
		if RunService:IsClient() then
			humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			
		elseif RunService:IsServer() then
			character.PrimaryPart:SetNetworkOwner(nil)
			
			humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		end

		-- Apply push only if explicitly requested
		if applyPushOnRagdoll then
			applyPush(character, pushMagnitude)
		end
	else -- Unragdoll the character
		resetJoints(character, humanoid)
		
		-- Restore camera to follow the Humanoid (default behavior)
		updateCameraSubject(character, false)
		
		if RunService:IsClient() then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			
		elseif RunService:IsServer() then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			
			-- Fix network ownership for players
			local player: Player? = Players:GetPlayerFromCharacter(character)
			if player then
				character.PrimaryPart:SetNetworkOwner(player)
			end
		end
	end
end

-- Return the module
return RagdollModule