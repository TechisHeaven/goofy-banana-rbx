local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local ShopConfig =
	require(Shared.Config.ShopConfig)

local CurrencyManager =
	require(script.Parent.CurrencyManager)

local InventoryManager =
	require(script.Parent.InventoryManager)

local MonetizationManager = {}

------------------------------------------------
-- Product Index
------------------------------------------------

local ProductsById = {}

------------------------------------------------
-- Add Product
------------------------------------------------

local function AddProduct(product, productType)

	if not product then
		return
	end

	if not product.ProductId
		or product.ProductId <= 0 then
		return
	end

	ProductsById[product.ProductId] = {
		Data = product,
		Type = productType,
	}

end

------------------------------------------------
-- Build Product Index
------------------------------------------------

local function BuildProductIndex()

	table.clear(ProductsById)

	------------------------------------------------
	-- Coin Packs
	------------------------------------------------
	for _, product in ipairs(
		ShopConfig.Categories.Coins.Items or {}
	) do

		AddProduct(
			product,
			"CoinPack"
		)

	end

	------------------------------------------------
	-- Game Packs
	------------------------------------------------

	local gamePackCategory =
		ShopConfig.Categories
		and ShopConfig.Categories.GamePacks
	if gamePackCategory then

		for _, product in ipairs(
			gamePackCategory.Items or {}
		) do

			AddProduct(
				product,
				"GamePack"
			)

		end

	end

end

------------------------------------------------
-- Grant Coin Pack
------------------------------------------------

local function GrantCoinPack(player, product)

	if not product.Amount
		or product.Amount <= 0 then

		warn(
			"[MonetizationManager] Invalid coin amount:",
			product.Id
		)

		return false
	end

	CurrencyManager:AddCoins(
		player,
		product.Amount
	)

	print(
		string.format(
			"[MonetizationManager] %s received %d coins from %s",
			player.Name,
			product.Amount,
			product.Id
		)
	)

	return true

end

------------------------------------------------
-- Grant Game Pack
------------------------------------------------

local function GrantGamePack(player, product)

	local rewards =
		product.Rewards
	if not rewards then

		warn(
			"[MonetizationManager] GamePack has no Rewards:",
			product.Id
		)

		return false
	end

	------------------------------------------------
	-- Coins
	------------------------------------------------

	if rewards.Coins
		and rewards.Coins.Amount
		and rewards.Coins.Amount > 0 then

		CurrencyManager:AddCoins(
			player,
			rewards.Coins.Amount
		)

	end

	------------------------------------------------
	-- Skins
	------------------------------------------------

	if rewards.Skins then

		for _, reward in ipairs(
			rewards.Skins
		) do

			if reward.Id then

				InventoryManager:SetOwned(
					player,
					"Skins",
					reward.Id,
					true
				)

			end

		end

	end

	------------------------------------------------
	-- Banana Skins
	------------------------------------------------

	if rewards.BananaSkins then

		for _, reward in ipairs(
			rewards.BananaSkins
		) do

			if reward.Id then

				InventoryManager:SetOwned(
					player,
					"BananaSkins",
					reward.Id,
					true
				)

			end

		end

	end

	------------------------------------------------
	-- Future reward categories
	------------------------------------------------

	if rewards.RescueEffects then

		for _, reward in ipairs(
			rewards.RescueEffects
		) do

			if reward.Id then

				InventoryManager:SetOwned(
					player,
					"RescueEffects",
					reward.Id,
					true
				)

			end

		end

	end

	if rewards.VictoryPoses then

		for _, reward in ipairs(
			rewards.VictoryPoses
		) do

			if reward.Id then

				InventoryManager:SetOwned(
					player,
					"VictoryPoses",
					reward.Id,
					true
				)

			end

		end

	end

	print(
		"[MonetizationManager] Granted GamePack:",
		product.Id,
		"to",
		player.Name
	)

	return true

end

------------------------------------------------
-- Grant Product
------------------------------------------------

local function GrantProduct(player, productInfo)

	local product =
		productInfo.Data

	local productType =
		productInfo.Type

	------------------------------------------------
	-- Coin Pack
	------------------------------------------------

	if productType == "CoinPack" then

		return GrantCoinPack(
			player,
			product
		)

	end

	------------------------------------------------
	-- Game Pack
	------------------------------------------------

	if productType == "GamePack" then

		return GrantGamePack(
			player,
			product
		)

	end

	warn(
		"[MonetizationManager] Unknown product type:",
		productType
	)

	return false

end

------------------------------------------------
-- Process Receipt
------------------------------------------------

local function ProcessReceipt(receiptInfo)

	local player =
		Players:GetPlayerByUserId(
			receiptInfo.PlayerId
		)

	------------------------------------------------
	-- Player isn't currently in server
	------------------------------------------------

	if not player then

		return Enum.ProductPurchaseDecision.NotProcessedYet

	end

	------------------------------------------------
	-- Find product
	------------------------------------------------

	local productInfo =
		ProductsById[
			receiptInfo.ProductId
		]

	if not productInfo then

		warn(
			"[MonetizationManager] Unknown ProductId:",
			receiptInfo.ProductId
		)

		return Enum.ProductPurchaseDecision.NotProcessedYet

	end

	------------------------------------------------
	-- Grant
	------------------------------------------------

	local success, granted =
		pcall(function()

			return GrantProduct(
				player,
				productInfo
			)

		end)

	if not success then

		warn(
			"[MonetizationManager] Grant failed:",
			productInfo.Data.Id,
			granted
		)

		return Enum.ProductPurchaseDecision.NotProcessedYet

	end

	if not granted then

		return Enum.ProductPurchaseDecision.NotProcessedYet

	end

	print(
		"[MonetizationManager] Purchase granted:",
		player.Name,
		productInfo.Data.Id
	)

	return Enum.ProductPurchaseDecision.PurchaseGranted

end

------------------------------------------------
-- Init
------------------------------------------------

function MonetizationManager:Init()

	print(
		"MonetizationManager Initializing..."
	)

	BuildProductIndex()

	MarketplaceService.ProcessReceipt =
		ProcessReceipt

end

return MonetizationManager