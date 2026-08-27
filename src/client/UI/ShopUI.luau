local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local PopupGui = PlayerGui:WaitForChild("PopupGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PopupManager = require(ReplicatedStorage.Shared.Modules.PopupModule)
local Shared = ReplicatedStorage.Shared
------------------------------------------------

local Overlay = PopupGui.Overlay
local ShopFrame = Overlay.ShopFrame

local RarityConfig =
	require(Shared.Config.RarityConfig)
local ShopConfig= require(Shared.Config.ShopConfig)
------------------------------------------------
-- Pages
------------------------------------------------

local Pages = ShopFrame.Pages

local DefaultPage = Pages.DefaultPage
local GamePackPage = Pages.GamePackPage

------------------------------------------------
-- Templates
------------------------------------------------

local DefaultScroll = DefaultPage
local DefaultTemplate = DefaultScroll.Item


DefaultTemplate.Visible = false

local PackScroll = GamePackPage
local PackTemplate = PackScroll.Item

PackTemplate.Visible = false



------------------------------------------------
-- Tabs
------------------------------------------------

local Tabs = ShopFrame.Tabs
local defaultTab = Tabs:FindFirstChild(ShopConfig.DefaultCategory)

------------------------------------------------

local ShopUI = {}
ShopUI.OnBuyPressed = nil
ShopUI.OnTabChanged = nil
ShopUI.OnOwnedItemPressed = nil

local CurrentTab = nil

local NORMAL_IMAGE = "rbxassetid://140549211259515"
local SELECTED_IMAGE = "rbxassetid://115943360307489"
local ROBUX_CURRENCY_IMAGE = "rbxassetid://97754220698381"
local COIN_CURRENCY_IMAGE = "rbxassetid://99841109202747"
------------------------------------------------

local function Clear(parent, template)

	for _, child in ipairs(parent:GetChildren()) do

		if child:IsA("Frame") and child ~= template then
			child:Destroy()
		end

	end

end

------------------------------------------------

-- local function SelectTab(tab)

-- 	if CurrentTab and tab.Name ~= "Coins"  then
-- 		CurrentTab.Image =
-- 			"rbxassetid://78379740934807"

-- 	end

-- 	CurrentTab = tab
-- 	tab.Image = "rbxassetid://112933688047512"

-- end

local function SelectTab(tab)

	if not tab then
		return
	end

	-- Reset previous tab (except Coins & GamePacks)
	if CurrentTab
		and CurrentTab.Name ~= "Coins"
		and CurrentTab.Name ~= "GamePacks" then

		CurrentTab.Image = NORMAL_IMAGE

	end

	CurrentTab = tab

	-- Highlight selected tab (except Coins & GamePacks)
	if tab.Name ~= "Coins"
		and tab.Name ~= "GamePacks" then

		tab.Image = SELECTED_IMAGE

	end

end

------------------------------------------------

function ShopUI:Init()

	PopupManager:Init(Overlay)

	if defaultTab then
		SelectTab(defaultTab)
	end

	for _,tab in ipairs(Tabs:GetChildren()) do

		if not tab:IsA("ImageButton")
		and not tab:IsA("TextButton") then
			continue
		end

		tab.Activated:Connect(function()

			SelectTab(tab)

			if self.OnTabChanged then
				self.OnTabChanged(tab.Name)
			end

		end)

	end

end

------------------------------------------------

function ShopUI:Open()
	PopupManager:Open(ShopFrame, {
        CanClickOutsideToClose = false
    })
end

------------------------------------------------

function ShopUI:Close()
	PopupManager:Close(ShopFrame)
end

------------------------------------------------

function ShopUI:ShowPage(name)

	DefaultPage.Visible = false
	GamePackPage.Visible = false

	Pages[name].Visible = true

end

------------------------------------------------

function ShopUI:RenderItems(items)

	Clear(DefaultScroll, DefaultTemplate)

    -- print(items)

	for _,data in ipairs(items) do

		local item = DefaultTemplate:Clone()

        local rarity =
	RarityConfig[data.Rarity]

		item.Name = "Item"
		item.Visible = true
		item.Parent = DefaultScroll
		item.Title.Text = data.Name

		item.Preview.Item.Image = data.Image
        local price = if data.Price <= 0 then "Free" else tostring(data.Price)
		

		local buttonImage = if data.Currency == "Robux" then ROBUX_CURRENCY_IMAGE else COIN_CURRENCY_IMAGE
		item.Button.Visible = false
		item.EquipButton.Visible = false
		if data.Owned then

			item.EquipButton.Visible = true

			if data.Equipped then
				item.EquipButton.Title.Text = "Equipped"
			else
				item.EquipButton.Title.Text = "Equip"
			end

			item.Button.Active = false

			item.EquipButton.Activated:Connect(function()

				if self.OnOwnedItemPressed then
					self.OnOwnedItemPressed(
						data.Category,
						data.Id
					)
				end

			end)

		else

			item.Button.Active = true
			item.Button.Visible = true

			item.Button.ButtonFrame.Coin.Image = buttonImage
			item.Button.ButtonFrame.Coin.Visible = true
			item.Button.ButtonFrame.Price.Text = price

			item.Button.Activated:Connect(function()

				if self.OnBuyPressed then
					self.OnBuyPressed(
						data.Category,
						data.Id
					)
				end

			end)

		end
		
        item.Preview.Background.Image =
            rarity.Background

        item.Preview.Info.Text =
            rarity.Name

        item.Preview.Info.TextColor3 =
            rarity.Color

	end

end

------------------------------------------------

function ShopUI:RenderGamePacks(items)

	Clear(PackScroll, PackTemplate)

    -- print(items)

	for _,data in ipairs(items) do
		local rewards = data.Rewards
		local pack = PackTemplate:Clone()

		pack.Name = "Item"

		pack.Visible = true

		pack.Parent = PackScroll

		pack.Title.Text = data.Name

		pack.Preview.Background.Image = data.Image

		pack.Button.ButtonFrame.Price.Text =
			tostring(data.Price)
        pack.Button.Activated:Connect(function()
				if self.OnBuyPressed then
					self.OnBuyPressed(data.Category, data.Id)
				end

			end)
		local coins = pack.Preview.Rewards.Coins.CoinsFrame

		coins.Price.Text = tostring(rewards.Coins.Amount)

		local skins = pack.Preview.Rewards.Skins

		for _, child in ipairs(skins:GetChildren()) do
			if child:IsA("ImageLabel") then
				child:Destroy()
			end
		end

		for _, skin in ipairs(rewards.Skins) do

			local image = Instance.new("ImageLabel")

			image.BackgroundTransparency = 1
			image.Size = UDim2.fromOffset(91,75)
			image.Image = skin.Image

			image.Parent = skins

		end

		local bananaSkins = pack.Preview.Rewards.BananaSkins

		for _, child in ipairs(bananaSkins:GetChildren()) do
			if child:IsA("ImageLabel") then
				child:Destroy()
			end
		end

		for _, skin in ipairs(rewards.BananaSkins) do

			local image = Instance.new("ImageLabel")

			image.BackgroundTransparency = 1
			image.Size = UDim2.fromOffset(72,60)
			image.Image = skin.Image

			image.Parent = bananaSkins

		end
		------------------------------------------------
		-- Rewards
		------------------------------------------------

		-- Later:
		-- Coins
		-- Heads
		-- Banana Skin
		-- Icons
		------------------------------------------------

	end

end

------------------------------------------------

return ShopUI