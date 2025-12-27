local Pulse = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

Pulse.Config = {
	ToggleKey = Enum.KeyCode.RightControl,  
	AccentColor = Color3.fromRGB(0, 180, 255), 
	GlowColor = Color3.fromRGB(100, 220, 255),  
	BackgroundColor = Color3.fromRGB(10, 10, 15),  
	MainColor = Color3.fromRGB(20, 20, 30),  
	SecondaryColor = Color3.fromRGB(30, 30, 45),  
	TextColor = Color3.fromRGB(240, 245, 255),  
	SubTextColor = Color3.fromRGB(180, 190, 210),  
	WindowSize = Vector2.new(550, 520),  
	NotifyDuration = 3,  
	Font = Enum.Font.Gotham,  
	CornerRadius = 12,
	Version = "v2.0",  
	AutoShow = true,  
	MinimizeKey = Enum.KeyCode.LeftControl,  
	ShowInteractiveIndicators = true,  
	IndicatorColor = Color3.fromRGB(0, 200, 255), 
	IndicatorHeight = 3, 
	ShowClickAnimation = true, 
	GlowEffect = true,  
	PulseRate = 0.8,  
	TransparencyLevel = 0.05  
}

Pulse.Colors = {
	Red = Color3.fromRGB(255, 80, 80),  
	Green = Color3.fromRGB(80, 255, 160),  
	Warning = Color3.fromRGB(255, 200, 50),  
	Stroke = Color3.fromRGB(40, 50, 70),  
	DarkStroke = Color3.fromRGB(20, 25, 35)
}

Pulse.Windows = {}
Pulse.Connections = {}
Pulse.Notifications = {}
Pulse.PulsingElements = {}

local function CreateGlowEffect(parent, color, intensity)
	if not Pulse.Config.GlowEffect then
		return nil
	end

	local glow = Instance.new("ImageLabel")
	glow.Name = "UIGlow"
	glow.Image = "rbxassetid://8992235945"
	glow.ImageColor3 = color or Pulse.Config.GlowColor
	glow.ImageTransparency = 0.8
	glow.ScaleType = Enum.ScaleType.Slice
	glow.SliceScale = 0.05
	glow.Size = UDim2.new(1, 20, 1, 20)
	glow.Position = UDim2.new(-0.1, -10, -0.1, -10)
	glow.BackgroundTransparency = 1
	glow.ZIndex = -1
	glow.Parent = parent

	local connection
	if intensity then
		local t = 0
		connection = RunService.Heartbeat:Connect(function(delta)
			t = t + delta
			local pulse = math.sin(t * Pulse.Config.PulseRate) * 0.1 + 0.9
			glow.ImageTransparency = 0.9 - intensity * pulse * 0.3
		end)
		table.insert(Pulse.Connections, connection)
	end

	return glow, connection
end

local function CreatePulseIndicator(parent, position)
	if not Pulse.Config.ShowInteractiveIndicators then
		return nil
	end

	local indicator = Instance.new("Frame")
	indicator.Name = "PulseIndicator"
	indicator.BackgroundColor3 = Pulse.Config.IndicatorColor
	indicator.BorderSizePixel = 0
	indicator.Size = UDim2.new(1, -10, 0, Pulse.Config.IndicatorHeight)
	indicator.Position = position
	indicator.AnchorPoint = Vector2.new(0.5, 0)
	indicator.BackgroundTransparency = 0.8
	indicator.ZIndex = 5
	indicator.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Pulse.Config.IndicatorHeight / 2)
	corner.Parent = indicator

	indicator.Visible = false

	if Pulse.Config.GlowEffect then
		CreateGlowEffect(indicator, Pulse.Config.IndicatorColor, 0.3)
	end

	return indicator
end

