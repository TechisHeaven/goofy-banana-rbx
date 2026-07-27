local ShopConfig = {}
print(script.Parent)

local ShopData = script.Parent:WaitForChild("ShopConfigData")

ShopConfig.DefaultCategory = "Skins"

ShopConfig.Categories = {

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
	},

	Coins = {
		Page = "DefaultPage",
		Items = require(ShopData.Coins)
	},

	GamePacks = {
		Page = "GamePackPage",
		Items = require(ShopData.GamePacks)
	}

}

return ShopConfig