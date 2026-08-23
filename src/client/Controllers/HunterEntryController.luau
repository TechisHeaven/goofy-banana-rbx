local HunterEntryController = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

local Players =
	game:GetService("Players")

local player = Players.LocalPlayer
local ReplicatedStorage =
	game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.Shared

local camera = workspace.CurrentCamera
local RemoteIndexData =
	require(
		Shared.Remotes.RemoteIndex
	)

local RemoteIndex =
	RemoteIndexData.Events

local Remotes =
	Shared:WaitForChild("Remotes")
	
local VFXFolder =
	ReplicatedStorage
		:WaitForChild("VFX")
		:WaitForChild("HunterEntry")

local LandSmoke =
	VFXFolder:WaitForChild("ToonSmoke")

local PunchLightning =
	VFXFolder:WaitForChild("ToonLightning")

local VFXUtils = require(Shared.Utils.VFXUtil)

local PlayerGui = player.PlayerGui
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "ImpactFrameGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
 
local flash = Instance.new("Frame", screenGui)
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
------------------------------------------------
-- REMOTE
------------------------------------------------

local HunterEntry =
	Remotes:WaitForChild(
		RemoteIndex.HunterEntry
	)



local LAND_SOUND_ID =
	"rbxassetid://85818610620233"

local PUNCH_SOUND_ID =
	"rbxassetid://85818610620233"

local Debris =
	game:GetService("Debris")

------------------------------------------------
-- SHARED
------------------------------------------------

local CinematicController =
	require(
		Shared.Modules.CinematicController
	)

local SoundUtils = require(Shared.Utils.SoundUtils)
local PunchImpact =
	require(
		Shared.Modules.PunchImpact
	)
------------------------------------------------
-- PLAYER
------------------------------------------------

local LocalPlayer =
	Players.LocalPlayer

------------------------------------------------
-- CONFIG
------------------------------------------------

local ANIMATION_NAME =
	"HunterEntry2"

local IMPACT_LIFETIME =
	3

------------------------------------------------
-- STATE
------------------------------------------------

local Playing = false
local CurrentCinematic = nil
local EffectConnection = nil

local function GetGroundPosition(character)

	local hrp = character:FindFirstChild("HumanoidRootPart")

	if not hrp then
		return nil
	end

	local params = RaycastParams.new()

	params.FilterDescendantsInstances = {
		character
	}

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	params.RespectCanCollide = true

	------------------------------------------------
	-- Raycast straight down from the character
	------------------------------------------------

	local result = workspace:Raycast(
		hrp.Position,
		Vector3.new(0, -1000, 0),
		params
	)

	if not result then
		warn("[HunterEntry] No ground detected")
		return nil
	end

	return result.Position, result.Normal
end

local function ScreenShake(intensity, duration, frequency)
    intensity = intensity or 1.2
    duration = duration or 0.45
    frequency = frequency or 0.016
    
    local elapsed = 0
    local conn
    
    conn = RunService.RenderStepped:Connect(function(dt)
        elapsed += dt
        if elapsed >= duration then
            conn:Disconnect()
            camera.CFrame = camera.CFrame -- subtle reset
        end
        
        -- Intensity decreases over time (ease-out)
        local t = 1 - (elapsed/duration)
        local strength = intensity * t * t
        
        local offset = CFrame.new(
            math.random(-100, 100) / 100 * strength,
            math.random(-100, 100) / 100 * strength,
            0
        ) * CFrame.Angles(
            math.rad(math.random(-100, 100) / 100 * strength * 0.5),
            math.rad(math.random(-100, 100) / 100 * strength * 0.5),
            0
        )
        
        camera.CFrame = camera.CFrame * offset
        task.wait(frequency)
    end)
end