local function PlayPulseAnimation(indicator)
	if not indicator or not indicator.Parent then
		return
	end

	if not Pulse.Config.ShowClickAnimation then
		indicator.Visible = true
		return
	end

	indicator.Size = UDim2.new(0, 0, 0, Pulse.Config.IndicatorHeight)
	indicator.Position = UDim2.new(0.5, 0, indicator.Position.Y.Scale, indicator.Position.Y.Offset)
	indicator.Visible = true
	indicator.BackgroundTransparency = 0.5

	local growTween = TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, -10, 0, Pulse.Config.IndicatorHeight),
		BackgroundTransparency = 0.3
	})

	local fadeTween = TweenService:Create(indicator, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.3), {
		BackgroundTransparency = 1,
		Size = UDim2.new(1.1, -10, 0, Pulse.Config.IndicatorHeight)
	})

	growTween:Play()
	growTween.Completed:Connect(function()
		fadeTween:Play()
		fadeTween.Completed:Connect(function()
			indicator.Visible = false
			indicator.BackgroundTransparency = 0.8
			indicator.Size = UDim2.new(1, -10, 0, Pulse.Config.IndicatorHeight)
		end)
	end)
end

local function Create(className, props)
	local obj = Instance.new(className)
	for prop, val in pairs(props) do
		if prop == "Parent" then
			obj.Parent = val
		else
			if pcall(function()
				return obj[prop]
			end) then
				obj[prop] = val
			end
		end
	end
	return obj
end

local function Roundify(obj, radius)
	local corner = Create("UICorner", {
		CornerRadius = UDim.new(0, radius or Pulse.Config.CornerRadius),
		Parent = obj
	})
	return corner
end

-- 添加边框
local function AddStroke(obj, color, thickness)
	local stroke = Create("UIStroke", {
		Color = color or Pulse.Colors.Stroke,
		Thickness = thickness or 1.5,
		Transparency = 0.3,
		Parent = obj
	})
	return stroke
end

function Pulse:PulseNotify(options)
	local title = options.Title or "脉冲提示"
	local content = options.Content or ""
	local duration = options.Duration or Pulse.Config.NotifyDuration
	local pulseType = options.Type or "info"

	local colors = {
		info = Pulse.Config.AccentColor,
		success = Pulse.Colors.Green,
		warning = Pulse.Colors.Warning,
		error = Pulse.Colors.Red
	}

	local notification = Create("Frame", {
		Name = "PulseNotification",
		Size = UDim2.new(0, 320, 0, 80),
		Position = UDim2.new(0.5, -160, 0.1, 0),
		BackgroundColor3 = Pulse.Config.MainColor,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 100,
		Parent = CoreGui
	})

	Roundify(notification, 10)
	local stroke = AddStroke(notification, colors[pulseType], 2)

	local glow, glowConn = CreateGlowEffect(notification, colors[pulseType], 0.5)

	local icon = Create("ImageLabel", {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(0, 15, 0.5, -15),
		BackgroundTransparency = 1,
		Image = "rbxassetid://10723392055",
		ImageColor3 = colors[pulseType],
		Parent = notification
	})

	local titleLabel = Create("TextLabel", {
		Size = UDim2.new(1, -55, 0, 25),
		Position = UDim2.new(0, 50, 0, 15),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Pulse.Config.TextColor,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = notification
	})

	local contentLabel = Create("TextLabel", {
		Size = UDim2.new(1, -55, 0, 35),
		Position = UDim2.new(0, 50, 0, 40),
		BackgroundTransparency = 1,
		Text = content,
		TextColor3 = Pulse.Config.SubTextColor,
		Font = Pulse.Config.Font,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = notification
	})

	TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		BackgroundTransparency = Pulse.Config.TransparencyLevel,
		Position = UDim2.new(0.5, -160, 0.1, 0)
	}):Play()

	TweenService:Create(stroke, TweenInfo.new(0.4), {
		Transparency = 0
	}):Play()

	local pulseTime = 0
	local pulseConnection = RunService.Heartbeat:Connect(function(delta)
		pulseTime = pulseTime + delta
		local pulse = math.sin(pulseTime * 2) * 0.05
		stroke.Transparency = 0.2 - pulse
	end)

	task.delay(duration, function()
		pulseConnection:Disconnect()
		if glowConn then
			glowConn:Disconnect()
		end

		TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, -160, 0, -20)
		}):Play()

		TweenService:Create(stroke, TweenInfo.new(0.4), {
			Transparency = 1
		}):Play()

		if glow then
			TweenService:Create(glow, TweenInfo.new(0.4), {
				ImageTransparency = 1
			}):Play()
		end

		task.wait(0.4)
		notification:Destroy()
	end)

	table.insert(Pulse.Notifications, notification)
	return notification
