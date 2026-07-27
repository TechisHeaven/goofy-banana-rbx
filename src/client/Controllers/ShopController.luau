local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local ShopConfig = require(Shared.Config.ShopConfig)

local ShopUI = require(script.Parent.Parent.UI.ShopUI)

----------------------------------------------------

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local LobbyGui = PlayerGui:WaitForChild("LobbyGui")

local ShopButton = LobbyGui.Center.Left.ShopButton

----------------------------------------------------

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

	ShopUI:ShowPage(category.Page)

	if category.Page == "DefaultPage" then

		ShopUI:RenderItems(category.Items)

	else

		ShopUI:RenderGamePacks(category.Items)

	end

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

	------------------------------------------------
	-- Tabs
	------------------------------------------------

	ShopUI.OnTabChanged = function(category)

		OpenCategory(category)

	end

end

----------------------------------------------------

return ShopController