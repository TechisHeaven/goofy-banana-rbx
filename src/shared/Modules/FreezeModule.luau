-- // Freeze Module // --
-- Supports:
-- Mode = "Duration" -> automatically unfreezes
-- Mode = "Rescue"   -> stays frozen until Module.Unfreeze(Target)

------------------------------------------------
-- CONFIG
------------------------------------------------

local AnchorIfNotMoving = false

local DisableScripts = true

local DisableToolScripts = false

local ClassNamesToFreeze = {
	"Part",
	"WedgePart",
	"CornerWedgePart",
	"TrussPart",
	"UnionOperation",
}

local IceSettings = {
	IceSize = 1.2,
	SpecialMeshSize = 1.2,

	Name = "Ice",
	TextureID = "",

	Color = Color3.fromRGB(128, 187, 219),
	Material = Enum.Material.Ice,

	CanCollide = false,
	CanTouch = false,
	CanQuery = false,

	CastShadow = false,
	Massless = true,

	Transparency = 0.5,
}

------------------------------------------------
-- SERVICES
------------------------------------------------

local Debris =
	game:GetService("Debris")

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FreezeEffects = ReplicatedStorage.Effects.FreezeEffects
------------------------------------------------
-- MODULE
------------------------------------------------

local Module = {}

------------------------------------------------
-- STATES
------------------------------------------------

local FreezeStates = {}

------------------------------------------------
-- OLD MOVEMENT VALUES
------------------------------------------------

local OldValues =
	setmetatable({}, {
		__mode = "k"
	})

------------------------------------------------
-- CHECK CLASS
------------------------------------------------

local function CheckClassName(Object)

	for _, ClassName in ipairs(
		ClassNamesToFreeze
	) do

		if Object:IsA(ClassName) then
			return true
		end

	end

	return false

end

------------------------------------------------
-- CHANGE MOVEMENT
------------------------------------------------

local function ChangeValues(
	player,
	NewWalkspeed,
	NewJumppower
)

	local Humanoid =
		player:FindFirstChildOfClass(
			"Humanoid"
		)

	if not Humanoid then
		return
	end

	OldValues[player] = {
		walkspeed = Humanoid.WalkSpeed,
		jumppower = Humanoid.JumpPower,
	}

	Humanoid.WalkSpeed =
		NewWalkspeed

	Humanoid.JumpPower =
		NewJumppower

end

------------------------------------------------
-- RESTORE MOVEMENT
------------------------------------------------

local function SetBackValues(player)

	local Humanoid =
		player:FindFirstChildOfClass(
			"Humanoid"
		)

	if not Humanoid then
		OldValues[player] = nil
		return
	end

	local Values =
		OldValues[player]

	if not Values then
		return
	end

	Humanoid.WalkSpeed =
		Values.walkspeed

	Humanoid.JumpPower =
		Values.jumppower

	OldValues[player] = nil

end

------------------------------------------------
-- ARGUMENT HELPERS
------------------------------------------------

function Module.IsArgumentBlank(
	Argument
)

	if Argument == nil then
		return true
	end

	local String =
		tostring(Argument)

	String =
		string.gsub(
			String,
			"%s",
			""
		)

	return String == ""

end

------------------------------------------------

function Module.IsArgumentNumber(
	Argument
)

	return tonumber(Argument) ~= nil

end

------------------------------------------------
-- EFFECT CLEANUP HELPER
------------------------------------------------

local function TrackObject(
	State,
	Object
)

	if not Object then
		return
	end

	table.insert(
		State.Objects,
		Object
	)

end

------------------------------------------------
-- CLEAN OBJECTS
------------------------------------------------

local function CleanupObjects(State)

	if not State then
		return
	end

	for _, Object in ipairs(
		State.Objects
	) do

		if Object
			and Object.Parent then

			Object:Destroy()

		end

	end

	table.clear(State.Objects)

end

------------------------------------------------
-- DISABLE SCRIPTS
------------------------------------------------

