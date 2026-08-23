local UserInputService = game:GetService("UserInputService")

local CursorController = {}

CursorController.Locked = false
CursorController.CanToggle = true

-----------------------------------------------------

local function ApplyState(self)
	if self.Locked then
		UserInputService.MouseIconEnabled = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	else
		UserInputService.MouseIconEnabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

-----------------------------------------------------

function CursorController:Init()

	UserInputService.InputBegan:Connect(function(input, gameProcessed)

		if gameProcessed then
			return
		end

		if not self.CanToggle then
			return
		end

		if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.X then
			self:SetLocked(not self.Locked)
		end

	end)

	ApplyState(self)
end

-----------------------------------------------------

function CursorController:SetLocked(locked)

	self.Locked = locked

	ApplyState(self)

end

-----------------------------------------------------

function CursorController:SetCanToggle(canToggle)

	self.CanToggle = canToggle

end

-----------------------------------------------------

function CursorController:EnterLobby()

	self.CanToggle = true
	self:SetLocked(false)

end

-----------------------------------------------------

function CursorController:EnterGameplay()

	self.CanToggle = true
	self:SetLocked(true)

end

-----------------------------------------------------

return CursorController