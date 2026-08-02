local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared

local RemoteIndex = require(Shared.Remotes.RemoteIndex)
local ShopConfig = require(Shared.Config.ShopConfig)

local Remotes = Shared.Remotes

------------------------------------------------

local RequestEquip =
	Remotes:WaitForChild(RemoteIndex.RequestEquip)

local UpdateInventory =
	Remotes:WaitForChild(RemoteIndex.UpdateInventory)

local RequestUnequip = Remotes:WaitForChild(RemoteIndex.RequestUnequip)

------------------------------------------------

local InventoryManager = {}

local PlayerInventory = {}

------------------------------------------------
-- Test Data
------------------------------------------------

local function CreateInventory()

	return {

		Owned = {

			SleepyBanana = true,
			CoolBanana = true,
			GalaxyBanana = false,

			RainbowPeel = true,
			IcePeel = false,

			Snow = true,
			Fire = false,

			Dance = true,
			Wave = false,

		},

		Equipped = {

			Skins = "SleepyBanana",

			BananaSkins = "RainbowPeel",

			RescueEffects = "Snow",

			VictoryPoses = "Dance",

		}

	}

end

------------------------------------------------

local function BuildCategory(categoryName, inventory)

	local category =
		ShopConfig.Categories[categoryName]

	local items = {}

	for _,item in ipairs(category.Items) do

		local data = table.clone(item)

		data.Owned =
			inventory.Owned[data.Id] == true

		data.Equipped =
			inventory.Equipped[categoryName] == data.Id

		table.insert(items,data)

	end

	return items

end

------------------------------------------------

function InventoryManager:SendInventory(player)

	local inventory =
		PlayerInventory[player]

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
		PlayerInventory[player]

	if not inventory then
		return
	end

	if not inventory.Owned[itemId] then
		return
	end

	inventory.Equipped[category] = itemId


	self:SendInventory(player)

end

function InventoryManager:Unequip(player, category)

	local inventory = PlayerInventory[player]

	if not inventory then
		return
	end

	inventory.Equipped[category] = nil

	self:SendInventory(player)

end

------------------------------------------------

function InventoryManager:Init()

	Players.PlayerAdded:Connect(function(player)

		PlayerInventory[player] =
			CreateInventory()

		task.wait(1)

		self:SendInventory(player)

	end)

	Players.PlayerRemoving:Connect(function(player)

		PlayerInventory[player] = nil

	end)

	RequestEquip.OnServerEvent:Connect(function(player,category,itemId)

		self:Equip(player,category,itemId)

	end)

    RequestUnequip.OnServerEvent:Connect(function(player, category)

	self:Unequip(player, category)

end)

end

------------------------------------------------

return InventoryManager