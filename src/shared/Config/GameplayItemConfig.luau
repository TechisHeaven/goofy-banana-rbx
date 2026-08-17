local GameplayItemConfig = {

	Banana = {

		Name = "Banana",

		Model = "BananaModel",
		SkinCategory = "BananaSkins",
		AttachTo = "RightHand",

		Attachment = "RightGripAttachment",

		Offset = CFrame.new(
			0,
			0,
			0
		),
		Pickup = {
			HoldDuration = 2,
			MaxDistance = 10,
		},


	},

	BananaGun = {

		Name = "Banana Gun",

		Model = "BananaGunModel",

		SkinCategory = nil,

		AttachTo = "RightHand",

		Attachment = "RightGripAttachment",

		Offset = CFrame.new(
			0,
			0,
			0
		),
		Pickup = {
			HoldDuration = 2,
			MaxDistance = 10,
		},


	},

	FreezeGun = {

		Name = "Freeze Gun",

		Model = "FreezeGunModel",

		SkinCategory = nil,
		AttachTo = "RightHand",

		Attachment = "RightGripAttachment",

		Offset = CFrame.new(
			0,
			0,
			0
		),
		Pickup = {
			HoldDuration = 2,
			MaxDistance = 10,
		},

	},

}

return GameplayItemConfig