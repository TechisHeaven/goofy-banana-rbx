local TweenService =
	game:GetService("TweenService")

------------------------------------------------
-- MODULE
------------------------------------------------

local CurrencyGainFX = {}

------------------------------------------------
-- SETTINGS
------------------------------------------------

CurrencyGainFX.Settings = {

	MaxCoins = 15,

	SpawnRadius = 90,

	Duration = 0.5,

	Stagger = 0.035,

	PopScale = 0.75,

	EndScale = 0.65,

}

------------------------------------------------
-- INTERNAL
------------------------------------------------

local Initialized = false

local CoinPool = {}

------------------------------------------------
-- SCALE UDim2
------------------------------------------------

local function ScaleUDim2(
	size,
	scale
)

	return UDim2.new(

		size.X.Scale * scale,
		size.X.Offset * scale,

		size.Y.Scale * scale,
		size.Y.Offset * scale

	)

end

------------------------------------------------
-- GET RELATIVE POSITION
------------------------------------------------

local function GetRelativePosition(
	container,
	screenPosition
)

	return Vector2.new(

		screenPosition.X
			- container.AbsolutePosition.X,

		screenPosition.Y
			- container.AbsolutePosition.Y

	)

end

------------------------------------------------
-- GET AVAILABLE COIN
------------------------------------------------

local function GetAvailableCoin()

	for _, coinData in ipairs(CoinPool) do

		if not coinData.Busy then

			coinData.Busy = true

			return coinData

		end

	end

	return nil

end

------------------------------------------------
-- RELEASE COIN
------------------------------------------------

local function ReleaseCoin(
	coinData
)

	if not coinData then
		return
	end

	local coin =
		coinData.Instance

	if not coin then

		coinData.Busy = false

		return
	end

	------------------------------------------------
	-- STOP ACTIVE TWEEN
	------------------------------------------------

	local tween =
		coinData.Tween

	if tween then

		tween:Cancel()

		tween:Destroy()

		coinData.Tween =
			nil

	end

	------------------------------------------------
	-- RESET
	------------------------------------------------

	coin.Visible =
		false

	coin.Rotation =
		0

	coin.Size =
		coinData.OriginalSize

	coin.Position =
		coinData.OriginalPosition

	------------------------------------------------
	-- RELEASE
	------------------------------------------------

	coinData.Busy =
		false

end

------------------------------------------------
-- INITIALIZE POOL
------------------------------------------------

function CurrencyGainFX:Init(
	container
)

	if Initialized then
		return
	end

	if not container then

		warn(
			"[CurrencyGainFX] Missing container"
		)

		return
	end

	Initialized = true

	------------------------------------------------
	-- BUILD POOL
	------------------------------------------------

	for i = 1, self.Settings.MaxCoins do

		local coin =
			container:FindFirstChild(
				"CoinTemplate" .. i
			)

		if coin then

			local coinData = {

				Instance = coin,

				Busy = false,

				Tween = nil,

				OriginalSize =
					coin.Size,

				OriginalPosition =
					coin.Position,

			}

			coin.Visible =
				false

			table.insert(
				CoinPool,
				coinData
			)

		else

			warn(
				"[CurrencyGainFX] Missing:",
				"CoinTemplate" .. i
			)

		end

	end

	print(
		"[CurrencyGainFX] Initialized pool:",
		#CoinPool
	)

end

------------------------------------------------
-- PLAY
------------------------------------------------

function CurrencyGainFX:Play(
	container,
	target,
	amount
)
	debug.profilebegin("is this currencygainfx play issue?")
	if not container
		or not target then

		return
	end

	if typeof(amount) ~= "number"
		or amount <= 0 then

		return
	end

	------------------------------------------------
	-- POOL SHOULD ALREADY EXIST
	------------------------------------------------

	if not Initialized then

		self:Init(
			container
		)

	end

	------------------------------------------------
	-- NUMBER OF COINS
	------------------------------------------------

	local count =
		math.min(

			math.floor(amount),

			self.Settings.MaxCoins

		)

	------------------------------------------------
	-- TARGET POSITION
	------------------------------------------------

	local targetScreenPosition =
		target.AbsolutePosition
		+ target.AbsoluteSize / 2

	local targetPosition =
		GetRelativePosition(
			container,
			targetScreenPosition
		)

	------------------------------------------------
	-- CONTAINER CENTER
	------------------------------------------------

	local containerCenter =
		Vector2.new(

			container.AbsoluteSize.X / 2,

			container.AbsoluteSize.Y / 2

		)

	------------------------------------------------
	-- SPAWN
	------------------------------------------------

	for i = 1, count do

		local coinData =
			GetAvailableCoin()

		if not coinData then
			break
		end

		local coin =
			coinData.Instance

		------------------------------------------------
		-- CANCEL OLD TWEEN
		------------------------------------------------

		if coinData.Tween then

			coinData.Tween:Cancel()

			coinData.Tween:Destroy()

			coinData.Tween =
				nil

		end

		------------------------------------------------
		-- RESET
		------------------------------------------------

		coin.Visible =
			true

		coin.Rotation =
			0

		coin.Size =
			ScaleUDim2(

				coinData.OriginalSize,

				self.Settings.PopScale

			)

		------------------------------------------------
		-- POSITION
		------------------------------------------------

		local startPosition =
			containerCenter
			+ Vector2.new(

				math.random(
					-self.Settings.SpawnRadius,
					self.Settings.SpawnRadius
				),

				math.random(
					-self.Settings.SpawnRadius,
					self.Settings.SpawnRadius
				)

			)

		coin.Position =
			UDim2.fromOffset(
				startPosition.X,
				startPosition.Y
			)

		------------------------------------------------
		-- STAGGER
		------------------------------------------------

		local delayTime =
			(i - 1)
			* self.Settings.Stagger

		task.delay(
			delayTime,
			function()

				if not coinData.Busy
					or not coin.Parent then

					ReleaseCoin(
						coinData
					)

					return
				end

				------------------------------------------------
				-- TWEEN
				------------------------------------------------

				local tween =
					TweenService:Create(

						coin,

						TweenInfo.new(

							self.Settings.Duration,

							Enum.EasingStyle.Quad,

							Enum.EasingDirection.In

						),

						{

							Position =
								UDim2.fromOffset(
									targetPosition.X,
									targetPosition.Y
								),

							Rotation =
								math.random(
									180,
									540
								),

							Size =
								ScaleUDim2(

									coinData.OriginalSize,

									self.Settings.EndScale

								),

						}

					)

				coinData.Tween =
					tween

				tween.Completed:Once(
					function()

						coinData.Tween =
							nil

						ReleaseCoin(
							coinData
						)

					end
				)

				tween:Play()

			end
		)

	end

	debug.profileend()

end

return CurrencyGainFX