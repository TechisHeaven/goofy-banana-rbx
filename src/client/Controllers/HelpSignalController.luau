local HelpSignalController = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

local Players =
	game:GetService("Players")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- SHARED
------------------------------------------------

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events

local HelpSignal =
	Shared.Remotes:WaitForChild(
		RemoteIndex.HelpSignal
	)

local GameConfig =
	require(Shared.GameConfig)

------------------------------------------------
-- PLAYER
------------------------------------------------

local LocalPlayer =
	Players.LocalPlayer

------------------------------------------------
-- UI
------------------------------------------------

local PlayerGui =
	LocalPlayer:WaitForChild("PlayerGui")

local GameGui =
	PlayerGui:WaitForChild("GameGui")
local HelpFrame =
	GameGui:WaitForChild("Help")
local Button = HelpFrame.Button

local HelpSignalUI = require(script.Parent.Parent.UI.HelpSignalUI)


local HelpMarkerController =
	require(
		script.Parent.HelpMarkerController
	)
------------------------------------------------
-- CONFIG
------------------------------------------------

local COOLDOWN =
	GameConfig.Round.HelpSignalCooldown


local Enums = require(Shared.Enums)
------------------------------------------------
-- STATE
------------------------------------------------

local OnCooldown = false

------------------------------------------------
-- SEND HELP
------------------------------------------------

------------------------------------------------
-- TEAM VISIBILITY
------------------------------------------------

local function UpdateVisibility()

	local isRunner =
		LocalPlayer:GetAttribute("Team")
		== Enums.Team.Runner

	local isFrozen =
		LocalPlayer:GetAttribute("State")
		== Enums.PlayerState.Frozen

	HelpFrame.Visible =
		isRunner and isFrozen

end


function HelpSignalController:SendHelp()
	if OnCooldown then
		return
	end

	OnCooldown = true

	------------------------------------------------
	-- Tell server
	------------------------------------------------
	HelpSignal:FireServer()

	------------------------------------------------
	-- Start cooldown
	------------------------------------------------

	task.spawn(function()

		for remaining = COOLDOWN, 1, -1 do

			HelpSignalUI:SetCooldown(
				remaining
			)

			task.wait(1)

		end

		HelpSignalUI:SetReady()

		OnCooldown = false

	end)

end

function HelpSignalController:OnHelpSignal(
	action,
	player,
	duration
)

	------------------------------------------------
	-- SHOW
	------------------------------------------------

	if action == "Show" then

		if not player then
			return
		end

		HelpMarkerController:Show(
			player,
			duration
		)

		return
	end

	------------------------------------------------
	-- REMOVE
	------------------------------------------------

	if action == "Remove" then

		if not player then
			return
		end

		HelpMarkerController:Hide(
			player
		)

		return
	end

	------------------------------------------------
	-- CLEAR ALL
	------------------------------------------------

	if action == "Clear" then

		HelpMarkerController:Clear()

	end

end

------------------------------------------------
-- INIT
------------------------------------------------

function HelpSignalController:Init()
	
	UpdateVisibility()

	LocalPlayer:GetPropertyChangedSignal("Team"):Connect(
			function()

				UpdateVisibility()

			end
		)

	------------------------------------------------
	-- State changes
	------------------------------------------------

	LocalPlayer:GetAttributeChangedSignal("State"):Connect(
		function()
			local isFrozen =
				LocalPlayer:GetAttribute("State")
				== Enums.PlayerState.Frozen
			
			if not isFrozen then
				HelpMarkerController:Hide(LocalPlayer)
			end

			UpdateVisibility()

		end
	)
	------------------------------------------------
	-- Button
	------------------------------------------------
	Button.Activated:Connect(function()
		self:SendHelp()
	end)

	------------------------------------------------
	-- Server signal
	------------------------------------------------

	HelpSignal.OnClientEvent:Connect(
		function(
			action,
			player,
			duration
		)
			self:OnHelpSignal(
				action,
				player,
				duration
			)

		end
	)

end

return HelpSignalController