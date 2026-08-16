local Players =
	game:GetService("Players")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local TweenService =
	game:GetService("TweenService")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local RarityConfig = require(Shared.Config.RarityConfig)

local PopupManager =
	require(
		Shared.Modules.PopupModule
	)

local ConfettiModule =
	require(
		Shared.Modules.ConfettiModule
	)


------------------------------------------------
-- Player GUI
------------------------------------------------

local PlayerGui =
	Players.LocalPlayer:WaitForChild(
		"PlayerGui"
	)

local PopupGui =
	PlayerGui:WaitForChild("PopupGui")

local Overlay =
	PopupGui:WaitForChild("Overlay")

local RewardFrame =
	Overlay:WaitForChild(
		"RewardItemFrame"
	)
	
local ConfettiContainer =
	RewardFrame:WaitForChild("ConfettiContainer")

------------------------------------------------
-- UI
------------------------------------------------

local ItemContainer =
	RewardFrame:WaitForChild("Item")

local Background =
	ItemContainer:WaitForChild(
		"Background"
	)

local ItemImage =
	ItemContainer:WaitForChild(
		"Item"
	)

local Heading =
	ItemContainer:WaitForChild(
		"Heading"
	)

local Info =
	ItemContainer:WaitForChild(
		"Info"
	)

local Continue =
	RewardFrame:WaitForChild(
		"Continue"
	)

------------------------------------------------
-- Reward UI
------------------------------------------------

local RewardItemUI = {}

local Queue = {}
local CurrentReward = nil
local Showing = false

------------------------------------------------
-- Helpers
------------------------------------------------

local function SetImage(object, image)

	if not object then
		return
	end

	if object:IsA("ImageLabel")
		or object:IsA("ImageButton") then

		object.Image = image or ""

	end

end

------------------------------------------------
-- Render
------------------------------------------------

function RewardItemUI:Render(reward)

	CurrentReward = reward

	------------------------------------------------
	-- Name
	------------------------------------------------

	-- Info.Text =
	-- 	reward.Name
	-- 	or reward.Id
	-- 	or "Reward"

	------------------------------------------------
	-- Rarity
	------------------------------------------------

	Heading.Text =
		string.upper(
			reward.Name
			or "REWARD"
		)

	------------------------------------------------
	-- Item image
	------------------------------------------------

	SetImage(
		ItemImage,
		reward.Image
	)

	------------------------------------------------
	-- Background
	------------------------------------------------

	if reward.Rarity then
        local rarity =
	            RarityConfig[reward.Rarity]

        Background.Image =
            rarity.Background

        Info.Text =
            rarity.Name

        Info.TextColor3 =
            rarity.Color

		-- Keep your existing background.
		-- You can later map rarity → image.

	end

end

------------------------------------------------
-- Bounce animation
------------------------------------------------

function RewardItemUI:AnimateItem()

	local Scale =
		ItemContainer:FindFirstChildOfClass(
			"UIScale"
		)

	if not Scale then

		Scale =
			Instance.new("UIScale")

		Scale.Parent =
			ItemContainer

	end

	Scale.Scale = 0.7

	local tween =
		TweenService:Create(
			Scale,

			TweenInfo.new(
				0.35,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),

			{
				Scale = 1
			}
		)

	tween:Play()

end

------------------------------------------------
-- Show next
------------------------------------------------

function RewardItemUI:ShowNext()

	if #Queue == 0 then

		Showing = false

		PopupManager:Close(
			RewardFrame
		)

		return

	end

	Showing = true

	local reward =
		table.remove(Queue, 1)

	PopupManager:Open(
		RewardFrame,
		{
			CanClickOutsideToClose = false,
			ReopenPreviousOnClose = true
		}
	)

	self:Render(reward)

	self:AnimateItem()

	ConfettiModule:Play(
		RewardFrame,
		ConfettiContainer
	)

end

------------------------------------------------
-- Add rewards
------------------------------------------------

function RewardItemUI:ShowRewards(
	rewards
)

	if not rewards or #rewards == 0 then
		return
	end

	-- Add ALL rewards to queue
	for _, reward in ipairs(rewards) do
		table.insert(Queue, reward)
	end

	-- Don't start another sequence if already showing
	if Showing then
		return
	end

	self:ShowNext()

end

------------------------------------------------
-- Continue
------------------------------------------------

function RewardItemUI:Init()

	RewardFrame.Visible = false

	Continue.Activated:Connect(
		function()

			self:ShowNext()

		end
	)

end

return RewardItemUI