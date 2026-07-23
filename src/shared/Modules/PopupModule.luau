local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local PopupManager = {}

PopupManager.CurrentPopup = nil
PopupManager.Overlay = nil

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

	self.Overlay.InputBegan:Connect(function(input)

		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		if self.CurrentPopup then
			self:CloseCurrent()
		end

	end)

end

-------------------------------------------------------

function PopupManager:Open(Popup)

	if self.CurrentPopup == Popup then
		return
	end

	if self.CurrentPopup then
		self:CloseCurrent()
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

end

-------------------------------------------------------

function PopupManager:Close(Popup)

	if not Popup then
		return
	end

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

	Popup.Visible = false

	self.Overlay.Visible = false

	if self.CurrentPopup == Popup then
		self.CurrentPopup = nil
	end

end

-------------------------------------------------------

function PopupManager:CloseCurrent()

	if self.CurrentPopup then
		self:Close(self.CurrentPopup)
	end

end

-------------------------------------------------------

return PopupManager