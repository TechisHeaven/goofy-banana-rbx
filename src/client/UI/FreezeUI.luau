local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local PopupGui = PlayerGui:WaitForChild("PopupGui")
local GameGui = PlayerGui:WaitForChild("GameGui")


local Popup = require(game.ReplicatedStorage.Shared.Modules.PopupModule)

local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)

local FreezeUI = {}

local Frame = PopupGui.Overlay.FrozenFrame
local FreezeCooldown = GameGui.Center.FreezeCooldown

local CooldownText =
	FreezeCooldown.Cooldown


------------------------------------------------
-- State
------------------------------------------------

local cooldownToken = 0


function FreezeUI:Show(data)

    Popup:Open(Frame)

    task.delay(data.duration or GameConfig.Game.FreezeDuration or 5,function()

        Popup:CloseCurrent()

    end)

end


function FreezeUI:ShowFreezeCooldown(cooldown)

	cooldown = tonumber(cooldown)

	if not cooldown or cooldown <= 0 then
		return
	end

	------------------------------------------------
	-- Cancel previous countdown
	------------------------------------------------

	cooldownToken += 1

	local token = cooldownToken

	------------------------------------------------
	-- Show
	------------------------------------------------

	FreezeCooldown.Visible = true

	------------------------------------------------
	-- Countdown
	------------------------------------------------

	local endTime =
		os.clock() + cooldown

	while token == cooldownToken do

		local remaining =
			math.max(
				0,
				endTime - os.clock()
			)

		if remaining <= 0 then
			break
		end

		------------------------------------------------
		-- 5 4 3 2 1
		------------------------------------------------

		CooldownText.Text =
			tostring(
				math.ceil(remaining)
			)

		task.wait(0.05)

	end

	------------------------------------------------
	-- Hide after cooldown
	------------------------------------------------

	if token == cooldownToken then

		CooldownText.Text = ""

		FreezeCooldown.Visible = false

	end

end

------------------------------------------------
-- Hide manually
------------------------------------------------

function FreezeUI:HideFreezeCooldown()

	cooldownToken += 1

	FreezeCooldown.Visible = false
	CooldownText.Text = ""

end

return FreezeUI