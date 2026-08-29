local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local ShopConfig = require(Shared.Config.ShopConfig)

local ShopUI = require(script.Parent.Parent.UI.ShopUI)
local InventoryController = require(script.Parent.Parent.Controllers.InventoryController)
----------------------------------------------------

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local LobbyGui = PlayerGui:WaitForChild("LobbyGui")

local ShopButton = LobbyGui.Center.Left.ShopButton

----------------------------------------------------
local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Functions
local RemoteEvents = RemoteIndexData.Events
----------------------------------------------------

local Remotes = Shared:WaitForChild("Remotes")

local function getRemote(name: RemoteFunction)

	return Remotes:WaitForChild(name)

end

local ShopController = {}

local CurrentCategory

----------------------------------------------------

local function OpenCategory(categoryName)

	local category = ShopConfig.Categories[categoryName]

	if not category then
		warn("Unknown Shop Category:", categoryName)
		return
	end
	
	CurrentCategory = categoryName

		-- ShopUI:ShowLoading(true)
	local items = getRemote(RemoteIndex.GetShopItems):InvokeServer(categoryName)
	-- ShopUI:ShowLoading(false)
	ShopUI:ShowPage(category.Page)


	if category.Page == "DefaultPage" then

		ShopUI:RenderItems(items)

	else

		ShopUI:RenderGamePacks(items)

	end

end


function ShopController:OpenShop(page)
	if not page then
		page = ShopConfig.DefaultOffersPage
	end
	OpenCategory(page)
end
----------------------------------------------------

function ShopController:Init()

	print("ShopController Initialized")

	ShopUI:Init()

	------------------------------------------------
	-- Open Shop
	------------------------------------------------

	ShopButton.Activated:Connect(function()

		ShopUI:Open()

		OpenCategory(ShopConfig.DefaultCategory)

	end)

	ShopUI.OnBuyPressed = function(category, itemId)
		local success, message = getRemote(RemoteIndex.RequestPurchase):InvokeServer(category, itemId)

		if success then
			OpenCategory(CurrentCategory)
		else
			-- Show notification
		end

	end


	ShopUI.OnOwnedItemPressed = function(category, itemId)
		InventoryController:OpenItem(
			category,
			itemId
		)
	end
	------------------------------------------------
	-- Tabs
	------------------------------------------------

	ShopUI.OnTabChanged = function(category)

		OpenCategory(category)

	end

	getRemote(RemoteEvents.UpdateInventory)
	.OnClientEvent
	:Connect(function()
		if CurrentCategory then
			OpenCategory(CurrentCategory)
		end

	end)

end

----------------------------------------------------

return ShopController