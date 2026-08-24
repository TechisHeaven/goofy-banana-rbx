local AnimationEffectManager = {}

local Debris = game:GetService("Debris")

------------------------------------------------
-- CONFIG
------------------------------------------------

local IMPACT_MARKER = "Impact"
local WOOOSH_MARKER = "Whoosh"

local DEFAULT_EMIT_COUNT = 5
local VFX_LIFETIME = 5

------------------------------------------------
-- GET RIGHT HAND
------------------------------------------------

local function GetRightHand(character)

	if not character then
		return nil
	end

	return character:FindFirstChild("RightHand")
		or character:FindFirstChild("Right Arm")

end



------------------------------------------------
-- ATTACH VFX TO HAND
------------------------------------------------

local function AttachVFXAttachmentToHand(character, vfxTemplate)
	if not character or not vfxTemplate then
		return nil
	end

	local rightHand =
		GetRightHand(character)

	if not rightHand then
		warn("[AnimationEffectManager] RightHand not found")
		return nil
	end

	------------------------------------------------
	-- Find attachment
	------------------------------------------------

	local sourceAttachment =
		vfxTemplate:IsA("Attachment")
			and vfxTemplate
			or vfxTemplate:FindFirstChildWhichIsA(
				"Attachment",
				true
			)

	if not sourceAttachment then
		warn(
			"[AnimationEffectManager] No Attachment found in VFX"
		)

		return nil
	end

	------------------------------------------------
	-- Clone ONLY attachment
	------------------------------------------------

	local attachment =
		sourceAttachment:Clone()

	attachment.Parent =
		rightHand


	return attachment
end

------------------------------------------------
-- EMIT ALL PARTICLES
------------------------------------------------

local function EmitParticles(vfx)

	for _, object in ipairs(
		vfx:GetDescendants()
	) do

		if object:IsA("ParticleEmitter") then

			local count =
				object:GetAttribute(
					"EmitCount"
				)

			if typeof(count) ~= "number" then
				count = DEFAULT_EMIT_COUNT
			end

			object:Emit(count)

		end

	end

end
------------------------------------------------
-- PREPARE IMPACT VFX
------------------------------------------------

function AnimationEffectManager:PrepareImpact(
	character,
	animationFolder
)

	if not character or not animationFolder then
		return nil
	end

	------------------------------------------------
	-- VFX
	------------------------------------------------

	local vfxFolder =
		animationFolder:FindFirstChild("VFX")

	if not vfxFolder then
		warn("[AnimationEffectManager] VFX folder missing")
		return nil
	end

	local impactFolder =
		vfxFolder:FindFirstChild("Impact")

	if not impactFolder then
		warn("[AnimationEffectManager] Impact folder missing")
		return nil
	end

	------------------------------------------------
	-- DIRECT ATTACHMENT
	------------------------------------------------

	local attachment =
		impactFolder:FindFirstChildWhichIsA(
			"Attachment"
		)

	if not attachment then
		warn(
			"[AnimationEffectManager] Attachment not found inside Impact"
		)
		return nil
	end

	------------------------------------------------
	-- ATTACH CLONED ATTACHMENT TO PLAYER HAND
	------------------------------------------------

	local attachedAttachment =
		AttachVFXAttachmentToHand(
			character,
			attachment
		)

	if not attachedAttachment then
		return nil
	end

	------------------------------------------------
	-- Disable continuous emission
	-- Emit() will be called on Impact marker
	------------------------------------------------

	for _, object in ipairs(
		attachedAttachment:GetDescendants()
	) do

		if object:IsA("ParticleEmitter") then
			object.Enabled = false
		end

	end

	return {
		Attachment = attachedAttachment,
		ImpactFolder = impactFolder,
	}

end

------------------------------------------------
-- PLAY PREPARED IMPACT
------------------------------------------------

function AnimationEffectManager:PlayPreparedImpact(
	character,
	prepared
)

	if not prepared then
		return
	end

	------------------------------------------------
	-- EMIT VFX
	------------------------------------------------

	local attachment =
		prepared.Attachment

	if attachment
		and attachment.Parent then

		for _, object in ipairs(
			attachment:GetDescendants()
		) do

			if object:IsA("ParticleEmitter") then

				local count =
					object:GetAttribute(
						"EmitCount"
					)

				if typeof(count) ~= "number" then
					count = DEFAULT_EMIT_COUNT
				end

				object:Emit(count)

			end

		end

	end

	------------------------------------------------
	-- IMPACT SOUND
	------------------------------------------------

	local impactSound =
		prepared.ImpactFolder:FindFirstChild(
			"ImpactSound"
		)

	if impactSound then

		local rightHand =
			GetRightHand(character)

		if rightHand then

			local sound =
				impactSound:Clone()

			sound.Parent =
				rightHand

			sound:Play()

			Debris:AddItem(
				sound,
				math.max(
					sound.TimeLength + 0.1,
					2
				)
			)

		end

	end

