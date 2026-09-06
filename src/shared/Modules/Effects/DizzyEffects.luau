local DizzyEffect = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ImpactSlip =
	ReplicatedStorage
		:WaitForChild("Sounds")
		:WaitForChild("ImpactSlip")
local player = Players.LocalPlayer

local active = false

local colorEffect
local blurEffect
local screenGui

local stars = {}

------------------------------------------------
-- CONFIG
------------------------------------------------

local STAR_TEXTURE = "rbxassetid://76576766325651"

-- How many stars are active at once
local STAR_COUNT = 10

------------------------------------------------
-- STAR SIZE
------------------------------------------------

-- BIG when they appear
local STAR_START_MIN_SIZE = 60
local STAR_START_MAX_SIZE = 140

-- SMALL when they reach the center
local STAR_END_MIN_SIZE = 5
local STAR_END_MAX_SIZE = 25

------------------------------------------------
-- STAR SPEED
------------------------------------------------

local STAR_TRAVEL_TIME_MIN = 0.8
local STAR_TRAVEL_TIME_MAX = 1.2


-- Short movement distance
local STAR_MOVE_MIN = 0.08
local STAR_MOVE_MAX = 0.28

-- Chance that a new star appears near another star
local OVERLAP_CHANCE = 0.35


local function playImpactSound()

	if not ImpactSlip then
		return
	end

	local sound = ImpactSlip:Clone()

	sound.Parent = player:WaitForChild("PlayerGui")

	sound:Play()

	sound.Ended:Once(function()
		sound:Destroy()
	end)

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

------------------------------------------------
-- CREATE RANDOM FLOATING STAR
------------------------------------------------

local function createStar()

	if not active or not screenGui then
		return
	end

	------------------------------------------------
	-- CREATE STAR
	------------------------------------------------

	local star = Instance.new("ImageLabel")

	star.Name = "DizzyStar"

	star.BackgroundTransparency = 1

	star.Image = STAR_TEXTURE

	star.ImageColor3 = Color3.new(1, 1, 1)

	star.ImageTransparency =
		math.random(25, 55) / 100

	star.AnchorPoint =
		Vector2.new(0.5, 0.5)

	star.ScaleType =
		Enum.ScaleType.Fit

	star.ZIndex = 10

	------------------------------------------------
	-- BIG START SIZE
	------------------------------------------------

	local startSize =
		math.random(
			STAR_START_MIN_SIZE,
			STAR_START_MAX_SIZE
		)

	star.Size =
		UDim2.fromOffset(
			startSize,
			startSize
		)

	------------------------------------------------
	-- RANDOM START POSITION
	------------------------------------------------

	local startX
	local startY

	------------------------------------------------
	-- SOMETIMES OVERLAP ANOTHER STAR
	------------------------------------------------

	if #stars > 0 and math.random() < OVERLAP_CHANCE then

		local otherStar =
			stars[
				math.random(
					1,
					#stars
				)
			]

		if otherStar and otherStar.Parent then

			local otherPosition =
				otherStar.Position

			startX =
				otherPosition.X.Scale +
				math.random(-12, 12) / 100

			startY =
				otherPosition.Y.Scale +
				math.random(-12, 12) / 100

		end

	end

	------------------------------------------------
	-- NORMAL RANDOM POSITION
	------------------------------------------------

	if not startX then

		startX =
			math.random(5, 95) / 100

		startY =
			math.random(5, 95) / 100

	end

	star.Position =
		UDim2.fromScale(
			startX,
			startY
		)

	star.Parent = screenGui

	table.insert(
		stars,
		star
	)

	------------------------------------------------
	-- RANDOM SHORT DIRECTION
	------------------------------------------------

	local angle =
		math.random(0, 359)

	local radians =
		math.rad(angle)

	------------------------------------------------
	-- SHORT MOVEMENT
	------------------------------------------------

	local distance =
		math.random(
			STAR_MOVE_MIN * 100,
			STAR_MOVE_MAX * 100
		) / 100

	local endX =
		startX +
		math.cos(radians) *
		distance

	local endY =
		startY +
		math.sin(radians) *
		distance

	------------------------------------------------
	-- SMALL END SIZE
	------------------------------------------------

	local endSize =
		math.random(
			STAR_END_MIN_SIZE,
			STAR_END_MAX_SIZE
		)

	------------------------------------------------
	-- RANDOM LIFETIME
	------------------------------------------------

	local travelTime =
		math.random(
			STAR_TRAVEL_TIME_MIN * 100,
			STAR_TRAVEL_TIME_MAX * 100
		) / 100

	------------------------------------------------
	-- SHRINK + FLOAT + FADE
	------------------------------------------------

	local tween =
		TweenService:Create(

			star,

			TweenInfo.new(

				travelTime,

				Enum.EasingStyle.Sine,

				Enum.EasingDirection.InOut
			),

			{
				Position =
					UDim2.fromScale(
						endX,
						endY
					),

				Size =
					UDim2.fromOffset(
						endSize,
						endSize
					),

				ImageTransparency = 1
			}
		)

	tween:Play()

	------------------------------------------------
	-- DESTROY COMPLETELY
	------------------------------------------------

	tween.Completed:Once(function()

		if star then
			star:Destroy()
		end

		for i, existingStar in
			ipairs(stars) do

			if existingStar == star then

				table.remove(
					stars,
					i
				)

				break
			end

		end

	end)

