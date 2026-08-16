local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local PopupManager = {}

PopupManager.CurrentPopup = nil
PopupManager.PreviousPopup = nil
PopupManager.ReopenPreviousOnClose = false
PopupManager.IsAnimating = false
PopupManager.Overlay = nil

PopupManager.CanClickOutsideToClose = true

-- SETTINGS

PopupManager.BlurSize = 18
PopupManager.BackgroundTransparency = 0.35

PopupManager.OpenScale = 1
PopupManager.ClosedScale = 0.8

PopupManager.OpenTime = 0.22
PopupManager.CloseTime = 0.15

-------------------------------------------------------

local Blur = Lighting:FindFirstChild("PopupBlur")

if not Blur then
	Blur = Instance.new("BlurEffect")
	Blur.Name = "PopupBlur"
	Blur.Size = 0
	Blur.Parent = Lighting
end

-------------------------------------------------------

function PopupManager:Init(Overlay)

	self.Overlay = Overlay
	self.Overlay.Visible = false
	self.Overlay.BackgroundTransparency = 1
	print("[popup] init")

	self.Overlay.InputBegan:Connect(function(input)

		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		if not self.CanClickOutsideToClose then
			return
		end

		if self.CurrentPopup and not self.IsAnimating then
		self:CloseCurrent()
	end

	end)

end

-------------------------------------------------------

function PopupManager:Open(Popup, Options : {CanClickOutsideToClose: boolean, ReopenPreviousOnClose: boolean}?)
	if self.IsAnimating then
		return
	end
	Options = Options or {}

	self.CanClickOutsideToClose =
		if Options.CanClickOutsideToClose ~= nil
			then Options.CanClickOutsideToClose
		else true
	
	self.ReopenPreviousOnClose =
		Options.ReopenPreviousOnClose == true


	if self.CurrentPopup == Popup then
		return
	end

	------------------------------------------------
	-- Remember current popup if requested
	------------------------------------------------

	local previousPopup = self.CurrentPopup

	if previousPopup
		and self.ReopenPreviousOnClose then

		self.PreviousPopup = previousPopup

	else

		self.PreviousPopup = nil

	end
	-- if self.CurrentPopup then
	-- 	self:CloseCurrent()
	-- end

	------------------------------------------------
	-- Close current popup
	------------------------------------------------

	if self.CurrentPopup then
		local oldPopup = self.CurrentPopup

		-- IMPORTANT:
		-- This is a switch, NOT a normal close.
		self:Close(oldPopup, true)
	end

	self.CurrentPopup = Popup

	local Scale = Popup:FindFirstChildOfClass("UIScale")

	if not Scale then
		Scale = Instance.new("UIScale")
		Scale.Parent = Popup
	end

	Scale.Scale = self.ClosedScale
	
	Popup.Visible = true
	self.Overlay.Visible = true

	TweenService:Create(
		self.Overlay,
		TweenInfo.new(0.2),
		{
			BackgroundTransparency = self.BackgroundTransparency
		}
	):Play()


	TweenService:Create(
		Blur,
		TweenInfo.new(0.2),
		{
			Size = self.BlurSize
		}
	):Play()

	TweenService:Create(
		Scale,
		TweenInfo.new(
			self.OpenTime,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Scale = self.OpenScale
		}
	):Play()

	-- SoundUtil:PlaySound(WoshSound, Popup)

end

-------------------------------------------------------

function PopupManager:Close(Popup, IsSwitching)
	if not Popup then
		return
	end
	if self.IsAnimating then
		return
	end

	self.IsAnimating = true
	local Scale = Popup:FindFirstChildOfClass("UIScale")

	if not Scale then
		return
	end

	local Tween = TweenService:Create(
		Scale,
		TweenInfo.new(
			self.CloseTime,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		),
		{
			Scale = self.ClosedScale
		}
	)

	Tween:Play()

	TweenService:Create(
		Blur,
		TweenInfo.new(self.CloseTime),
		{
			Size = 0
		}
	):Play()

	TweenService:Create(
		self.Overlay,
		TweenInfo.new(self.CloseTime),
		{
			BackgroundTransparency = 1
		}
	):Play()

	Tween.Completed:Wait()

	-- SoundUtil:PlaySound(WoshSound, Popup)

	Popup.Visible = false
	

	if self.CurrentPopup == Popup then
		self.CurrentPopup = nil
	end

	-- Don't reopen while switching popup
	if IsSwitching then
		self.IsAnimating = false
		return
	end

	-- Reopen previous popup
	if self.ReopenPreviousOnClose
		and self.PreviousPopup then


		local previous =
			self.PreviousPopup

		-- Clear history BEFORE opening
		-- prevents recursive reopening

		self.PreviousPopup = nil
		self.ReopenPreviousOnClose = false
		self.IsAnimating = false

		self:Open(previous)

	end

	-- Hide overlay only if nothing reopened

	if not self.CurrentPopup then
		self.Overlay.Visible = false
	end

	self.Overlay.Visible = false

	self.IsAnimating = false
	
end

-------------------------------------------------------

function PopupManager:CloseCurrent()
	if self.CurrentPopup then
		self:Close(self.CurrentPopup)
	end

end

-------------------------------------------------------

return PopupManager

