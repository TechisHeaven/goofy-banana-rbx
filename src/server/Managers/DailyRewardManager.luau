local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local DailyRewardConfig = require(Shared.Config.DailyRewardConfig)
local RemoteIndex = require(Shared.Remotes.RemoteIndex)

local RemotesFolder = Shared:WaitForChild("Remotes")

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

-- function DailyRewardManager:RefreshPlayer(player)

--     local data = getPlayerData(player)

--     if data.LastClaim == 0 then
--         return
--     end

--     local elapsed = os.time() - data.LastClaim

--     if elapsed >= DailyRewardConfig.ClaimCooldown then

--         if data.CurrentDay < DailyRewardConfig.MaxDay then
--             data.CurrentDay += 1
--         end
        
--         data.LastClaim = 0
--     end

-- end

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
    local canClaim = self:CanClaim(player)

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

----------------------------------------------------

-- function DailyRewardManager:Claim(player)

--     if not self:CanClaim(player) then

--         self:SendData(player)

--         return

--     end

--     local data = getPlayerData(player)

--     local reward =
--         DailyRewardConfig.Rewards[data.CurrentDay]

--     ------------------------------------------------
--     -- TODO
--     -- Give Coins
--     -- Give Skin
--     -- Give Head
--     ------------------------------------------------

--     print(player.Name.." claimed Day "..data.CurrentDay)

--     if reward.Coins then
--         print("Coins:",reward.Coins)
--     end

--     if reward.Skin then
--         print("Skin:",reward.Skin)
--     end

--     if reward.Head then
--         print("Head:",reward.Head)
--     end

--     ------------------------------------------------

--     data.LastClaim = os.time()

--    -- Give rewards
--     ------------------------------------------------

--     self:SendData(player)

-- end

function DailyRewardManager:Claim(player)

    self:RefreshPlayer(player)

    if not self:CanClaim(player) then
        self:SendData(player)
        return
    end

    local data = getPlayerData(player)

    local reward =
        DailyRewardConfig.Rewards[data.CurrentDay]

    ------------------------------------------------
    -- Give reward here
    ------------------------------------------------

    data.ClaimedDay = data.CurrentDay

    if data.LastUnlock == 0 then
        data.LastUnlock = os.time()
    end

    self:SendData(player)

end

----------------------------------------------------

function DailyRewardManager:Init()

    Players.PlayerAdded:Connect(function(player)

        getPlayerData(player)

        task.wait(1)

        self:SendData(player)

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