local BallManager = {}

------------------------------------------------
-- SERVICES
------------------------------------------------

local Players =
	game:GetService("Players")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")
local EasyRagdoll =
	require(
		ReplicatedStorage
			.Shared
			.Modules
			.EasyRagdoll
	)
------------------------------------------------
-- MODULES
------------------------------------------------

local ItemPickupDropModule =
	require(
		ReplicatedStorage
			.Shared
			.Modules
			.ItemPickupDropModule
	)

------------------------------------------------
-- REMOTE
------------------------------------------------

local Remotes =
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Remotes")

local DashBall =
	Remotes:WaitForChild("DashBall")

------------------------------------------------
-- FOLDERS
------------------------------------------------

local BallsFolder =
	workspace:WaitForChild("Balls")

------------------------------------------------
-- CONFIG
------------------------------------------------

local PROMPT_NAME =
	"PickupPrompt"

local EQUIP_OFFSET =
	CFrame.new(
		0,
		-0.5,
		-1
	)

------------------------------------------------
-- THROW CONFIG
------------------------------------------------

local THROW_SPEED =
	125
local THROW_UPWARD = 25

local THROW_FORWARD_OFFSET =
	2.5

local THROW_HEIGHT_OFFSET =
	1.2


-- RAGDOLL

local RAGDOLL_DURATION = 2.5

local THROW_HIT_COOLDOWN = 0.2

------------------------------------------------
-- STATE
------------------------------------------------

-- [player] = {
--     Item = ball,
--     MainPart = main,
--     Hand = hand,
--     Weld = weld
-- }

local HoldingBalls = {}

local BallConnections = {}

------------------------------------------------
-- GET MAIN PART
------------------------------------------------

local function GetMainPart(ball)

	return ItemPickupDropModule:GetMainPart(
		ball
	)

end

local function GetCharacterFromPart(part)

	if not part then
		return nil
	end

	local character =
		part:FindFirstAncestorOfClass("Model")

	if not character then
		return nil
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil
	end

	return character

end
local function SetupThrowHit(
	ball,
	thrower
)

	local main =
		GetMainPart(ball)

	if not main then
		return
	end

	local alreadyHit = {}

	local connection

	connection =
		main.Touched:Connect(
			function(hitPart)

				local character =
					GetCharacterFromPart(
						hitPart
					)

				if not character then
					return
				end

				------------------------------------------------
				-- DON'T HIT THROWER
				------------------------------------------------

				if character ==
					thrower.Character then

					return

				end

				------------------------------------------------
				-- DON'T HIT SAME PLAYER TWICE
				------------------------------------------------

				if alreadyHit[character] then
					return
				end

				alreadyHit[character] = true

				------------------------------------------------
				-- RAGDOLL
				------------------------------------------------

				print(
					"[BallManager] DashBall hit:",
					character.Name
				)

				EasyRagdoll.SetRagdoll(
					character,
					true,
					true,
					200
				)

				------------------------------------------------
				-- RECOVER
				------------------------------------------------

				task.delay(
					RAGDOLL_DURATION,
					function()

						if character
							and character.Parent then

							EasyRagdoll.SetRagdoll(
								character,
								false
							)

						end

					end
				)

				------------------------------------------------
				-- CLEANUP
				------------------------------------------------

				if connection then

					connection:Disconnect()

					connection = nil

				end

			end
		)

	------------------------------------------------
	-- SAFETY CLEANUP
	------------------------------------------------

	task.delay(
		5,
		function()

			if connection then

				connection:Disconnect()

				connection = nil

			end

		end
	)

end



------------------------------------------------
-- HAS BALL
------------------------------------------------

function BallManager:HasBall(player)

	return HoldingBalls[player] ~= nil

end

------------------------------------------------
-- GET EQUIPPED BALL
------------------------------------------------

function BallManager:GetBall(player)

	local equipped =
		HoldingBalls[player]

	if not equipped then
		return nil
	end

	return equipped.Item

end

------------------------------------------------
-- PICKUP
------------------------------------------------

function BallManager:PickupBall(
	player,
	ball
)

	if not player
		or not player.Parent then

		return false

	end

	------------------------------------------------
	-- ONLY ONE BALL
	------------------------------------------------

	if self:HasBall(player) then

		print(
			"[BallManager] Player already has Ball:",
			player.Name
		)

		return false

	end

	------------------------------------------------
	-- VALIDATE BALL
	------------------------------------------------

	if not ball
		or not ball.Parent then

		return false

	end

	if not ball:IsDescendantOf(
		BallsFolder
	) then

		return false

	end

	------------------------------------------------
	-- MAKE SURE BALL IS NOT HELD
	------------------------------------------------

	if ball:GetAttribute("PickedUp") then

		return false

	end

	------------------------------------------------
	-- MAIN PART
	------------------------------------------------

	local main =
		GetMainPart(ball)

	if not main then

		warn(
			"[BallManager] Main part missing:",
			ball:GetFullName()
		)

		return false

	end

	------------------------------------------------
	-- PROMPT
	------------------------------------------------

	local prompt =
		main:FindFirstChild(
			PROMPT_NAME
		)

	if prompt then

		prompt.Enabled =
			false

	end

	------------------------------------------------
	-- CHARACTER
	------------------------------------------------

	local character =
		player.Character

	if not character then

		if prompt then
			prompt.Enabled = true
		end

		return false

	end

	------------------------------------------------
	-- EQUIP
	------------------------------------------------

	local equipped =
		ItemPickupDropModule:Equip(
			character,
			ball,
			EQUIP_OFFSET
		)

	if not equipped then

		if prompt then
			prompt.Enabled = true
		end

		return false

	end

	------------------------------------------------
	-- STORE
	------------------------------------------------

	HoldingBalls[player] =
		equipped
	player:SetAttribute("HoldingDashBall", true)
	ball:SetAttribute(
		"PickedUp",
		true
	)

	ball:SetAttribute(
		"HeldBy",
		player.UserId
	)

	print(
		"[BallManager] Equipped Ball:",
		player.Name
	)

	return true

