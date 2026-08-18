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

	for _, coin in ipairs(CoinPool) do

		if not coin.Busy then

			coin.Busy = true

			return coin

		end

	end

	return nil

end

------------------------------------------------
-- RETURN COIN
------------------------------------------------

local function ReleaseCoin(
	coinData
)

	if not coinData then
		return
	end

	local coin =
		coinData.Instance

	if coin then

		coin.Visible = false

		coin.Rotation = 0

	end

	coinData.Busy = false

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

	Initialized = true

	------------------------------------------------
	-- FIND PRE-CREATED COINS
	------------------------------------------------

	for i = 1, self.Settings.MaxCoins do

		local coin =
			container:FindFirstChild(
				"CoinTemplate" .. i
			)

		if coin then

			coin.Visible = false

			table.insert(
				CoinPool,
				{
					Instance = coin,
					Busy = false,
				}
			)

		else

			warn(
				"[CurrencyGainFX] Missing:",
				"Coin" .. i
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

	if not container
		or not target then

		return

	end

	if typeof(amount) ~= "number"
		or amount <= 0 then

		return

	end

	------------------------------------------------
	-- MAKE SURE POOL EXISTS
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

		------------------------------------------------
		-- Pool is currently busy
		------------------------------------------------

		if not coinData then
			break
		end

		local coin =
			coinData.Instance

		------------------------------------------------
		-- RESET
		------------------------------------------------

		coin.Visible = true

		coin.Rotation = 0

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
		-- SIZE
		------------------------------------------------

		local originalSize =
			coin.Size

		coin.Size =
			ScaleUDim2(
				originalSize,
				self.Settings.PopScale
			)

		------------------------------------------------
		-- STAGGER
		------------------------------------------------

		task.delay(

			(i - 1)
				* self.Settings.Stagger,

			function()

				if not coin
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
									originalSize,
									self.Settings.EndScale
								),

						}

					)

				tween:Play()

				tween.Completed:Once(

					function()

						ReleaseCoin(
							coinData
						)

					end

				)

			end

		)

	end

end

return CurrencyGainFX