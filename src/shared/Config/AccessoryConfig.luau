local AccessoryConfig = {

	Sword = {
		Model = "SwordModel",
		AttachTo = "RightHand",
		Attachment = "RightGripAttachment",
		Behavior = "HandHeld",
		Offset = CFrame.new(
			0,
			0,
			0
		),
	},
	
	BackPack = {
		Model = "BackPackModel",
		AttachTo = "UpperTorso",
		Attachment = "BodyBackAttachment",
		Behavior = "Static",
		Offset = CFrame.new(
			0,
			0,
			1
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
	}

}

return AccessoryConfig