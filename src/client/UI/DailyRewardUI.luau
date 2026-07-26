local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local PopupGui = PlayerGui:WaitForChild("PopupGui")
local LobbyGui = PlayerGui:WaitForChild("LobbyGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")


local DailyRewardButton = LobbyGui.Center.Right.DailyRewardButton


local PopupManager = require(ReplicatedStorage.Shared.Modules.PopupModule)


local Overlay = PopupGui:WaitForChild("Overlay")
local DailyRewardGui = Overlay:WaitForChild("DailyRewardFrame")

local Popup = DailyRewardGui.DailyRewardItemsFrame

local RewardsFrame =
    Popup.ScrollingFrame


local Template =
    RewardsFrame.RewardTemplate
---------------------------------------------------
-- DailyRewardGui.NextReward = nil

local DailyRewardUI = {}



-- Template.Visible = false
-- DailyRewardButton.Activated:Connect(function()

--     PopupManager:Open(DailyRewardGui)

-- end)
---------------------------------------------------

-- local rewardFrames = {

--     RewardsFrame.Reward1,
--     RewardsFrame.Reward2,
--     RewardsFrame.Reward3,
--     RewardsFrame.Reward4,

-- }

local function ClearRewards()

    for _,child in ipairs(RewardsFrame:GetChildren()) do

        if child.Name == "Reward" then

            child:Destroy()

        end

    end

end


-- function DailyRewardUI:Render(data)

--     ClearRewards()
--     print(data)

--     for _,card in ipairs(data.Cards) do

--         local reward = Template:Clone()

--         reward.Name = "Reward"

--         reward.Visible = true

--         reward.Parent = RewardsFrame


        
--         local claimButton = reward.Claim
--         local timerLabel = reward.Timer
--         local laterLabel = reward.Later

--         claimButton.Visible = false
--         timerLabel.Visible = false
--         laterLabel.Visible = false
--         ------------------------------------

--         reward.Day.Text =
--             "Day "..card.Day

--         reward.Preview.Coins.Text =
--             tostring(card.Reward.Coins)

--         ------------------------------------
--         -- Big reward
--         ------------------------------------

--         if card.BigReward then

--             -- reward.Preview.ItemImage.Image =
--             --     "rbxassetid://YOUR_BIG_REWARD"
--             print("Big reward for day "..card.Day.." is available!")

--         end

--         ------------------------------------
--         -- State
--         ------------------------------------

--         if card.Day == data.CurrentDay then
--             if data.CanClaim then
--                 claimButton.Visible = true
--                 claimButton.Text.Text = "Claim"

--                 reward.Claim.Text.TextColor3 =
--                     Color3.fromRGB(255,255,255)

--                 claimButton.Activated:Once(function()

--             if DailyRewardUI.OnClaimPressed then
--                 DailyRewardUI.OnClaimPressed()
--                 end
--             end)

--             else
--                 claimButton.Visible = true
--                 reward.Claim.Text.Text = "Claimed"
--                 claimButton.Active = false
--                 claimButton.AutoButtonColor = false
--             end

--        elseif card.Day == data.CurrentDay + 1 and not data.CanClaim then
--             timerLabel.Visible = true

--         else

--             laterLabel.Visible = true

--         end

--     end

-- end

