local Players =
	game:GetService("Players")

local player =
	Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
------------------------------------------------
-- MODULE
------------------------------------------------

local BananaUIController = {}
local GameConfig = require(Shared.GameConfig)
------------------------------------------------
-- SETTINGS
------------------------------------------------

local COOLDOWN_DURATION = GameConfig.BananaPeel.PlacementCooldown or 10
local EQUIPPED_TRANSPARENCY = 0.5
local NORMAL_TRANSPARENCY = 1

------------------------------------------------
-- STATE
------------------------------------------------

local initialized = false

local cooldownActive = false

------------------------------------------------
-- UI
------------------------------------------------

local bananaButton
local cooldownLabel

------------------------------------------------
-- GET UI
------------------------------------------------

local function GetUI()

	local playerGui =
		player:WaitForChild(
			"PlayerGui"
		)

	local gameGui =
		playerGui:WaitForChild(
			"GameGui"
		)

	local bottom =
		gameGui:WaitForChild(
			"Bottom"
		)

	local Item =
		bottom:WaitForChild(
			"Item"
		)

	bananaButton =
		Item:WaitForChild(
			"BananaButton"
		)

	cooldownLabel =
		bananaButton:WaitForChild(
			"Cooldown"
		)

end

------------------------------------------------
-- EQUIPPED STATE
------------------------------------------------

local function UpdateEquippedState()

	local character =
		player.Character

	if not character then
		return
	end

	local heldItemId =
		character:GetAttribute(
			"HeldItemId"
		)

	if heldItemId == "Banana" then

		bananaButton.BackgroundTransparency =
			EQUIPPED_TRANSPARENCY

	else

		bananaButton.BackgroundTransparency =
			NORMAL_TRANSPARENCY

	end

end

------------------------------------------------
-- COOLDOWN
------------------------------------------------

function BananaUIController:StartCooldown(
	duration
)

	duration =
		duration
		or COOLDOWN_DURATION

	if cooldownActive then
		return
	end

	cooldownActive = true

	task.spawn(
		function()

			for remaining = duration, 1, -1 do

				if cooldownLabel
					and cooldownLabel.Parent then

					cooldownLabel.Text =
						tostring(remaining).. 's'

				end

				task.wait(1)

			end

			if cooldownLabel
				and cooldownLabel.Parent then

				cooldownLabel.Text =
					""

			end

			cooldownActive = false

		end
	)

end

------------------------------------------------
-- CHECK COOLDOWN
------------------------------------------------

function BananaUIController:IsOnCooldown()

	return cooldownActive

end

------------------------------------------------
-- INIT
------------------------------------------------

function BananaUIController:Init()

	if initialized then
		return
	end

	initialized = true

	GetUI()

	------------------------------------------------
	-- INITIAL STATE
	------------------------------------------------

	UpdateEquippedState()

	------------------------------------------------
	-- WATCH HELD ITEM
	------------------------------------------------

	local function SetupCharacter(
		character
	)

		character:GetAttributeChangedSignal(
			"HeldItemId"
		):Connect(
			function()

				UpdateEquippedState()

			end
		)

		UpdateEquippedState()

	end

	if player.Character then

		SetupCharacter(
			player.Character
		)

	end

	player.CharacterAdded:Connect(
		function(character)

			SetupCharacter(
				character
			)

		end
	)

	print(
		"[BananaUIController] Initialized"
	)

end

return BananaUIController