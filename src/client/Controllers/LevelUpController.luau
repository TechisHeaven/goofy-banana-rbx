local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local Enums =
	require(Shared.Enums)

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events

local LevelUpUI =
	require(script.Parent.Parent.UI.LevelUpUI)

local Remotes =
	Shared:WaitForChild("Remotes")

local Player =
	Players.LocalPlayer

local LevelUpController = {}

------------------------------------------------
-- Pending level-up
------------------------------------------------

local PendingLevelUp = nil

------------------------------------------------
-- Check lobby
------------------------------------------------

local function IsInLobby()

	return Player:GetAttribute("LobbyState")
		== Enums.PlayerLobbyState.InLobby

end

------------------------------------------------
-- Show if possible
------------------------------------------------

local function TryShowLevelUp()

	if not PendingLevelUp then
		return
	end

	if not IsInLobby() then
		return
	end

	local data =
		PendingLevelUp

	PendingLevelUp = nil

	LevelUpUI:Show(data)

end

------------------------------------------------
-- Level Up received
------------------------------------------------

local function OnLevelUp(data)

	if not data then
		return
	end

	------------------------------------------------
	-- Always store it first
	------------------------------------------------

	PendingLevelUp = data

	------------------------------------------------
	-- If already in lobby, show immediately
	------------------------------------------------

	TryShowLevelUp()

end

------------------------------------------------
-- Init
------------------------------------------------

function LevelUpController:Init()

	print(
		"[LevelUpController] Initialized"
	)

	------------------------------------------------
	-- Level Up remote
	------------------------------------------------

	local LevelUpRemote =
		Remotes:WaitForChild(
			RemoteIndex.LevelUp
		)

	LevelUpRemote.OnClientEvent:Connect(
		OnLevelUp
	)

	------------------------------------------------
	-- Watch THIS player's lobby state
	------------------------------------------------

	Player:GetAttributeChangedSignal(
		"LobbyState"
	):Connect(function()

		TryShowLevelUp()

	end)

	------------------------------------------------
	-- Handle initial state
	------------------------------------------------

	task.defer(function()

		TryShowLevelUp()

	end)

end

return LevelUpController