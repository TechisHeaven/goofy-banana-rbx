local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

------------------------------------------------
-- SHARED
------------------------------------------------

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local RemotesFolder =
	Shared:WaitForChild("Remotes")

local RemoteIndex =
	require(
		RemotesFolder:WaitForChild("RemoteIndex")
	)

------------------------------------------------
-- MANAGER
------------------------------------------------

local RemoteManager = {}

------------------------------------------------
-- STATE
------------------------------------------------

local Remotes = {}

------------------------------------------------
-- CREATE / GET REMOTE EVENT
------------------------------------------------

local function createRemoteEvent(name)

	local existing =
		RemotesFolder:FindFirstChild(name)

	if existing then

		if not existing:IsA("RemoteEvent") then

			error(
				"[RemoteManager] "
					.. name
					.. " exists but is not a RemoteEvent"
			)

		end

		return existing

	end

	local remote =
		Instance.new("RemoteEvent")

	remote.Name = name
	remote.Parent = RemotesFolder

	return remote

end

------------------------------------------------
-- CREATE / GET REMOTE FUNCTION
------------------------------------------------

local function createRemoteFunction(name)

	local existing =
		RemotesFolder:FindFirstChild(name)

	if existing then

		if not existing:IsA("RemoteFunction") then

			error(
				"[RemoteManager] "
					.. name
					.. " exists but is not a RemoteFunction"
			)

		end

		return existing

	end

	local remote =
		Instance.new("RemoteFunction")

	remote.Name = name
	remote.Parent = RemotesFolder

	return remote

end

------------------------------------------------
-- INIT
------------------------------------------------

function RemoteManager:Init()

	print("[RemoteManager] Initializing...")

	------------------------------------------------
	-- RemoteEvents
	------------------------------------------------

	for _, name in pairs(
		RemoteIndex.Events
	) do

		local remote =
			createRemoteEvent(name)

		Remotes[name] =
			remote

	end

	------------------------------------------------
	-- RemoteFunctions
	------------------------------------------------

	for _, name in pairs(
		RemoteIndex.Functions
	) do

		local remote =
			createRemoteFunction(name)

		Remotes[name] =
			remote

	end

	print(
		"[RemoteManager] Created / loaded",
		#Remotes,
		"remotes"
	)

end

------------------------------------------------
-- GET
------------------------------------------------

function RemoteManager:Get(name)

	local remote =
		Remotes[name]

	if not remote then

		warn(
			"[RemoteManager] Remote not found:",
			name
		)

		return nil

	end

	return remote

end

------------------------------------------------
-- GET EVENT
------------------------------------------------

function RemoteManager:GetEvent(name)

	local remote =
		Remotes[name]

	if not remote then

		warn(
			"[RemoteManager] RemoteEvent not found:",
			name
		)

		return nil

	end

	if not remote:IsA("RemoteEvent") then

		warn(
			"[RemoteManager] Remote is not a RemoteEvent:",
			name
		)

		return nil

	end

	return remote

end

------------------------------------------------
-- GET FUNCTION
------------------------------------------------

function RemoteManager:GetFunction(name)

	local remote =
		Remotes[name]

	if not remote then

		warn(
			"[RemoteManager] RemoteFunction not found:",
			name
		)

		return nil

	end

	if not remote:IsA("RemoteFunction") then

		warn(
			"[RemoteManager] Remote is not a RemoteFunction:",
			name
		)

		return nil

	end

	return remote

end

------------------------------------------------
-- CLEANUP
------------------------------------------------

function RemoteManager:Cleanup()

	table.clear(Remotes)

	print("[RemoteManager] Cache cleared")

end

return RemoteManager