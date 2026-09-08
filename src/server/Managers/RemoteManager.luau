local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Players =
	game:GetService("Players")

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

local ReadyPlayers = {}

local PendingEvents = {}

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
-- QUEUE EVENT
------------------------------------------------

local function QueueEvent(
	player,
	remoteName,
	arguments
)

	if not PendingEvents[player] then

		PendingEvents[player] = {}

	end

	table.insert(
		PendingEvents[player],
		{
			Remote = remoteName,
			Arguments = arguments,
		}
	)

end

------------------------------------------------
-- FIRE CLIENT
------------------------------------------------

function RemoteManager:FireClient(
	player,
	remoteName,
	...
)

	if not player
		or not player.Parent then

		return

	end

	local remote =
		self:GetEvent(remoteName)

	if not remote then
		return
	end

	------------------------------------------------
	-- Client isn't ready yet
	------------------------------------------------

	if not ReadyPlayers[player] then

		QueueEvent(
			player,
			remote.Name,
			{
				...
			}
		)

		return

	end

	------------------------------------------------
	-- Client ready
	------------------------------------------------

	remote:FireClient(
		player,
		...
	)

end

------------------------------------------------
-- FIRE ALL CLIENTS
------------------------------------------------

function RemoteManager:FireAllClients(
	remoteName,
	...
)

	local arguments = {
		...
	}

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		if ReadyPlayers[player] then

			local remote =
				self:GetEvent(remoteName)

			if remote then

				remote:FireClient(
					player,
					table.unpack(arguments)
				)

			end

		else

			QueueEvent(
				player,
				remoteName,
				arguments
			)

		end

	end

end

------------------------------------------------
-- PLAYER READY
------------------------------------------------

function RemoteManager:SetPlayerReady(player)

	if not player
		or not player.Parent then

		return

	end

	ReadyPlayers[player] = true

	local events =
		PendingEvents[player]

	if not events then
		return
	end

	PendingEvents[player] = nil

	------------------------------------------------
	-- FLUSH
	------------------------------------------------

	for _, eventData in ipairs(events) do

		local remote =
			self:GetEvent(
				eventData.Remote
			)

		if remote then

			remote:FireClient(
				player,
				table.unpack(
					eventData.Arguments
				)
			)

		end

	end

	print(
		"[RemoteManager] Flushed",
		#events,
		"pending events for",
		player.Name
	)

end

------------------------------------------------
-- INIT
------------------------------------------------

function RemoteManager:Init()

	print(
		"[RemoteManager] Initializing..."
	)

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

	------------------------------------------------
	-- CLIENT READY
	------------------------------------------------

	local ClientReady =
		self:GetEvent(
			RemoteIndex.Events.ClientReady
		)

	ClientReady.OnServerEvent:Connect(
		function(player)

			self:SetPlayerReady(
				player
			)

		end
	)

	------------------------------------------------
	-- CLEANUP
	------------------------------------------------

	Players.PlayerRemoving:Connect(
		function(player)

			ReadyPlayers[player] = nil
			PendingEvents[player] = nil

		end
	)

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

	------------------------------------------------
	-- Allow RemoteEvent instance
	------------------------------------------------

	if typeof(name) == "Instance" then

		if name:IsA("RemoteEvent") then
			return name
		end

		warn(
			"[RemoteManager] Instance is not a RemoteEvent:",
			name:GetFullName()
		)

		return nil
	end

	------------------------------------------------
	-- Cached lookup
	------------------------------------------------

	local remote =
		Remotes[name]

	if remote
		and remote:IsA("RemoteEvent") then

		return remote

	end

	------------------------------------------------
	-- Fallback to actual folder
	------------------------------------------------

	remote =
		RemotesFolder:FindFirstChild(name)

	if remote then

		if not remote:IsA("RemoteEvent") then

			warn(
				"[RemoteManager] Remote exists but is not a RemoteEvent:",
				name
			)

			return nil

		end

		-- Repair cache
		Remotes[name] = remote

		return remote

	end

	warn(
		"[RemoteManager] RemoteEvent not found:",
		name
	)

	return nil

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
	table.clear(ReadyPlayers)
	table.clear(PendingEvents)

	print(
		"[RemoteManager] Cache cleared"
	)

end

return RemoteManager