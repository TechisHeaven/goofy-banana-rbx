local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local ServerStorage = game:GetService("ServerStorage")

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
local RemoteIndexFunctions = RemoteIndexData.Functions
local ShopConfig = require(Shared.Config.ShopConfig)

local ProfileManager =
	require(script.Parent.ProfileManager)

local Remotes = Shared.Remotes

------------------------------------------------

local RequestEquip =
	Remotes:WaitForChild(RemoteIndex.RequestEquip)

local UpdateInventory =
	Remotes:WaitForChild(RemoteIndex.UpdateInventory)

local GetInventoryItems = Remotes:WaitForChild(RemoteIndexFunctions.GetInventoryItems)

local RequestUnequip = Remotes:WaitForChild(RemoteIndex.RequestUnequip)

-----------------------------------------------
--Templates

local PlayerProfiles =
	require(ServerStorage.Data.PlayerProfiles)

------------------------------------------------

local InventoryManager = {}

local RequireEquip = {
	Skins = true,
	BananaSkins = true,
	RescueEffects = true,
	VictoryPoses = true,
}

------------------------------------------------

local function BuildCategory(categoryName, inventory)

	local category =
		ShopConfig.Categories[categoryName]

	local items = {}

	for _,item in ipairs(category.Items) do

		local data = table.clone(item)

		data.Owned =
			inventory.Owned[categoryName][data.Id] == true

		data.Equipped =
			inventory.Equipped[categoryName] == data.Id

		table.insert(items,data)

	end

	return items

end

------------------------------------------------

function InventoryManager:SendInventory(player)
	local profile = ProfileManager:GetProfile(player)
	if not profile then
		return
	end

	UpdateInventory:FireClient(player)

end

function InventoryManager:NotifyInventoryChanged(player)
    UpdateInventory:FireClient(player)
end


------------------------------------------------

function InventoryManager:Equip(player,category,itemId)

	local inventory =
		self:GetInventory(player)

	if not inventory then
		return
	end

	if not inventory.Owned[category][itemId] then
		return
	end

	inventory.Equipped[category] = itemId


	self:NotifyInventoryChanged(player)

end

function InventoryManager:Unequip(player, category)

	local inventory = self:GetInventory(player)

	if not inventory then
		return
	end

	if RequireEquip[category] then
		return
	end


	inventory.Equipped[category] = nil

	self:NotifyInventoryChanged(player)

end

function InventoryManager:AddItem(player, category, itemId)

	local profile = ProfileManager:GetProfile(player)
	if not profile then
		return false
	end

	local inventory = profile.Inventory

	inventory.Owned[category] = inventory.Owned[category] or {}

	if inventory.Owned[category][itemId] then
		return false
	end

	inventory.Owned[category][itemId] = true

	self:SendInventory(player)

	return true

end

function InventoryManager:SetOwned(player, category, itemId, owned)

	local profile = ProfileManager:GetProfile(player)
	if not profile then
		return false
	end

	local inventory = profile.Inventory

	inventory.Owned[category] = inventory.Owned[category] or {}

	if owned then
		inventory.Owned[category][itemId] = true
	else
		inventory.Owned[category][itemId] = nil
	end

	return true

end

function InventoryManager:RemoveItem(player, category, itemId)

	local profile = ProfileManager:GetProfile(player)
	if not profile then
		return false
	end

	local inventory = profile.Inventory

	if inventory.Owned[category] then
		inventory.Owned[category][itemId] = nil
	end

	if inventory.Equipped[category] == itemId then
		inventory.Equipped[category] = nil
	end

	self:SendInventory(player)

	return true

end
----------------------------------------------
function InventoryManager:GetInventory(player)
	return PlayerProfiles[player].Inventory
end

function InventoryManager:GetEquipped(player, category)
	local inventory = PlayerProfiles[player].Inventory

	if not inventory then
		return nil
	end

	return inventory.Equipped[category]
end

function InventoryManager:GetOwned(player, category)
	local inventory = PlayerProfiles[player].Inventory

	if not inventory then
		return nil
	end

	return inventory.Owned[category]
end

function InventoryManager:GetInventoryItems(player, category)

	local profile = ProfileManager:GetProfile(player)

	if not profile then
		return {}
	end

	local inventory = profile.Inventory
	return BuildCategory(category, inventory)

end
------------------------------------------------

function InventoryManager:Init()
	
	Players.PlayerAdded:Connect(function(player)
		self:SendInventory(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		ProfileManager:RemovePlayer(player)
	end)

	GetInventoryItems.OnServerInvoke = function(player, category)

		return InventoryManager:GetInventoryItems(
			player,
			category
		)

	end

	RequestEquip.OnServerEvent:Connect(function(player,category,itemId)
		self:Equip(player,category,itemId)
	end)

    RequestUnequip.OnServerEvent:Connect(function(player, category)

		self:Unequip(player, category)

	end)

	-- Register players already in the server
	for _, player in ipairs(Players:GetPlayers()) do
		self:SendInventory(player)
	end

end

------------------------------------------------

return InventoryManager