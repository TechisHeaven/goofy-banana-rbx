local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local AssetLoader = require(
	ReplicatedStorage.Shared.Modules.AssetLoader
)

local ShopConfig = require(
	ReplicatedStorage.Shared.Config.ShopConfig
)
local RarityConfig = require(
	ReplicatedStorage.Shared.Config.RarityConfig
)
------------------------------------------------
-- PLAYER
------------------------------------------------

local player =
	Players.LocalPlayer

local playerGui =
	player:WaitForChild("PlayerGui")

------------------------------------------------
-- LOADING GUI
------------------------------------------------

local LoadingGui =
	playerGui:WaitForChild("LoadingGui")

local MainFrame =
	LoadingGui:WaitForChild("MainFrame")

local Center =
	MainFrame:WaitForChild("Center")

local LoadingText =
	Center:WaitForChild("TextLabel")

local Bar =
	Center
		:WaitForChild("LoadingBar")
		:WaitForChild("Bar")

LoadingGui.Enabled = true

------------------------------------------------
-- LOADING BAR TWEEN
------------------------------------------------

local barTween

local function TweenLoadingBar(progress)

	if barTween then
		barTween:Cancel()
	end

	barTween = TweenService:Create(
		Bar,
		TweenInfo.new(
			0.12,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.new(
				progress,
				-6,
				1,
				-6
			)
		}
	)

	barTween:Play()
end

------------------------------------------------
-- LOADER
------------------------------------------------

AssetLoader:Init()

------------------------------------------------
-- UI
------------------------------------------------

AssetLoader:AddRoot(
	StarterGui:WaitForChild("GameGui"),
	"UI",
	true
)

AssetLoader:AddRoot(
	StarterGui:WaitForChild("LobbyGui"),
	"UI",
	true
)

AssetLoader:AddRoot(
	StarterGui:WaitForChild("PopupGui"),
	"UI",
	true
)

AssetLoader:AddRoot(
	StarterGui:WaitForChild("StaminaUI"),
	"UI",
	true
)

------------------------------------------------
-- SHOP
------------------------------------------------

AssetLoader:AddShopConfig(
	ShopConfig,
	true
)

------------------------------------------------
-- RARITY
------------------------------------------------

for _, rarity in pairs(RarityConfig) do

	if rarity.Background
		and rarity.Background ~= "" then

		AssetLoader:AddAsset(
			"UI",
			rarity.Background,
			"Image",
			true
		)

	end

end


------------------------------------------------
-- AUDIO
------------------------------------------------

AssetLoader:AddRoot(
	ReplicatedStorage:WaitForChild("Sounds"),
	"Audio",
	true
)

------------------------------------------------
-- WORLD
------------------------------------------------

local CriticalWorld = {
	"Floor",
	"Floor1",
	"Floor2",
	"Walls",
	"BigLeaves",
	"Chair",
	"Cones",
	"Crates",
	"Tables",
	"Veins",
	"Tyre",
	"Trampoline",
	"TubeLightsComplete",
	"SmallMeshNets",
	"Signals",
	"Rocks",
	"SingleFloor",
	"HangingLamps",
}

for _, name in ipairs(CriticalWorld) do

	local object =
		Workspace:FindFirstChild(name)

	if object then

		AssetLoader:AddRoot(
			object,
			"World",
			true
		)

	end
end

------------------------------------------------
-- EFFECTS
-- BACKGROUND, NOT CRITICAL
------------------------------------------------

AssetLoader:AddRoot(
	ReplicatedStorage:WaitForChild("Effects"),
	"Effects",
	false
)

AssetLoader:AddRoot(
	ReplicatedStorage:WaitForChild("VFX"),
	"Effects",
	false
)

------------------------------------------------
-- ANIMATIONS
-- BACKGROUND
------------------------------------------------

AssetLoader:AddRoot(
	ReplicatedStorage:WaitForChild("CinematicAnimations"),
	"Animations",
	false
)

AssetLoader:AddRoot(
	ReplicatedStorage:WaitForChild("RescueAnimations"),
	"Animations",
	false
)

------------------------------------------------
-- OTHER WORLD
-- BACKGROUND
------------------------------------------------

local Maps =
	Workspace:FindFirstChild("Maps")

if Maps then

	AssetLoader:AddRoot(
		Maps,
		"Maps",
		false
	)

end

------------------------------------------------
-- CRITICAL LOADING
------------------------------------------------

local moduleProgress = {}

local function UpdateProgress(
	moduleName,
	moduleProgressValue,
	completed,
	total
)
	moduleProgress[moduleName] =
		moduleProgressValue

	------------------------------------------------
	-- Calculate overall progress
	------------------------------------------------

	local totalProgress = 0
	local moduleCount = 0

	for _, progress in pairs(
		moduleProgress
	) do
		totalProgress += progress
		moduleCount += 1
	end

	if moduleCount > 0 then
		totalProgress /=
			moduleCount
	end

	------------------------------------------------
	-- UI
	------------------------------------------------

	TweenLoadingBar(totalProgress)

	LoadingText.Text =
		"Loading "
		.. moduleName
		.. "..."
end

------------------------------------------------
-- LOAD
------------------------------------------------

AssetLoader:LoadCritical(
	UpdateProgress
)

------------------------------------------------
-- READY
------------------------------------------------

TweenLoadingBar(1)

LoadingText.Text =
	"Ready!"

task.wait(0.15)

LoadingGui.Enabled = false

------------------------------------------------
-- BACKGROUND
------------------------------------------------

task.spawn(function()

	AssetLoader:LoadBackground()

end)