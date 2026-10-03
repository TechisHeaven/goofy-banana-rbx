local AccessoryConfig = {

	Parcel = {
		Model = "Parcel",
		AttachTo = "LeftHand",
		Attachment = "LeftGripAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			1.4,
			0
		) * CFrame.Angles(
					math.rad(0),
					math.rad(90),
					math.rad(90)
				),
	},


	BackPack = {
		Model = "BackPack",
		AttachTo = "UpperTorso",
		Attachment = "BodyBackAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.4,
			0.2
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(90)
				),
	},

	Pendant = {
		Model = "PendantModel",
		AttachTo = "UpperTorso",
		Attachment = "BodyFrontAttachment",
		Behavior = "Pendulum",
		Offset = CFrame.new(
			0,
			-0.2,
			0
		),
	},
	BananaHat = {
		Model = "Hat",
		AttachTo = "Head",
		Attachment = "HatAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			-0.1,
			-0.2
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
	},
	ChiefHat = {
		Model = "ChiefHat",
		AttachTo = "Head",
		Attachment = "HatAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.4,
			0
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
	},

	DeliveryHat = {
		Model = "DeliveryHat",
		AttachTo = "Head",
		Attachment = "HatAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.2,
			-0.1
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
	},

	EnginnerHat = {
		Model = "Hat",
		AttachTo = "Head",
		Attachment = "HatAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.2,
			-0.1
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
	},
	DreamyHat = {
		Model = "Hat",
		AttachTo = "Head",
		Attachment = "HatAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.4,
			-0.1
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
	},

	Pan = {
		Model = "Pan",
		AttachTo = "LeftHand",
		Attachment = "LeftGripAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			-0.1,
			-0.2
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
	},
	Hammer = {
		Model = "Hammer",
		AttachTo = "LeftHand",
		Attachment = "LeftGripAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.4,
			-0.1
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(0)
				),
	},

	
	HeadBand = {
		Model = "HeadBand",
		AttachTo = "Head",
		Attachment = "HatAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.2,
			0
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
	},

	BladeKunai = {
		Model = "BladeKunai",
		AttachTo = "LowerTorso",
		Attachment = "WaistBackAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.4,
			0.2
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(45)
				),
	},
	PirateBand = {
		Model = "HeadBand",
		AttachTo = "Head",
		Attachment = "HatAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.2,
			0
		) * CFrame.Angles(
					math.rad(0),
					math.rad(90),
					math.rad(-90)
				),
	},
	MagicianHat = {
		Model = "Hat",
		AttachTo = "Head",
		Attachment = "HatAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.6,
			0
		) * CFrame.Angles(
					math.rad(0),
					math.rad(180),
					math.rad(0)
				),
	},
	Hook = {
		Model = "Hook",
		AttachTo = "LeftHand",
		Attachment = "LeftGripAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.2,
			0
		) * CFrame.Angles(
					math.rad(0),
					math.rad(90),
					math.rad(-90)
				),
	},
	Wond = {
		Model = "Wond",
		AttachTo = "LeftHand",
		Attachment = "LeftGripAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0.2,
			0
		) * CFrame.Angles(
					math.rad(90),
					math.rad(0),
					math.rad(180)
				),
	},

	SemuraiHat = {
		Model = "Hat",
		AttachTo = "Head",
		Attachment = "HatAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0,
			0
		) * CFrame.Angles(
					math.rad(-90),
					math.rad(-180),
					math.rad(0)
				),
	},

	HealerLordHelmet = {
		Model = "Helmet",
		AttachTo = "Head",
		Attachment = "HatAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0,
			0
		) * CFrame.Angles(
					math.rad(90),
					math.rad(180),
					math.rad(0)
				),
	},

	Katana = {
		Model = "Katana",
		AttachTo = "UpperTorso",
		Attachment = "BodyBackAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			1,
			0.6,
			0
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(45)
				),
	},

	Wings = {
		Model = "Wings",
		AttachTo = "UpperTorso",
		Attachment = "BodyBackAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0,
			0
		) * CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(0)
				)
	}
	
}

return AccessoryConfig