local function CreateLandEffect(character)

	local hrp = character:FindFirstChild("HumanoidRootPart")

	if not hrp then
		return
	end

	local groundPosition, groundNormal =
		GetGroundPosition(character)

	if not groundPosition then
		return
	end

	------------------------------------------------
	-- DEBUG
	------------------------------------------------

	print(
		"[HunterEntry] Ground:",
		groundPosition,
		"Normal:",
		groundNormal
	)
	------------------------------------------------
	-- SHOCKWAVE
	------------------------------------------------
	local thickness = 0.08

	local shockwave =
		Instance.new("Part")

	shockwave.Name =
		"HunterLandImpact"

	shockwave.Shape =
		Enum.PartType.Cylinder

	-- IMPORTANT:
	-- Cylinder axis is local X.
	-- Rotate it so the cylinder lies flat.
	-- shockwave.CFrame =
	-- 	CFrame.new(impactPosition)
	-- 	* CFrame.Angles(
	-- 		0,
	-- 		0,
	-- 		math.rad(90)
	-- 	)
	
	-- Debris:AddItem(marker, 5)
	shockwave.Size =
		Vector3.new(
			thickness,
			2,
			2
		)
	shockwave.Material =
		Enum.Material.Neon

	shockwave.Transparency =
		0.15

	shockwave.Anchored =
		true

	shockwave.CanCollide =
		false

	shockwave.CanTouch =
		false

	shockwave.CanQuery =
		false

	------------------------------------------------
	-- IMPORTANT:
	-- Put the CENTER slightly below the ground.
	-- The top surface remains at ground level.
	------------------------------------------------

	local impactPosition =
		groundPosition
		- groundNormal * (thickness * 0.45)

	------------------------------------------------
	-- Align cylinder to ground normal
	------------------------------------------------

	local right =
		groundNormal

	local forward =
		right:Cross(Vector3.yAxis)

	if forward.Magnitude < 0.01 then
		forward =
			right:Cross(Vector3.xAxis)
	end

	forward =
		forward.Unit

	local up =
		forward:Cross(right).Unit

	shockwave.CFrame =
		CFrame.fromMatrix(
			impactPosition,
			right,
			up
		)
	shockwave.Parent =
		workspace

	------------------------------------------------
	-- EXPAND
	------------------------------------------------

	local tween =
		TweenService:Create(
			shockwave,

			TweenInfo.new(
				0.35,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),

			{
				Size = Vector3.new(
					thickness,
					8,
					8
				),

				Transparency = 1
			}
		)

	tween:Play()

	------------------------------------------------
	-- CLEANUP
	------------------------------------------------

	Debris:AddItem(
		shockwave,
		0.4
	)

	------------------------------------------------
	-- LANDING SOUND
	------------------------------------------------

	SoundUtils:PlaySound(
		LAND_SOUND_ID,
		character,
		0.8
	)

end
local CFG = {
    -- Configs
    waveCount     = 15,
    waveSpacing   = 3,
    riseTime      = 0.145,
    spreadDelay   = 0.045,
    lifeTime      = 3
}

