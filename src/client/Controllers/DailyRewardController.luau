local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local RemoteIndex = require(Shared.Remotes.RemoteIndex)

local DailyRewardUI =
	require(script.Parent.Parent.UI.DailyRewardUI)

-----------------------------------------------------

local Remotes = Shared:WaitForChild("Remotes")

local function getRemote(name)

	return Remotes:WaitForChild(name)

end

-----------------------------------------------------

local DailyRewardController = {}

local CurrentData = nil


-----------------------------------------------------
-- Countdown
-----------------------------------------------------

local CountdownThread = nil

local function StartCountdown()
	if CountdownThread then
		task.cancel(CountdownThread)
	end

	CountdownThread = task.spawn(function()

		while CurrentData and not CurrentData.CanClaim do
			local remaining =
				math.max(
					0,
					CurrentData.NextClaimTime - os.time()
				)

			local hours =
				math.floor(remaining / 3600)

			local minutes =
				math.floor((remaining % 3600) / 60)

			local seconds =
				remaining % 60

			DailyRewardUI:SetCountdown(
				string.format(
					"%02dh %02dm %02ds",
					hours,
					minutes,
					seconds
				)
			)

			if remaining <= 0 then
                getRemote(RemoteIndex.GetDailyReward):FireServer()

				break
			end

			task.wait(1)

		end

	end)

end

-----------------------------------------------------
-- Remote
-----------------------------------------------------

local function OnDailyRewardUpdate(data)

	CurrentData = data

	DailyRewardUI:Render(data)

	if data.CanClaim then

		DailyRewardUI:SetCountdown("Claim")

	else

		StartCountdown()

	end

end

-----------------------------------------------------
-- Claim Button
-----------------------------------------------------

local function OnClaimPressed()

	if not CurrentData then
		return
	end

	if not CurrentData.CanClaim then
		return
	end

	getRemote(RemoteIndex.RequestDailyReward):FireServer()

end

-----------------------------------------------------

function DailyRewardController:Init()

	print("DailyRewardController Initialized")

	DailyRewardUI:Init()

	DailyRewardUI.OnClaimPressed = OnClaimPressed

	getRemote(RemoteIndex.UpdateDailyReward)
		.OnClientEvent
		:Connect(OnDailyRewardUpdate)
    getRemote(RemoteIndex.GetDailyReward)
        .OnClientEvent
        :Connect(function(player)
            self:SendData(player)
        end)

end

-----------------------------------------------------

return DailyRewardController