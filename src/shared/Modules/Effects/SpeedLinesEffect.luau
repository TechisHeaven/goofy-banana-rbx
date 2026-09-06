local module = {}
local RunService = game:GetService("RunService")
local Camera = game.Workspace.CurrentCamera
local Particle = game.ReplicatedStorage:WaitForChild("Speedlines")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local ViewportSize = Camera.ViewportSize
local AspectRatio = ViewportSize.X / ViewportSize.Y
local Offset = 10


function module:Start(rate: number, speed: number)
  if not Camera then
    return 
  end

  if rate == nil then
    rate = 1500
  end

  if speed == nil then
    speed = 20
  end

  Particle.Attachment.ParticleEmitter.Enabled = true
  Particle.Parent = Camera

  if AspectRatio > 1.5 then
		Offset = 10
	else
		Offset = 13
	end


  task.spawn(function()
     RunService:BindToRenderStep("Speedlines", Enum.RenderPriority.Camera.Value, function()
       -- Render step logic here
        Particle.CFrame =
            Camera.CFrame
            + Camera.CFrame.LookVector
            * (Offset / (Camera.FieldOfView / 70))
	
	
	    Particle.Attachment.ParticleEmitter.Rate = (humanoid.WalkSpeed / speed) * rate
     end)
  end)

end


function module:Stop()
  RunService:UnbindFromRenderStep("Speedlines")
  Particle.Position = Particle.Position + Vector3.new(0, 500, 0)
  Particle.Attachment.ParticleEmitter.Enabled = false
  Particle.Parent = nil
end

return module