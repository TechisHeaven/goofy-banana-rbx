local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local TaskConfig =
	require(Shared.Config.TaskConfig)

local PlayerProfiles =
	require(ServerStorage.Data.PlayerProfiles)

local CurrencyManager =
	require(script.Parent.CurrencyManager)

local InventoryManager =
	require(script.Parent.InventoryManager)

local NotificationManager =
	require(script.Parent.NotificationManager)

local Enums =
	require(Shared.Enums)
	
local RewardDisplay =
	require(
		Shared.Modules.RewardDisplay
	)

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events
local RemoteIndxFunction = RemoteIndexData.Functions

local Remotes =
	Shared:WaitForChild("Remotes")


local GetTasksRemote = Remotes:WaitForChild(RemoteIndxFunction.GetTasks)
local UpdateTasks =
	Remotes:WaitForChild(
		RemoteIndex.UpdateTasks
	)

local ClaimTask =
	Remotes:WaitForChild(
		RemoteIndxFunction.ClaimTask
)


local TaskManager = {}

------------------------------------------------
-- Utilities
------------------------------------------------

local function GetProfile(player)

	return PlayerProfiles[player]

end

------------------------------------------------

local function GetDateKey()

	return os.date("!%Y-%m-%d")

end

------------------------------------------------

local function GetWeekKey()

	local date = os.date("!*t")

	-- ISO-like week identifier.
	-- The exact week number isn't important;
	-- it only needs to change once per week.

	local year = date.year
	local dayOfYear = tonumber(
		os.date("!%j")
	)

	local week =
		math.floor(
			(dayOfYear - 1) / 7
		) + 1

	return string.format(
		"%04d-W%02d",
		year,
		week
	)

end

------------------------------------------------
-- Task state
------------------------------------------------

local function CreateTaskState()

	return {
		Progress = 0,
		Completed = false,
		Claimed = false,
	}

end

------------------------------------------------
-- Pick tasks
------------------------------------------------

local function PickTasks(pool, amount)

	local selected = {}
	local used = {}

	------------------------------------------------
	-- Try to create difficulty variety
	------------------------------------------------

	local difficultyOrder = {
		"Easy",
		"Medium",
		"Hard",
	}

	for _, difficulty in ipairs(
		difficultyOrder
	) do

		if #selected >= amount then
			break
		end

		local candidates = {}

		for index, task in ipairs(pool) do

			if not used[index]
				and task.Difficulty == difficulty then

				table.insert(
					candidates,
					{
						Index = index,
						Task = task,
					}
				)

			end

		end

		if #candidates > 0 then

			local choice =
				candidates[
					math.random(
						1,
						#candidates
					)
				]

			used[choice.Index] = true

			table.insert(
				selected,
				choice.Task
			)

		end

	end

	------------------------------------------------
	-- Fill remaining slots randomly
	------------------------------------------------

	while #selected < amount do

		local candidates = {}

		for index, task in ipairs(pool) do

			if not used[index] then

				table.insert(
					candidates,
					{
						Index = index,
						Task = task,
					}
				)

			end

		end

		if #candidates == 0 then
			break
		end

		local choice =
			candidates[
				math.random(
					1,
					#candidates
				)
			]

		used[choice.Index] = true

		table.insert(
			selected,
			choice.Task
		)

	end

	return selected

end

------------------------------------------------
-- Generate Daily
------------------------------------------------

function TaskManager:GenerateDaily(profile)

	local selected =
		PickTasks(
			TaskConfig.Daily,
			TaskConfig.DailyCount
		)

	profile.Tasks.Daily = {
		Version = GetDateKey(),
		Tasks = {},
	}

	for _, task in ipairs(selected) do

		profile.Tasks.Daily.Tasks[task.Id] =
			CreateTaskState()

	end

end

------------------------------------------------
-- Generate Weekly
------------------------------------------------

function TaskManager:GenerateWeekly(profile)

	local selected =
		PickTasks(
			TaskConfig.Weekly,
			TaskConfig.WeeklyCount
		)

	profile.Tasks.Weekly = {
		Version = GetWeekKey(),
		Tasks = {},
	}

	for _, task in ipairs(selected) do

		profile.Tasks.Weekly.Tasks[task.Id] =
			CreateTaskState()

	end

end

------------------------------------------------
-- Initialize Overall
------------------------------------------------

function TaskManager:InitializeOverall(profile)

	profile.Tasks.Overall =
		profile.Tasks.Overall or {}

	for _, task in ipairs(
		TaskConfig.Overall
	) do

		if not profile.Tasks.Overall[task.Id] then

			profile.Tasks.Overall[task.Id] =
				CreateTaskState()

		end

	end

end

------------------------------------------------
-- Refresh Tasks
------------------------------------------------

