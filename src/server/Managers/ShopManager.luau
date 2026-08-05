local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ServerStorage = game:GetService("ServerStorage")

local ShopConfig = require(Shared.Config.ShopConfig)

local InventoryManager = require(script.Parent.InventoryManager)
local NotificationManager = require(script.Parent.NotificationManager)
local PlayerProfiles =
	require(ServerStorage.Data.PlayerProfiles)


local RemoteIndex = require(Shared.Remotes.RemoteIndex)
local RemoteIndexFunctions = RemoteIndex.Functions

local Remotes = Shared.Remotes

local GetShopItems =
	Remotes:WaitForChild(RemoteIndexFunctions.GetShopItems)

local RequestPurchase =
	Remotes:WaitForChild(RemoteIndexFunctions.RequestPurchase)

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
    print("Category:", categoryName, category)
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

function ShopManager:Purchase(player, category, itemId)

    local profile = PlayerProfiles[player]

    if not profile then
        return
    end

    local inventory = InventoryManager:GetInventory(player)
    print("Inventory:", inventory)
    local data = {}
    local ownedCategory = inventory.Owned[category] or {}

    data.Owned = ownedCategory[itemId] == true
  if data.Owned then
        NotificationManager:Send(
            player,
            "Already owned.")
        --update inventory
        InventoryManager:NotifyInventoryChanged(player)
		return false, "Already owned."
	end
    local item = self:GetItem(category, itemId)

    if not item then
        NotificationManager:Send(
            player,
            "Item not found.")
        return
    end

    if profile.Coins < item.Price then
        NotificationManager:Send(
            player,
            "Not enough coins.!")
        return false, "Not enough coins."
    end

    profile.Coins -= item.Price

   InventoryManager:SetOwned(player, category, itemId, true)

    NotificationManager:Success(
        player,
        "Purchase successful!"
    )
    return true, "Purchase successful."
end


function ShopManager:Init()

	GetShopItems.OnServerInvoke = function(player, category)

		return self:GetShopItems(player, category)

	end

	RequestPurchase.OnServerInvoke = function(player, category, itemId)
        return self:Purchase(player, category, itemId)
    end

end


return ShopManager