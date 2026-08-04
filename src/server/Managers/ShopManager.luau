local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ServerStorage = game:GetService("ServerStorage")

local ShopConfig = require(Shared.Config.ShopConfig)

local InventoryManager = require(script.Parent.InventoryManager)

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

function ShopManager:Purchase(player, category, itemId)

    local profile = PlayerProfiles[player]

    if not profile then
        return
    end

    local inventory = profile.Inventory

    if inventory.Owned[itemId] then
        return
    end

    local item = self:GetItem(category, itemId)

    if not item then
        return
    end

    if profile.Coins < item.Price then
        return
    end

    profile.Coins -= item.Price

    inventory.Owned[itemId] = true

    InventoryManager:SendInventory(player)

end


function ShopManager:Init()

	GetShopItems.OnServerInvoke = function(player, category)

		return self:GetShopItems(player, category)

	end

	RequestPurchase.OnServerEvent:Connect(function(player, category, itemId)

		self:Purchase(player, category, itemId)

	end)

end


return ShopManager