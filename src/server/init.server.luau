local Managers = script.Managers

local LoadedManagers = {}

for _, module in ipairs(Managers:GetChildren()) do
	if module:IsA("ModuleScript") then
		local manager = require(module)

		if manager.Init then
			manager:Init()
		end

		table.insert(LoadedManagers, manager)
	end
end

print("Loaded", #LoadedManagers, "Managers")