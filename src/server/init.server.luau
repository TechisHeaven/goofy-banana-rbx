local Managers = script.Managers
local Services = script.Services


local LoadOrder = {
	"RemoteManager",  -- Creates all remotes first
	"ProfileManager",
	"LobbyManager",
	"PlayerManager",
	"InventoryManager",
	"ShopManager",
	"FreezeManager",
	"SpawnManager",
	"RoundEventManager",
	"VictoryManager",
	"RoundManager",
	"CurrencyManager",
	"CoinManager",
	"MonetizationManager",
	"DailyRewardManager",
	"TaskManager",
	"CosmeticManager",
	"GameplayItemManager",
	"BananaPeelManager",
	"HelpSignalManager",
	"CharacterAppearanceManager",
	"BallManager",
}


local ServicesLoadOrder = {
	"SettingsService",
	"RedeemCodeService",
	"SettingsService",
}

local LoadedServices = {}
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

-------------------------------------------------------
-- LOAD SERVICES IN ORDER
-------------------------------------------------------

for _, name in ipairs(ServicesLoadOrder) do

	local module = Services:FindFirstChild(name)

	if not module then
		error(("Missing service: %s"):format(name))
	end

	if not module:IsA("ModuleScript") then
		error(("Service is not a ModuleScript: %s"):format(name))
	end

	local service = require(module)

	if service.Init then
		service:Init()
	end

	LoadedServices[name] = service

end

print("Loaded", #LoadedServices, "Services")