end


------------------------------------------------
-- PLAY WOOSH
------------------------------------------------

function AnimationEffectManager:PlayWoosh(
	character,
	animationFolder
)

	local rightHand =
		GetRightHand(character)

	if not rightHand then
		return
	end

	local sounds =
		animationFolder:FindFirstChild(
			"Sounds"
		)

	if not sounds then
		return
	end

	local woosh =
		sounds:FindFirstChild(
			"Woosh"
		)

	if not woosh then
		return
	end

	local sound =
		woosh:Clone()

	sound.Parent =
		rightHand

	sound:Play()

	Debris:AddItem(
		sound,
		math.max(
			sound.TimeLength + 0.1,
			2
		)
	)

end



function AnimationEffectManager:DebugMarkers(animation)

	if not animation then
		warn("[AnimationEffectManager] No Animation provided")
		return
	end

	print("========================================")
	print("[AnimationEffectManager] MARKER DEBUG")
	print("Animation:", animation:GetFullName())
	print("AnimationId:", animation.AnimationId)
	print("========================================")

	local KeyframeSequenceProvider =
		game:GetService("KeyframeSequenceProvider")

	local success, sequence = pcall(function()

		return KeyframeSequenceProvider:GetKeyframeSequenceAsync(
			animation.AnimationId
		)

	end)

	if not success then

		warn(
			"[AnimationEffectManager] Could not load animation:",
			sequence
		)

		return
	end

	local foundMarkers = 0

	for _, keyframe in ipairs(sequence:GetKeyframes()) do

		for _, marker in ipairs(
			keyframe:GetMarkers()
		) do

			foundMarkers += 1

			print(
				string.format(
					"[MARKER] Time: %.3f | Name: %s | Value: %s",
					keyframe.Time,
					marker.Name,
					marker.Value
				)
			)

		end

	end

	if foundMarkers == 0 then

		warn(
			"[AnimationEffectManager] NO MARKERS FOUND"
		)

	else

		print(
			"[AnimationEffectManager] Total markers:",
			foundMarkers
		)

	end

	print("========================================")

end


------------------------------------------------
-- BIND ANIMATION
------------------------------------------------

function AnimationEffectManager:Bind(
	character,
	animationTrack,
	animationFolder
)
	if not character
		or not animationTrack
		or not animationFolder then

		return

	end

	local preparedImpact =
		self:PrepareImpact(
			character,
			animationFolder
		)


    -- local animation =
	-- 	animationFolder:FindFirstChild("Animation")

    -- self:DebugMarkers(animation)
	------------------------------------------------
	-- IMPACT
	------------------------------------------------

	local impactConnection =
		animationTrack:GetMarkerReachedSignal(
			IMPACT_MARKER
		):Connect(
			function()
				self:PlayPreparedImpact(
					character,
					preparedImpact
				)

			end
		)

	------------------------------------------------
	-- WOOSH
	------------------------------------------------

	local wooshConnection =
		animationTrack:GetMarkerReachedSignal(
			WOOOSH_MARKER
		):Connect(
			function()
				self:PlayWoosh(
					character,
					animationFolder
				)

			end
		)

	------------------------------------------------
	-- Cleanup connections
	------------------------------------------------

	animationTrack.Stopped:Once(
		function()
			if impactConnection then
				impactConnection:Disconnect()
			end

			if wooshConnection then
				wooshConnection:Disconnect()
			end

			------------------------------------------------
			-- Destroy prepared VFX
			------------------------------------------------

			if preparedImpact
				and preparedImpact.Attachment
				and preparedImpact.Attachment.Parent then

				Debris:AddItem(
					preparedImpact.Attachment,
					VFX_LIFETIME
				)

			end

		end
	)

	return {
		ImpactConnection = impactConnection,
		WooshConnection = wooshConnection,
	}

end

return AnimationEffectManager