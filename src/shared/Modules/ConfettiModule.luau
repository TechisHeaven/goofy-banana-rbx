local RunService = game:GetService("RunService")

local Confetti = {}

local COLORS = {
	Color3.fromRGB(255, 92, 92),
	Color3.fromRGB(255, 210, 60),
	Color3.fromRGB(75, 210, 255),
	Color3.fromRGB(125, 255, 110),
	Color3.fromRGB(190, 100, 255),
	Color3.fromRGB(255, 120, 210),
}

local function bezier(p0, p1, p2, p3, t)
	local u = 1 - t

	return
		p0 * (u ^ 3)
		+ p1 * (3 * u ^ 2 * t)
		+ p2 * (3 * u * t ^ 2)
		+ p3 * (t ^ 3)
end

local function createConfetti(origin, container)
    print(origin, container)
	local piece = Instance.new("Frame")
	piece.Name = "Confetti"

	-- Different sizes for depth
	local depth = math.random()

	local width
	local height

	if depth < 0.25 then
		width = math.random(4, 7)
		height = math.random(7, 12)
	elseif depth < 0.75 then
		width = math.random(7, 11)
		height = math.random(11, 18)
	else
		width = math.random(10, 16)
		height = math.random(16, 25)
	end

	piece.Size = UDim2.fromOffset(width, height)
	piece.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Origin point
	piece.Position = UDim2.fromOffset(origin.X, origin.Y)

	piece.BackgroundColor3 = COLORS[math.random(1, #COLORS)]
	piece.BorderSizePixel = 0
	piece.Rotation = math.random(0, 360)
	piece.ZIndex = 20

	piece.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.15, 0)
	corner.Parent = piece

	--------------------------------------------------
	-- RANDOM DIRECTION
	--------------------------------------------------

	local angle = math.random() * math.pi * 2
	local distance = math.random(30, 65) / 100

	local dx = math.cos(angle)
	local dy = math.sin(angle)

	--------------------------------------------------
	-- CONVERT SCREEN MOVEMENT INTO UI SCALE
	--------------------------------------------------

	local containerSize = container.AbsoluteSize

	local directionX = dx * distance * containerSize.X
	local directionY = dy * distance * containerSize.Y

	--------------------------------------------------
	-- BEZIER POINTS
	--------------------------------------------------

	local start = origin

	local control1 = Vector2.new(
		origin.X + directionX * 0.35,
		origin.Y + directionY * 0.35
	)

	local control2 = Vector2.new(
		origin.X + directionX * 0.85,
		origin.Y + directionY * 0.65
	)

	local target = Vector2.new(
		origin.X + directionX,
		origin.Y + directionY + math.random(20, 120)
	)

	--------------------------------------------------
	-- SPEED
	--------------------------------------------------

	local duration = math.random(65, 110) / 100

	--------------------------------------------------
	-- ROTATION / 3D FLIP
	--------------------------------------------------

	local originalWidth = width
	local originalHeight = height

	local rotation = math.random(0, 360)
	local rotationSpeed = math.random(500, 1200)
	local flipSpeed = math.random(8, 16)

	local startTime = os.clock()

	local connection

	connection = RunService.RenderStepped:Connect(function()

		local elapsed = os.clock() - startTime

		local rawT = math.clamp(elapsed / duration, 0, 1)

		-- Fast burst → slow down
		local t = 1 - ((1 - rawT) ^ 3)

		--------------------------------------------------
		-- CURVE
		--------------------------------------------------

		local position = bezier(
			start,
			control1,
			control2,
			target,
			t
		)

		piece.Position = UDim2.fromOffset(
			position.X,
			position.Y
		)

		--------------------------------------------------
		-- ROTATION
		--------------------------------------------------

		piece.Rotation =
			rotation + rotationSpeed * rawT

		--------------------------------------------------
		-- FAKE 3D FLIP
		--------------------------------------------------

		local flip = math.abs(
			math.cos(rawT * math.pi * flipSpeed)
		)

		piece.Size = UDim2.fromOffset(
			math.max(1, originalWidth * flip),
			originalHeight
		)

		--------------------------------------------------
		-- FADE
		--------------------------------------------------

		if rawT > 0.75 then

			local fade = (rawT - 0.75) / 0.25

			piece.BackgroundTransparency = fade

		end

		--------------------------------------------------
		-- CLEANUP
		--------------------------------------------------

		if rawT >= 1 then

			connection:Disconnect()
			piece:Destroy()

		end
	end)
end

--------------------------------------------------
-- PUBLIC FUNCTION
--------------------------------------------------
function Confetti:Play(originObject, container, amount)

	amount = amount or 50

	task.defer(function()

		-- Origin in SCREEN coordinates
		local originPosition = originObject.AbsolutePosition
		local originSize = originObject.AbsoluteSize

		local screenOrigin = Vector2.new(
			originPosition.X + originSize.X / 2,
			originPosition.Y + originSize.Y / 2
		)

		-- Convert SCREEN coordinates to CONTAINER coordinates
		local containerPosition = container.AbsolutePosition

		local origin = screenOrigin - containerPosition

		print("Screen Origin:", screenOrigin)
		print("Container Origin:", origin)

		for i = 1, amount do

			task.delay(
				math.random(0, 12) / 100,
				function()

					createConfetti(
						origin,
						container
					)

			end)

		end

	end)
end

return Confetti