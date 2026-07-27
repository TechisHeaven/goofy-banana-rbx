local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local ShopConfig = require(Shared.Config.ShopConfig)

local ShopManager = {}

function ShopManager:GetCategory(name)

	return ShopConfig.Categories[name]

end

return ShopManager