local UserInputService =
	game:GetService("UserInputService")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

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
-- CONTROLLER
------------------------------------------------

local GameplayItemController = {}

GameplayItemController.Item = nil
GameplayItemController.Equipped = nil
GameplayItemController.SelectedItem = nil

------------------------------------------------
-- SELECTED ITEM
------------------------------------------------


------------------------------------------------
-- SELECT
------------------------------------------------

function GameplayItemController:Select(
	itemId
)

	ItemRequest:FireServer(
		"Select",
		itemId
	)

end

------------------------------------------------
-- TOGGLE
------------------------------------------------

function GameplayItemController:Toggle()

	if not self.Selected then
		return
	end

	ItemRequest:FireServer(
		"Toggle"
	)

end


function GameplayItemController:Drop()

	if not self.Item then
		return
	end

	ItemRequest:FireServer(
		"Drop"
	)

end


------------------------------------------------
-- STATE FROM SERVER
------------------------------------------------

function GameplayItemController:Init()

	ItemState.OnClientEvent:Connect(
		function(data)
			if not data then
				return
			end

			self.Item =
				data.Item

			self.Selected =
				data.Selected

			self.Equipped =
				data.Equipped

			
			print(
				"[GameplayItemController]",
				"Item:",
				self.Item,
				"Selected:",
				self.Selected,
				"Equipped:",
				self.Equipped
			)

			------------------------------------------------
			-- UI update later
			------------------------------------------------

		end
	)

	------------------------------------------------
	-- E
	------------------------------------------------

	UserInputService.InputBegan:Connect(
		function(
			input,
			gameProcessed
		)

			if gameProcessed then
				return
			end

			if input.KeyCode
				== Enum.KeyCode.E then

				self:Toggle()

			end

			if input.KeyCode == Enum.KeyCode.Q then
				GameplayItemController:Drop()
			end

		end
	)

	------------------------------------------------
	-- Get current server state
	------------------------------------------------

	ItemRequest:FireServer(
		"State"
	)

	-- task.wait(6)
	-- ItemRequest:FireServer("Select", "Banana")

end

return GameplayItemController