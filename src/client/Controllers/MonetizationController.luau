local MarketplaceService =
	game:GetService("MarketplaceService")

local Players =
	game:GetService("Players")

local ReplicatedStorage =
	game:GetService("ReplicatedStorage")

local Shared =
	ReplicatedStorage:WaitForChild("Shared")

local Remotes =
	Shared:WaitForChild("Remotes")

local RemoteIndexData =
	require(Shared.Remotes.RemoteIndex)

local RemoteIndex =
	RemoteIndexData.Events

local PromptProductPurchase =
	Remotes:WaitForChild(
		RemoteIndex.PromptProductPurchase
)

local MonetizationController = {}

local Player =
	Players.LocalPlayer

------------------------------------------------
-- Prompt
------------------------------------------------

function MonetizationController:PurchaseProduct(
	productId
)

	if not productId
		or productId <= 0 then

		warn(
			"[MonetizationController] Invalid ProductId:",
			productId
		)

		return

	end

	local success, err =
		pcall(function()

			MarketplaceService:PromptProductPurchase(
				Player,
				productId
			)

		end)

	if not success then

		warn(
			"[MonetizationController] Prompt failed:",
			err
		)

	end

end


function MonetizationController:PurchaseGamePass(passId)
    if not passId or passId <= 0 then
        warn("Invalid GamePass ID")
        return
    end

    local player = Players.LocalPlayer

	local success, err =
		pcall(function()
			return MarketplaceService:PromptGamePassPurchase(
					player,
					passId
				)
		end)
    
	if not success then
		warn(
			"[MonetizationController] Failed to prompt GamePass:",
			err
		)
	end
end


------------------------------------------------
-- Init
------------------------------------------------

function MonetizationController:Init()

	PromptProductPurchase.OnClientEvent:Connect(
		function(data)

			if not data then
				return
			end

			if not data.ProductId then
				return
			end

			self:PurchaseProduct(
				data.ProductId
			)

		end
	)

	print(
		"[MonetizationController] Initialized"
	)

end

return MonetizationController