end

------------------------------------------------
-- THROW BALL
------------------------------------------------

function BallManager:ThrowBall(
	player
)

	------------------------------------------------
	-- CHECK PLAYER HAS BALL
	------------------------------------------------

	local equipped =
		HoldingBalls[player]

	if not equipped then

		return false

	end

	------------------------------------------------
	-- CHARACTER
	------------------------------------------------

	local character =
		player.Character

	if not character then

		return false

	end

	local root =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then

		return false

	end

	------------------------------------------------
	-- BALL
	------------------------------------------------

	local ball =
		equipped.Item

	if not ball
		or not ball.Parent then

		HoldingBalls[player] =
			nil

		return false

	end

	------------------------------------------------
	-- MAIN PART
	------------------------------------------------

	local main =
		GetMainPart(ball)

	if not main then

		HoldingBalls[player] =
			nil

		return false

	end

	------------------------------------------------
	-- REMOVE HAND WELD
	------------------------------------------------

	ItemPickupDropModule:Unequip(
		equipped
	)

	------------------------------------------------
	-- MOVE BALL BACK TO BALLS FOLDER
	------------------------------------------------

	ball.Parent =
		BallsFolder

	------------------------------------------------
	-- THROW POSITION
	------------------------------------------------

	local throwPosition =
		root.Position
		+ root.CFrame.LookVector
			* THROW_FORWARD_OFFSET
		+ Vector3.new(
			0,
			THROW_HEIGHT_OFFSET,
			0
		)

	------------------------------------------------
	-- POSITION BALL
	------------------------------------------------

	if ball:IsA("Model") then

		ball:PivotTo(
			CFrame.new(
				throwPosition
			)

		)

	else

		ball.CFrame =
			CFrame.new(
				throwPosition
			)

	end

	------------------------------------------------
	-- RESTORE PHYSICS
	------------------------------------------------

	ItemPickupDropModule:PrepareForDrop(
		ball
	)

	------------------------------------------------
	-- RESET ATTRIBUTES
	------------------------------------------------
	player:SetAttribute("HoldingDashBall", false)
	ball:SetAttribute(
		"PickedUp",
		false
	)

	ball:SetAttribute(
		"HeldBy",
		nil
	)
	-- Re-enable pickup prompt
	local prompt =
		main:FindFirstChild("PickupPrompt")


	------------------------------------------------
	-- THROW
	------------------------------------------------

	main.AssemblyLinearVelocity =
		root.CFrame.LookVector * THROW_SPEED
		+ Vector3.new(0, THROW_UPWARD, 0)

	------------------------------------------------
	-- CLEAR PLAYER STATE
	------------------------------------------------

	HoldingBalls[player] =
		nil

	SetupThrowHit(
		ball,
		player
	)

	if prompt then
		prompt.Enabled = true
	end
	print(
		"[BallManager] Ball thrown:",
		player.Name
	)

	return true

end

------------------------------------------------
-- SETUP BALL
------------------------------------------------

function BallManager:SetupBall(
	ball
)

	if BallConnections[ball] then
		return
	end

	local main =
		GetMainPart(ball)

	if not main then

		warn(
			"[BallManager] Invalid Ball:",
			ball:GetFullName()
		)

		return

	end

	local prompt =
		main:FindFirstChild(
			PROMPT_NAME
		)

	if not prompt then

		warn(
			"[BallManager] PickupPrompt missing:",
					ball:GetFullName()
		)

		return

	end

	BallConnections[ball] =
		prompt.Triggered:Connect(
			function(player)

				self:PickupBall(
					player,
					ball
				)

			end
		)

	------------------------------------------------
	-- CLEAN CONNECTION
	------------------------------------------------

	ball.Destroying:Connect(
		function()

			if BallConnections[ball] then

				BallConnections[ball]:Disconnect()

				BallConnections[ball] =
					nil

			end

		end
	)

end

------------------------------------------------
-- REMOTE
------------------------------------------------

local RemoteConnection

local function SetupRemote()

	if RemoteConnection then
		return
	end

	RemoteConnection =
		DashBall.OnServerEvent:Connect(
			function(
				player,
				action
			)

				if action == "Throw" then

					BallManager:ThrowBall(
						player
					)

				end

			end
		)

end

------------------------------------------------
-- INIT
------------------------------------------------

function BallManager:Init()

	print(
		"[BallManager] Initializing..."
	)

	------------------------------------------------
	-- REMOTE
	------------------------------------------------

	SetupRemote()

	------------------------------------------------
	-- EXISTING BALLS
	------------------------------------------------

	for _, ball in ipairs(
		BallsFolder:GetChildren()
	) do

		self:SetupBall(
			ball
		)

	end

	------------------------------------------------
	-- NEW BALLS
	------------------------------------------------

	BallsFolder.ChildAdded:Connect(
		function(ball)

			self:SetupBall(
				ball
			)

		end
	)

	------------------------------------------------
	-- PLAYER CLEANUP
	------------------------------------------------

	Players.PlayerRemoving:Connect(
		function(player)

			local equipped =
				HoldingBalls[player]

			if equipped then

				ItemPickupDropModule:Unequip(
					equipped
				)

			end

			HoldingBalls[player] =
				nil

		end
	)

	print(
		"[BallManager] Initialized"
	)

end

return BallManager