end

function Pulse:CreateWindow(options)
	options = options or {}

	local ScreenGui = Create("ScreenGui", {
		Name = "PulseUI_" .. tick(),
		DisplayOrder = 999,
		ResetOnSpawn = false,
		Parent = CoreGui
	})

	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		BackgroundColor3 = Pulse.Config.BackgroundColor,
		BackgroundTransparency = Pulse.Config.AutoShow and Pulse.Config.TransparencyLevel or 1,
		Position = UDim2.new(0.5, -Pulse.Config.WindowSize.X / 2, 0.5, -Pulse.Config.WindowSize.Y / 2),
		Size = UDim2.new(0, Pulse.Config.WindowSize.X, 0, Pulse.Config.AutoShow and Pulse.Config.WindowSize.Y or 0),
		Visible = Pulse.Config.AutoShow,
		ZIndex = 10,
		Parent = ScreenGui
	})

	Roundify(MainFrame, 14)
	local mainStroke = AddStroke(MainFrame, Pulse.Colors.DarkStroke, 3)

	local windowGlow = CreateGlowEffect(MainFrame, Pulse.Config.AccentColor, 0.2)

	local titleBar = Create("Frame", {
		Name = "TitleBar",
		BackgroundColor3 = Pulse.Config.MainColor,
		Size = UDim2.new(1, 0, 0, 65),
		Parent = MainFrame
	})

	Roundify(titleBar, { TopLeft = true, TopRight = true })
	AddStroke(titleBar, Pulse.Colors.Stroke, 1)

	local pulseIcon = Create("ImageLabel", {
		Name = "PulseIcon",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(0, 12, 0.5, -18),
		Image = "rbxassetid://10723392055",
		ImageColor3 = Pulse.Config.AccentColor,
		Parent = titleBar
	})

	local pulseTime = 0
	local pulseConnection = RunService.Heartbeat:Connect(function(delta)
		pulseTime = pulseTime + delta
		local pulse = math.sin(pulseTime * 1.5) * 0.1 + 0.9
		pulseIcon.Size = UDim2.new(0, 36 * pulse, 0, 36 * pulse)
		pulseIcon.Position = UDim2.new(0, 12 + (36 - 36 * pulse) / 2, 0.5, -18 * pulse)
	end)
	table.insert(Pulse.Connections, pulseConnection)

	local titleLabel = Create("TextLabel", {
		Name = "UITitle",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 180, 0, 28),
		Position = UDim2.new(0, 55, 0, 10),
		Text = options.Title or "脉冲界面系统",
		TextColor3 = Pulse.Config.TextColor,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar
	})

	local subtitleLabel = Create("TextLabel", {
		Name = "UISubtitle",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 200, 0, 20),
		Position = UDim2.new(0, 55, 0, 35),
		Text = options.SubTitle or "Pulse UI v2.0",
		TextColor3 = Pulse.Config.SubTextColor,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar
	})

	local quickTabs = Create("Frame", {
		Name = "QuickTabs",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 120, 0, 25),
		Position = UDim2.new(1, -130, 0, 10),
		Parent = titleBar
	})

	local tabNames = options.CompactTabs or { "仪表盘", "设置" }
	local tabButtons = {}

	for i, tabName in ipairs(tabNames) do
		local tabButton = Create("TextButton", {
			Name = "QuickTab" .. i,
			Size = UDim2.new(0, 55, 1, 0),
			Position = UDim2.new((i - 1) * 0.5, 5 * (i - 1), 0, 0),
			BackgroundColor3 = i == 1 and Pulse.Config.AccentColor or Pulse.Config.SecondaryColor,
			BackgroundTransparency = i == 1 and 0.1 or 0.2,
			Text = tabName,
			TextColor3 = i == 1 and Color3.new(1, 1, 1) or Pulse.Config.TextColor,
			Font = Pulse.Config.Font,
			TextSize = 11,
			Parent = quickTabs
		})

		Roundify(tabButton, 6)
		AddStroke(tabButton, Pulse.Colors.Stroke, 1)

		local indicator = CreatePulseIndicator(tabButton, UDim2.new(0.5, 0, 1, -2))

		tabButton.MouseButton1Click:Connect(function()
			PlayPulseAnimation(indicator)
		end)

		tabButtons[i] = tabButton
	end

	local controlButtons = Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 70, 0, 25),
		Position = UDim2.new(1, -80, 0, 35),
		Parent = titleBar
	})

	local minimizeBtn = Create("TextButton", {
		Name = "Minimize",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 25, 0, 25),
		Position = UDim2.new(0, 5, 0, 0),
		Text = "─",
		TextColor3 = Pulse.Config.SubTextColor,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		Parent = controlButtons
	})

	local closeBtn = Create("TextButton", {
		Name = "Close",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 25, 0, 25),
		Position = UDim2.new(1, -30, 0, 0),
		Text = "✕",
		TextColor3 = Pulse.Config.SubTextColor,
		Font = Pulse.Config.Font,
		TextSize = 16,
		Parent = controlButtons
	})

	local contentArea = Create("Frame", {
		Name = "ContentArea",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 1, -85),
		Position = UDim2.new(0, 10, 0, 75),
		Parent = MainFrame
	})

	local tabSidebar = Create("Frame", {
		Name = "TabSidebar",
		BackgroundColor3 = Pulse.Config.MainColor,
		Size = UDim2.new(0, 160, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Parent = contentArea
	})

	Roundify(tabSidebar, 10)
	AddStroke(tabSidebar, Pulse.Colors.Stroke, 1)

	local mainContent = Create("Frame", {
		Name = "MainContent",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -170, 1, 0),
		Position = UDim2.new(0, 170, 0, 0),
		Parent = contentArea
	})

	local statusBar = Create("Frame", {
		Name = "StatusBar",
		BackgroundColor3 = Pulse.Config.MainColor,
		Size = UDim2.new(1, -20, 0, 35),
		Position = UDim2.new(0, 10, 1, -45),
		Visible = options.StatusText ~= nil,
		Parent = MainFrame
	})

	Roundify(statusBar, { BottomLeft = true, BottomRight = true })
	AddStroke(statusBar, Pulse.Colors.Stroke, 1)

	local statusText = Create("TextLabel", {
		Name = "StatusText",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Text = options.StatusText or "就绪",
		TextColor3 = Pulse.Config.SubTextColor,
		Font = Pulse.Config.Font,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = statusBar
	})

	local statusIndicator = Create("Frame", {
		Name = "StatusIndicator",
		Size = UDim2.new(0, 8, 0, 8),
		Position = UDim2.new(1, -25, 0.5, -4),
		BackgroundColor3 = Pulse.Colors.Green,
		Parent = statusBar
	})

	Roundify(statusIndicator, 4)

	local statusTime = 0
	local statusPulse = RunService.Heartbeat:Connect(function(delta)
		statusTime = statusTime + delta
		local pulse = math.sin(statusTime * 1.2) * 0.3 + 0.7
		statusIndicator.BackgroundTransparency = 1 - pulse
	end)
	table.insert(Pulse.Connections, statusPulse)

	local Window = {
		MainFrame = MainFrame,
		ScreenGui = ScreenGui,
		TitleBar = titleBar,
		ContentArea = contentArea,
		StatusBar = statusBar,
		StatusText = statusText,
		TabSidebar = tabSidebar,
		MainContent = mainContent,
		TitleLabel = titleLabel,
		SubtitleLabel = subtitleLabel,
		QuickTabs = tabButtons
	}

	if Pulse.Config.AutoShow then
		task.wait(0.3)
		self:PulseNotify({
			Title = "脉冲系统已激活",
			Content = "界面加载完成，准备接收指令",
			Type = "success",
			Duration = 3
		})
	end

	return Window
