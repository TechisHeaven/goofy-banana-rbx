local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local PlayerProfiles =
	require(ServerStorage.Data.PlayerProfiles)

local SettingsConfig =
	require(ReplicatedStorage.Shared.Config.SettingsConfig)

local SettingsService = {}

------------------------------------------------
-- REMOTES
------------------------------------------------

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = Shared:WaitForChild("Remotes")

local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events
local RemoteFunctions = RemoteIndexData.Functions

local GetSettings =
	Remotes:WaitForChild(RemoteFunctions.GetSettings)

local UpdateSettings =
	Remotes:WaitForChild(RemoteIndex.UpdateSettings)

------------------------------------------------
-- DEFAULTS
------------------------------------------------

local DEFAULTS =
	SettingsConfig.Defaults

------------------------------------------------
-- VALIDATION
------------------------------------------------

local function ValidateSettings(settings)

	if type(settings) ~= "table" then
		return nil
	end

	local validated = {}

	------------------------------------------------
	-- MUSIC
	------------------------------------------------

	if type(settings.MusicVolume) == "number" then

		validated.MusicVolume =
			math.clamp(
				settings.MusicVolume,
				SettingsConfig.Limits.MusicVolume.Min,
				SettingsConfig.Limits.MusicVolume.Max
			)

	else

		validated.MusicVolume =
			DEFAULTS.MusicVolume

	end


	if type(settings.MusicEnabled) == "boolean" then

		validated.MusicEnabled =
			settings.MusicEnabled

	else

		validated.MusicEnabled =
			DEFAULTS.MusicEnabled

	end

	------------------------------------------------
	-- FOV
	------------------------------------------------

	if type(settings.FOV) == "number" then

		validated.FOV =
			math.clamp(
				settings.FOV,
				SettingsConfig.Limits.FOV.Min,
				SettingsConfig.Limits.FOV.Max
			)

	else

		validated.FOV =
			DEFAULTS.FOV

	end

	------------------------------------------------
	-- RUNNING FOV
	------------------------------------------------

	if type(settings.RunningFOV) == "number" then

		validated.RunningFOV =
			math.clamp(
				settings.RunningFOV,
				SettingsConfig.Limits.RunningFOV.Min,
				SettingsConfig.Limits.RunningFOV.Max
			)

	else

		validated.RunningFOV =
			DEFAULTS.RunningFOV

	end

	------------------------------------------------
	-- CAMERA SHAKE
	------------------------------------------------

	if type(settings.CameraShake) == "boolean" then

		validated.CameraShake =
			settings.CameraShake

	else

		validated.CameraShake =
			DEFAULTS.CameraShake

	end

	------------------------------------------------

	return validated
end

------------------------------------------------
-- GET CURRENT SETTINGS
------------------------------------------------

function SettingsService:GetSettings(player)

	local profile =
		PlayerProfiles[player]

	if not profile then
		return table.clone(DEFAULTS)
	end

	if not profile.Settings then
		profile.Settings =
			table.clone(DEFAULTS)
	end

	return table.clone(
		profile.Settings
	)

end

------------------------------------------------
-- UPDATE SETTINGS
------------------------------------------------

function SettingsService:UpdateSettings(
	player,
	settings
)

	local profile =
		PlayerProfiles[player]

	if not profile then
		warn(
			"Cannot update settings. Profile missing:",
			player.Name
		)

		return
	end

	local validated =
		ValidateSettings(settings)

	if not validated then
		warn(
			"Invalid settings received from:",
			player.Name
		)

		return
	end

	------------------------------------------------
	-- UPDATE PROFILE
	------------------------------------------------

	profile.Settings =
		validated

	print(
		"Settings updated for",
		player.Name
	)

	print(
		"FOV:",
		profile.Settings.FOV
	)

end

------------------------------------------------
-- INIT
------------------------------------------------

function SettingsService:Init()

	-- print("SettingsService Initialized")

	------------------------------------------------
	-- CLIENT GETS SETTINGS ONCE
	------------------------------------------------

	GetSettings.OnServerInvoke =
		function(player)

			return self:GetSettings(player)

		end

	------------------------------------------------
	-- CLIENT APPLIES SETTINGS
	------------------------------------------------

	UpdateSettings.OnServerEvent:Connect(
		function(player, settings)

			self:UpdateSettings(
				player,
				settings
			)

		end
	)

end

------------------------------------------------

return SettingsService