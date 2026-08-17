local Managers = script.Managers
local LoadOrder = {
	"LobbyManager",        -- Creates all remotes first
	"ProfileManager",
	"PlayerManager",
	"InventoryManager",
	"ShopManager",
	"FreezeManager",
	"SpawnManager",
	"RoundEventManager",
	"VictoryManager",
	"RoundManager",
	"DailyRewardManager",
	"CurrencyManager",
	"CoinManager",
	"MonetizationManager",
	"TaskManager",
	"CosmeticManager",
	"GameplayItemManager",
	"BananaPeelManager",
}




local LoadedManagers = {}

-- for _, module in ipairs(Managers:GetChildren()) do
-- 	if module:IsA("ModuleScript") then
-- 		local manager = require(module)

-- 		if manager.Init then
-- 			manager:Init()
-- 		end
-- 		table.insert(LoadedManagers, manager)
-- 	end
-- end

for _, name in ipairs(LoadOrder) do

	local module = Managers:FindFirstChild(name)

	if not module then
		error(("Missing manager: %s"):format(name))
	end

	local manager = require(module)

	if manager.Init then
		manager:Init()
	end

	LoadedManagers[name] = manager

end

print("Loaded", #LoadedManagers, "Managers")



local Players = game:GetService("Players")

task.wait(8)

local GameplayItemManager =
	LoadedManagers["GameplayItemManager"]

GameplayItemManager:Give(
	Players:GetPlayers()[1],
	"Banana"
)
-- GameplayItemManager:Select(Players:GetPlayers()[1], "Banana")
