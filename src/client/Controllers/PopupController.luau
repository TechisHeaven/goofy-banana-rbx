local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PopupModule = require(ReplicatedStorage.Shared.Modules.PopupModule)

------------------------------------------------
-- Controller
------------------------------------------------

local PopupController = {}

------------------------------------------------
-- Init
------------------------------------------------

function PopupController:Init()

	print("PopupController Initialized")

	------------------------------------------------
	-- Player
	------------------------------------------------

	local player =
		Players.LocalPlayer

	if not player then
		warn(
			"[PopupController] LocalPlayer not available"
		)

		return
	end

	------------------------------------------------
	-- UI
	------------------------------------------------

	local PlayerGui =
		player:WaitForChild("PlayerGui")

	local PopupGui =
		PlayerGui:WaitForChild("PopupGui")

	local Overlay =
		PopupGui:WaitForChild("Overlay")

	------------------------------------------------
	-- Initialize PopupModule
	------------------------------------------------

	PopupModule:Init(Overlay)

end

------------------------------------------------

return PopupController