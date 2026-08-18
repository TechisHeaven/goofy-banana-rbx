local Players =
	game:GetService("Players")

local ServerStorage =
	game:GetService("ServerStorage")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- MODULES
------------------------------------------------

local AttachmentModule =
	require(
		ReplicatedStorage
			.Shared
			.Modules
			.AttachmentModule
	)
local GameplayItemDropModule =
	require(
		ReplicatedStorage.Shared.Modules.GameplayItemDropModule
	)
local BananaSkinManager =
	require(
		script.Parent.BananaSkinManager
	)

local GameplayItemConfig =
	require(
		ReplicatedStorage
			.Shared
			.Config
			.GameplayItemConfig
	)

------------------------------------------------
-- FOLDER
------------------------------------------------

local GameplayItemsFolder =
	ServerStorage:WaitForChild(
		"GameplayItems"
	)




------------------------------------------------
-- REMOTES
------------------------------------------------

local Shared = ReplicatedStorage.Shared
local RemoteIndex =
    require(Shared.Remotes.RemoteIndex).Events

local Remotes = Shared.Remotes



local ItemRequest =
	Remotes:WaitForChild(
		RemoteIndex.GameplayItemRequest
	)

local ItemState =
	Remotes:WaitForChild(
		RemoteIndex.GameplayItemState
	)

------------------------------------------------
-- MANAGER
------------------------------------------------

local GameplayItemManager = {}

------------------------------------------------
-- TEMPORARY SERVER STATE
------------------------------------------------

local PlayerItems = {}

------------------------------------------------
-- CREATE STATE
------------------------------------------------

local function CreateState()

	return {
		Item = nil,
		Selected = nil,
		Equipped = false,
		SkinId = nil
	}

end

------------------------------------------------
-- GET STATE
------------------------------------------------

function GameplayItemManager:GetState(
	player
)

	if not PlayerItems[player] then

		PlayerItems[player] =
			CreateState()

	end

	return PlayerItems[player]

end



------------------------------------------------
-- SEND STATE
------------------------------------------------

function GameplayItemManager:SendState(
	player
)

	local state =
		self:GetState(player)

	ItemState:FireClient(
		player,
		{
			Item = state.Item,
			Selected = state.Selected,
			Equipped = state.Equipped,
			SkinId = state.SkinId
		}
	)

end



------------------------------------------------
-- GIVE ITEM
------------------------------------------------

function GameplayItemManager:Give(
	player,
	itemId,
	skinId
)

	if not GameplayItemConfig[itemId] then

		warn(
			"[GameplayItemManager] Unknown item:",
			itemId
		)

		return false
	end

	local state =
		self:GetState(player)

	------------------------------------------------
	-- Remove current item
	------------------------------------------------

	if state.Item then

		self:ClearVisual(
			player
		)

	end
	

	state.Item =
		itemId

	state.Selected =
		itemId

	state.Equipped =
		false
		
	state.SkinId =
		skinId

	self:SendState(player)

	print(
		"[GameplayItemManager] Given:",
		player.Name,
		itemId
	)

	return true

end


function GameplayItemManager:PickUp(
	player,
	itemId,
	skinId
)
	return self:Give(
		player,
		itemId,
		skinId
	)
end


------------------------------------------------
-- HAS ITEM
------------------------------------------------


function GameplayItemManager:HasItem(
	player
)

	local state =
		self:GetState(player)

	return state.Item ~= nil

end

function GameplayItemManager:Select(
	player,
	itemId
)

	local state =
		self:GetState(player)

	if state.Item ~= itemId then
		return false
	end

	state.Selected =
		itemId

	self:SendState(player)

	return true

end

------------------------------------------------
-- CLEAR VISUAL
------------------------------------------------

function GameplayItemManager:ClearVisual(
	player
)

	local character =
		player.Character

	if not character then
		return
	end

	for _, object in ipairs(
		character:GetChildren()
	) do

		if object:GetAttribute(
			"GameplayItem"
		) == true then

			object:Destroy()

		end

	end

end

------------------------------------------------
-- EQUIP
------------------------------------------------

function GameplayItemManager:Equip(
	player
)

	local state =
		self:GetState(player)

	local itemId =
		state.Selected

	if not itemId then
		return false
	end

	if state.Item ~= itemId then
		return false
	end

	if state.Equipped then
		return true
	end

	local config =
		GameplayItemConfig[itemId]

	if not config then
		return false
	end

	local character =
		player.Character

	if not character then
		return false
	end

	------------------------------------------------
	-- Find item folder
	------------------------------------------------

	local itemFolder =
		GameplayItemsFolder:FindFirstChild(
			itemId
		)

	if not itemFolder then

		warn(
			"[GameplayItemManager] Missing item folder:",
			itemId
		)

		return false
	end

	------------------------------------------------
	-- Find model
	------------------------------------------------

	local source =
		itemFolder:FindFirstChild(
			config.Model
		)

	if not source then

		warn(
			"[GameplayItemManager] Missing model:",
			config.Model
		)

		return false
	end

	------------------------------------------------
	-- Clone
	------------------------------------------------

	local visual =
		source:Clone()

	visual.Name =
		"EquippedGameplayItem"

	visual:SetAttribute(
		"GameplayItem",
		true
	)

	visual.Parent =
		character

	------------------------------------------------
	-- Attach
	------------------------------------------------

	local success =
		AttachmentModule:Attach(
			character,
			visual,
			config.AttachTo,
			config.Attachment,
			config.Offset
		)

	if not success then

		visual:Destroy()

		return false

	end
	if itemId == "Banana" then
		-- local equippedSkinId =
		-- BananaSkinManager:GetEquipped(
		-- 	player
		-- )

		-- if state.SkinId ~= equippedSkinId then

		-- 	state.SkinId =
		-- 		equippedSkinId

		-- end

		if not state.SkinId then

			state.SkinId =
				BananaSkinManager:GetEquipped(
					player
				)

		end
		BananaSkinManager:Apply(
			player,
			visual,
			state.SkinId
		)

	end

	state.Equipped =
		true

	self:SendState(
		player
	)

	print(
		"[GameplayItemManager] Equipped:",
		player.Name,
		itemId
	)

	return true

