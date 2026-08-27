local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

------------------------------------------------
-- CONFIG
------------------------------------------------

local HunterRevealConfig =
	require(
		Shared.Config.HunterRevealConfig
	)

------------------------------------------------
-- UI
------------------------------------------------

local AbilityUI =
	require(
		script.Parent.Parent.UI.RobuxAbilitiyUI
	)

---------------------------------------
-- Remotes
-------------------------------------

local Remotes =
	Shared:WaitForChild("Remotes")

local RemoteIndex =
	require(Shared.Remotes.RemoteIndex)


local RevealEffect =
	Remotes:WaitForChild(
		RemoteIndex.Events.HunterRevealEffect
	)

------------------------------------------------
-- CONTROLLER
------------------------------------------------
local HighlightModule = require(Shared.Modules.HighlightVisual)
local HunterRevealController = {}

------------------------------------------------
-- OPEN PURCHASE POPUP
------------------------------------------------

local function OnRevealPressed()

	------------------------------------------------
	-- CLIENT-SIDE CHECK
	-- Server validates again through receipt.
	------------------------------------------------

	if player:GetAttribute("Team") ~= "Hunter" then
		return
	end

	------------------------------------------------
	-- ROBLOX PURCHASE POPUP
	------------------------------------------------

	MarketplaceService:PromptProductPurchase(
		player,
		HunterRevealConfig.ProductId
	)

end


-----------------------------------------------
-- REVEAL EFFECT
------------------------------------------------

local function OnRevealEffect(
	targetUserIds,
	duration
)

	------------------------------------------------
	-- ONLY HUNTER CAN SEE REVEAL
	------------------------------------------------

	if player:GetAttribute("Team") ~= "Hunter" then
		return
	end

	if typeof(targetUserIds) ~= "table" then
		return
	end

	if typeof(duration) ~= "number" then
		return
	end

	------------------------------------------------
	-- APPLY YOUR EXISTING HIGHLIGHT SYSTEM HERE
	------------------------------------------------

	for _, userId in ipairs(targetUserIds) do

		if typeof(userId) ~= "number" then
			continue
		end

		local targetPlayer =
			Players:GetPlayerByUserId(userId)

		if not targetPlayer then
			continue
		end

		local character =
			targetPlayer.Character

		if not character then
			continue
		end

		------------------------------------------------
		-- USE YOUR EXISTING HIGHLIGHT MODULE HERE
		------------------------------------------------

			-- Example:
		HighlightModule.Create(
		    character,
		   {
			FillColor = Color3.fromRGB(255, 200, 50),
			Duration = HunterRevealConfig.Duration,
		})

	end

end



------------------------------------------------
-- INIT
------------------------------------------------

function HunterRevealController:Init()

	print(
		"HunterRevealController Initialized"
	)

	AbilityUI:Init()

	AbilityUI.OnRevealPressed =
		OnRevealPressed

	RevealEffect.OnClientEvent:Connect(
			OnRevealEffect
		)
end

return HunterRevealController