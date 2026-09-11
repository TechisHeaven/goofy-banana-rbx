local Players =
	game:GetService("Players")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local player =
	Players.LocalPlayer

local PlayerGui =
	player:WaitForChild("PlayerGui")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local Remotes =
	Shared:WaitForChild("Remotes")

local RemoteIndex =
	require(
		Shared.Remotes.RemoteIndex
	)

------------------------------------------------
-- UI
------------------------------------------------

local PopupGui =
	PlayerGui:WaitForChild(
		"PopupGui"
	)

local SettingsFrame =
	PopupGui:WaitForChild("Overlay"):WaitForChild(
		"SettingsFrame"
	)

local Items =
	SettingsFrame:WaitForChild(
		"Items"
	)

local RedeemFrame =
	Items:WaitForChild(
		"RedeemFrame"
	)

local Input =
	RedeemFrame:WaitForChild(
		"Input"
	)

local Code =
	Input:WaitForChild(
		"Code"
	)

local Claim =
	Input:WaitForChild(
		"Claim"
	)

------------------------------------------------
-- REMOTE
------------------------------------------------

local RedeemCode =
	Remotes:WaitForChild(
		RemoteIndex.Functions.RedeemCode
	)

------------------------------------------------
-- CONTROLLER
------------------------------------------------

local RedeemCodeController = {}

local Busy = false

------------------------------------------------
-- HELPERS
------------------------------------------------

local function SetButtonEnabled(
	enabled
)

	Claim.Active = enabled
	Claim.AutoButtonColor = enabled

end

------------------------------------------------
-- REDEEM
------------------------------------------------

local function Redeem()

	if Busy then
		return
	end

	local code =
		Code.Text

	if typeof(code) ~= "string" then
		return
	end

	code = code:match(
		"^%s*(.-)%s*$"
	)

	if #code == 0 then
		return
	end

	------------------------------------------------
	-- Client-side UX validation.
	--
	-- This is NOT security.
	-- The server validates it again.
	------------------------------------------------

	if #code > 32 then
		return
	end

	Busy = true

	SetButtonEnabled(false)

	local success, message =
		pcall(
			function()

				return RedeemCode:InvokeServer(
					code
				)

			end
		)

	if success then

		local redeemed,
			serverMessage =
			message

		------------------------------------------------
		-- Success
		------------------------------------------------

		if redeemed then

			Code.Text = ""

			print(
				"[RedeemCode]",
				serverMessage
					or "Code redeemed!"
			)

		else

			warn(
				"[RedeemCode]",
				serverMessage
					or "Unable to redeem code."
			)

		end

	else

		warn(
			"[RedeemCode] Remote failed:",
			message
		)

	end

	Busy = false

	SetButtonEnabled(true)

end

------------------------------------------------
-- INIT
------------------------------------------------

function RedeemCodeController:Init()

	Claim.Activated:Connect(
		Redeem
	)

	-- print(
	-- 	"[RedeemCodeController] Initialized"
	-- )

end

return RedeemCodeController