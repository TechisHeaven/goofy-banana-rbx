local Players = game:GetService("Players")

local PlayerGui =
	Players.LocalPlayer:WaitForChild("PlayerGui")

local PopupGui =
	PlayerGui:WaitForChild("PopupGui")

local TaskGui = PopupGui.Overlay

local TaskFrame =
	TaskGui:WaitForChild("TaskFrame")
local MainFrame =
	TaskFrame:WaitForChild("MainFrame")

local Tabs =
	MainFrame:WaitForChild("Tabs")


local TasksContainer =
	MainFrame.TasksFrame:WaitForChild("Tasks")

local TaskTemplate =
	TasksContainer:WaitForChild("Task")

local Popup =
	require(
		game.ReplicatedStorage.Shared.Modules.PopupModule
	)

------------------------------------------------
-- TaskUI
------------------------------------------------

local TaskUI = {}

------------------------------------------------
-- State
------------------------------------------------

local CurrentCategory = "Daily"

------------------------------------------------
-- Events
------------------------------------------------

TaskUI.OnTabChanged = nil
TaskUI.OnClaimPressed = nil

------------------------------------------------
-- Helpers
------------------------------------------------

local function Find(parent, name)

	return parent:FindFirstChild(
		name,
		true
	)

end

------------------------------------------------
-- Tab visuals
------------------------------------------------

local function SetTabVisual(tab, active)

	if not tab then
		return
	end

	local activeObject =
		tab:FindFirstChild("ActiveBG")

	local nonActiveObject =
		tab:FindFirstChild("NonActiveBG")

	if activeObject then
		activeObject.Enabled = active
	end

	if nonActiveObject then
		nonActiveObject.Enabled = not active
	end

end

------------------------------------------------

local function SetActiveTab(category)

	CurrentCategory = category

	local dailyTab =
		Tabs:FindFirstChild("DailyTab")

	local weeklyTab =
		Tabs:FindFirstChild("WeeklyTab")

	local overallTab =
		Tabs:FindFirstChild("OverallTab")

	SetTabVisual(
		dailyTab,
		category == "Daily"
	)

	SetTabVisual(
		weeklyTab,
		category == "Weekly"
	)

	SetTabVisual(
		overallTab,
		category == "Overall"
	)

end

------------------------------------------------
-- Tab click
------------------------------------------------

local function ConnectTab(tab, category)

	if not tab then
		return
	end

	tab.InputBegan:Connect(
		function(input)

			if input.UserInputType
				~= Enum.UserInputType.MouseButton1
				and input.UserInputType
				~= Enum.UserInputType.Touch then

				return
			end

			if CurrentCategory == category then
				return
			end

			SetActiveTab(category)

			if TaskUI.OnTabChanged then

				TaskUI.OnTabChanged(
					category
				)

			end

		end
	)

end

------------------------------------------------
-- Clear task cards
------------------------------------------------

local function ClearTasks()

	for _, child in ipairs(
		TasksContainer:GetChildren()
	) do

		if child:IsA("GuiObject")
			and child ~= TaskTemplate then

			child:Destroy()

		end

	end

end

------------------------------------------------
-- Progress
------------------------------------------------

local function RenderProgress(
	card,
	taskData
)

	local progressValue =
		Find(
			card,
			"ProgressValue"
		)

	if progressValue
		and progressValue:IsA("TextLabel") then

		progressValue.Text =
			string.format(
				"%d/%d",
				taskData.Progress,
				taskData.Target
			)

	end

	local progressBar =
		Find(
			card,
			"ProgressBar"
		)

	if progressBar
		and progressBar:IsA("GuiObject") then

		local percent = 0

		if taskData.Target > 0 then

			percent =
				math.clamp(
					taskData.Progress
						/ taskData.Target,
					0,
					1
				)

		end

		progressBar.Size =
			UDim2.new(
				percent,
				0,
				1,
				0
			)

	end

end

------------------------------------------------
-- Reward
------------------------------------------------

local function RenderReward(
	card,
	taskData
)

	local rewardText =
		Find(
			card,
			"Text"
		)

	if not rewardText
		or not rewardText:IsA("TextLabel") then

		return
	end

	local reward =
		taskData.Reward

	if not reward then
		return
	end

	if reward.Coins then

		rewardText.Text =
			tostring(reward.Coins)

	end

end

------------------------------------------------
-- Task information
------------------------------------------------

