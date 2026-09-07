local SettingsUI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local PopupGui = PlayerGui:WaitForChild("PopupGui")

------------------------------------------------
-- CONFIG
------------------------------------------------

local SettingsConfig =
	require(ReplicatedStorage.Shared.Config.SettingsConfig)

local VOLUME_STEP = 0.1
local FOV_STEP = 5
local RUNNING_FOV_STEP = 5

------------------------------------------------
-- UI
------------------------------------------------

local Overlay = PopupGui:WaitForChild("Overlay")
local SettingsFrame = Overlay:WaitForChild("SettingsFrame")

local Items = SettingsFrame:WaitForChild("Items")

------------------------------------------------
-- BGM VOLUME
------------------------------------------------

local VolumeControls =
	Items.BgVolumeFrame.Controls

local VolumeMinusButton =
	VolumeControls.MinusButton

local VolumePlusButton =
	VolumeControls.PlusButton

local VolumeProgressBarBg =
	VolumeControls.ProgressBarBg

local VolumeProgressBar =
	VolumeProgressBarBg.ProgressBar

local VolumeValueLabel =
	VolumeControls.Value

------------------------------------------------
-- BGM ENABLED
------------------------------------------------

local MusicToggle =
	Items.BgEnableFrame.Controls.ToggleButton

local MusicKnob =
	MusicToggle.Knob

------------------------------------------------
-- FOV
------------------------------------------------

local FOVControls =
	Items.FOVFrame.Controls

local FOVMinusButton =
	FOVControls.MinusButton

local FOVPlusButton =
	FOVControls.PlusButton

local FOVProgressBarBg =
	FOVControls.ProgressBarBg

local FOVProgressBar =
	FOVProgressBarBg.ProgressBar

local FOVValueLabel =
	FOVControls.Value

------------------------------------------------
-- RUNNING FOV
------------------------------------------------

local RunningFOVControls =
	Items.RunningFOVFrame.Controls

local RunningFOVMinusButton =
	RunningFOVControls.MinusButton

local RunningFOVPlusButton =
	RunningFOVControls.PlusButton

local RunningFOVProgressBarBg =
	RunningFOVControls.ProgressBarBg

local RunningFOVProgressBar =
	RunningFOVProgressBarBg.ProgressBar

local RunningFOVValueLabel =
	RunningFOVControls.Value


------------------------------------------------
-- ACTIONS
------------------------------------------------

local ApplyButton =
	SettingsFrame.Options.ApplyButton

local CancelButton =
	SettingsFrame.Options.CancelButton

local ResetToDefaultsButton =
	SettingsFrame.Options.ResetToDefaultsButton
	
local ON_COLOR = Color3.fromRGB(50, 220, 80)
local OFF_COLOR = Color3.fromRGB(100, 100, 100)
------------------------------------------------
-- TOGGLE SETTINGS
------------------------------------------------

local function UpdateToggle(toggleButton, knob, enabled)

	local targetPosition
	
	if enabled then
		targetPosition = UDim2.new(
			1,
			0,
			0.5,
			0
		)
	else
		targetPosition = UDim2.new(
			0,
			0,
			0.5,
			0
		)
	end

	TweenService:Create(
		toggleButton,
		TweenInfo.new(
			0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			BackgroundColor3 = enabled and ON_COLOR or OFF_COLOR
		}
	):Play()

	TweenService:Create(
		knob,
		TweenInfo.new(
			0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Position = targetPosition,
		}
	):Play()
end

------------------------------------------------
-- MUSIC VOLUME
------------------------------------------------

local function UpdateMusicVolumeBar(volume)

	local percent = math.clamp(volume, 0, 1)

	TweenService:Create(
		VolumeProgressBar,
		TweenInfo.new(
			0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.new(
				percent,
				-6,
				1,
				-6
			)
		}
	):Play()

	VolumeValueLabel.Text =
		math.round(percent * 100) .. "%"

end

------------------------------------------------
-- FOV BAR
------------------------------------------------

local function UpdateFOVBar(value)

	local minValue = SettingsConfig.Limits.FOV.Min
	local maxValue = SettingsConfig.Limits.FOV.Max

	local percent =
		math.clamp(
			(value - minValue) / (maxValue - minValue),
			0,
			1
		)

	TweenService:Create(
		FOVProgressBar,
		TweenInfo.new(
			0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.new(
				percent,
				-6,
				1,
				-6
			)
		}
	):Play()

	FOVValueLabel.Text =
		tostring(math.round(value))

end

------------------------------------------------
-- RUNNING FOV BAR
------------------------------------------------

