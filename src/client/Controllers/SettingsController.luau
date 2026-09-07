local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SettingsController = {}

local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")
local PopupGui = PlayerGui:WaitForChild("PopupGui")
local Overlay = PopupGui:WaitForChild("Overlay")


local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = Shared:WaitForChild("Remotes")

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
local RemoteFunctions = RemoteIndexData.Functions
local GetSettings = Remotes:WaitForChild(RemoteFunctions.GetSettings)
local UpdateSettings = Remotes:WaitForChild(RemoteIndex.UpdateSettings)

local SettingsConfig =
	require(ReplicatedStorage.Shared.Config.SettingsConfig)

local DEFAULTS = SettingsConfig.Defaults

local SettingsUI =
	require(script.Parent.Parent.UI.SettingsUI)

local SoundService =
	require(script.Parent.Parent.Services.SoundService)

----------------------------------------------------
-- Settings State
----------------------------------------------------

local AppliedSettings = table.clone(DEFAULTS)
local PendingSettings = table.clone(DEFAULTS)

----------------------------------------------------
-- Internal
----------------------------------------------------

local function GetCamera()
	return workspace.CurrentCamera
end

local function ApplyCameraSettings()

	local camera = GetCamera()

	if not camera then
		return
	end

	------------------------------------------------
	-- Store settings as Camera attributes
	------------------------------------------------

	camera:SetAttribute(
		"NormalFOV",
		AppliedSettings.FOV
	)

	camera:SetAttribute(
		"RunningFOV",
		AppliedSettings.RunningFOV
	)

	------------------------------------------------
	-- Apply normal FOV
	------------------------------------------------


	camera.FieldOfView = AppliedSettings.FOV
end

local function ApplyAudioSettings()
	SoundService:SetMusicEnabled(
		AppliedSettings.MusicEnabled
	)

	SoundService:SetMusicVolume(
		AppliedSettings.MusicVolume
	)

end



function SettingsController:LoadFromServer()

	local settings =
		GetSettings:InvokeServer()

	if type(settings) ~= "table" then
		warn("Failed to load settings from server")
		return
	end

	AppliedSettings =
		table.clone(settings)

	PendingSettings =
		table.clone(settings)

	SettingsUI:Refresh(
		AppliedSettings
	)

	ApplyCameraSettings()
	ApplyAudioSettings()

	print("Settings loaded from server")

end

----------------------------------------------------
-- Public
----------------------------------------------------

function SettingsController:Get(setting)

	return PendingSettings[setting]

end

----------------------------------------------------

function SettingsController:GetAll()

	return table.clone(PendingSettings)

end

----------------------------------------------------
-- Set Pending Setting
----------------------------------------------------

function SettingsController:Set(setting, value)

	if PendingSettings[setting] == nil then
		warn("Unknown setting:", setting)
		return false
	end

	PendingSettings[setting] = value

	return true

end

----------------------------------------------------
-- FOV
----------------------------------------------------

function SettingsController:SetFOV(value)

	value = math.clamp(
		value,
		SettingsConfig.Limits.FOV.Min,
		SettingsConfig.Limits.FOV.Max
	)

	PendingSettings.FOV = value

end

----------------------------------------------------
-- Running FOV
----------------------------------------------------

function SettingsController:SetRunningFOV(value)

	value = math.clamp(
		value,
		SettingsConfig.Limits.RunningFOV.Min,
		SettingsConfig.Limits.RunningFOV.Max
	)

	PendingSettings.RunningFOV = value

end

----------------------------------------------------
-- Music
----------------------------------------------------

function SettingsController:SetMusicEnabled(enabled)

	PendingSettings.MusicEnabled = enabled == true

end

----------------------------------------------------

function SettingsController:SetMusicVolume(volume)

	volume = math.clamp(
		volume,
		SettingsConfig.Limits.MusicVolume.Min,
		SettingsConfig.Limits.MusicVolume.Max
	)

	PendingSettings.MusicVolume = volume

