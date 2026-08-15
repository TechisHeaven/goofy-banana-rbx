local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local Remotes =
	Shared:WaitForChild("Remotes")

local RemoteIndexData =
	require(
		Shared.Remotes.RemoteIndex
	)

local RemoteIndex =
	RemoteIndexData.Events

local LevelUpUI =
	require(
		script.Parent.Parent.UI.LevelUpUI
	)

local LevelUpController = {}

------------------------------------------------
-- Remote
------------------------------------------------

local LevelUpRemote =
	Remotes:WaitForChild(
		RemoteIndex.LevelUp
	)

------------------------------------------------
-- Level up
------------------------------------------------

local function OnLevelUp(data)

	if not data then
		return
	end

	LevelUpUI:Show(data)

end

------------------------------------------------
-- Init
------------------------------------------------

function LevelUpController:Init()

	print(
		"LevelUpController Initialized"
	)

	LevelUpUI:Init()

	LevelUpRemote.OnClientEvent:Connect(
		OnLevelUp
	)

end

return LevelUpController