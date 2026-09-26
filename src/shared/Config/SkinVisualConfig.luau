local SkinVisualConfig = {

	SimpleBanana = {

		Model = "SimpleBanana",

        UsePlayerAppearance = false,

		Parts = {

			Head = {
				Visual = "Head",
				Offset = CFrame.new(0, 0, 0),
			},

			UpperTorso = {
				Visual = "UpperTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(90),
					math.rad(0)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(5),
					math.rad(0)
				),
			},

			LeftUpperLeg = {
				Visual = "LeftUpperLeg",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			LeftLowerLeg = {
				Visual = "LeftLowerLeg",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			RightUpperLeg = {
				Visual = "RightUpperLeg",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			RightLowerLeg = {
				Visual = "RightLowerLeg",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
		},

		-- Accessories = {
		-- 	Hat = true,
		-- },
		Accessories = {
			Pendant = true,
			BananaHat = true,
			-- Sword = true,
			-- BackPack = true
		},

	},

	CoolBanana = {

		Model = "CoolBanana",

        UsePlayerAppearance = false,
		Parts = {
			Head = "Head",
			UpperTorso = "UpperTorso",
			LowerTorso = "LowerTorso",

			LeftUpperArm = "LeftUpperArm",
			LeftLowerArm = "LeftLowerArm",
			LeftHand = "LeftHand",

			RightUpperArm = "RightUpperArm",
			RightLowerArm = "RightLowerArm",
			RightHand = "RightHand",

			LeftUpperLeg = "LeftUpperLeg",
			LeftLowerLeg = "LeftLowerLeg",
			LeftFoot = "LeftFoot",

			RightUpperLeg = "RightUpperLeg",
			RightLowerLeg = "RightLowerLeg",
			RightFoot = "RightFoot",
		},

		Accessories = {
			BackPack = true
		},

	},

	JackLantern = {
 		Model = "JackLantern",
        UsePlayerAppearance = false,
		Parts = {
			Head = "Head",
		},
		Accessories = {},

	},

	GalaxyBanana = {

		Model = "GalaxyBanana",
		UsePlayerAppearance = false,
		Parts = {
			Head = "Head",
			UpperTorso = "UpperTorso",
			LowerTorso = "LowerTorso",
		},
		Accessories = {},

	},

}

return SkinVisualConfig