end

function Pulse:CreatePulseButton(parent, options)
	options = options or {}

	local button = Create("TextButton", {
		Name = options.Name or "PulseButton",
		Size = options.Size or UDim2.new(0, 120, 0, 40),
		Position = options.Position or UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = options.BackgroundColor or Pulse.Config.AccentColor,
		BackgroundTransparency = 0.2,
		Text = options.Text or "脉冲按钮",
		TextColor3 = options.TextColor or Color3.new(1, 1, 1),
		Font = options.Font or Enum.Font.GothamBold,
		TextSize = options.TextSize or 14,
		Parent = parent
	})

	Roundify(button, 8)
	AddStroke(button, Pulse.Config.AccentColor, 2)

	local glow = CreateGlowEffect(button, Pulse.Config.AccentColor, 0.4)

	local pulseTime = 0
	local pulseConnection
	if options.PulseEffect ~= false then
		pulseConnection = RunService.Heartbeat:Connect(function(delta)
			pulseTime = pulseTime + delta
			local pulse = math.sin(pulseTime * 2) * 0.05
			button.BackgroundTransparency = 0.2 - pulse
		end)
		table.insert(Pulse.Connections, pulseConnection)
	end

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundTransparency = 0,
			Size = options.Size and (options.Size + UDim2.new(0, 4, 0, 4)) or UDim2.new(0, 124, 0, 44)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundTransparency = 0.2,
			Size = options.Size or UDim2.new(0, 120, 0, 40)
		}):Play()
	end)

	button.MouseButton1Click:Connect(function()
		if options.OnClick then
			options.OnClick()
		end

		TweenService:Create(button, TweenInfo.new(0.1), {
			BackgroundTransparency = 0
		}):Play()

		if glow then
			TweenService:Create(glow, TweenInfo.new(0.1), {
				ImageTransparency = 0.6
			}):Play()
		end

		task.wait(0.1)

		TweenService:Create(button, TweenInfo.new(0.3), {
			BackgroundTransparency = 0.2
		}):Play()

		if glow then
			TweenService:Create(glow, TweenInfo.new(0.3), {
				ImageTransparency = 0.8
			}):Play()
		end
	end)

	return button