function TaskManager:RefreshPlayer(player)

	local profile =
		GetProfile(player)

	if not profile then
		return
	end

	profile.Tasks =
		profile.Tasks or {}

	------------------------------------------------
	-- Daily
	------------------------------------------------

	profile.Tasks.Daily =
		profile.Tasks.Daily or {
			Version = "",
			Tasks = {},
		}

	if profile.Tasks.Daily.Version
		~= GetDateKey() then

		self:GenerateDaily(profile)

	end

	------------------------------------------------
	-- Weekly
	------------------------------------------------

	profile.Tasks.Weekly =
		profile.Tasks.Weekly or {
			Version = "",
			Tasks = {},
		}

	if profile.Tasks.Weekly.Version
		~= GetWeekKey() then

		self:GenerateWeekly(profile)

	end

	------------------------------------------------
	-- Overall
	------------------------------------------------

	self:InitializeOverall(profile)

end

------------------------------------------------
-- Find Config
------------------------------------------------

local function FindTaskConfig(
	taskType,
	taskId
)

	local pool

	if taskType == "Daily" then

		pool = TaskConfig.Daily

	elseif taskType == "Weekly" then

		pool = TaskConfig.Weekly

	elseif taskType == "Overall" then

		pool = TaskConfig.Overall

	end

	if not pool then
		return nil
	end

	for _, task in ipairs(pool) do

		if task.Id == taskId then
			return task
		end

	end

	return nil

end

------------------------------------------------
-- Progress a task
------------------------------------------------

local function UpdateTaskProgress(
	task,
	state,
	event,
	amount
)

	if task.Event ~= event then
		return false
	end

	if state.Claimed then
		return false
	end

	if state.Completed then
		return false
	end

	state.Progress += amount

	if state.Progress >= task.Target then

		state.Progress =
			task.Target

		state.Completed = true
		return true
	end
	return false
end


------------------------------------------------
-- Mission Completion Notification
------------------------------------------------

local function SendTaskCompletedNotification(
	player,
	task
)

	local reward =
		RewardDisplay:GetRewardDisplay(
			task.Reward
		)

	local rewardText = ""

	if reward then

		if reward.Type == "Coins" then

			rewardText =
				string.format(
					' <font color="#FFD43B"><b>+%d Coins</b></font>',
					reward.Value
				)

		elseif reward.Type == "XP" then

			rewardText =
				string.format(
					' <font color="#61D9FF"><b>+%d XP</b></font>',
					reward.Value
				)

		elseif reward.Id then

			rewardText =
				string.format(
					' <font color="#9BFF7A"><b>%s</b></font>',
					tostring(reward.Id)
				)

		end

	end

	local message =
		'<font color="#FFD43B"><b>MISSION COMPLETE!</b></font> ' ..
		'<font color="#FFFFFF">' ..
		tostring(task.Name) ..
		'</font>' ..
		rewardText

	NotificationManager:Send(
		player,
		message,
		Enums.NotificationTarget.Default
	)

end


------------------------------------------------
-- Add Progress
------------------------------------------------

function TaskManager:AddProgress(
	player,
	event,
	amount,
	sendUpdate
)

	if amount == nil then
		amount = 1
	end

	if sendUpdate == nil then
		sendUpdate = true
	end

	if amount <= 0 then
		return
	end

	local profile =
		GetProfile(player)

	if not profile then
		return
	end

	self:RefreshPlayer(player)

	------------------------------------------------
	-- Daily
	------------------------------------------------

	for taskId, state in pairs(
		profile.Tasks.Daily.Tasks
	) do

		local task =
			FindTaskConfig(
				"Daily",
				taskId
			)

		if task then

			local completed =
				UpdateTaskProgress(
					task,
					state,
					event,
					amount
				)

			if completed then

				SendTaskCompletedNotification(
					player,
					task
				)

			end

		end

	end

	------------------------------------------------
	-- Weekly
	------------------------------------------------

	for taskId, state in pairs(
		profile.Tasks.Weekly.Tasks
	) do

		local task =
			FindTaskConfig(
				"Weekly",
				taskId
			)

		if task then

			local completed =
				UpdateTaskProgress(
					task,
					state,
					event,
					amount
				)

			if completed then

				SendTaskCompletedNotification(
					player,
					task
				)

			end

		end

	end

	------------------------------------------------
	-- Overall
	------------------------------------------------

	for taskId, state in pairs(
		profile.Tasks.Overall
	) do

		local task =
			FindTaskConfig(
				"Overall",
				taskId
			)

		if task then

			local completed =
				UpdateTaskProgress(
					task,
					state,
					event,
					amount
				)

			if completed then

				SendTaskCompletedNotification(
					player,
					task
				)

			end

		end

	end

	------------------------------------------------
	-- Update client
	------------------------------------------------

	if sendUpdate then
		self:SendTasks(player)
	end

end

------------------------------------------------
-- Build Client Data
------------------------------------------------

local function BuildTaskData(
	taskType,
	states
)

	local result = {}

	for taskId, state in pairs(states) do

		local config =
			FindTaskConfig(
				taskType,
				taskId
			)


		if config then

			table.insert(
				result,
				{
					Id = config.Id,

					Name = config.Name,

					Description =
						config.Description,

					Event = config.Event,

					Target = config.Target,

					Difficulty =
						config.Difficulty,
					
					Reward = RewardDisplay:GetRewardDisplay(
						config.Reward
					),

					Progress =
						state.Progress,

					Completed =
						state.Completed,

					Claimed =
						state.Claimed,
				}
			)

		end

	end

	return result

