local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local DailyRewardConfig = require(Shared.Config.DailyRewardConfig)
local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events

local RemotesFolder = Shared:WaitForChild("Remotes")

------------------------------------------------
-- Managers
------------------------------------------------

local CurrencyManager =
	require(script.Parent.CurrencyManager)

----------------------------------------------------
-- Remotes
----------------------------------------------------

local RequestReward =
    RemotesFolder:WaitForChild(RemoteIndex.RequestDailyReward)

local UpdateReward =
    RemotesFolder:WaitForChild(RemoteIndex.UpdateDailyReward)

----------------------------------------------------

local DailyRewardManager = {}

----------------------------------------------------
-- Temporary Data
--
-- Replace this section with DataStore later.
----------------------------------------------------

local PlayerData = {}

----------------------------------------------------

local function getPlayerData(player)

    local data = PlayerData[player]

    if not data then

        data = {
            CurrentDay = 4,     -- Current unlocked calendar day
            ClaimedDay = 3,     -- Last claimed reward
            LastUnlock = os.time(),     -- Time current day was unlocked
        }

        PlayerData[player] = data

    end

    return data

end

----------------------------------------------------

-- function DailyRewardManager:CanClaim(player)

--     -- local data = getPlayerData(player)

--     -- if data.LastClaim == 0 then
--     --     return true
--     -- end

--     -- local elapsed =
--     --     os.time() - data.LastClaim

--     -- return elapsed >= DailyRewardConfig.ClaimCooldown

--     local data = getPlayerData(player)

-- 	return data.NextDay <= data.HighestUnlocked

-- end

function DailyRewardManager:CanClaim(player)

    local data = getPlayerData(player)

    return data.ClaimedDay < data.CurrentDay

end

----------------------------------------------------

function DailyRewardManager:GetRemaining(player)

     local data = getPlayerData(player)

    local nextUnlock =
        data.LastUnlock + DailyRewardConfig.ClaimCooldown

    return math.max(
        0,
        nextUnlock - os.time()
    )


end


function DailyRewardManager:BuildCards(player)

     local data = getPlayerData(player)

    local cards = {}

    local startDay = data.CurrentDay

    for day = 1, startDay + DailyRewardConfig.VisibleRewards - 1 do

        table.insert(cards,{

            Day = day,
            Reward = DailyRewardConfig.Rewards[day],
            BigReward = day == DailyRewardConfig.MaxDay,

        })

    end

    return cards

end

function DailyRewardManager:RefreshPlayer(player)

    local data = getPlayerData(player)

    if data.LastUnlock == 0 then
        return
    end

    local now = os.time()

    while
        data.CurrentDay < DailyRewardConfig.MaxDay
        and now >= data.LastUnlock + DailyRewardConfig.ClaimCooldown
    do

        data.CurrentDay += 1
        data.LastUnlock += DailyRewardConfig.ClaimCooldown

    end

end

----------------------------------------------------

function DailyRewardManager:SendData(player)

    self:RefreshPlayer(player)

    local data = getPlayerData(player)

    UpdateReward:FireClient(player,{

        CurrentDay = data.CurrentDay,

	ClaimedDay = data.ClaimedDay,

	LastUnlock = data.LastUnlock,

	CanClaim = self:CanClaim(player),

	Remaining = self:GetRemaining(player),

	NextClaimTime =
		self:CanClaim(player)
		and 0
		or (data.LastUnlock + DailyRewardConfig.ClaimCooldown),

	Cards = self:BuildCards(player),
    })

end

------------------------------------------------
-- Give Reward
------------------------------------------------

function DailyRewardManager:GiveReward(player, reward)

	if not reward then
		return false
	end

	------------------------------------------------
	-- Coins
	------------------------------------------------

	if reward.Coins then
		CurrencyManager:AddCoins(
			player,
			reward.Coins
		)

		print(
			player.Name
			.. " received "
			.. reward.Coins
			.. " coins"
		)

	end

	------------------------------------------------
	-- Skin
	------------------------------------------------

	if reward.Skin then

		print(
			player.Name
			.. " received skin: "
			.. tostring(reward.Skin)
		)

		-- Add to InventoryManager later

	end

	------------------------------------------------
	-- Head
	------------------------------------------------

	if reward.Head then

		print(
			player.Name
			.. " received head: "
			.. tostring(reward.Head)
		)

		-- Add to InventoryManager later

	end

	return true

end



----------------------------------------------------

function DailyRewardManager:Claim(player)

    self:RefreshPlayer(player)

    if not self:CanClaim(player) then
        self:SendData(player)
        return false
    end

    local data = getPlayerData(player)

   local reward =
		DailyRewardConfig.Rewards[
			data.CurrentDay
		]

	if not reward then

		warn(
			"No reward configured for day "
			.. tostring(data.CurrentDay)
		)

		return false

	end


    ------------------------------------------------
    -- Give reward here
    ------------------------------------------------
    local success =
            self:GiveReward(
                player,
                reward
            )

        if not success then
            return false
        end

    data.ClaimedDay = data.CurrentDay

    if data.LastUnlock == 0 then
        data.LastUnlock = os.time()
    end

    self:SendData(player)

	return true
end

----------------------------------------------------

function DailyRewardManager:Init()

    ------------------------------------------------
	-- Existing players
	------------------------------------------------

	for _, player in ipairs(
		Players:GetPlayers()
	) do

		getPlayerData(player)

		task.defer(function()

			self:SendData(player)

		end)

	end


    Players.PlayerAdded:Connect(function(player)

        getPlayerData(player)

        -- task.wait(1)

        -- self:SendData(player)

        task.defer(function()

			self:SendData(player)

		end)

    end)

    Players.PlayerRemoving:Connect(function(player)

        PlayerData[player] = nil

    end)

    RequestReward.OnServerEvent:Connect(function(player)

        self:Claim(player)

    end)

end

----------------------------------------------------

return DailyRewardManager