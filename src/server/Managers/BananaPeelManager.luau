local ServerStorage =
	game:GetService("ServerStorage")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")


------------------------------------------------
-- MODULE
------------------------------------------------

local BananaPeelModule =
	require(
		ReplicatedStorage
			.Shared
			.Modules
			.BananaPeelModule
	)

	
local ItemPickupDropModule =
	require(
		ReplicatedStorage
			.Shared
			.Modules
			.ItemPickupDropModule
	)

local GameplayItemManager =
	require(script.Parent.GameplayItemManager)

local BananaSkinManager =
	require(script.Parent.BananaSkinManager)

------------------------------------------------
-- FOLDER
------------------------------------------------

local GameplayItems =
	ServerStorage:WaitForChild(
		"GameplayItems"
	)

local BananaFolder =
	GameplayItems:WaitForChild(
		"Banana"
	)

local BananaPeelSource =
	BananaFolder:WaitForChild(
		"BananaModel"
	)

------------------------------------------------
-- REMOTE
------------------------------------------------

local Shared = ReplicatedStorage.Shared
local RemoteIndex =
    require(Shared.Remotes.RemoteIndex).Events

local Remotes = Shared.Remotes



local BananaPeelRequest =
	Remotes:WaitForChild(
		RemoteIndex.BananaPeelRequest
	)

------------------------------------------------
-- FOLDER
------------------------------------------------

local ActivePeels =
	workspace:FindFirstChild(
		"BananaPeels"
	)

if not ActivePeels then

	ActivePeels =
		Instance.new("Folder")

	ActivePeels.Name =
		"BananaPeels"

	ActivePeels.Parent =
		workspace

end

------------------------------------------------
-- MANAGER
------------------------------------------------

local BananaPeelManager = {}

local PlacementCooldowns = {}
------------------------------------------------
-- PREPARE
------------------------------------------------

local function PreparePeel(
	peel
)

	for _, object in ipairs(
		peel:GetDescendants()
	) do

		if object:IsA("BasePart") then

			object.Anchored = true

			object.CanCollide = false

			object.CanTouch = true

			object.CanQuery = true

		end

	end

	if peel:IsA("BasePart") then

		peel.Anchored = true

		peel.CanCollide = false

		peel.CanTouch = true

	end

end

------------------------------------------------
-- GET MAIN
------------------------------------------------

local function GetMain(
	peel
)

	if peel:IsA("BasePart") then
		return peel
	end

	if peel:IsA("Model") then

		if peel.PrimaryPart then
			return peel.PrimaryPart
		end

		return peel:FindFirstChildWhichIsA(
			"BasePart",
			true
		)

	end

	return nil

end

------------------------------------------------
-- SLIP PLAYER
------------------------------------------------

function BananaPeelManager:Slip(
	player
)

	if not player then
		return
	end

	local character =
		player.Character

	if not character then
		return
	end

	local humanoid =
		character:FindFirstChildOfClass(
			"Humanoid"
		)

	local root =
		character:FindFirstChild(
			"HumanoidRootPart"
		)

	if not humanoid or not root then
		return
	end


	------------------------------------------------
	-- Temporary slip
	------------------------------------------------

	humanoid.PlatformStand = true

	------------------------------------------------
	-- Small fall impulse
	------------------------------------------------

	root.AssemblyLinearVelocity =
		Vector3.new(
			0,
			-8,
			0
		)

	task.delay(
		BananaPeelModule.Settings.SlipDuration,
		function()

			if humanoid
				and humanoid.Parent then

				humanoid.PlatformStand =
					false

			end

		end
	)
    
end

------------------------------------------------
-- TOUCH
------------------------------------------------

function BananaPeelManager:ConnectTouch(
	peel
)

	local main =
		GetMain(peel)

	if not main then
		return
	end
	main.Touched:Connect(
		function(hit)
         

			local character =
				hit:FindFirstAncestorOfClass(
					"Model"
				)

			if not character then
				return
			end

			local player =
				game.Players:GetPlayerFromCharacter(
					character
				)

			if not player then
				return
			end

            if peel:GetAttribute("Triggered") then
                return
            end

            peel:SetAttribute(
                "Triggered",
                true
            )

			self:Slip(player)
            if peel and peel.Parent then
                peel:Destroy()
            end
		end
	)

end

------------------------------------------------
-- CREATE
------------------------------------------------

function BananaPeelManager:Create(
	player,
	position
)
    ------------------------------------------------
	-- MUST HAVE BANANA EQUIPPED
	------------------------------------------------

	local itemState =
		GameplayItemManager:GetState(player)
	print(itemState)
	if not itemState then
		return false
	end

	if itemState.Item ~= "Banana" then
		return false
	end

	if itemState.Selected ~= "Banana" then
		return false
	end

	if not itemState.Equipped then
		return false
	end
    ------------------------------------------------
	-- PLACEMENT COOLDOWN
	------------------------------------------------
    if PlacementCooldowns[player] then
            return false
        end

        PlacementCooldowns[player] = true

        task.delay(
            BananaPeelModule.Settings.PlacementCooldown,
            function()

                PlacementCooldowns[player] = nil

            end
        )


    local groundPosition, normal =
        BananaPeelModule:GetGroundPosition(
            player,
            position
        )

        if not groundPosition then
            return false
        end
        local skinId = itemState.SkinId
        local peel =
            BananaPeelSource:Clone()
      

        peel.Name =
            "BananaPeel"

        peel:SetAttribute(
            "BananaPeel",
            true
        )
        peel:SetAttribute(
            "SkinId",
            skinId
        )

        peel.Parent =
            ActivePeels

        PreparePeel(peel)

        BananaPeelModule:Place(
            peel,
            groundPosition,
            normal
        )

        if skinId then

            local success =
                BananaSkinManager:Apply(
                    player,
                    peel,
                    skinId
                )

            if not success then

                warn(
                    "[BananaPeelManager] Failed to apply skin:",
                    skinId
                )

            end

        end

        self:ConnectTouch(
            peel
        )

        ------------------------------------------------
        -- Cleanup
        ------------------------------------------------

        task.delay(
            BananaPeelModule.Settings.LifeTime,
            function()

                if peel
                    and peel.Parent then

                    peel:Destroy()

                end

            end
        )

	ItemPickupDropModule:ClearHeldItem(
		player.Character
	)


    return true

end

------------------------------------------------
-- INIT
------------------------------------------------

function BananaPeelManager:Init()

	BananaPeelRequest.OnServerEvent:Connect(
		function(
			player,
			position
		)
			print(position)
			if typeof(position) ~= "Vector3" then
				return
			end

			self:Create(
				player,
				position
			)

		end
	)

	print(
		"BananaPeelManager initialized"
	)

end

return BananaPeelManager