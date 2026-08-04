local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local ServerStorage = game:GetService("ServerStorage")

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
local ShopConfig = require(Shared.Config.ShopConfig)

local ProfileManager =
	require(script.Parent.ProfileManager)

local Remotes = Shared.Remotes

------------------------------------------------

local RequestEquip =
	Remotes:WaitForChild(RemoteIndex.RequestEquip)

local UpdateInventory =
	Remotes:WaitForChild(RemoteIndex.UpdateInventory)

local RequestUnequip = Remotes:WaitForChild(RemoteIndex.RequestUnequip)

-----------------------------------------------
--Templates
local InventoryTemplate =
	require(ServerStorage.Data.InventoryTemplate)

local PlayerProfiles =
	require(ServerStorage.Data.PlayerProfiles)

------------------------------------------------

local InventoryManager = {}

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

	local inventory = profile.Inventory
	-- local inventory =
	-- 	PlayerProfiles[player].Inventory

	UpdateInventory:FireClient(player,{

		Skins =
			BuildCategory("Skins",inventory),

		BananaSkins =
			BuildCategory("BananaSkins",inventory),

		RescueEffects =
			BuildCategory("RescueEffects",inventory),

		VictoryPoses =
			BuildCategory("VictoryPoses",inventory),

	})

end

------------------------------------------------

function InventoryManager:Equip(player,category,itemId)

	local inventory =
		PlayerProfiles[player].Inventory

	if not inventory then
		return
	end

	if not inventory.Owned[category][itemId] then
		return
	end

	inventory.Equipped[category] = itemId


	self:SendInventory(player)

end

function InventoryManager:Unequip(player, category)

	local inventory = PlayerProfiles[player].Inventory

	if not inventory then
		return
	end

	inventory.Equipped[category] = nil

	self:SendInventory(player)

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


------------------------------------------------

function InventoryManager:Init()
	task.wait(1)
	Players.PlayerAdded:Connect(function(player)
		local profile = ProfileManager:GetProfile(player)
		-- task.wait(1)
		self:SendInventory(player)

	end)

	Players.PlayerRemoving:Connect(function(player)
		ProfileManager:RemovePlayer(player)
	end)

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