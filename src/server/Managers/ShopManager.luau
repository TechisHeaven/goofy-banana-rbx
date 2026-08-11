local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ServerStorage = game:GetService("ServerStorage")

local ShopConfig = require(Shared.Config.ShopConfig)

local InventoryManager = require(script.Parent.InventoryManager)
local NotificationManager = require(script.Parent.NotificationManager)
local PlayerProfiles =
	require(ServerStorage.Data.PlayerProfiles)
local CurrencyManager = require(script.Parent.CurrencyManager)


local RemoteIndex = require(Shared.Remotes.RemoteIndex)
local RemoteIndexFunctions = RemoteIndex.Functions
local RemoteIndexEvents = RemoteIndex.Events
local Remotes = Shared.Remotes

local GetShopItems =
	Remotes:WaitForChild(RemoteIndexFunctions.GetShopItems)

local RequestPurchase =
	Remotes:WaitForChild(RemoteIndexFunctions.RequestPurchase)

local PromptProductPurchase =
	Remotes:WaitForChild(RemoteIndexEvents.PromptProductPurchase)

local ShopManager = {}

function ShopManager:GetCategory(name)
	return ShopConfig.Categories[name]
end

function ShopManager:GetShopItems(player, categoryName)
	local category = ShopConfig.Categories[categoryName]
	if not category then
		return {}
	end

	local inventory = InventoryManager:GetInventory(player)

	local items = {}

	for _, item in ipairs(category.Items) do

		local data = table.clone(item)
        data.Category = categoryName
        data.Owned = false

        if inventory.Owned[categoryName] then
            data.Owned = inventory.Owned[categoryName][data.Id] == true
        end

        
		-- data.Owned =
		-- 	inventory.Owned[categoryName][data.Id] == true

		data.Equipped =
			inventory.Equipped[categoryName] == data.Id

		table.insert(items, data)

	end

	return items

end

function ShopManager:GetItem(categoryName,itemId)

    local category = ShopConfig.Categories[categoryName]
    if not category then
        return nil
    end

    for _,item in ipairs(category.Items) do

        if item.Id == itemId then
            return item
        end

    end

    return nil

end


function ShopManager:PromptProduct(
	player,
	productId
)

	if not productId
		or productId <= 0 then

		return false, "Invalid product."
	end

	PromptProductPurchase:FireClient(
		player,
		{
			ProductId = productId,
		}
	)

	return true, "Purchase prompted."

end

function ShopManager:GetCoinProduct(itemId)
    local Coins = self:GetCategory("Coins").Items

	for _, item in ipairs(Coins or {}) do
        
		if item.Id == itemId then
			return item
		end

	end

	return nil
end

function ShopManager:GetGameProduct(itemId)
    local GamePacks = self:GetCategory("GamePacks").Items

	for _, item in ipairs(GamePacks or {}) do
        
		if item.Id == itemId then
			return item
		end

	end

	return nil

end

function ShopManager:PurchaseCoinPack(
	player,
	itemId
)

	local item =
		self:GetCoinProduct(itemId)
	if not item then

		return false, "Coin pack not found."
	end

	if item.Currency ~= "Robux" then

		return false, "Invalid coin pack."
	end

	return self:PromptProduct(
		player,
		item.ProductId
	)

end


function ShopManager:PurchaseGamePack(
	player,
	itemId
)

	local item =
		self:GetGameProduct(itemId)
	if not item then

		return false, "Coin pack not found."
	end

	if item.Currency ~= "Robux" then

		return false, "Invalid coin pack."
	end

	return self:PromptProduct(
		player,
		item.ProductId
	)

end



function ShopManager:GetBestCoinProduct(requiredCoins, currentCoins)
	local missingCoins =
		math.max(
			0,
			requiredCoins - currentCoins
		)

	if missingCoins <= 0 then
		return nil
	end

	local bestProduct = nil
    local Coins = self:GetCategory("Coins").Items
	for _, product in ipairs(Coins or {}) do
		if product.Currency ~= "Robux" then
			continue
		end

		if not product.Amount then
			continue
		end

		if not product.ProductId
			or product.ProductId <= 0 then
			continue
		end

		-- Product must cover the missing coins
		if product.Amount >= missingCoins then

			-- Pick the smallest suitable pack
			if not bestProduct
				or product.Amount < bestProduct.Amount then
                    
				bestProduct = product

			elseif product.Amount == bestProduct.Amount
				and product.Price < bestProduct.Price then

				bestProduct = product

			end

		end

	end

	return bestProduct
end


function ShopManager:Purchase(player, category, itemId)

	local profile = PlayerProfiles[player]

	if not profile then
		return false, "Profile not loaded."
	end

	local inventory = InventoryManager:GetInventory(player)

	if not inventory then
		return false, "Inventory not loaded."
	end

	------------------------------------------------
	-- Find item
	------------------------------------------------

	local item = self:GetItem(category, itemId)
	if not item then

		NotificationManager:Send(
			player,
			"Item not found."
		)

		return false, "Item not found."
	end
	------------------------------------------------
	-- Already owned
	------------------------------------------------

	local ownedCategory =
		inventory.Owned[category] or {}

	if ownedCategory[itemId] then

		NotificationManager:Send(
			player,
			"Already owned."
		)

		InventoryManager:NotifyInventoryChanged(player)

		return false, "Already owned."
	end

	------------------------------------------------
	-- FREE
	------------------------------------------------

	if item.Price <= 0 then

		InventoryManager:SetOwned(
			player,
			category,
			itemId,
			true
		)

		NotificationManager:Success(
			player,
			"Item unlocked!"
		)

		return true, "Purchase successful."
	end

	------------------------------------------------
	-- COINS
	------------------------------------------------
	if item.Currency == "Coins" then

		local success =
			CurrencyManager:TrySpend(
				player,
				item.Price
			)

		if not success then
            local currentCoins =
            CurrencyManager:GetCoins(player)

            local coinProduct =
                self:GetBestCoinProduct(
                    item.Price,
                    currentCoins
                )
          
			return self:PromptProduct(
                player,
                coinProduct.ProductId
            )
		end

		InventoryManager:SetOwned(
			player,
			category,
			itemId,
			true
		)

		NotificationManager:Success(
			player,
			"Purchase successful!"
		)

		return true, "Purchase successful."
	end

	------------------------------------------------
	-- ROBUX
	------------------------------------------------

	if item.Currency == "Robux" then

		if not item.ProductId then

			warn(
				"Missing Developer ProductId:",
				category,
				itemId
			)

			return false, "Product unavailable."
		end

		-- IMPORTANT:
		-- Do not grant the item here.
		-- Your MarketplaceService ProcessReceipt
		-- handler must grant it after Roblox confirms
		-- the purchase.

        return self:PromptProduct(
            player,
            item.ProductId
        )
	end

	return false, "Unsupported currency."

end


function ShopManager:Init()

	GetShopItems.OnServerInvoke = function(player, category)

		return self:GetShopItems(player, category)

	end

	RequestPurchase.OnServerInvoke = function(player, category, itemId)

       if category == "Coins" then

			return self:PurchaseCoinPack(
				player,
				itemId
			)

		end
        if category == "GamePacks" then

			return self:PurchaseGamePack(
				player,
				itemId
			)

		end

		return self:Purchase(
			player,
			category,
			itemId
		)

    end

end


return ShopManager