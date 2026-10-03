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

	ChiefBanana = {

		Model = "ChiefBanana",

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
					math.rad(0),
					math.rad(-90)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, -0.5, 0) * 
				CFrame.Angles(
					math.rad(-80),
					math.rad(0),
					math.rad(0)
				),
			},
			
			LeftUpperArm = {
				Visual = "LeftUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			LeftLowerArm = {
				Visual = "LeftLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			RightUpperArm = {
				Visual = "RightUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			RightLowerArm = {
				Visual = "RightLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
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
			ChiefHat = true,
			Pan = true
			-- Sword = true,
			-- BackPack = true
		},

	},
	DeliveryBanana = {

		Model = "DeliveryBanana",

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
					math.rad(0),
					math.rad(0)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(0)
				),
			},
			
			LeftUpperArm = {
				Visual = "LeftUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			LeftLowerArm = {
				Visual = "LeftLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			RightUpperArm = {
				Visual = "RightUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			RightLowerArm = {
				Visual = "RightLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
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
		Accessories = {
			DeliveryHat = true,
			Parcel = true,
			BackPack = true
		},

	},

	EnginnerBanana = {

		Model = "EnginnerBanana",

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
					math.rad(0),
					math.rad(90)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(0)
				),
			},
			
			LeftUpperArm = {
				Visual = "LeftUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			LeftLowerArm = {
				Visual = "LeftLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			RightUpperArm = {
				Visual = "RightUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			RightLowerArm = {
				Visual = "RightLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
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
		Accessories = {
			EnginnerHat = true,
			Hammer = true
		},

	},

	DreamyBanana = {
 		
		Model = "DreamyBanana",

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
					math.rad(90),
					math.rad(0),
					math.rad(0)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(0)
				),
			},
			
			LeftUpperArm = {
				Visual = "LeftUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			LeftLowerArm = {
				Visual = "LeftLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			RightUpperArm = {
				Visual = "RightUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			RightLowerArm = {
				Visual = "RightLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
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
		Accessories = {
			DreamyHat = true,
		},

	},
	NinjaWarrior = {
 		
		Model = "NinjaWarrior",

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
					math.rad(-90),
					math.rad(0)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(0)
				),
			},
			
			LeftUpperArm = {
				Visual = "LeftUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			LeftLowerArm = {
				Visual = "LeftLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			
			LeftHand = {
				Visual = "LeftHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},

			RightUpperArm = {
				Visual = "RightUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			RightLowerArm = {
				Visual = "RightLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},

			RightHand = {
				Visual = "RightHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
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
			LeftFoot = {
				Visual = "LeftFoot",
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
			RightFoot = {
				Visual = "RightFoot",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
		},
		Accessories = {
			BladeKunai = true,
			HeadBand = true,
		},

	},

	PirateBanana = {
 		
		Model = "PirateBanana",

        UsePlayerAppearance = false,

		Parts = {

			Head = {
				Visual = "Head",
				Offset = CFrame.new(0, 0, 0),
			},

			UpperTorso = {
				Visual = "UpperTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, -0.6	, 0) *
				CFrame.Angles(
					math.rad(-90),
					math.rad(-180),
					math.rad(0)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(-90),
					math.rad(90)
				),
			},
			
			LeftUpperArm = {
				Visual = "LeftUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			LeftLowerArm = {
				Visual = "LeftLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(90)
				),
			},
			
			LeftHand = {
				Visual = "LeftHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},

			RightUpperArm = {
				Visual = "RightUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			RightLowerArm = {
				Visual = "RightLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(90)
				),
			},

			RightHand = {
				Visual = "RightHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
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
			LeftFoot = {
				Visual = "LeftFoot",
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
			RightFoot = {
				Visual = "RightFoot",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
		},
		Accessories = {
			PirateBand = true,
			Hook = true,
		},

	},
	MagicianBanana = {
 		
		Model = "MagicianBanana",

        UsePlayerAppearance = false,

		Parts = {

			Head = {
				Visual = "Head",
				Offset = CFrame.new(0, 0, 0),
			},

			UpperTorso = {
				Visual = "UpperTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, -0.6	, 0) *
				CFrame.Angles(
					math.rad(0),
					math.rad(-180),
					math.rad(0)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(0)
				),
			},
			
			LeftUpperArm = {
				Visual = "LeftUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			LeftLowerArm = {
				Visual = "LeftLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(90)
				),
			},
			
			LeftHand = {
				Visual = "LeftHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},

			RightUpperArm = {
				Visual = "RightUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			RightLowerArm = {
				Visual = "RightLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(90)
				),
			},

			RightHand = {
				Visual = "RightHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
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
			LeftFoot = {
				Visual = "LeftFoot",
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
			RightFoot = {
				Visual = "RightFoot",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
		},
		Accessories = {
			MagicianHat = true,
			Wond = true,
		},

	},
	
	GalaxyBanana = {

		Model = "GalaxyBanana",
        UsePlayerAppearance = false,
		Parts = {
			Head = {
				Visual = "Head",
				Offset = CFrame.new(0, 0, 0) *
				CFrame.Angles(
					math.rad(90),
					math.rad(0),
					math.rad(0)
				),
			},

			UpperTorso = {
				Visual = "UpperTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, -0.6	, 0) *
				CFrame.Angles(
					math.rad(-90),
					math.rad(180),
					math.rad(0)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) *
				CFrame.Angles(
					math.rad(0),
					math.rad(90),
					math.rad(-90)
				),
			},
			
			LeftUpperArm = {
				Visual = "LeftUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			LeftLowerArm = {
				Visual = "LeftLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(180),
					math.rad(90)
				),
			},
			
			LeftHand = {
				Visual = "LeftHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},

			RightUpperArm = {
				Visual = "RightUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			RightLowerArm = {
				Visual = "RightLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(90)
				),
			},

			RightHand = {
				Visual = "RightHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
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
			LeftFoot = {
				Visual = "LeftFoot",
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
			RightFoot = {
				Visual = "RightFoot",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
		},
		Accessories = {

		},

	},

	SemuraiBanana = {
 		
		Model = "SemuraiBanana",

        UsePlayerAppearance = false,

		Parts = {

			Head = {
				Visual = "Head",
				Offset = CFrame.new(0, 0, 0),
			},

			UpperTorso = {
				Visual = "UpperTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0	, 0) *
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, -0.4, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(90),
					math.rad(-90)
				),
			},
			
			LeftUpperArm = {
				Visual = "LeftUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(90),
					math.rad(-90)
				),
			},
			LeftLowerArm = {
				Visual = "LeftLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			
			LeftHand = {
				Visual = "LeftHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, -90),
			},

			RightUpperArm = {
				Visual = "RightUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(-180),
					math.rad(-180)
				),
			},
			RightLowerArm = {
				Visual = "RightLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, -0.2, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(180),
					math.rad(-90)
				),
			},

			RightHand = {
				Visual = "RightHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			LeftUpperLeg = {
				Visual = "LeftUpperLeg",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, -0.2, 0)* 
				CFrame.Angles(
					math.rad(0),
					math.rad(180),
					math.rad(180)
				),
			},
			LeftLowerLeg = {
				Visual = "LeftLowerLeg",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			LeftFoot = {
				Visual = "LeftFoot",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			RightUpperLeg = {
				Visual = "RightUpperLeg",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, -0.2, 0),
			},
			RightLowerLeg = {
				Visual = "RightLowerLeg",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
			RightFoot = {
				Visual = "RightFoot",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
		},
		Accessories = {
			SemuraiHat = true,
			Katana = true
		},

	},

	HealerLordBanana = {
 		
		Model = "HealerLordBanana",

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
					math.rad(180),
					math.rad(0)
				),
			},

			LowerTorso = {
				Visual = "LowerTorso",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(-90),
					math.rad(90)
				),
			},
			
			LeftUpperArm = {
				Visual = "LeftUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			LeftLowerArm = {
				Visual = "LeftLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(90)
				),
			},
			
			LeftHand = {
				Visual = "LeftHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},

			RightUpperArm = {
				Visual = "RightUpperArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(-90)
				),
			},
			RightLowerArm = {
				Visual = "RightLowerArm",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0) * 
				CFrame.Angles(
					math.rad(0),
					math.rad(0),
					math.rad(90)
				),
			},

			RightHand = {
				Visual = "RightHand",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
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
			LeftFoot = {
				Visual = "LeftFoot",
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
			RightFoot = {
				Visual = "RightFoot",
				Mode = "ReplaceVisual",
				Offset = CFrame.new(0, 0, 0),
			},
		},
		Accessories = {
			Wings = true,
			HealerLordHelmet = true
		},

	},
}

return SkinVisualConfig