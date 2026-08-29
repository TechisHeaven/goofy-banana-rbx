local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared =
ReplicatedStorage:WaitForChild("Shared")

local ShopController = require(script.Parent.ShopController
)
local ShopConfig = require(Shared.Config.ShopConfig)

local RemoteIndex =
	require(Shared.Remotes.RemoteIndex)

local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local PopupGui = PlayerGui:WaitForChild("PopupGui")
local Overlay = PopupGui:WaitForChild("Overlay")
local DailyRewardFrame = Overlay:WaitForChild("DailyRewardFrame")
local ShopFrame = Overlay:WaitForChild("ShopFrame")
-----------------------------------------------------
-- Remotes
-----------------------------------------------------

local Remotes =
	Shared:WaitForChild("Remotes")

local function getRemote(name)

	return Remotes:WaitForChild(name)

end

local OpenUI = getRemote(RemoteIndex.Events.OpenUI)


local PopupModule = require(ReplicatedStorage.Shared.Modules.PopupModule)

-----------------------------------------------------
-- Controller
-----------------------------------------------------

local OpenUIController = {}

-----------------------------------------------------
-- Init
-----------------------------------------------------

function OpenUIController:OpenShop()
	PopupModule:Open(ShopFrame, {
		CanClickOutsideToClose = false
	})
	ShopController:OpenShop(ShopConfig.DefaultOffersPage)
end


function OpenUIController:Init()

	print(
		"DailyRewardController Initialized"
	)



	OpenUI.OnClientEvent:Connect(function(uiName)
		if uiName == "DailyReward" then
			PopupModule:Open(DailyRewardFrame, {
				CanClickOutsideToClose = true
			})
		end

        if uiName == "Shop" then
           self:OpenShop()
        end

	end)
end

return OpenUIController