end

function Pulse:CreatePulseSlider(parent, options)
	options = options or {}

	local sliderFrame = Create("Frame", {
		Name = options.Name or "PulseSlider",
		Size = options.Size or UDim2.new(1, 0, 0, 60),
		Position = options.Position or UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = parent
	})

	local label = Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(0.6, 0, 0, 25),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = options.Label or "脉冲强度",
		TextColor3 = Pulse.Config.TextColor,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sliderFrame
	})

	local valueLabel = Create("TextLabel", {
		Name = "ValueLabel",
		Size = UDim2.new(0.4, 0, 0, 25),
		Position = UDim2.new(0.6, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = tostring(options.Value or 50),
		TextColor3 = Pulse.Config.AccentColor,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = sliderFrame
	})

	local track = Create("Frame", {
		Name = "Track",
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = Pulse.Config.SecondaryColor,
		Parent = sliderFrame
	})

	Roundify(track, 4)

	local fill = Create("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Pulse.Config.AccentColor,
		Parent = track
	})

	Roundify(fill, 4)

	local handle = Create("TextButton", {
		Name = "Handle",
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0, -10, 0.5, -10),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Text = "",
		Parent = track
	})

	Roundify(handle, 10)

	return sliderFrame
end

function Pulse:Cleanup()
	for _, window in pairs(Pulse.Windows) do
		if window and window.ScreenGui then
			window.ScreenGui:Destroy()
		end
	end

	for _, conn in pairs(Pulse.Connections) do
		if conn then
			pcall(function()
				conn:Disconnect()
			end)
		end
	end

	for _, notification in pairs(Pulse.Notifications) do
		if notification then
			pcall(function()
				notification:Destroy()
			end)
		end
	end

	Pulse.Windows = {}
	Pulse.Connections = {}
	Pulse.Notifications = {}

	self:PulseNotify({
		Title = "脉冲系统已关闭",
		Content = "所有界面资源已释放",
		Type = "info",
		Duration = 2
	})
end

return Pulse