function DailyRewardUI:Render(data)

    ClearRewards()

    local currentReward

    for _,card in ipairs(data.Cards) do

        local reward = Template:Clone()

        reward.Name = "Reward"
        reward.Visible = true
        reward.Parent = RewardsFrame

        reward.Day.Text = "Day "..card.Day
        reward.Preview.Coins.Text = tostring(card.Reward.Coins)

        local claim = reward.Claim
        local timer = reward.Timer
        local later = reward.Later

        claim.Visible = false
        timer.Visible = false
        later.Visible = false

        claim.Active = false
        claim.AutoButtonColor = false

        ------------------------------------------------
        -- Already Claimed
        ------------------------------------------------

        if card.Day <= data.ClaimedDay then

            claim.Visible = true
            claim.Text.Text = "Claimed"
            claim.Active = false

        ------------------------------------------------
        -- Today's reward
        ------------------------------------------------

        elseif card.Day == data.CurrentDay and data.CanClaim then

            currentReward = reward

                claim.Visible = true

                claim.Text.Text = "Claim"

                claim.Active = true
                claim.AutoButtonColor = true

                claim.Activated:Once(function()

                    if DailyRewardUI.OnClaimPressed then
                        DailyRewardUI.OnClaimPressed()
                    end

                end)
        elseif card.Day == data.CurrentDay + 1 and not data.CanClaim then

            timer.Visible = true

        ------------------------------------------------
        -- Future rewards
        ------------------------------------------------

        else

            later.Visible = true

        end

    end

    ------------------------------------------------
    -- Auto Scroll
    ------------------------------------------------
local layout = RewardsFrame.UIListLayout

RewardsFrame.CanvasSize = UDim2.fromOffset(
    layout.AbsoluteContentSize.X + 10,
    0
)

task.wait()

if currentReward then
    local x = currentReward.AbsolutePosition.X - RewardsFrame.AbsolutePosition.X
    x += RewardsFrame.CanvasPosition.X

    RewardsFrame.CanvasPosition = Vector2.new(
        math.max(0, x - 20),
        0
    )
end

end

---------------------------------------------------

function DailyRewardUI:SetVisible(visible)

    Popup.Visible = visible

end

---------------------------------------------------

local function hideAll()

    for _,frame in ipairs(rewardFrames) do

        frame.Visible = false

    end

end

---------------------------------------------------

-- function DailyRewardUI:Render(data)

--     hideAll()

--     for index,card in ipairs(data.Cards) do

--         local frame = rewardFrames[index]

--         if not frame then
--             break
--         end

--         frame.Visible = true

--         ------------------------------------------
--         -- Day
--         ------------------------------------------

--         frame.Day.Text =
--             "Day "..card.Day

--         ------------------------------------------
--         -- Coins
--         ------------------------------------------

--         frame.Preview.Coins.Text =
--             tostring(card.Reward.Coins or 0)

--         ------------------------------------------
--         -- Big reward
--         ------------------------------------------

--         if card.BigReward then

--             Popup.FutureRewards.Visible = true

--         else

--             Popup.FutureRewards.Visible = false

--         end

--         ------------------------------------------
--         -- Current day
--         ------------------------------------------

--         if card.Day == data.CurrentDay then

--             if data.CanClaim then

--                 frame.Claim.Text = "Claim"

--                 frame.Claim.TextColor3 =
--                     Color3.fromRGB(255,255,255)

--                 frame.Claim.Active = true

--             else

--                 frame.Claim.Text = "Claimed"

--                 frame.Claim.TextColor3 =
--                     Color3.fromRGB(0,255,0)

--                 frame.Claim.Active = false

--             end

--         elseif card.Day == data.CurrentDay + 1
--             and not data.CanClaim then

--             frame.Claim.Text = ""
--             frame.Claim.Active = false

--         else

--             frame.Claim.Text = "Later..."

--             frame.Claim.TextColor3 =
--                 Color3.fromRGB(160,160,160)

--             frame.Claim.Active = false

--         end

--     end

-- end


function DailyRewardUI:Init()

    Template.Visible = false

    DailyRewardButton.Activated:Connect(function()

        PopupManager:Open(DailyRewardGui)

    end)

end


---------------------------------------------------

function DailyRewardUI:SetCountdown(text)

    for _,reward in ipairs(RewardsFrame:GetChildren()) do

        if reward.Name ~= "Reward" then
            continue
        end

        if reward.Timer.Visible then
            reward.Timer.Text = text
            return

        end

    end
            -- self.NextReward.Claim.Text = text


end

---------------------------------------------------

return DailyRewardUI