local function UpdateRunningFOVBar(value)

	local minValue = SettingsConfig.Limits.RunningFOV.Min
	local maxValue = SettingsConfig.Limits.RunningFOV.Max

	local percent =
		math.clamp(
			(value - minValue) / (maxValue - minValue),
			0,
			1
		)

	TweenService:Create(
		RunningFOVProgressBar,
		TweenInfo.new(
			0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Size = UDim2.new(
				percent,
				-6,
				1,
				-6
			)
		}
	):Play()

	RunningFOVValueLabel.Text =
		tostring(math.round(value))

end

------------------------------------------------
-- PUBLIC
------------------------------------------------

function SettingsUI:SetMusicVolume(volume)

	UpdateMusicVolumeBar(volume)

end

------------------------------------------------

function SettingsUI:SetMusicEnabled(enabled)

	UpdateToggle(
		MusicToggle,
		MusicKnob,
		enabled
	)

end

------------------------------------------------

function SettingsUI:SetFOV(value)

	UpdateFOVBar(value)

end

------------------------------------------------

function SettingsUI:SetRunningFOV(value)

	UpdateRunningFOVBar(value)

end



------------------------------------------------
-- REFRESH EVERYTHING
------------------------------------------------

function SettingsUI:Refresh(settings)

	------------------------------------------------
	-- MUSIC
	------------------------------------------------

	if settings.MusicVolume ~= nil then
		self:SetMusicVolume(
			settings.MusicVolume
		)
	end

	if settings.MusicEnabled ~= nil then
		self:SetMusicEnabled(
			settings.MusicEnabled
		)
	end

	------------------------------------------------
	-- FOV
	------------------------------------------------

	if settings.FOV ~= nil then
		self:SetFOV(
			settings.FOV
		)
	end

	------------------------------------------------
	-- RUNNING FOV
	------------------------------------------------

	if settings.RunningFOV ~= nil then
		self:SetRunningFOV(
			settings.RunningFOV
		)
	end



end

------------------------------------------------

function SettingsUI:GetFrameName()

	return SettingsFrame.Name

end

------------------------------------------------
-- INIT
------------------------------------------------

function SettingsUI:Init()

	print("SettingsUI Initialized")

	------------------------------------------------
	-- MUSIC +
	------------------------------------------------

	VolumePlusButton.Activated:Connect(function()

		if self.OnMusicVolumeChanged then

			self.OnMusicVolumeChanged(
				VOLUME_STEP
			)

		end

	end)

	------------------------------------------------
	-- MUSIC -
	------------------------------------------------

	VolumeMinusButton.Activated:Connect(function()

		if self.OnMusicVolumeChanged then

			self.OnMusicVolumeChanged(
				-VOLUME_STEP
			)

		end

	end)

	------------------------------------------------
	-- MUSIC TOGGLE
	------------------------------------------------

	MusicToggle.Activated:Connect(function()

		if self.OnMusicEnabledChanged then

			self.OnMusicEnabledChanged()

		end

	end)

	------------------------------------------------
	-- FOV +
	------------------------------------------------

	FOVPlusButton.Activated:Connect(function()

		if self.OnFOVChanged then

			self.OnFOVChanged(
				FOV_STEP
			)

		end

	end)

	------------------------------------------------
	-- FOV -
	------------------------------------------------

	FOVMinusButton.Activated:Connect(function()

		if self.OnFOVChanged then

			self.OnFOVChanged(
				-FOV_STEP
			)

		end

	end)

	------------------------------------------------
	-- RUNNING FOV +
	------------------------------------------------

	RunningFOVPlusButton.Activated:Connect(function()

		if self.OnRunningFOVChanged then

			self.OnRunningFOVChanged(
				RUNNING_FOV_STEP
			)

		end

	end)

	------------------------------------------------
	-- RUNNING FOV -
	------------------------------------------------

	RunningFOVMinusButton.Activated:Connect(function()

		if self.OnRunningFOVChanged then

			self.OnRunningFOVChanged(
				-RUNNING_FOV_STEP
			)

		end

	end)


	------------------------------------------------
	-- APPLY
	------------------------------------------------

	ApplyButton.Activated:Connect(function()

		if self.OnApplyPressed then
			self.OnApplyPressed()
		end

	end)

	------------------------------------------------
	-- CANCEL
	------------------------------------------------

	CancelButton.Activated:Connect(function()

		if self.OnCancelPressed then
			self.OnCancelPressed()
		end

	end)

	------------------------------------------------
	-- RESET
	------------------------------------------------

	ResetToDefaultsButton.Activated:Connect(function()

		if self.OnResetPressed then
			self.OnResetPressed()
		end

	end)

end

------------------------------------------------
-- CALLBACKS
------------------------------------------------

SettingsUI.OnMusicVolumeChanged = nil
SettingsUI.OnMusicEnabledChanged = nil

SettingsUI.OnFOVChanged = nil
SettingsUI.OnRunningFOVChanged = nil


SettingsUI.OnApplyPressed = nil
SettingsUI.OnCancelPressed = nil
SettingsUI.OnResetPressed = nil

------------------------------------------------

return SettingsUI