end



----------------------------------------------------
-- Check Changes
----------------------------------------------------

function SettingsController:HasChanges()

	for setting, value in pairs(PendingSettings) do

		if AppliedSettings[setting] ~= value then
			return true
		end

	end

	return false

end

----------------------------------------------------
-- Cancel
----------------------------------------------------

function SettingsController:Cancel()

	PendingSettings = table.clone(AppliedSettings)

	SettingsUI:Refresh(
		PendingSettings
	)

end

----------------------------------------------------
-- Apply
----------------------------------------------------

function SettingsController:Apply()

	AppliedSettings = table.clone(PendingSettings)

	------------------------------------------------
	-- Apply local settings
	------------------------------------------------

	ApplyCameraSettings()
	ApplyAudioSettings()

	UpdateSettings:FireServer(
		AppliedSettings
	)
	------------------------------------------------
	-- Server save will go here
	------------------------------------------------

	print("Settings Applied")
end

function SettingsController:ResetToDefaults()

	PendingSettings = table.clone(DEFAULTS)

	SettingsUI:Refresh(
		PendingSettings
	)

end

function SettingsController:Open()

	-- Start editing from the currently applied settings
	PendingSettings = table.clone(AppliedSettings)

	-- Refresh every UI element
	SettingsUI:Refresh(PendingSettings)

end


----------------------------------------------------
-- Init
----------------------------------------------------

function SettingsController:Init()

	print("SettingsController Initialized")

	SettingsUI:Init()

	Overlay:GetAttributeChangedSignal("FocusedPopup"):Connect(function()
		local focusedPopup =
			Overlay:GetAttribute("FocusedPopup")

		if focusedPopup == SettingsUI:GetFrameName() then

			self:Open()

		else

			PendingSettings =
				table.clone(AppliedSettings)

		end

	end)
	------------------------------------------------
	-- Music Volume
	------------------------------------------------

	SettingsUI.OnMusicVolumeChanged = function(change)

		local currentVolume =
			self:Get("MusicVolume")

		self:SetMusicVolume(
			currentVolume + change
		)

		SettingsUI:SetMusicVolume(
			self:Get("MusicVolume")
		)

	end

	------------------------------------------------
	-- MUSIC ENABLED
	------------------------------------------------

	SettingsUI.OnMusicEnabledChanged = function()

		local current =
			self:Get("MusicEnabled")

		self:SetMusicEnabled(
			not current
		)

		SettingsUI:SetMusicEnabled(
			self:Get("MusicEnabled")
		)

	end

	------------------------------------------------
	-- FOV
	------------------------------------------------

	SettingsUI.OnFOVChanged = function(change)

		local current =
			self:Get("FOV")

		self:SetFOV(
			current + change
		)

		SettingsUI:SetFOV(
			self:Get("FOV")
		)
	end

	------------------------------------------------
	-- RUNNING FOV
	------------------------------------------------

	SettingsUI.OnRunningFOVChanged = function(change)

		local current =
			self:Get("RunningFOV")

		self:SetRunningFOV(
			current + change
		)

		SettingsUI:SetRunningFOV(
			self:Get("RunningFOV")
		)

	end


	------------------------------------------------
	-- Apply
	------------------------------------------------

	SettingsUI.OnApplyPressed = function()

		self:Apply()

	end

	------------------------------------------------
	-- Cancel
	------------------------------------------------

	SettingsUI.OnCancelPressed = function()

		self:Cancel()

	end


	-- Reset to Defaults

	SettingsUI.OnResetPressed = function()
		self:ResetToDefaults()
	end


	------------------------------------------------
	-- Initial UI State
	------------------------------------------------
	self:LoadFromServer()

	-- SettingsUI:Refresh(
	-- 	PendingSettings
	-- )

	
	-- ApplyCameraSettings()
	-- ApplyAudioSettings()

end

----------------------------------------------------

return SettingsController