local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Bootstrap lobby UI & queue controller
local LobbyController = require(script.Controllers.LobbyController)
local RoundController = require(script.Controllers.RoundController)
local CursorController = require(
	ReplicatedStorage.Shared.Modules.CursorModule
)
local FreezeController = require(script.Controllers.FreezeController)
local DailyRewardController = require(script.Controllers.DailyRewardController)
local ShopController = require(script.Controllers.ShopController)
local InventoryController = require(script.Controllers.InventoryController)
local VictoryController = require(script.Controllers.VictoryController)
local CurrencyController= require(script.Controllers.CurrencyController)
local MonetizationController = require(script.Controllers.MonetizationController)
local SlowMoController = require(script.Controllers.SlowMoController)
local TaskController = require(script.Controllers.TaskController)
local LevelUpController = require(script.Controllers.LevelUpController)
local RewardItemController = require(script.Controllers.RewardItemController)
local PopupController = require(script.Controllers.PopupController)
local GameplayItemController = require(script.Controllers.GameplayItemController)
local BananaPeelController= require(script.Controllers.BananaPeelController)
local CurrencyUIController = require(script.Controllers.CurrencyUIController)
local MarkedTargetController= require(script.Controllers.MarkedTargetController)
local InfectedController = require(script.Controllers.InfectedController)
local RoundInfoController = require(script.Controllers.RoundInfoController)
local HelpSignalController = require(script.Controllers.HelpSignalController)
local HunterEntryController= require(script.Controllers.HunterEntryController)
local RescueCinematicController = require(script.Controllers.RescueCinematicController)

ShopController:Init()
CursorController:Init()
LobbyController:Init()
RoundController:Init()
FreezeController:Init()
InventoryController:Init()
DailyRewardController:Init()
VictoryController:Init()
CurrencyController:Init()
MonetizationController:Init()
SlowMoController:Init()
TaskController:Init()
LevelUpController:Init()
RewardItemController:Init()
PopupController:Init()
GameplayItemController:Init()
BananaPeelController:Init()
CurrencyUIController:Init()
MarkedTargetController:Init()
InfectedController:Init()
RoundInfoController:Init()
HelpSignalController:Init()
HunterEntryController:Init()
RescueCinematicController:Init()

-- Wait for attributes to replicate
if not LocalPlayer:GetAttribute("Team") then
	LocalPlayer:GetAttributeChangedSignal("Team"):Wait()
end

ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
	-- Only target Rescue prompts
	if prompt.ActionText == "Rescue" then
		-- The prompt is parented to the frozen player's HumanoidRootPart (prompt.Parent).
		-- So the character Model is prompt.Parent.Parent.
		local character = prompt.Parent and prompt.Parent.Parent
		local frozenPlayer = character and Players:GetPlayerFromCharacter(character)
		
		if frozenPlayer then
			local localTeam = LocalPlayer:GetAttribute("Team")
			local localState = LocalPlayer:GetAttribute("State")

			-- Hide/Disable prompt for:
			-- 1. The frozen player themselves (can't rescue self)
			-- 2. Anyone on the Hunter team (can't rescue runners)
			-- 3. Any Runner who is currently frozen (can't rescue others while frozen)
			if frozenPlayer == LocalPlayer or localTeam == "Hunter" or localState == "Frozen" then
				prompt.Enabled = false
			end
		end
	end
end)

print("Client-side Rescue ProximityPrompt filter initialized.")