end

------------------------------------------------
-- STAR LOOP
------------------------------------------------

local function startStarLoop()

	task.spawn(function()

		while active do

			createStar()

			------------------------------------------------
			-- RANDOM SPAWN DELAY
			------------------------------------------------

			local delayTime =
				math.random(10, 30) / 100

			task.wait(delayTime)

		end

	end)
end

------------------------------------------------
-- START
------------------------------------------------

function DizzyEffect.Start()

	if active then
		return
	end

	active = true

	playImpactSound()

	------------------------------------------------
	-- BLACK & WHITE
	------------------------------------------------

	colorEffect = Instance.new(
		"ColorCorrectionEffect"
	)

	colorEffect.Name =
		"DizzyBlackWhite"

	colorEffect.Saturation = 0
	colorEffect.Contrast = 0
	colorEffect.Brightness = 0

	colorEffect.Parent = Lighting

	TweenService:Create(

		colorEffect,

		TweenInfo.new(
			0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),

		{
			Saturation = -1,
			Contrast = 0.15
		}

	):Play()

	------------------------------------------------
	-- BLUR
	------------------------------------------------

	blurEffect = Instance.new(
		"BlurEffect"
	)

	blurEffect.Name =
		"DizzyBlur"

	blurEffect.Size = 0

	blurEffect.Parent = Lighting

	TweenService:Create(

		blurEffect,

		TweenInfo.new(
			0.2,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),

		{
			Size = 5
		}

	):Play()

	------------------------------------------------
	-- SCREEN GUI
	------------------------------------------------

	screenGui = Instance.new(
		"ScreenGui"
	)

	screenGui.Name =
		"DizzyEffect"

	screenGui.IgnoreGuiInset =
		true

	screenGui.ResetOnSpawn =
		false

	screenGui.DisplayOrder =
		999

	screenGui.Parent =
		player:WaitForChild("PlayerGui")


	
    ScreenShake(0.8, 0.45, 0.016)
	------------------------------------------------
	-- INITIAL RANDOM STARS
	------------------------------------------------

	for i = 1, STAR_COUNT do

		createStar()

		-- Randomize the initial timing
		task.wait(
			math.random(3, 12) / 100
		)

	end

	------------------------------------------------
	-- CONTINUE SPAWNING
	------------------------------------------------

	startStarLoop()
end

------------------------------------------------
-- STOP
------------------------------------------------

function DizzyEffect.Stop()

	if not active then
		return
	end

	active = false

	------------------------------------------------
	-- REMOVE ACTIVE STARS
	------------------------------------------------

	for _, star in ipairs(stars) do

		if star and star.Parent then

			TweenService:Create(

				star,

				TweenInfo.new(
					0.15,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				),

				{
					ImageTransparency = 1
				}

			):Play()

			task.delay(0.2, function()

				if star then
					star:Destroy()
				end

			end)

		end

	end

	stars = {}

	------------------------------------------------
	-- RESTORE COLOR
	------------------------------------------------

	if colorEffect then

		local currentColorEffect =
			colorEffect

		local tween = TweenService:Create(

			currentColorEffect,

			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),

			{
				Saturation = 0,
				Contrast = 0
			}
		)

		tween:Play()

		tween.Completed:Once(function()

			if currentColorEffect then
				currentColorEffect:Destroy()
			end

			if colorEffect ==
				currentColorEffect then

				colorEffect = nil

			end

		end)

	end

	------------------------------------------------
	-- REMOVE BLUR
	------------------------------------------------

	if blurEffect then

		local currentBlur =
			blurEffect

		local tween = TweenService:Create(

			currentBlur,

			TweenInfo.new(
				0.25,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),

			{
				Size = 0
			}
		)

		tween:Play()

		tween.Completed:Once(function()

			if currentBlur then
				currentBlur:Destroy()
			end

			if blurEffect ==
				currentBlur then

				blurEffect = nil

			end

		end)

	end

	------------------------------------------------
	-- REMOVE GUI
	------------------------------------------------

	local currentGui =
		screenGui

	task.delay(0.3, function()

		if currentGui then
			currentGui:Destroy()
		end

		if screenGui ==
			currentGui then

			screenGui = nil

		end

	end)

end

------------------------------------------------
-- PLAY
------------------------------------------------

function DizzyEffect.Play(duration)

	DizzyEffect.Start()

	task.delay(

		duration or 2.5,

		function()

			DizzyEffect.Stop()

		end

	)

end

return DizzyEffect