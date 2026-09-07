local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local ServerStorage =
	game:GetService("ServerStorage")

local Players =
	game:GetService("Players")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local Remotes =
	Shared:WaitForChild("Remotes")

local RemoteIndex =
	require(
		Shared.Remotes.RemoteIndex
	)

local ServerScripts =
    game:GetService("ServerScriptService"):WaitForChild("Server")

local RedeemCodeConfig =
	require(
		ServerScripts.Config.RedeemCodeConfig
	)

local ProfileManager =
    require(
        ServerScripts.Managers.ProfileManager
    )

local PlayerProfiles =
	require(
		ServerStorage.Data.PlayerProfiles
	)

local CurrencyManager =
	require(
		ServerScripts.Managers.CurrencyManager
	)

local InventoryManager =
	require(
		ServerScripts.Managers.InventoryManager
	)

local RewardManager =
	require(
		ServerScripts.Managers.RewardManager
	)

local NotificationManager =
    require(
        ServerScripts.Managers.NotificationManager
    )


local RedeemCodeService = {}

------------------------------------------------
-- SETTINGS
------------------------------------------------

local MAX_CODE_LENGTH = 32
local MIN_CODE_LENGTH = 1

local REQUEST_COOLDOWN = 1.5

------------------------------------------------
-- STATE
------------------------------------------------

local LastRequest = {}

------------------------------------------------
-- REMOTE
------------------------------------------------

local RedeemCodeRemote =
	Remotes:WaitForChild(
		RemoteIndex.Functions.RedeemCode
	)

------------------------------------------------
-- CODE NORMALIZATION
------------------------------------------------

local function NormalizeCode(code)

	if typeof(code) ~= "string" then
		return nil
	end

	code = string.upper(code)

	------------------------------------------------
	-- Remove accidental spaces around the code.
	------------------------------------------------

	code = code:match("^%s*(.-)%s*$")

	if #code < MIN_CODE_LENGTH then
		return nil
	end

	if #code > MAX_CODE_LENGTH then
		return nil
	end

	------------------------------------------------
	-- Only allow letters, numbers and underscore.
	------------------------------------------------

	if not string.match(
		code,
		"^[A-Z0-9_]+$"
	) then
		return nil
	end

	return code
end

------------------------------------------------
-- PROFILE
------------------------------------------------

local function GetProfile(player)

	if not player then
		return nil
	end

	return PlayerProfiles[player]
end

------------------------------------------------
-- RATE LIMIT
------------------------------------------------

local function IsRateLimited(player)

	local now = os.clock()

	local last =
		LastRequest[player]

	if last
		and now - last < REQUEST_COOLDOWN
	then
		return true
	end

	LastRequest[player] = now

	return false
end

------------------------------------------------
-- REWARD VALIDATION
------------------------------------------------

local function ValidateReward(
	player,
	reward
)

	if typeof(reward) ~= "table" then
		return false
	end

	local rewardCount = 0

	for rewardType, value in pairs(reward) do

		rewardCount += 1

		------------------------------------------------
		-- COINS
		------------------------------------------------

		if rewardType == "Coins" then

			if typeof(value) ~= "number"
				or value <= 0
				or value > 1000000
				or value % 1 ~= 0
			then

				return false
			end

		------------------------------------------------
		-- XP
		------------------------------------------------

		elseif rewardType == "XP" then

			if typeof(value) ~= "number"
				or value <= 0
				or value > 1000000
				or value % 1 ~= 0
			then

				return false
			end

		------------------------------------------------
		-- SKIN
		------------------------------------------------

		elseif rewardType == "Skin" then

			if typeof(value) ~= "string"
				or #value < 1
				or #value > 64
			then

				return false
			end

			if not InventoryManager:GetItem(
				"Skins",
				value
			) then
                NotificationManager:Send(
                    player,
                    "Something Went Wrong"
                )
				warn(
					"[RedeemCodeService] Skin does not exist:",
					value
				)

				return false
			end

		------------------------------------------------
		-- BANANA SKIN
		------------------------------------------------

		elseif rewardType == "BananaSkin" then

			if typeof(value) ~= "string"
				or #value < 1
				or #value > 64
			then

				return false
			end

			if not InventoryManager:GetItem(
				"BananaSkins",
				value
			) then
                NotificationManager:Send(
                    player,
                    "Something Went Wrong"
                )
				warn(
					"[RedeemCodeService] BananaSkin does not exist:",
					value
				)

				return false
			end

		------------------------------------------------
		-- VICTORY POSE
		------------------------------------------------

		elseif rewardType == "VictoryPose" then

			if typeof(value) ~= "string"
				or #value < 1
				or #value > 64
			then

				return false
			end

			if not InventoryManager:GetItem(
				"VictoryPoses",
				value
			) then
                NotificationManager:Send(
                    player,
                    "Something Went Wrong"
                )
				warn(
					"[RedeemCodeService] VictoryPose does not exist:",
					value
				)

				return false
			end

		------------------------------------------------
		-- RESCUE EFFECT
		------------------------------------------------

		elseif rewardType == "RescueEffect" then

			if typeof(value) ~= "string"
				or #value < 1
				or #value > 64
			then

				return false
			end

			if not InventoryManager:GetItem(
				"RescueEffects",
				value
			) then
                  NotificationManager:Send(
                    player,
                    "Something Went Wrong"
                )
				warn(
					"[RedeemCodeService] RescueEffect does not exist:",
					value
				)

				return false
			end

		else
            NotificationManager:Send(
                    player,
                    "Invalid Code"
                )
			warn(
				"[RedeemCodeService] Unknown reward type:",
				rewardType
			)

			return false

		end
	end

	------------------------------------------------
	-- EXACTLY ONE REWARD TYPE PER ENTRY
	------------------------------------------------

	if rewardCount ~= 1 then
		return false
	end

	return true

