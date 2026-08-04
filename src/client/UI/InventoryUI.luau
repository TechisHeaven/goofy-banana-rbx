local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local PopupGui = PlayerGui:WaitForChild("PopupGui")
local LobbyGui = PlayerGui:WaitForChild("LobbyGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PopupManager =
	require(ReplicatedStorage.Shared.Modules.PopupModule)

local Shared = ReplicatedStorage.Shared

local InventoryConfig =
	require(Shared.Config.InventoryConfig)

local RarityConfig =
	require(Shared.Config.RarityConfig)

------------------------------------------------

local InventoryButton =
	LobbyGui.Center.Left.BagButton

local Overlay = PopupGui.Overlay
local InventoryFrame = Overlay.InventoryFrame

------------------------------------------------
-- Pages
------------------------------------------------

local Pages = InventoryFrame.Pages

local DefaultPage = Pages.DefaultPage

------------------------------------------------
-- Template
------------------------------------------------

local DefaultScroll = DefaultPage
local DefaultTemplate = DefaultScroll.Item

DefaultTemplate.Visible = false

------------------------------------------------
-- Tabs
------------------------------------------------

local Tabs = InventoryFrame.Tabs

------------------------------------------------

local InventoryUI = {}

InventoryUI.OnEquipPressed = nil
InventoryUI.OnUnequipPressed = nil
InventoryUI.OnTabChanged = nil

local CurrentTab

------------------------------------------------

local function Clear()

	for _,child in ipairs(DefaultScroll:GetChildren()) do

		if child:IsA("Frame")
			and child ~= DefaultTemplate then

			child:Destroy()

		end

	end

end

------------------------------------------------

local NORMAL_IMAGE =
	"rbxassetid://78379740934807"

local SELECTED_IMAGE =
	"rbxassetid://112933688047512"

function InventoryUI:SetSelectedTab(name)

	local tab = Tabs:FindFirstChild(name)

	if not tab then
		return
	end

	if CurrentTab then
		CurrentTab.Image = NORMAL_IMAGE
	end

	CurrentTab = tab

	CurrentTab.Image = SELECTED_IMAGE

end

------------------------------------------------

function InventoryUI:Init()

	PopupManager:Init(Overlay)

	InventoryButton.Activated:Connect(function()

		self:Open()

	end)

	for _,tab in ipairs(Tabs:GetChildren()) do

		if not tab:IsA("ImageButton") then
			continue
		end

		tab.Activated:Connect(function()

			self:SetSelectedTab(tab.Name)

			if self.OnTabChanged then

				self.OnTabChanged(tab.Name)

			end

		end)

	end

	self:SetSelectedTab(
		InventoryConfig.DefaultCategory
	)

end

------------------------------------------------

function InventoryUI:Open()

	PopupManager:Open(
		InventoryFrame,
		{
			CanClickOutsideToClose = false
		}
	)

end

------------------------------------------------

function InventoryUI:Close()

	PopupManager:Close(InventoryFrame)

end

------------------------------------------------

function InventoryUI:ShowPage(page)

	for _,child in ipairs(Pages:GetChildren()) do

		if child:IsA("Frame") then

			child.Visible = false

		end

	end

	Pages[page].Visible = true

end

------------------------------------------------

function InventoryUI:RenderItems(category,items)

	Clear()
	for _,data in ipairs(items) do

		local item = DefaultTemplate:Clone()

		item.Name = "Item"
		item.Visible = true
		item.Parent = DefaultScroll

		-------------------------------------

		local rarity =
			RarityConfig[data.Rarity]

		item.Title.Text = data.Name

		item.Preview.Item.Image = data.Image

		item.Preview.Background.Image =
			rarity.Background

		item.Preview.Info.Text =
			rarity.Name

		item.Preview.Info.TextColor3 =
			rarity.Color

		-------------------------------------
		-- Button
		-------------------------------------
        local equipButton = item.EquipButton
        local equippedButton = item.EquippedButton

        equipButton.Visible = false
        equippedButton.Visible = false

		if data.Equipped then

        equippedButton.Visible = true

        equippedButton.Activated:Connect(function()

            if InventoryUI.OnUnequipPressed then

                InventoryUI.OnUnequipPressed(
                    category,
                    data.Id
                )

            end

        end)

        ------------------------------------------------
        -- Owned
        ------------------------------------------------

        elseif data.Owned then

            equipButton.Visible = true

            equipButton.Activated:Connect(function()

                if InventoryUI.OnEquipPressed then

                    InventoryUI.OnEquipPressed(
                        category,
                        data.Id
                    )

                end

            end)

        ------------------------------------------------
        -- Locked
        ------------------------------------------------

        else

            equipButton.Visible = true

            equipButton.Title.Text = "Locked"

            equipButton.Active = false
            equipButton.AutoButtonColor = false

        end

	end

end

------------------------------------------------

return InventoryUI