local PunchImpact = {}

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

------------------------------------------------
-- CONFIG
------------------------------------------------

local ROCK_COUNT = 30

local ROCK_MIN_SIZE = 0.2
local ROCK_MAX_SIZE = 0.4

local HORIZONTAL_FORCE = 35
local UPWARD_FORCE_MIN = 30
local UPWARD_FORCE_MAX = 60

local FADE_DELAY = 2
local FADE_TIME = 1
local LIFETIME = 3

local ATTACHMENT_NAME = "PunchImpactAttachment"


function PunchImpact:GetAttachment(character)

	if not character then
		return nil
	end

	local hand =
		character:FindFirstChild("RightHand")

	if not hand then
		warn(
			"[PunchImpact] RightHand not found"
		)

		return nil
	end

	local attachment =
		hand:FindFirstChild(
			ATTACHMENT_NAME
		)

	------------------------------------------------
	-- Create automatically if missing
	------------------------------------------------

	if not attachment then

		attachment =
			Instance.new("Attachment")

		attachment.Name =
			ATTACHMENT_NAME

		------------------------------------------------
		-- Slightly below the hand
		-- Adjust this if required
		------------------------------------------------

		attachment.Position =
			Vector3.new(
				0,
				-0.5,
				0
			)

		attachment.Parent =
			hand

	end

	return attachment

end

------------------------------------------------
-- SPAWN ROCKS
------------------------------------------------

function PunchImpact:SpawnRocks(origin)

	if typeof(origin) ~= "Vector3" then
		return
	end

	for _ = 1, ROCK_COUNT do

		local size =
			math.random(
				ROCK_MIN_SIZE * 100,
				ROCK_MAX_SIZE * 100
			) / 100

		local rock = Instance.new("Part")

		rock.Name = "PunchImpactRock"

		rock.Size = Vector3.new(
			size,
			size,
			size
		)

		rock.Shape =
			Enum.PartType.Block

		rock.Material =
			Enum.Material.Slate

		rock.Color =
			Color3.fromRGB(
				90,
				90,
				90
			)

		rock.Position =
			origin

		rock.Anchored = false
		rock.CanCollide = true
		rock.CanTouch = false
		rock.CanQuery = false
		rock.Massless = false

		------------------------------------------------
		-- Collision group
		------------------------------------------------

		rock.CollisionGroup =
			"DebrisRocks"

		rock.Parent =
			workspace

		------------------------------------------------
		-- Throw rock outward
		------------------------------------------------

		local impulse =
			Vector3.new(
				math.random(
					-HORIZONTAL_FORCE,
					HORIZONTAL_FORCE
				),

				math.random(
					UPWARD_FORCE_MIN,
					UPWARD_FORCE_MAX
				),

				math.random(
					-HORIZONTAL_FORCE,
					HORIZONTAL_FORCE
				)
			)

		rock:ApplyImpulse(
			impulse * rock.AssemblyMass
		)

		------------------------------------------------
		-- Random rotation
		------------------------------------------------

		local angularImpulse =
			Vector3.new(
				math.random(-10, 10),
				math.random(-10, 10),
				math.random(-10, 10)
			)

		rock:ApplyAngularImpulse(
			angularImpulse * rock.AssemblyMass
		)

		------------------------------------------------
		-- Fade
		------------------------------------------------

		task.delay(
			FADE_DELAY,
			function()

				if not rock.Parent then
					return
				end

				local tween =
					TweenService:Create(
						rock,
						TweenInfo.new(
							FADE_TIME
						),
						{
							Transparency = 1
						}
					)

				tween:Play()

			end
		)

		Debris:AddItem(
			rock,
			LIFETIME
		)

	end

end



------------------------------------------------
-- CREATE IMPACT FROM CHARACTER
------------------------------------------------

function PunchImpact:CreateFromCharacter(
	character
)

	local attachment =
		self:GetAttachment(
			character
		)

	if not attachment then
		return
	end

	self:SpawnRocks(
		attachment.WorldPosition
	)

end


return PunchImpact