local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxSoundService = game:GetService("SoundService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
------------------------------------------------
-- MODULES
------------------------------------------------

local SoundUtils =
	require(Shared.Utils.SoundUtils)

local SoundConfig =
	require(Shared.Config.SoundConfig)

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
-- STATE
------------------------------------------------

local ActiveLoops = {}

local CurrentMusic = nil

local MusicEnabled = true
local MusicVolume = 1

local SFXEnabled = true
local SFXVolume = 1

------------------------------------------------
-- CONFIG
------------------------------------------------

local function GetConfig(soundName)

	local config =
		SoundConfig[soundName]

	if not config then
		config = SoundConfig.Default
	end

	return config
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
-- GET GROUP
------------------------------------------------

local function GetSoundGroup(category)

	if category == "Music" then
		return MusicGroup
	end

	return SFXGroup
end

------------------------------------------------
-- PLAY
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
	-- CHECK ENABLED
	------------------------------------------------

	if category == "Music" then

		if not MusicEnabled then
			return nil
		end

	else

		if not SFXEnabled then
			return nil
		end
	end

	------------------------------------------------
	-- PARENT
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

	local soundClone =
		SoundUtils:PlaySound(
			sound,
			parent,
			duration,
			properties
		)

	return soundClone
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

	------------------------------------------------
	-- ENABLED CHECK
	------------------------------------------------

	if category == "Music" then

		if not MusicEnabled then
			return nil
		end

	else

		if not SFXEnabled then
			return nil
		end

	end

	------------------------------------------------
	-- PARENT
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

		Looped = true,

		SoundGroup =
			GetSoundGroup(category),

	}

	------------------------------------------------
	-- PLAY
	------------------------------------------------

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
-- STOP ALL LOOPS
------------------------------------------------

function SoundService:StopAllLoops()

	for soundName, sound in pairs(ActiveLoops) do

		if sound
			and sound.Parent then

			sound:Stop()
			sound:Destroy()

		end

		ActiveLoops[soundName] = nil
	end
end

------------------------------------------------
-- MUSIC
------------------------------------------------

function SoundService:PlayMusic(soundName)

	------------------------------------------------
	-- STOP CURRENT MUSIC
	------------------------------------------------

	self:StopMusic()

	------------------------------------------------
	-- PLAY
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

	enabled =
		enabled == true

	if MusicEnabled == enabled then
		return
	end

	------------------------------------------------
	-- TOGGLE FEEDBACK
	------------------------------------------------

	if enabled then

		MusicEnabled = true

		self:Play("ToggleOn")

	else

		self:Play("ToggleOff")

		MusicEnabled = false

	end

	------------------------------------------------
	-- STOP MUSIC
	------------------------------------------------

	if not MusicEnabled then
		self:StopMusic()
	end
end

------------------------------------------------
-- MUSIC VOLUME
------------------------------------------------

function SoundService:SetMusicVolume(volume)

	MusicVolume =
		math.clamp(volume, 0, 1)

	MusicGroup.Volume =
		if MusicEnabled
		then MusicVolume
		else 0
end

------------------------------------------------
-- SFX ENABLED
------------------------------------------------

function SoundService:SetSFXEnabled(enabled)

	enabled =
		enabled == true

	if SFXEnabled == enabled then
		return
	end

	if enabled then

		SFXEnabled = true

		self:Play("ToggleOn")

	else

		self:Play("ToggleOff")

		SFXEnabled = false

	end

	------------------------------------------------
	-- MUTE GROUP
	------------------------------------------------

	SFXGroup.Volume =
		if SFXEnabled
		then SFXVolume
		else 0
end

------------------------------------------------
-- SFX VOLUME
------------------------------------------------

function SoundService:SetSFXVolume(volume)

	SFXVolume =
		math.clamp(volume, 0, 1)

	SFXGroup.Volume =
		if SFXEnabled
		then SFXVolume
		else 0
end

------------------------------------------------
-- INITIALIZE
------------------------------------------------

function SoundService:Init()

	MusicGroup.Volume =
		MusicVolume

	SFXGroup.Volume =
		SFXVolume

	print("SoundService Initialized")

end

return SoundService