end



local function ValidatePlayerCanReceiveReward(
	player,
	reward
)

	local profile =
		ProfileManager:GetProfile(player)

	if not profile then
		return false
	end

	local inventory =
		profile.Inventory

	if reward.Skin then

		return not (
			inventory.Owned.Skins
			and inventory.Owned.Skins[reward.Skin]
		)

	end

	if reward.BananaSkin then

		return not (
			inventory.Owned.BananaSkins
			and inventory.Owned.BananaSkins[
				reward.BananaSkin
			]
		)

	end

	if reward.VictoryPose then

		return not (
			inventory.Owned.VictoryPoses
			and inventory.Owned.VictoryPoses[
				reward.VictoryPose
			]
		)

	end

	if reward.RescueEffect then

		return not (
			inventory.Owned.RescueEffects
			and inventory.Owned.RescueEffects[
				reward.RescueEffect
			]
		)

	end

	return true

end
------------------------------------------------
-- VALIDATE ALL REWARDS
------------------------------------------------

local function ValidateRewards(
	player,
	rewards
)

	if typeof(rewards) ~= "table" then
		return false
	end

	if #rewards == 0 then
		return false
	end

	------------------------------------------------
	-- Maximum rewards per code
	------------------------------------------------

	if #rewards > 20 then
		return false
	end

	for _, reward in ipairs(rewards) do

        if not ValidateReward(
            player,
            reward
        ) then

            return false
        end

        if not ValidatePlayerCanReceiveReward(
            player,
            reward
        ) then

            return false
        end

    end

	return true

end

------------------------------------------------
-- GRANT ONE REWARD
------------------------------------------------

local function GrantReward(
	player,
	reward
)

	------------------------------------------------
	-- COINS
	------------------------------------------------

	if reward.Coins then

		CurrencyManager:AddCoins(
			player,
			reward.Coins
		)

		return true
	end

	------------------------------------------------
	-- XP
	------------------------------------------------

	if reward.XP then

		CurrencyManager:AddXP(
			player,
			reward.XP
		)

		return true
	end

	------------------------------------------------
	-- SKIN
	------------------------------------------------

	if reward.Skin then

		return InventoryManager:AddItem(
			player,
			"Skins",
			reward.Skin
		)

	end

	------------------------------------------------
	-- BANANA SKIN
	------------------------------------------------

	if reward.BananaSkin then

		return InventoryManager:AddItem(
			player,
			"BananaSkins",
			reward.BananaSkin
		)

	end

	------------------------------------------------
	-- VICTORY POSE
	------------------------------------------------

	if reward.VictoryPose then

		return InventoryManager:AddItem(
			player,
			"VictoryPoses",
			reward.VictoryPose
		)

	end

	------------------------------------------------
	-- RESCUE EFFECT
	------------------------------------------------

	if reward.RescueEffect then

		return InventoryManager:AddItem(
			player,
			"RescueEffects",
			reward.RescueEffect
		)

	end

	return false

