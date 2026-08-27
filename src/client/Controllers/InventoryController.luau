local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
local RemoteIndexFunctions = RemoteIndexData.Functions

local InventoryConfig =
	require(Shared.Config.InventoryConfig)

local InventoryUI =
	require(script.Parent.Parent.UI.InventoryUI)

----------------------------------------------------

local Remotes = Shared:WaitForChild("Remotes")

local function getRemote(name)

	return Remotes:WaitForChild(name)

end

----------------------------------------------------

local InventoryController = {}

local InventoryData = {}

local CurrentCategory

----------------------------------------------------

local function OpenCategory(category)

	CurrentCategory = category

	local config =
		InventoryConfig.Categories[category]

	if not config then
		return
	end

	InventoryUI:OpenCategory(category)

	local items =
		getRemote(RemoteIndexFunctions.GetInventoryItems)
		:InvokeServer(category)


	InventoryUI:RenderItems(
		category,
		items
	)

end

----------------------------------------------------
-- Open specific inventory item
----------------------------------------------------

function InventoryController:OpenItem(
	category,
	itemId
)

	if not category then
		return
	end

	local config =
		InventoryConfig.Categories[category]

	if not config then
		warn(
			"[InventoryController] Unknown category:",
			category
		)
		return
	end

	CurrentCategory = category

	InventoryUI:Open()

	OpenCategory(category)

	------------------------------------------------
	-- Tell UI which item should be selected
	------------------------------------------------

	if InventoryUI.SelectItem then
		InventoryUI:SelectItem(itemId)
	end

end

----------------------------------------------------

local function OnInventoryUpdate()
	  if CurrentCategory then
        OpenCategory(CurrentCategory)
    end
end

----------------------------------------------------

local function OnEquip(category,itemId)

	getRemote(RemoteIndex.RequestEquip)
		:FireServer(category,itemId)

end

----------------------------------------------------

function InventoryController:Init()

	print("InventoryController Initialized")

	InventoryUI:Init()

	InventoryUI.OnEquipPressed = OnEquip

	InventoryUI.OnTabChanged = function(category)

		OpenCategory(category)

	end

	InventoryUI.OnOpened = function()
		OpenCategory(CurrentCategory or InventoryConfig.DefaultCategory)
	end


    InventoryUI.OnEquipPressed = function(category, id)

        getRemote(RemoteIndex.RequestEquip)
            :FireServer(category, id)

    end

    InventoryUI.OnUnequipPressed = function(category, id)

        getRemote(RemoteIndex.RequestUnequip)
            :FireServer(category, id)

    end

	getRemote(RemoteIndex.UpdateInventory)
		.OnClientEvent
		:Connect(OnInventoryUpdate)


	OpenCategory(
		InventoryConfig.DefaultCategory
	)

end

----------------------------------------------------

return InventoryController