local ServerStorage =
	game:GetService("ServerStorage")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BananaSkinManager = require(ServerScriptService.Server.Managers.BananaSkinManager)
------------------------------------------------
-- MODULES
------------------------------------------------

local GameplayItemConfig =
	require(
		ReplicatedStorage
			.Shared
			.Config
			.GameplayItemConfig
	)

------------------------------------------------
-- FOLDERS
------------------------------------------------

local GameplayItemsFolder =
	ServerStorage:WaitForChild(
		"GameplayItems"
	)

local DropsFolder =
	workspace:WaitForChild(
		"GameplayItemDrops"
	)


if not DropsFolder then

	DropsFolder =
		Instance.new("Folder")

	DropsFolder.Name =
		"GameplayItemDrops"

	DropsFolder.Parent =
		workspace

end
------------------------------------------------
-- MODULE
------------------------------------------------

local GameplayItemDropModule = {}

------------------------------------------------
-- GET MAIN PART
------------------------------------------------

local function GetMainPart(
	visual
)

	if visual:IsA("BasePart") then
		return visual
	end

	if visual:IsA("Model") then

		if visual.PrimaryPart then
			return visual.PrimaryPart
		end

		local main =
			visual:FindFirstChild(
				"Main",
				true
			)

		if main and main:IsA("BasePart") then
			return main
		end

		local handle =
			visual:FindFirstChild(
				"Handle",
				true
			)

		if handle and handle:IsA("BasePart") then
			return handle
		end

	end

	return nil

end

------------------------------------------------
-- PREPARE DROP
------------------------------------------------

local function PrepareDrop(
	visual
)

	for _, object in ipairs(
		visual:GetDescendants()
	) do

		if object:IsA("BasePart") then

			object.Anchored = false
			object.CanCollide = true
			object.CanTouch = true
			object.CanQuery = true
			object.Massless = false

		end

	end

	if visual:IsA("BasePart") then

		visual.Anchored = false
		visual.CanCollide = true

	end

end

------------------------------------------------
-- CREATE PICKUP PROMPT
------------------------------------------------

local function CreatePrompt(
	main,
	itemId,
	config,
	onPickup
)

	local pickupConfig =
		config.Pickup
		or {}

	local prompt =
		Instance.new("ProximityPrompt")

	prompt.Name =
		"PickupPrompt"

	prompt.ActionText =
		"Pick Up"

	prompt.ObjectText =
		config.Name
		or itemId

	prompt.HoldDuration =
		pickupConfig.HoldDuration
		or 2

	prompt.MaxActivationDistance =
		pickupConfig.MaxDistance
		or 10

	prompt.RequiresLineOfSight =
		false

	prompt.Parent =
		main

	local pickedUp = false

	prompt.Triggered:Connect(
		function(player)

			if pickedUp then
				return
			end

			if not player
				or not player.Parent then
				return
			end

			pickedUp = true

            local drop =
					main:FindFirstAncestorWhichIsA(
						"Model"
					)

            local droppedSkinId = nil

            if drop then

                droppedSkinId =
                    drop:GetAttribute(
                        "SkinId"
                    )

            end
            print("droppedSKinid", droppedSkinId)
        
			local success =
				onPickup(
					player,
					itemId,
                    droppedSkinId
				)

			if success then

				local drop =
					main:FindFirstAncestorWhichIsA(
						"Model"
					)
               
				if drop then
					drop:Destroy()
				else
					main:Destroy()
				end

			else

				pickedUp = false

			end

		end
	)

end

------------------------------------------------
-- SPAWN DROP
------------------------------------------------

function GameplayItemDropModule:Create(
	player,
	itemId,
	skinId,
	onPickup
)
    print("drop create", skinId)
	local character =
		player.Character

	if not character then
		return nil
	end

	local root =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not root then
		return nil
	end

	local config =
		GameplayItemConfig[itemId]

	if not config then

		warn(
			"[GameplayItemDropModule] Unknown item:",
			itemId
		)

		return nil

	end

	------------------------------------------------
	-- Find source
	------------------------------------------------

	local itemFolder =
		GameplayItemsFolder:FindFirstChild(
			itemId
		)

	if not itemFolder then

		warn(
			"[GameplayItemDropModule] Missing folder:",
			itemId
		)

		return nil

	end

	local source =
		itemFolder:FindFirstChild(
			config.Model
		)

	if not source then

		warn(
			"[GameplayItemDropModule] Missing model:",
			config.Model
		)

		return nil

	end

	------------------------------------------------
	-- Clone
	------------------------------------------------

	local drop =
		source:Clone()

	drop.Name =
		itemId .. "_Drop"

	drop:SetAttribute(
		"GameplayItemDrop",
		true
	)
  

	drop:SetAttribute(
		"ItemId",
		itemId
	)
    drop:SetAttribute(
            "SkinId",
            skinId
        )
	drop.Parent =
		DropsFolder
    
    if itemId == "Banana" and skinId then

        local success =
            BananaSkinManager:Apply(
                player,
                drop,
                skinId
            )

        if not success then

            warn(
                "[GameplayItemDropModule] Failed to apply Banana skin:",
                skinId
            )

        end

    end
	------------------------------------------------
	-- Main part
	------------------------------------------------

	local main =
		GetMainPart(drop)

	if not main then

		warn(
			"[GameplayItemDropModule] No main part:",
			itemId
		)

		drop:Destroy()

		return nil

	end

	------------------------------------------------
	-- Physics
	------------------------------------------------

	PrepareDrop(drop)

	------------------------------------------------
	-- Position
	------------------------------------------------

	local position =
		root.Position
		+ root.CFrame.LookVector * 3
		+ Vector3.new(0, 1, 0)

	if drop:IsA("Model") then

		drop:PivotTo(
			CFrame.new(position)
		)

	else

		drop.CFrame =
			CFrame.new(position)

	end

	------------------------------------------------
	-- Pickup
	------------------------------------------------

	CreatePrompt(
		main,
		itemId,
		config,
		onPickup
	)

	return drop

end

------------------------------------------------

return GameplayItemDropModule