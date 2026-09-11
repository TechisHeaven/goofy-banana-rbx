local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxSoundService = game:GetService("SoundService")

------------------------------------------------
-- MODULES
------------------------------------------------

local SoundUtils =
	require(ReplicatedStorage.Shared.Utils.SoundUtils)

local SoundConfig =
	require(ReplicatedStorage.Shared.Config.SoundConfig)

local SettingsConfig =
	require(ReplicatedStorage.Shared.Config.SettingsConfig)

------------------------------------------------
-- SOUNDS
------------------------------------------------

local SoundsFolder =
	ReplicatedStorage:WaitForChild("Sounds")

------------------------------------------------
-- SOUND GROUPS
------------------------------------------------

local MusicGroup =
	RobloxSoundService:FindFirstChild("MusicGroup")

if not MusicGroup then

	MusicGroup = Instance.new("SoundGroup")
	MusicGroup.Name = "MusicGroup"
	MusicGroup.Parent = RobloxSoundService

end

local SFXGroup =
	RobloxSoundService:FindFirstChild("SFXGroup")

if not SFXGroup then

	SFXGroup = Instance.new("SoundGroup")
	SFXGroup.Name = "SFXGroup"
	SFXGroup.Parent = RobloxSoundService

end

------------------------------------------------
-- SERVICE
------------------------------------------------

local SoundService = {}

------------------------------------------------
-- DEFAULTS
------------------------------------------------

local DEFAULTS =
	SettingsConfig.Defaults

------------------------------------------------
-- STATE
------------------------------------------------

local ActiveLoops = {}

local CurrentMusic = nil
local CurrentMusicName = nil

local MusicEnabled =
	DEFAULTS.MusicEnabled

local MusicVolume =
	DEFAULTS.MusicVolume

------------------------------------------------
-- CONFIG
------------------------------------------------

local function GetConfig(soundName)

	return SoundConfig[soundName]
		or SoundConfig.Default

end

------------------------------------------------
-- GET SOUND
------------------------------------------------

local function GetSound(soundName)

	local sound =
		SoundsFolder:FindFirstChild(soundName)

	if not sound then

		warn(
			"[SoundService] Sound not found:",
			soundName
		)

		return nil
	end

	if not sound:IsA("Sound") then

		warn(
			"[SoundService] Instance is not a Sound:",
			soundName
		)

		return nil
	end

	return sound

end

------------------------------------------------
-- GET SOUND GROUP
------------------------------------------------

local function GetSoundGroup(category)

	if category == "Music" then
		return MusicGroup
	end

	return SFXGroup

end

------------------------------------------------
-- APPLY GROUP VOLUMES
------------------------------------------------

local function ApplyMusicVolume()

	if MusicEnabled then
		MusicGroup.Volume = MusicVolume
	else
		MusicGroup.Volume = 0
	end

end



------------------------------------------------
-- PLAY SOUND
------------------------------------------------

function SoundService:Play(
	soundName,
	duration,
	parent
)

	local sound =
		GetSound(soundName)

	if not sound then
		return nil
	end

	local config =
		GetConfig(soundName)

	local category =
		config.Category or "SFX"

	------------------------------------------------
	-- DEFAULT PARENT
	------------------------------------------------

	parent =
		parent
		or RobloxSoundService

	------------------------------------------------
	-- PROPERTIES
	------------------------------------------------

	local properties = {

		Volume =
			config.Volume
			or SoundConfig.Default.Volume,

		Looped =
			config.Looped
			or false,

		SoundGroup =
			GetSoundGroup(category),

	}
	------------------------------------------------
	-- PLAY
	------------------------------------------------

	return SoundUtils:PlaySound(
		sound,
		parent,
		duration,
		properties
	)

end

------------------------------------------------
-- PLAY LOOP
------------------------------------------------

function SoundService:PlayLoop(
	soundName,
	parent
)

	self:StopLoop(soundName)

	local sound =
		GetSound(soundName)

	if not sound then
		return nil
	end

	local config =
		GetConfig(soundName)

	local category =
		config.Category or "SFX"

	parent =
		parent
		or RobloxSoundService

	local properties = {

		Volume =
			config.Volume
			or SoundConfig.Default.Volume,

		Looped = true,

		SoundGroup =
			GetSoundGroup(category),

	}

	local soundClone =
		SoundUtils:PlaySound(
			sound,
			parent,
			nil,
			properties
		)

	if not soundClone then
		return nil
	end

	ActiveLoops[soundName] =
		soundClone

	return soundClone

end

------------------------------------------------
-- STOP LOOP
------------------------------------------------

function SoundService:StopLoop(soundName)

	local sound =
		ActiveLoops[soundName]

	if not sound then
		return
	end

	ActiveLoops[soundName] = nil

	if sound.Parent then

		sound:Stop()
		sound:Destroy()

	end

end

------------------------------------------------
-- PLAY MUSIC
------------------------------------------------

function SoundService:PlayMusic(soundName)

	------------------------------------------------
	-- Remember requested music
	------------------------------------------------

	CurrentMusicName =
		soundName

	------------------------------------------------
	-- Stop previous music
	------------------------------------------------

	self:StopMusic()

	------------------------------------------------
	-- Play new music
	------------------------------------------------

	local soundClone =
		self:Play(
			soundName,
			nil,
			RobloxSoundService
		)

	if not soundClone then
		return nil
	end

	soundClone.Looped = true

	CurrentMusic =
		soundClone

	return soundClone

end

------------------------------------------------
-- STOP MUSIC
------------------------------------------------

function SoundService:StopMusic()

	if not CurrentMusic then
		return
	end

	if CurrentMusic.Parent then

		CurrentMusic:Stop()
		CurrentMusic:Destroy()

	end

	CurrentMusic = nil

end

------------------------------------------------
-- MUSIC ENABLED
------------------------------------------------

function SoundService:SetMusicEnabled(enabled)

	MusicEnabled =
		enabled == true

	ApplyMusicVolume()

end

------------------------------------------------
-- MUSIC VOLUME
------------------------------------------------

function SoundService:SetMusicVolume(volume)

	MusicVolume =
		math.clamp(
			volume,
			0,
			1
		)

	ApplyMusicVolume()

end



------------------------------------------------
-- GET MUSIC STATE
------------------------------------------------

function SoundService:IsMusicEnabled()

	return MusicEnabled

end

------------------------------------------------
-- GET MUSIC VOLUME
------------------------------------------------

function SoundService:GetMusicVolume()

	return MusicVolume

end

------------------------------------------------
-- INITIALIZE
------------------------------------------------

function SoundService:Init()

	ApplyMusicVolume()

	-- print(
	-- 	"SoundService Initialized",
	-- 	"Music:",
	-- 	MusicEnabled,
	-- 	MusicVolume
	-- )

end

return SoundService