end
------------------------------------------------
-- UNEQUIP
------------------------------------------------

function GameplayItemManager:Unequip(
	player
)

	local state =
		self:GetState(player)

	if not state.Equipped then
		return false
	end

	self:ClearVisual(
		player
	)

	state.Equipped =
		false

	self:SendState(
		player
	)

	print(
		"[GameplayItemManager] Unequipped:",
		player.Name
	)

	return true

end


------------------------------------------------
-- TOGGLE
------------------------------------------------

function GameplayItemManager:Toggle(
	player
)

	local state =
		self:GetState(player)
	print("state", state)
	if not state.Selected then
		return false
	end

	if state.Equipped then

		return self:Unequip(
			player
		)

	end

	return self:Equip(
		player
	)
end


function GameplayItemManager:Drop(
	player
)

	local state =
		self:GetState(player)

	local itemId =
		state.Item

	if not itemId then
		return false
	end

	------------------------------------------------
	-- Remove equipped visual
	------------------------------------------------

	self:ClearVisual(
		player
	)
	
	local skinId = nil
	print("itemid", itemId)
	print("stateid", state.skinId)
	if itemId == "Banana" then
		skinId = state.SkinId
	end

	
	GameplayItemDropModule:Create(
		player,
		itemId,
		skinId,

		function(
			picker,
			pickedItemId,
			pickedSkinId
		)
			print("picked skin", pickedSkinId)
			return self:PickUp(
				picker,
				pickedItemId,
				pickedSkinId
			)

		end
	)

	------------------------------------------------
	-- Clear state
	------------------------------------------------

	state.Item =
		nil

	state.Selected =
		nil

	state.Equipped =
		false

	self:SendState(
		player
	)

	print(
		"[GameplayItemManager] Dropped:",
		player.Name,
		itemId
	)

	return true

end

function GameplayItemManager:GetItem(
	player
)

	local state =
		self:GetState(player)

	return state.Item

end


function GameplayItemManager:GetSelected(
	player
)

	local state =
		self:GetState(player)

	return state.Selected

end
------------------------------------------------
-- GET EQUIPPED
------------------------------------------------

function GameplayItemManager:GetEquipped(
	player
)

	local state =
		self:GetState(player)

	return state.Equipped

end

------------------------------------------------
-- CHARACTER RESPAWN
------------------------------------------------

function GameplayItemManager:ApplyCharacter(
	player
)

	local state =
		PlayerItems[player]

	if not state then
		return
	end

	if not state.Equipped then
		return
	end

	self:Equip(
		player
	)

end

------------------------------------------------
-- REMOVE GAMEPLAY ITEM
------------------------------------------------

function GameplayItemManager:Remove(
	player,
	itemId
)

	if not player then
		return false
	end

	local state =
		PlayerItems[player]

	if not state then
		return false
	end

	------------------------------------------------
	-- Only remove if this is the current item
	------------------------------------------------

	if itemId
		and state.Item ~= itemId then

		return false

	end

	------------------------------------------------
	-- Remove equipped visual
	------------------------------------------------

	if player.Character then

		for _, object in ipairs(
			player.Character:GetDescendants()
		) do

			if object:GetAttribute(
				"GameplayItemVisual"
			) == true then

				object:Destroy()

			end

		end

	end
	
	------------------------------------------------
	-- Clear temporary state
	------------------------------------------------

	state.Item = nil
	state.Selected = nil
	state.Equipped = false
	state.SkinId = nil

	------------------------------------------------
	-- Update client
	------------------------------------------------

	self:SendState(
		player
	)

	print(
		"[GameplayItemManager] Removed:",
		player.Name,
		itemId or "Current Item"
	)

	return true

end

------------------------------------------------
-- PLAYER SETUP
------------------------------------------------

function GameplayItemManager:Init()

	Players.PlayerAdded:Connect(
		function(player)

			PlayerItems[player] =
				CreateState()

			player.CharacterAdded:Connect(
				function()

					task.wait(0.2)

					self:ApplyCharacter(
						player
					)

				end
			)

		end
	)

	Players.PlayerRemoving:Connect(
		function(player)

			PlayerItems[player] =
				nil

		end
	)

	------------------------------------------------
	-- CLIENT REQUESTS
	------------------------------------------------

	ItemRequest.OnServerEvent:Connect(
		function(
			player,
			action,
			itemId
		)

			if typeof(action) ~= "string" then
				return
			end

			if action == "Select" then

				if typeof(itemId) ~= "string" then
					return
				end

				self:Select(
					player,
					itemId
				)
			elseif action == "Toggle" then

				self:Toggle(
					player
				)

			elseif action == "Equip" then

				self:Equip(
					player
				)

			elseif action == "Unequip" then

				self:Unequip(
					player
				)
			elseif action == "Drop" then

				self:Drop(
					player
				)
				
			elseif action == "State" then

				self:SendState(
					player
				)
		
			end

		end
	)

end

return GameplayItemManager