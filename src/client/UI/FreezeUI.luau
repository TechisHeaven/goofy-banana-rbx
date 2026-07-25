local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local PopupGui = PlayerGui:WaitForChild("PopupGui")

local Popup = require(game.ReplicatedStorage.Shared.Modules.PopupModule)

local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)

local FreezeUI = {}

local Frame = PopupGui.Overlay.FrozenFrame

function FreezeUI:Show(data)

    Popup:Open(Frame)

    task.delay(data.duration or GameConfig.Game.FreezeDuration or 5,function()

        Popup:CloseCurrent()

    end)

end

return FreezeUI