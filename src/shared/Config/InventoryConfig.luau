local InventoryConfig = {}

local ShopData = script.Parent:WaitForChild("ShopConfigData")

InventoryConfig.DefaultCategory = "Skins"

InventoryConfig.Categories = {

	Skins = {
		Page = "DefaultPage",
		Items = require(ShopData.Skins)
	},

	BananaSkins = {
		Page = "DefaultPage",
		Items = require(ShopData.BananaSkins)
	},

	RescueEffects = {
		Page = "DefaultPage",
		Items = require(ShopData.RescueEffects)
	},

	VictoryPoses = {
		Page = "DefaultPage",
		Items = require(ShopData.VictoryPoses)
	}

}

return InventoryConfig