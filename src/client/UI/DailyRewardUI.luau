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

local PremiumButton = Popup.PurchaseButton
local GetPremium = Popup.GetPremium

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
local function RenderReward(frame, rewardData)
	if not rewardData then
		frame.Visible = false
		return
	end

	frame.Visible = true

	------------------------------------------------
	-- Image
	------------------------------------------------
	frame.Image.Image =
		rewardData.Image or ""

	------------------------------------------------
	-- Text
	------------------------------------------------

	if rewardData.Type == "Coins" then

		frame.Amount.Text =
			tostring(rewardData.Value)

	elseif rewardData.Type == "XP" then

		frame.Amount.Text =
			tostring(rewardData.Value) .. " XP"

	else

		frame.Amount.Text =
			rewardData.Id or rewardData.Type

	end

end


function DailyRewardUI:Render(data)

    ClearRewards()
    
    local currentReward
    for _,card in ipairs(data.Cards) do

        local reward = Template:Clone()

        reward.Name = "Reward"
        reward.Visible = true
        reward.Parent = RewardsFrame

        reward.Day.Text = "Day "..card.Day
        RenderReward(
            reward.Preview.BasicReward,
            card.FreeReward
        )

        RenderReward(
            reward.Preview.PremiumReward,
            card.PremiumReward
        )

        if data.IsPremium then
             reward.Preview.PremiumReward.Locked.Visible = false
             PremiumButton.Selectable = false
             PremiumButton.Visible = false
             GetPremium.Selectable = false
        end
        local claim = reward.Claim
        -- local later = reward.Later

        claim.Visible = false
        -- later.Visible = false

        claim.Active = false
        claim.AutoButtonColor = false
        ------------------------------------------------
        -- Already Claimed
        ------------------------------------------------
        if card.Day <= data.ClaimedDay then

            claim.Visible = true
            claim.Text.Text = "Claimed"
            claim.Active = false
	        claim.AutoButtonColor = false

        ------------------------------------------------
        -- Today's reward
        ------------------------------------------------

        elseif card.Day == data.CurrentDay and data.CanClaim then
            reward.BackgroundColor3  = Color3.fromRGB(249, 200, 53)
            currentReward = reward

                claim.Visible = true

                claim.Text.Text = "Claim"

                claim.Active = true
                claim.AutoButtonColor = false

                claim.Activated:Once(function()

                    if DailyRewardUI.OnClaimPressed then
                        DailyRewardUI.OnClaimPressed()
                    end

                end)
        elseif card.Day == data.CurrentDay + 1 and not data.CanClaim then

        ------------------------------------------------
        -- Future rewards
        ------------------------------------------------

        else
            claim.Visible = false
            -- later.Visible = true

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



function DailyRewardUI:Init()

    Template.Visible = false

    DailyRewardButton.Activated:Connect(function()
        PopupManager:Open(DailyRewardGui)
    end)


    PremiumButton.Activated:Connect(function()
		if DailyRewardUI.OnPremiumPressed then
			DailyRewardUI.OnPremiumPressed()
		end

	end)

    GetPremium.Activated:Connect(function()
		if DailyRewardUI.OnPremiumPressed then
			DailyRewardUI.OnPremiumPressed()
		end
	end)
end


---------------------------------------------------


---------------------------------------------------

return DailyRewardUI