local function DisableTargetScripts(
	Target,
	State
)

	local IgnoreList = {
		badgereward = true,
		stunscript = true,
	}

	for _, Object in ipairs(
		Target:GetDescendants()
	) do

		if not (
			Object:IsA("Script")
			or Object:IsA("LocalScript")
		) then

			continue
		end

		local ShouldDisable = false

		if not Object.Parent:IsA("Tool") then

			if DisableScripts then
				ShouldDisable = true
			end

		else

			if DisableToolScripts then
				ShouldDisable = true
			end

		end

		if not ShouldDisable then
			continue
		end

		if not Object.Enabled then
			continue
		end

		if IgnoreList[
			string.lower(Object.Name)
		] then

			continue

		end

		Object.Enabled = false

		table.insert(
			State.DisabledScripts,
			Object
		)

	end

end

------------------------------------------------
-- RESTORE SCRIPTS
------------------------------------------------

local function RestoreScripts(State)

	if not State then
		return
	end

	for _, Object in ipairs(
		State.DisabledScripts
	) do

		if Object
			and Object.Parent then

			Object.Enabled = true

		end

	end

	table.clear(
		State.DisabledScripts
	)

end

------------------------------------------------
-- SCHEDULE OBJECT CLEANUP
------------------------------------------------

local function ScheduleCleanup(
	State,
	Object,
	Duration
)

	TrackObject(
		State,
		Object
	)

	if Duration then

		Debris:AddItem(
			Object,
			Duration
		)

	end

end

------------------------------------------------
-- UNFREEZE
------------------------------------------------

function Module.Unfreeze(Target)

	if not Target then
		return
	end

	local State =
		FreezeStates[Target]

	if not State then
		return
	end

	------------------------------------------------
	-- Mark cleanup
	------------------------------------------------

	State.Unfreezing = true

	------------------------------------------------
	-- Restore movement
	------------------------------------------------

	local Humanoid =
		Target:FindFirstChildOfClass(
			"Humanoid"
		)

	if Humanoid then

		Humanoid.UseJumpPower = true

		SetBackValues(Target)

		local Animator =
			Humanoid:FindFirstChildOfClass(
				"Animator"
			)

		if Animator then

			for _, Track in ipairs(
				Animator:GetPlayingAnimationTracks()
			) do

				Track:AdjustSpeed(1)

			end

		end

		Humanoid:ChangeState(
			Enum.HumanoidStateType.Freefall
		)

	end

	------------------------------------------------
	-- Animation Controller
	------------------------------------------------

	local AnimationController =
		Target:FindFirstChildOfClass(
			"AnimationController"
		)

	if AnimationController then

		local Animator =
			AnimationController:FindFirstChildOfClass(
				"Animator"
			)

		if Animator then

			for _, Track in ipairs(
				Animator:GetPlayingAnimationTracks()
			) do

				Track:AdjustSpeed(1)

			end

		end

	end

	------------------------------------------------
	-- Restore scripts
	------------------------------------------------

	RestoreScripts(State)

	------------------------------------------------
	-- Remove FrozenTag
	------------------------------------------------

	local FrozenTag =
		Target:FindFirstChild(
			"FrozenTag"
		)

	if FrozenTag then
		FrozenTag:Destroy()
	end

	------------------------------------------------
	-- Shatter sound
	------------------------------------------------

	local Root =
		Target:FindFirstChild(
			"HumanoidRootPart"
		)

	if Root then

		task.spawn(function()

			local Sound =
				ReplicatedStorage.Sounds:FindFirstChild(
					"Ice Shatter"
				)

			if not Sound then
				return
			end

			local Clone =
				Sound:Clone()

			Clone.Parent = Root

			Clone:Play()

			Debris:AddItem(
				Clone,
				2
			)

		end)

	end

	------------------------------------------------
	-- Shatter effects
	------------------------------------------------

	if Root
		and Target.Parent then

		local CharacterSize =
			Target:GetExtentsSize().Magnitude

		if CharacterSize >= 20 then
			CharacterSize = 20
		end

		for _, Effect in ipairs(
			FreezeEffects:GetChildren()
		) do

			if not Effect:IsA(
				"ParticleEmitter"
			) then

				continue

			end

			if Effect.Name ~= "Shock Wave"
				and Effect.Name ~= "Specs" then

				continue

			end

			local EffectClone =
				Effect:Clone()

			local Attachment =
				Instance.new(
					"Attachment"
				)

			Attachment.Parent =
				Root

			EffectClone.Parent =
				Attachment

			if Effect.Name
				== "Shock Wave" then

				local SizeMultiplier =
					CharacterSize

				EffectClone.Size =
					NumberSequence.new(
						0,
						SizeMultiplier
					)

			elseif Effect.Name
				== "Specs" then

				local SizeMultiplier =
					CharacterSize * 0.2

				EffectClone.Size =
					NumberSequence.new(
						SizeMultiplier,
						SizeMultiplier
					)

			end

			EffectClone:Emit(
				EffectClone:GetAttribute(
					"EmitCount"
				)
			)

			Debris:AddItem(
				Attachment,
				2
			)

		end

	end

	------------------------------------------------
	-- Remove ice / temporary objects
	------------------------------------------------

	CleanupObjects(State)

	------------------------------------------------
	-- Clear state
	------------------------------------------------

	FreezeStates[Target] = nil