end

------------------------------------------------
-- Get Tasks
------------------------------------------------

function TaskManager:GetTasks(player)

	local profile =
		GetProfile(player)

	if not profile then
		return nil
	end

	self:RefreshPlayer(player)

	return {

		Daily = {
			Version =
				profile.Tasks.Daily.Version,

			Tasks =
				BuildTaskData(
					"Daily",
					profile.Tasks.Daily.Tasks
				),
		},

		Weekly = {
			Version =
				profile.Tasks.Weekly.Version,

			Tasks =
				BuildTaskData(
					"Weekly",
					profile.Tasks.Weekly.Tasks
				),
		},

		Overall = {
			Tasks =
				BuildTaskData(
					"Overall",
					profile.Tasks.Overall
				),
		},

	}

end

------------------------------------------------
-- Send Tasks
------------------------------------------------

function TaskManager:SendTasks(player)

	local data =
		self:GetTasks(player)

	if not data then
		return
	end

	UpdateTasks:FireClient(
		player,
		data
	)

end

------------------------------------------------
-- Give Reward
------------------------------------------------

local function GiveReward(
	player,
	reward
)

	if not reward then
		return
	end

	------------------------------------------------
	-- Coins
	------------------------------------------------

	if reward.Coins
		and reward.Coins > 0 then

		CurrencyManager:AddCoins(
			player,
			reward.Coins
		)

	end

	
	if reward.XP
		and reward.XP > 0 then

		CurrencyManager:AddXP(
			player,
			reward.XP
		)

	end

	------------------------------------------------
	-- Item
	------------------------------------------------

	if reward.Item then

		local item =
			reward.Item

		if item.Category
			and item.Id then

			InventoryManager:AddItem(
				player,
				item.Category,
				item.Id
			)

		end

	end

end

------------------------------------------------
-- Claim Task
------------------------------------------------

function TaskManager:ClaimTask(
	player,
	taskType,
	taskId
)

	local profile =
		GetProfile(player)

	if not profile then
		return false, "Profile not loaded."
	end

	self:RefreshPlayer(player)

	------------------------------------------------
	-- Validate task type
	------------------------------------------------

	if taskType ~= "Daily"
		and taskType ~= "Weekly"
		and taskType ~= "Overall" then

		return false, "Invalid task type."

	end

	------------------------------------------------
	-- Get state
	------------------------------------------------

	local container

	if taskType == "Daily" then

		container =
			profile.Tasks.Daily.Tasks

	elseif taskType == "Weekly" then

		container =
			profile.Tasks.Weekly.Tasks

	else

		container =
			profile.Tasks.Overall

	end

	local state =
		container[taskId]

	if not state then

		return false, "Task not found."

	end

	------------------------------------------------
	-- Already claimed
	------------------------------------------------

	if state.Claimed then

		return false, "Task already claimed."

	end

	------------------------------------------------
	-- Not completed
	------------------------------------------------

	if not state.Completed then

		return false, "Task not completed."

	end

	------------------------------------------------
	-- Get config
	------------------------------------------------

	local task =
		FindTaskConfig(
			taskType,
			taskId
		)

	if not task then

		return false, "Task configuration not found."

	end

	------------------------------------------------
	-- Grant reward
	------------------------------------------------

	GiveReward(
		player,
		task.Reward
	)

	------------------------------------------------
	-- Mark claimed
	------------------------------------------------

	state.Claimed = true

	------------------------------------------------
	-- Update UI
	------------------------------------------------

	self:SendTasks(player)

	return true, "Reward claimed."

end

------------------------------------------------
-- Player Added
------------------------------------------------

function TaskManager:PlayerLoaded(player)

	local profile =
		GetProfile(player)

	if not profile then
		return
	end

	self:RefreshPlayer(player)

	self:SendTasks(player)

end

------------------------------------------------
-- Player Removing
------------------------------------------------

function TaskManager:PlayerRemoving(player)

	-- ProfileManager owns the actual profile cleanup.
	-- TaskManager does not maintain separate player data.

end

------------------------------------------------
-- Init
------------------------------------------------

function TaskManager:Init()

	print(
		"TaskManager Initializing..."
	)

	------------------------------------------------
	-- Existing players
	------------------------------------------------

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		task.defer(function()

			self:PlayerLoaded(player)

		end)

	end

	------------------------------------------------
	-- New players
	------------------------------------------------

	Players.PlayerAdded:Connect(
		function(player)

			task.defer(function()

				self:PlayerLoaded(player)

			end)

		end
	)

	------------------------------------------------
	-- Claim
	------------------------------------------------

	ClaimTask.OnServerInvoke =
		function(
			player,
			taskType,
			taskId
		)

			return self:ClaimTask(
				player,
				taskType,
				taskId
			)

		end

		GetTasksRemote.OnServerInvoke = function(player)

			return self:GetTasks(player)

		end

end

return TaskManager