end


------------------------------------------------
-- REDEEM
------------------------------------------------

function RedeemCodeService:Redeem(
	player,
	rawCode
)

	if not player
		or not player.Parent
	then
        NotificationManager:Send(
                    player,
                    "Invalid player."
                )
		return false, "Invalid player."

	end

	------------------------------------------------
	-- RATE LIMIT
	------------------------------------------------

	if IsRateLimited(player) then
        NotificationManager:Send(
                    player,
                    "Please wait before trying another code."
                )
		return false,
			"Please wait before trying another code."
	end

	------------------------------------------------
	-- PROFILE
	------------------------------------------------

	local profile =
		GetProfile(player)

	if not profile then
		return false,
			"Your data is still loading."
	end

	------------------------------------------------
	-- NORMALIZE
	------------------------------------------------

	local code =
		NormalizeCode(rawCode)

	if not code then
          NotificationManager:Send(
                    player,
                    "Invalid Code"
                )
		return false,
			"Invalid code format."
	end

	------------------------------------------------
	-- FIND CODE
	------------------------------------------------

	local codeData =
		RedeemCodeConfig[code]

	if not codeData then
         NotificationManager:Send(
                    player,
                    "Invalid or expired code."
                )
		return false,
			"Invalid or expired code."

	end

	------------------------------------------------
	-- VALIDATE CONFIG
	------------------------------------------------

	if codeData.UseType ~= "OncePerPlayer"
		and codeData.UseType ~= "Unlimited"
	then

		warn(
			"[RedeemCodeService] Invalid UseType:",
			code
		)
         NotificationManager:Send(
                    player,
                    "This code is unavailable."
                )
		return false,
			"This code is unavailable."

	end

	if not ValidateRewards(
        player,
        codeData.Rewards
    ) then

		warn(
			"[RedeemCodeService] Invalid reward configuration:",
			code
		)
         NotificationManager:Send(
                    player,
                    "This code is unavailable."
                )
		return false,
			"This code is unavailable."

	end

	------------------------------------------------
	-- EXPIRATION
	------------------------------------------------

	if codeData.ExpiresAt
		and typeof(codeData.ExpiresAt) == "number"
		and os.time() >= codeData.ExpiresAt
	then

		NotificationManager:Send(
			player,
			"This code has expired."
		)
		return false,
			"This code has expired."

	end

	------------------------------------------------
	-- REDEEMED CODES
	------------------------------------------------

	profile.RedeemedCodes =
		profile.RedeemedCodes
		or {}

	if codeData.UseType == "OncePerPlayer"
		and profile.RedeemedCodes[code]
	then

		NotificationManager:Send(
			player,
			"You already redeemed this code."
		)
		return false,
			"You already redeemed this code."

	end

	------------------------------------------------
	-- GRANT EVERYTHING
	------------------------------------------------

	local grantedRewards = {}
	for _, reward in ipairs(
		codeData.Rewards
	) do

		local success =
			GrantReward(
				player,
				reward
			)
		if not success then

			warn(
				"[RedeemCodeService] Failed to grant reward:",
				code
			)
             NotificationManager:Send(
                    player,
                    "Failed to grant reward."
                )
			return false,
				"Unable to grant this reward."

		end

		table.insert(
			grantedRewards,
			reward
		)

	end

	------------------------------------------------
	-- MARK ONE-TIME CODE AS USED
	------------------------------------------------

	if codeData.UseType
		== "OncePerPlayer"
	then

		profile.RedeemedCodes[code] =
			true

	end

	------------------------------------------------
	-- SHOW REWARDS
	------------------------------------------------
	RewardManager:SendRewards(
		player,
		grantedRewards
	)
    NotificationManager:Send(
                    player,
                    "Code redeemed successfully!"
                )
	return true,
		"Code redeemed successfully!"

end

------------------------------------------------
-- PLAYER CLEANUP
------------------------------------------------

Players.PlayerRemoving:Connect(
	function(player)

		LastRequest[player] = nil

	end
)

------------------------------------------------
-- INIT
------------------------------------------------

function RedeemCodeService:Init()

	print(
		"[RedeemCodeService] Initialized"
	)

	RedeemCodeRemote.OnServerInvoke =
		function(
			player,
			code
		)

			return self:Redeem(
				player,
				code
			)

		end

end

return RedeemCodeService