local function spawnGroundWave(impactPos, impactNorm, lookVec)
    -- Main Direction
    local dir = Vector3.new(lookVec.X, 0, lookVec.Z) -- we just want X and Z
    
    if dir.Magnitude < 0.01 then -- dir ~ 0 would cause some problems
        dir = Vector3.new(0, 0, -1)
    end
    
    dir = dir.Unit -- Normalize vector (we only keep direction, not distance)
    
    -- Perpendicular Real Vector
    local right = dir:Cross(Vector3.yAxis).Unit
    
    local rockColor = Color3.fromRGB(88, 90, 98)
    
    for i = 1, CFG.waveCount do
        
        task.delay((i-1) * CFG.spreadDelay, function() -- delay between every rock
            
            -- Center of every rock pair (remember, we are working with two sides)
            local centerPos = impactPos + (dir * (i * CFG.waveSpacing)) -- the wave advances as "i" increases
            
            -- Variation (rndm)
            local width = math.random(22, 35) / 10
            local height = math.random(8, 17) / 10
            local depth  = math.random(22, 35) / 10
            local crackWidth = math.random(3, 9) / 10
            
            -- Real World Separation
            -- It depends on the size of the rock and the width of the crack
            local lateralDistance = (width * 0.5) + crackWidth
            local leftWorldPos = centerPos - (right * lateralDistance)
            local rightWorldPos = centerPos + (right * lateralDistance)
            
            -- Buried (the we just tween them out of the floor)
            leftWorldPos += Vector3.new(0, -height, 0)
            rightWorldPos += Vector3.new(0, -height, 0)
            
            -- Parts
            
            local leftRock = Instance.new("Part")
            leftRock.Anchored = true
            leftRock.CanCollide = false
            leftRock.Material = Enum.Material.Plastic
            leftRock.MaterialVariant = "Studs"
            leftRock.Color = rockColor
            leftRock.Size = Vector3.new(width, height, depth)
            leftRock.Parent = workspace
            
            local rightRock = leftRock:Clone()
            rightRock.Parent = workspace
            
            -- Base orientation
            local leftCF = CFrame.lookAt(leftWorldPos, leftWorldPos + dir)
            local rightCF = CFrame.lookAt(rightWorldPos, rightWorldPos + dir)
            
            -- Very IMPORTANT:
            -- Roll to the CENTER (gives every rock a subtle inclination to the center)
            local leftRoll = CFrame.Angles(0, 0, math.rad(12 + math.random() * 8))
            local rightRoll = CFrame.Angles(0, 0, math.rad(-12 - math.random() * 8))
            
            -- Applying CFrame to the rocks
            leftRock.CFrame = leftCF * leftRoll
            rightRock.CFrame = rightCF * rightRoll
            
            -- Goal Pos
            local leftGoal = (leftCF * leftRoll) + Vector3.new(0, height, 0)
            local rightGoal = (rightCF * rightRoll) + Vector3.new(0, height, 0)
            
            -- RISE TWEEN
            local riseTweenInfo = TweenInfo.new(CFG.riseTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            -- Tweening left side
            TweenService:Create(leftRock, riseTweenInfo, {CFrame = leftGoal}):Play()
            
            -- Right
            TweenService:Create(rightRock, riseTweenInfo, {CFrame = rightGoal}):Play()
            
            -- Fade Out
            task.delay(CFG.lifeTime, function()
                
                local shrinkInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                
                -- Bringing the rocks underground
                local leftDown = leftGoal * CFrame.new(0, -height, 0)
                local rightDown = rightGoal * CFrame.new(0, -height, 0)
                
                local tween1 = TweenService:Create(
                    leftRock,
                    shrinkInfo,
                    {
                        Size = Vector3.new(width, 0.05, depth),
                        CFrame = leftDown
                    }
                )
                
                local tween2 = TweenService:Create(
                    rightRock,
                    shrinkInfo,
                    {
                        Size = Vector3.new(width, 0.05, depth),
                        CFrame = rightDown
                    }
                )
                
                tween1:Play()
                tween2:Play()
                
                -- Destroy when tween completed
                
                tween1.Completed:Connect(function()
                    leftRock:Destroy()
                end)
                
                tween2.Completed:Connect(function()
                    rightRock:Destroy()
                end)
            end)
        end)
    end
end

local function ImpactFrame(duration)
    duration = duration or 0.08
    
    -- Flash in
    flash.BackgroundTransparency = .2
    
    -- Flash out
    local tween = TweenService:Create(
        flash,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    
    tween:Play()
end

local function ImpactFrameStyled(duration)
    
    local cc = game.Lighting:FindFirstChild("ImpactFrame") or Instance.new("ColorCorrectionEffect", game.Lighting)
    cc.Name = "ImpactFrame"
    
    cc.Saturation = -1.1
    cc.Contrast = 5
    cc.Brightness = 1
    
    task.delay(duration or 0.07, function()
        
        local t = TweenService:Create(cc, TweenInfo.new(0.045), {
            Saturation = 0, Contrast = 0, Brightness = 0
        })
        t:Play()
    end)
end
 
------------------------------------------------
-- IMPACT
------------------------------------------------
local function PlayEffect(
	character,
	parameter
)
	local groundPosition, groundNormal =
			GetGroundPosition(character)
	if parameter == "land" then
        
		task.wait(.04)
		CreateLandEffect(character)
		VFXUtils:PlayVFX(
			LandSmoke,
			groundPosition
		)

	elseif parameter == "punch" then
    	ScreenShake(1.2, 0.45, 0.016)
		ImpactFrameStyled(.06)
        task.wait(.08)
        ImpactFrame(.3)
        SoundUtils:PlaySound(
            PUNCH_SOUND_ID,
            character,
            1
        )
		
		if groundPosition then

			local hrp =
				character:FindFirstChild(
					"HumanoidRootPart"
				)
			
			if hrp then
				VFXUtils:PlayVFX(
					PunchLightning,
					hrp.Position,
					1
				)
				spawnGroundWave(
					groundPosition,
					groundNormal,
					hrp.CFrame.LookVector
				)

			end
		end
			PunchImpact:CreateFromCharacter(
				character
			)
		else

		warn(
			"[HunterEntryController] Unknown effect:",
			parameter
		)

	end

end

------------------------------------------------
-- PLAY
------------------------------------------------

function HunterEntryController:Play(
	hunter
)

	if Playing then
		return
	end

	if not hunter then
		return
	end

	if not hunter.Parent then
		return
	end

	Playing = true

	local character =
		hunter.Character

	if not character then

		Playing = false

		return

	end

	------------------------------------------------
	-- Cinematic
	------------------------------------------------

	CurrentCinematic =
		CinematicController:Play(
			character,
			ANIMATION_NAME,
			{
				ResetCamera = true,
				FOV = 90,
			}
		)

	if not CurrentCinematic then

		Playing = false

		return

	end

	------------------------------------------------
	-- Animation events
	------------------------------------------------

	EffectConnection =
		CurrentCinematic.HumTrack
			:GetMarkerReachedSignal(
				"Impact"
			)
			:Connect(
				function(parameter)
                    
					PlayEffect(
						character,
						parameter
					)

				end
			)

	------------------------------------------------
	-- Wait for animation
	------------------------------------------------

	CurrentCinematic.HumTrack.Stopped:Wait()
	task.wait(2)
	------------------------------------------------
	-- Cleanup
	------------------------------------------------

	if EffectConnection then

		EffectConnection:Disconnect()
		EffectConnection = nil

	end

	if CurrentCinematic then
		CurrentCinematic:Cleanup()
		CurrentCinematic = nil

	end

	Playing = false

end

------------------------------------------------
-- STOP
------------------------------------------------

function HunterEntryController:Stop()

	if EffectConnection then

		EffectConnection:Disconnect()

		EffectConnection = nil

	end

	if CurrentCinematic then

		CurrentCinematic:Cleanup()

		CurrentCinematic = nil

	end

	Playing = false

end

------------------------------------------------
-- INIT
------------------------------------------------

function HunterEntryController:Init()
	HunterEntry.OnClientEvent:Connect(
		function(hunter)
			self:Play(hunter)
		end
	)
	print(
		"[HunterEntryController] Initialized"
	)

end

return HunterEntryController