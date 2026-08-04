local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local RemoteIndexData = require(Shared.Remotes.RemoteIndex)
local RemoteIndex = RemoteIndexData.Events

local FreezeEventManager = {}

local RemotesFolder = Shared:WaitForChild("Remotes")


-- Cached remote references (filled in Init)
local remotes: { [string]: RemoteEvent } = {}

local function getRemote(name)
    return RemotesFolder:WaitForChild(name)
end


------------------------------------------------
function FreezeEventManager:Init()

    for _, name in pairs(RemoteIndex) do

        local remote = RemotesFolder:FindFirstChild(name)

        if remote then
            remotes[name] = remote
        end

    end

end



function FreezeEventManager:FirePlayerFrozen(player, freezer: Player?)
    local FrozenRemote = getRemote(RemoteIndex.PlayerFrozen)


    FrozenRemote:FireClient(player,{
        duration = 5,
        rescuesNeeded = 1,
        frozenBy = freezer and freezer.Name
    })

end

return FreezeEventManager