end

------------------------------------------------
-- FREEZE
------------------------------------------------

function Module.Freeze(
	Target,
	Options
)

	if not Target then
		return
	end

	Options =
		Options or {}

	------------------------------------------------
	-- MODE
	------------------------------------------------

	local Mode =
		Options.Mode
		or "Duration"

	if Mode ~= "Duration"
		and Mode ~= "Rescue" then

		warn(
			"[FreezeModule] Invalid Mode:",
			Mode
		)

		return
	end

	------------------------------------------------
	-- DURATION
	------------------------------------------------

	local Duration

	if Mode == "Duration" then

		Duration =
			tonumber(
				Options.Duration
			)

		if not Duration
			or Duration <= 0 then

			warn(
				"[FreezeModule] Duration mode requires a valid Duration"
			)

			return
		end

	end

	------------------------------------------------
	-- ALREADY FROZEN
	------------------------------------------------

	if FreezeStates[Target] then
		return
	end

	local ExistingTag =
		Target:FindFirstChild(
			"FrozenTag"
		)

	if ExistingTag then
		return
	end

	------------------------------------------------
	-- ROOT
	------------------------------------------------

	local Root =
		Target:FindFirstChild(
			"HumanoidRootPart"
		)

	if not Root then
		return
	end

	------------------------------------------------
	-- STATE
	------------------------------------------------

	local State = {
		Mode = Mode,
		Duration = Duration,

		Objects = {},
		DisabledScripts = {},

		Unfreezing = false,
	}

	FreezeStates[Target] =
		State

	------------------------------------------------
	-- FROZEN TAG
	------------------------------------------------

	local Frozen =
		Instance.new(
			"ObjectValue"
		)

	Frozen.Name =
		"FrozenTag"

	Frozen.Value =
		Target

	Frozen.Parent =
		Target

	TrackObject(
		State,
		Frozen
	)

	------------------------------------------------
	-- EFFECT DURATION
	------------------------------------------------

	-- Duration mode:
	-- effects live until automatic unfreeze.
	--
	-- Rescue mode:
	-- effects stay until Unfreeze().
	local EffectDuration =
		Duration

	------------------------------------------------
	-- TWEEN TIME
	------------------------------------------------

	local TweenTime

	if Mode == "Rescue" then

		TweenTime = 0.5

	elseif Duration >= 1 then

		TweenTime = 0.5

	else

		TweenTime =
			Duration / 5

	end

	local TI =
		TweenInfo.new(
			TweenTime,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.InOut
		)

	------------------------------------------------
	-- CHARACTER SIZE
	------------------------------------------------

	local CharacterSize =
		Target:GetExtentsSize().Magnitude

	if CharacterSize >= 20 then
		CharacterSize = 20
	end

	------------------------------------------------
	-- ICE COVER
	------------------------------------------------

	local CoverPart =
		Instance.new("Part")

	CoverPart.Name =
		"IceCover"

	CoverPart.Color =
		IceSettings.Color

	CoverPart.Material =
		IceSettings.Material

	CoverPart.CanCollide =
		IceSettings.CanCollide

	CoverPart.CanTouch =
		IceSettings.CanTouch

	CoverPart.CanQuery =
		IceSettings.CanQuery

	CoverPart.CastShadow =
		IceSettings.CastShadow

	CoverPart.Massless =
		IceSettings.Massless

	CoverPart.Transparency =
		1

	CoverPart.Size =
		Vector3.new(
			CharacterSize,
			CharacterSize,
			CharacterSize
		)

	CoverPart.Position =
		Root.Position

	CoverPart.Parent =
		Root

	------------------------------------------------
	-- WELD COVER
	------------------------------------------------

	local CoverWeld =
		Instance.new(
			"WeldConstraint"
		)

	CoverWeld.Part0 =
		CoverPart

	CoverWeld.Part1 =
		Root

	CoverWeld.Parent =
		CoverPart

	------------------------------------------------
	-- TRACK COVER
	------------------------------------------------

	ScheduleCleanup(
		State,
		CoverPart,
		EffectDuration
	)

	------------------------------------------------
	-- FREEZE SOUND
	------------------------------------------------

	task.spawn(function()

		local FreezeSound =
			ReplicatedStorage.Sounds:FindFirstChild(
				"Freeze"
			)

		if not FreezeSound then
			return
		end

		if not CoverPart.Parent then
			return
		end

		local Clone =
			FreezeSound:Clone()

		Clone.Parent =
			CoverPart

		if Mode == "Duration"
			and Duration
			and Duration < Clone.TimeLength
			and Duration > 0 then

			Clone.PlaybackSpeed =
				Clone.TimeLength
				/ Duration

		end

		Clone:Play()

	end)

	------------------------------------------------
	-- ICE BLOCKS
	------------------------------------------------

	local IceFolder =
		FreezeEffects[
			"Ice Blocks"
		]

	local IceBlocks = {
		IceFolder.IceBlock1,
		IceFolder.IceBlock2,
	}

	------------------------------------------------
	-- CHARACTER PARTS
	------------------------------------------------

	for _, Part in ipairs(
		Target:GetDescendants()
	) do

		------------------------------------------------
		-- NORMAL PART
		------------------------------------------------

		if CheckClassName(Part)
			and not Part:FindFirstChildOfClass(
				"SpecialMesh"
			) then

			if Part.Transparency ~= 1 then

				task.spawn(function()

					local IceBlock =
						IceBlocks[
							math.random(
								1,
								#IceBlocks
							)
						]

					local Ice =
						IceBlock:Clone()

					if Root.AssemblyLinearVelocity.Magnitude < 2
						and AnchorIfNotMoving then

						Ice.Anchored = true

					else

						Ice.Anchored = false

					end

					Ice.Name =
						IceSettings.Name

					Ice.TextureID =
						IceSettings.TextureID

					Ice.Color =
						IceSettings.Color

					Ice.Material =
						IceSettings.Material

					Ice.CanCollide =
						IceSettings.CanCollide

					Ice.CanTouch =
						IceSettings.CanTouch

					Ice.CanQuery =
						IceSettings.CanQuery

					Ice.CastShadow =
						IceSettings.CastShadow

					Ice.Massless =
						IceSettings.Massless

					Ice.Transparency =
						1

					Ice.Size =
						Vector3.new(
							0,
							0,
							0
						)

					Ice.Position =
						Part.Position

					Ice.Orientation =
						Part.Orientation

					Ice.Parent =
						Part

					local NewSize =
						Vector3.new(
							Part.Size.X,
							Part.Size.Y,
							Part.Size.Z
						)
						* IceSettings.IceSize

					local Tween =
						TweenService:Create(
							Ice,
							TI,
							{
								Transparency =
									IceSettings.Transparency,

								Size =
									NewSize,
							}
						)

					Tween:Play()

					local Weld =
						Instance.new(
							"WeldConstraint"
						)

					Weld.Part0 =
						Ice

					Weld.Part1 =
						Part

					Weld.Parent =
						Ice

					local Weld2 =
						Instance.new(
							"WeldConstraint"
						)

					Weld2.Part0 =
						Root

					Weld2.Part1 =
						Part

					Weld2.Parent =
						Ice

					ScheduleCleanup(
						State,
						Ice,
						EffectDuration
					)

				end)

			end

		------------------------------------------------
		-- MESHPART
		------------------------------------------------

		elseif Part:IsA("MeshPart")
			and not Part:FindFirstChildOfClass(
				"WrapLayer"
			) then

			if Part.Transparency ~= 1 then

				task.spawn(function()

					local Ice =
						Part:Clone()

					Ice:ClearAllChildren()

					Ice.Name =
						IceSettings.Name

					Ice.TextureID =
						IceSettings.TextureID

					Ice.Color =
						IceSettings.Color

					Ice.Material =
						IceSettings.Material

					Ice.CanCollide =
						IceSettings.CanCollide

					Ice.CanTouch =
						IceSettings.CanTouch

					Ice.CanQuery =
						IceSettings.CanQuery

					Ice.CastShadow =
						IceSettings.CastShadow

					Ice.Massless =
						IceSettings.Massless

					Ice.Transparency =
						1

					Ice.Size =
						Vector3.new(
							0,
							0,
							0
						)

					Ice.Position =
						Part.Position

					Ice.Orientation =
						Part.Orientation

					Ice.Parent =
						Part

					local NewSize =
						Vector3.new(
							Part.Size.X,
							Part.Size.Y,
							Part.Size.Z
						)
						* IceSettings.IceSize

					local Tween =
						TweenService:Create(
							Ice,
							TI,
							{
								Transparency =
									IceSettings.Transparency,

								Size =
									NewSize,
							}
						)

					Tween:Play()

					local Weld =
						Instance.new(
							"WeldConstraint"
						)

					Weld.Part0 =
						Ice

					Weld.Part1 =
						Part

					Weld.Parent =
						Ice

					local Weld2 =
						Instance.new(
							"WeldConstraint"
						)

					Weld2.Part0 =
						Root

					Weld2.Part1 =
						Part

					Weld2.Parent =
						Ice

					ScheduleCleanup(
						State,
						Ice,
						EffectDuration
					)

				end)

			end

		------------------------------------------------
		-- SPECIAL MESH
		------------------------------------------------

		elseif Part:IsA(
			"SpecialMesh"
		) then

			if Part.Parent:IsA("Part")
				and Part.Parent.Transparency ~= 1 then

				task.spawn(function()

					local Ice =
						Part.Parent:Clone()

					for _, Child in ipairs(
						Ice:GetChildren()
					) do

						if not Child:IsA(
							"SpecialMesh"
						) then

							Child:Destroy()

						end

					end

					local IceMesh =
						Ice:FindFirstChildOfClass(
							"SpecialMesh"
						)

					if not IceMesh then
						Ice:Destroy()
						return
					end

					Ice.Name =
						IceSettings.Name

					IceMesh.TextureId =
						IceSettings.TextureID

					Ice.Color =
						IceSettings.Color

					Ice.Material =
						IceSettings.Material

					Ice.CanCollide =
						IceSettings.CanCollide

					Ice.CanTouch =
						IceSettings.CanTouch

					Ice.CanQuery =
						IceSettings.CanQuery

					Ice.CastShadow =
						IceSettings.CastShadow

					Ice.Massless =
						IceSettings.Massless

					Ice.Transparency =
						1

					IceMesh.Scale =
						Vector3.new(
							Part.Scale.X,
							Part.Scale.Y,
							Part.Scale.Z
						)
						* IceSettings.SpecialMeshSize

					Ice.Position =
						Part.Parent.Position

					Ice.Orientation =
						Part.Parent.Orientation

					Ice.Parent =
						Part.Parent

					local Tween =
						TweenService:Create(
							Ice,
							TI,
							{
								Transparency =
									IceSettings.Transparency
							}
						)

					Tween:Play()

					local Weld =
						Instance.new(
							"WeldConstraint"
						)

					Weld.Part0 =
						Ice

					Weld.Part1 =
						Part.Parent

					Weld.Parent =
						Ice

					local Weld2 =
						Instance.new(
							"WeldConstraint"
						)

					Weld2.Part0 =
						Root

					Weld2.Part1 =
						Part.Parent

					Weld2.Parent =
						Ice

					ScheduleCleanup(
						State,
						Ice,
						EffectDuration
					)

				end)

			end

		------------------------------------------------
		-- SCRIPTS
		------------------------------------------------

		elseif Part:IsA("Script")
			or Part:IsA("LocalScript") then

			-- handled below
		end

	end

	------------------------------------------------
	-- DISABLE SCRIPTS
	------------------------------------------------

	DisableTargetScripts(
		Target,
		State
	)

	------------------------------------------------
	-- PARTICLE ATTACHMENT
	------------------------------------------------

	local Attachment =
		Instance.new(
			"Attachment"
		)

	Attachment.Parent =
		Root

	ScheduleCleanup(
		State,
		Attachment,
		EffectDuration
	)

	------------------------------------------------
	-- FREEZE PARTICLES
	------------------------------------------------

	for _, Effect in ipairs(
		FreezeEffects:GetChildren()
	) do

		if not Effect:IsA(
			"ParticleEmitter"
		) then

			continue

		end

		local EffectClone =
			Effect:Clone()

		------------------------------------------------
		-- SMOKE
		------------------------------------------------

		if EffectClone.Name
			== "Smoke" then

			local SizeMultiplier =
				CharacterSize

			EffectClone.Size =
				NumberSequence.new(
					0,
					SizeMultiplier
				)

			EffectClone.Parent =
				Attachment

			EffectClone.Enabled =
				true

			ScheduleCleanup(
				State,
				EffectClone,
				EffectDuration
			)

		------------------------------------------------
		-- SPARKLES
		------------------------------------------------

		elseif EffectClone.Name
			== "Sparkles" then

			EffectClone.Parent =
				CoverPart

			EffectClone.Enabled =
				true

			ScheduleCleanup(
				State,
				EffectClone,
				EffectDuration
			)

		------------------------------------------------
		-- SHOCK WAVE
		------------------------------------------------

		elseif EffectClone.Name
			== "Shock Wave" then

			local SizeMultiplier =
				CharacterSize

			EffectClone.Size =
				NumberSequence.new(
					0,
					SizeMultiplier
				)

			EffectClone.Parent =
				Attachment

			EffectClone:Emit(
				EffectClone:GetAttribute(
					"EmitCount"
				)
			)

			ScheduleCleanup(
				State,
				EffectClone,
				EffectDuration
			)

		------------------------------------------------
		-- SPECS
		------------------------------------------------

		elseif EffectClone.Name
			== "Specs" then

			local SizeMultiplier =
				CharacterSize * 0.2

			EffectClone.Size =
				NumberSequence.new(
					SizeMultiplier,
					SizeMultiplier
				)

			EffectClone.Parent =
				Attachment

			EffectClone:Emit(
				EffectClone:GetAttribute(
					"EmitCount"
				)
			)

			ScheduleCleanup(
				State,
				EffectClone,
				EffectDuration
			)

		------------------------------------------------
		-- OTHER
		------------------------------------------------

		else

			EffectClone.Parent =
				Root

			EffectClone:Emit(
				EffectClone:GetAttribute(
					"EmitCount"
				)
			)

			ScheduleCleanup(
				State,
				EffectClone,
				EffectDuration
			)

		end

	end

	------------------------------------------------
	-- HUMANOID
	------------------------------------------------

	local Humanoid =
		Target:FindFirstChildOfClass(
			"Humanoid"
		)

	if Humanoid then

		Humanoid.UseJumpPower =
			true

		------------------------------------------------
		-- Save movement
		------------------------------------------------

		ChangeValues(
			Target,
			0,
			0
		)

		------------------------------------------------
		-- Freeze animations
		------------------------------------------------

		local Animator =
			Humanoid:FindFirstChildOfClass(
				"Animator"
			)

		if Animator then

			for _, Track in ipairs(
				Animator:GetPlayingAnimationTracks()
			) do

				Track:AdjustSpeed(0)
				Track:Stop()

			end

		end

		Humanoid:ChangeState(
			Enum.HumanoidStateType.Physics
		)

	end

	------------------------------------------------
	-- ANIMATION CONTROLLER
	------------------------------------------------

	local AnimationController =
		Target:FindFirstChildOfClass(
			"AnimationController"
		)

	if AnimationController then

		local Animator =
			AnimationController:FindFirstChildOfClass(
				"Animator"
			)

		if Animator then

			for _, Track in ipairs(
				Animator:GetPlayingAnimationTracks()
			) do

				Track:AdjustSpeed(0)
				Track:Stop()

			end

		end

	end

	------------------------------------------------
	-- AUTOMATIC UNFREEZE
	------------------------------------------------

	if Mode == "Duration" then

		task.delay(
			Duration,
			function()

				if FreezeStates[Target]
					== State then

					Module.Unfreeze(
						Target
					)

				end

			end
		)

	end

end

------------------------------------------------
-- RETURN
------------------------------------------------

return Module