local function RenderInfo(
	card,
	taskData
)

	------------------------------------------------
	-- Task title
	------------------------------------------------

	local taskTitle =
		Find(
			card,
			"Task"
		)

	local taskDescription =
		Find(
			card,
			"Description"
		)

	if taskTitle
		and taskTitle:IsA("TextLabel") then

		taskTitle.Text =
			taskData.Name
		taskDescription.Text = taskData.Description or "No Description"
	end

	------------------------------------------------
	-- Description
	------------------------------------------------

	local description =
		Find(
			card,
			"Description"
		)

	if description
		and description:IsA("TextLabel") then

		description.Text =
			taskData.Description

	end

	------------------------------------------------
	-- Difficulty
	------------------------------------------------

	local difficulty =
		Find(
			card,
			"Difficulty"
		)

	if difficulty
		and difficulty:IsA("TextLabel") then

		difficulty.Text =
			taskData.Difficulty

	end

end

------------------------------------------------
-- Claim button
------------------------------------------------

local function SetupClaim(
	card,
	taskData
)

	local claim =
		Find(
			card,
			"Claim"
		)

	if not claim
		or not claim:IsA("GuiButton") then

		return
	end

	local claimText =
		Find(
			claim,
			"Text"
		)

	------------------------------------------------
	-- Claimed
	------------------------------------------------

	if taskData.Claimed then

		claim.Visible = true
		claim.Active = false

		if claimText
			and claimText:IsA("TextLabel") then

			claimText.Text =
				"CLAIMED"

		end

		return

	end

	------------------------------------------------
	-- Completed
	------------------------------------------------

	if taskData.Completed then

		claim.Visible = true
		claim.Active = true

		if claimText
			and claimText:IsA("TextLabel") then

			claimText.Text =
				"CLAIM"

		end

		claim.Activated:Connect(
			function()

				if TaskUI.OnClaimPressed then

					TaskUI.OnClaimPressed(
						CurrentCategory,
						taskData.Id
					)

				end

			end
		)

		return

	end

	------------------------------------------------
	-- Not completed
	------------------------------------------------

	claim.Visible = false
	claim.Active = false

end

------------------------------------------------
-- Render one task
------------------------------------------------

local function RenderTask(taskData)

	local card =
		TaskTemplate:Clone()

	card.Name =
		"Task_" .. taskData.Id

	card.Visible = true

	card.Parent =
		TasksContainer

	------------------------------------------------
	-- Information
	------------------------------------------------

	RenderInfo(
		card,
		taskData
	)

	------------------------------------------------
	-- Progress
	------------------------------------------------

	RenderProgress(
		card,
		taskData
	)

	------------------------------------------------
	-- Reward
	------------------------------------------------

	RenderReward(
		card,
		taskData
	)

	------------------------------------------------
	-- Claim
	------------------------------------------------

	SetupClaim(
		card,
		taskData
	)

	return card

end

------------------------------------------------
-- Render Tasks
------------------------------------------------

function TaskUI:RenderTasks(
	category,
	tasks
)

	SetActiveTab(category)

	ClearTasks()

	for _, taskData in ipairs(
		tasks or {}
	) do

		RenderTask(
			taskData
		)

	end

end

------------------------------------------------
-- Show Page
------------------------------------------------

function TaskUI:ShowPage(category)

	SetActiveTab(category)

end

------------------------------------------------
-- Open
------------------------------------------------

function TaskUI:Open()

	Popup:Open(
		TaskFrame
	)

end

------------------------------------------------
-- Close
------------------------------------------------

function TaskUI:Close()

	Popup:CloseCurrent()

end

------------------------------------------------
-- Get current category
------------------------------------------------

function TaskUI:GetCurrentCategory()

	return CurrentCategory

end

------------------------------------------------
-- Init
------------------------------------------------

function TaskUI:Init()

	print(
		"[TaskUI] Initialized"
	)

	TaskTemplate.Visible = false

	------------------------------------------------
	-- Default tab
	------------------------------------------------

	SetActiveTab("Daily")

	------------------------------------------------
	-- Tabs
	------------------------------------------------

	ConnectTab(
		Tabs:FindFirstChild("DailyTab"),
		"Daily"
	)

	ConnectTab(
		Tabs:FindFirstChild("WeeklyTab"),
		"Weekly"
	)

	ConnectTab(
		Tabs:FindFirstChild("OverallTab"),
		"Overall"
	)

end

return TaskUI