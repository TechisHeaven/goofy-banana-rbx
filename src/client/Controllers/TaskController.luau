local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local TaskUI =
	require(script.Parent.Parent.UI.TaskUI)

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData

local Remotes =
	Shared:WaitForChild("Remotes")

------------------------------------------------
-- UI
------------------------------------------------

local PlayerGui =
	Players.LocalPlayer:WaitForChild("PlayerGui")

local LobbyGui =
	PlayerGui:WaitForChild("LobbyGui")

local MissionsButton =
	LobbyGui.Center.Right.MissionsButton

------------------------------------------------
-- Remotes
------------------------------------------------

local function getRemote(name)

	return Remotes:WaitForChild(name)

end

local GetTasks =
	getRemote(
		RemoteIndex.Functions.GetTasks
	)

local UpdateTasks =
	getRemote(
		RemoteIndex.Events.UpdateTasks
	)

local TaskController = {}

local CurrentCategory = "Daily"

------------------------------------------------
-- Open / Refresh
------------------------------------------------

local function OpenCategory(category)

	CurrentCategory = category

	local success, data =
		pcall(function()

			return GetTasks:InvokeServer()

		end)

	if not success then

		warn(
			"[TaskController] Failed to get tasks:",
			data
		)

		return

	end

	if not data then
		return
	end

	local categoryData =
		data[category]

	if not categoryData then
		return
	end

	TaskUI:ShowPage(category)

	TaskUI:RenderTasks(
		category,
		categoryData.Tasks
	)

end

------------------------------------------------
-- Init
------------------------------------------------

function TaskController:Init()

	print(
		"[TaskController] Initialized"
	)

	TaskUI:Init()

	------------------------------------------------
	-- Open Missions
	------------------------------------------------

	MissionsButton.Activated:Connect(function()
		TaskUI:Open()

		-- Always fetch latest data
		OpenCategory(
			CurrentCategory
		)

	end)

	------------------------------------------------
	-- Tabs
	------------------------------------------------

	TaskUI.OnTabChanged = function(category)

		OpenCategory(category)

	end

	------------------------------------------------
	-- Server task update
	------------------------------------------------

	UpdateTasks.OnClientEvent:Connect(
		function(data)

			if not data then
				return
			end

			local categoryData =
				data[CurrentCategory]

			if not categoryData then
				return
			end

			TaskUI:RenderTasks(
				CurrentCategory,
				categoryData.Tasks
			)

		end
	)

end

return TaskController