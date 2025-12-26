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
    Version = "v2.1",
    AutoShow = true,
    MinimizeKey = Enum.KeyCode.LeftControl,
    ShowInteractiveIndicators = true,
    IndicatorColor = Color3.fromRGB(0, 200, 255),
    IndicatorHeight = 3,
    ShowClickAnimation = true,
    GlowEffect = true,
    PulseRate = 0.8,
    TransparencyLevel = 0.05,
    EnableLucide = true
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
Pulse.LucideIcons = {}
Pulse.Tooltips = {}
Pulse.CurrentTutorial = nil

-- 完整Lucide图标库
Pulse.LucideIcons.Map = {
    home = 10709777533,
    settings = 10709779000,
    user = 10709779256,
    bell = 10709774526,
    search = 10709778472,
    plus = 10709777760,
    trash = 10709778878,
    download = 10709775797,
    upload = 10709779152,
    play = 10709777672,
    pause = 10709777459,
    stop = 10709778694,
    chevronRight = 10709775320,
    chevronLeft = 10709775207,
    chevronUp = 10709775432,
    chevronDown = 10709775078,
    star = 10709778608,
    heart = 10709776165,
    eye = 10709775909,
    eyeOff = 10709775977,
    lock = 10709776697,
    unlock = 10709779075,
    check = 10709775140,
    x = 10709779324,
    menu = 10709776960,
    filter = 10709776040,
    refresh = 10709778168,
    alertCircle = 10709774285,
    alertTriangle = 10709774352,
    info = 10709776464,
    zap = 10709779390,
    sun = 10709778679,
    moon = 10709777269,
    cpu = 10709775578,
    shield = 10709778537,
    trophy = 10709778944,
    messageCircle = 10709777088,
    mail = 10709776826,
    phone = 10709777381,
    wifi = 10709779292,
    battery = 10709774599,
    batteryCharging = 10709774667,
    volume2 = 10709779189,
    volumeX = 10709779222,
    camera = 10709774809,
    video = 10709779119,
    microphone = 10709777156,
    microphoneOff = 10709777224,
    music = 10709777314,
    image = 10709776396,
    file = 10709776008,
    folder = 10709776102,
    save = 10709778336,
    edit = 10709775729,
    copy = 10709775510,
    share = 10709778504,
    externalLink = 10709775942,
    globe = 10709776200,
    mapPin = 10709776893,
    navigation = 10709777348,
    compass = 10709775465,
    helpCircle = 10709776130,
    code = 10709775388,
    terminal = 10709778761,
    database = 10709775647,
    server = 10709778438,
    cloud = 10709775499,
    key = 10709776575,
    palette = 10709777426,
    type = 10709778977,
    bold = 10709774699,
    italic = 10709776430,
    underline = 10709779042,
    list = 10709776764,
    grid = 10709776268,
    layout = 10709776628,
    sidebar = 10709778571,
    toggleLeft = 10709778852,
    toggleRight = 10709778885,
    power = 10709777728,
    mousePointer = 10709777381,
    maximize = 10709777022,
    minimize = 10709777190,
    monitor = 10709777257,
    smartphone = 10709778586
}

function Pulse:GetLucideIcon(iconName)
    if not Pulse.Config.EnableLucide then
        return nil
    end
    
    local assetId = Pulse.LucideIcons.Map[iconName]
    if assetId then
        return "rbxassetid://" .. assetId
    end
    return nil
end

local function Create(className, props)
    local obj = Instance.new(className)
    for prop, val in pairs(props) do
        if prop == "Parent" then
            obj.Parent = val
        else
            if pcall(function() return obj[prop] end) then
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

local function AddStroke(obj, color, thickness)
    local stroke = Create("UIStroke", {
        Color = color or Pulse.Colors.Stroke,
        Thickness = thickness or 1.5,
        Transparency = 0.3,
        Parent = obj
    })
    return stroke
end

local function CreateGlowEffect(parent, color, intensity)
    if not Pulse.Config.GlowEffect then return nil end
    
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
            glow.ImageTransparency = 0.9 - (intensity * pulse * 0.3)
        end)
        table.insert(Pulse.Connections, connection)
    end
    
    return glow, connection
end

local function CreatePulseIndicator(parent, position)
    if not Pulse.Config.ShowInteractiveIndicators then return nil end
    
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
    if not indicator or not indicator.Parent then return end
    
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

function Pulse:CreateTooltip(parent, options)
    options = options or {}
    
    local tooltip = Create("Frame", {
        Name = "PulseTooltip",
        Size = UDim2.new(0, 200, 0, 80),
        BackgroundColor3 = Pulse.Config.MainColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 1000,
        Parent = CoreGui
    })
    
    Roundify(tooltip, 8)
    AddStroke(tooltip, Pulse.Config.AccentColor, 1.5)
    
    local glow = CreateGlowEffect(tooltip, Pulse.Config.AccentColor, 0.3)
    
    local contentFrame = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Parent = tooltip
    })
    
    local englishText = Create("TextLabel", {
        Name = "EnglishText",
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = options.English or "Tooltip",
        TextColor3 = Pulse.Config.TextColor,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame
    })
    
    local divider = Create("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Pulse.Config.AccentColor,
        BackgroundTransparency = 0.5,
        Parent = contentFrame
    })
    
    local chineseText = Create("TextLabel", {
        Name = "ChineseText",
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundTransparency = 1,
        Text = options.Chinese or "提示",
        TextColor3 = Pulse.Config.SubTextColor,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = contentFrame
    })
    
    tooltip.Visible = false
    
    local connection1, connection2
    
    if parent then
        connection1 = parent.MouseEnter:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            tooltip.Position = UDim2.new(0, mouse.X + 10, 0, mouse.Y + 10)
            tooltip.Visible = true
            
            TweenService:Create(tooltip, TweenInfo.new(0.2), {
                BackgroundTransparency = Pulse.Config.TransparencyLevel
            }):Play()
        end)
        
        connection2 = parent.MouseLeave:Connect(function()
            TweenService:Create(tooltip, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            
            task.wait(0.2)
            tooltip.Visible = false
        end)
        
        table.insert(Pulse.Connections, connection1)
        table.insert(Pulse.Connections, connection2)
    end
    
    local tooltipObj = {
        Frame = tooltip,
        Show = function(pos)
            tooltip.Position = UDim2.new(0, pos.X, 0, pos.Y)
            tooltip.Visible = true
            TweenService:Create(tooltip, TweenInfo.new(0.2), {
                BackgroundTransparency = Pulse.Config.TransparencyLevel
            }):Play()
        end,
        Hide = function()
            TweenService:Create(tooltip, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.2)
            tooltip.Visible = false
        end
    }
    
    table.insert(Pulse.Tooltips, tooltipObj)
    return tooltipObj
end

function Pulse:PulseNotify(options)
    local title = options.Title or "Pulse Notification"
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
        Image = Pulse:GetLucideIcon("alertCircle") or "rbxassetid://10723392055",
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
    
    table.insert(Pulse.Connections, pulseConnection)
    
    task.delay(duration, function()
        pulseConnection:Disconnect()
        if glowConn then glowConn:Disconnect() end
        
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

-- 修复的HSV转RGB函数
local function hsvToRgb(h, s, v)
    local r, g, b
    
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q end
    
    return Color3.fromRGB(math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

function Pulse:CreateButton(parent, options)
    options = options or {}
    
    local buttonFrame = Create("TextButton", {
        Name = options.Name or "PulseButton",
        Size = options.Size or UDim2.new(0, 150, 0, 40),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Pulse.Config.AccentColor,
        BackgroundTransparency = 0.2,
        Text = options.Text or "Button",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = parent
    })
    
    Roundify(buttonFrame, 8)
    AddStroke(buttonFrame, Pulse.Config.AccentColor, 1.5)
    
    if options.Icon then
        buttonFrame.Text = "   " .. buttonFrame.Text
        local icon = Create("ImageLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            BackgroundTransparency = 1,
            Image = Pulse:GetLucideIcon(options.Icon) or "rbxassetid://10723392055",
            ImageColor3 = Color3.new(1, 1, 1),
            Parent = buttonFrame
        })
    end
    
    local indicator = CreatePulseIndicator(buttonFrame, UDim2.new(0.5, 0, 1, -2))
    
    local clickEffect = Create("Frame", {
        Name = "ClickEffect",
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.8,
        ZIndex = -1,
        Parent = buttonFrame
    })
    Roundify(clickEffect, 100)
    
    buttonFrame.MouseEnter:Connect(function()
        TweenService:Create(buttonFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            Size = (options.Size or UDim2.new(0, 150, 0, 40)) + UDim2.new(0, 4, 0, 4)
        }):Play()
    end)
    
    buttonFrame.MouseLeave:Connect(function()
        TweenService:Create(buttonFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2,
            Size = options.Size or UDim2.new(0, 150, 0, 40)
        }):Play()
    end)
    
    buttonFrame.MouseButton1Down:Connect(function()
        PlayPulseAnimation(indicator)
        
        clickEffect.Size = UDim2.new(0, 0, 0, 0)
        clickEffect.Position = UDim2.new(0.5, 0, 0.5, 0)
        clickEffect.BackgroundTransparency = 0.8
        
        TweenService:Create(clickEffect, TweenInfo.new(0.3), {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(buttonFrame, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
    
    buttonFrame.MouseButton1Up:Connect(function()
        TweenService:Create(buttonFrame, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2
        }):Play()
        
        if options.OnClick then
            options.OnClick()
        end
    end)
    
    local buttonObj = {
        Frame = buttonFrame,
        SetText = function(text)
            buttonFrame.Text = text
        end,
        SetColor = function(color)
            buttonFrame.BackgroundColor3 = color
        end
    }
    
    return buttonObj
end

function Pulse:CreateToggle(parent, options)
    options = options or {}
    
    local toggleFrame = Create("Frame", {
        Name = options.Name or "PulseToggle",
        Size = options.Size or UDim2.new(0, 120, 0, 40),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Label or "Toggle",
        TextColor3 = Pulse.Config.TextColor,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame
    })
    
    local toggleButton = Create("Frame", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 50, 0, 25),
        Position = UDim2.new(1, -50, 0.5, -12.5),
        BackgroundColor3 = Pulse.Config.SecondaryColor,
        Parent = toggleFrame
    })
    
    Roundify(toggleButton, 12.5)
    AddStroke(toggleButton, Pulse.Colors.Stroke, 1)
    
    local toggleKnob = Create("Frame", {
        Name = "ToggleKnob",
        Size = UDim2.new(0, 21, 0, 21),
        Position = UDim2.new(0, 2, 0.5, -10.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = toggleButton
    })
    
    Roundify(toggleKnob, 10.5)
    
    local indicator = CreatePulseIndicator(toggleButton, UDim2.new(0.5, 0, 1, -1))
    
    local isToggled = options.Default or false
    
    local function updateToggle()
        if isToggled then
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Pulse.Config.AccentColor
            }):Play()
            
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -23, 0.5, -10.5)
            }):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Pulse.Config.SecondaryColor
            }):Play()
            
            TweenService:Create(toggleKnob, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -10.5)
            }):Play()
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        PlayPulseAnimation(indicator)
        isToggled = not isToggled
        updateToggle()
        
        if options.OnToggle then
            options.OnToggle(isToggled)
        end
    end)
    
    updateToggle()
    
    local toggleObj = {
        Frame = toggleFrame,
        IsToggled = isToggled,
        SetState = function(state)
            isToggled = state
            updateToggle()
        end,
        Toggle = function()
            isToggled = not isToggled
            updateToggle()
        end
    }
    
    return toggleObj
end

function Pulse:CreateSlider(parent, options)
    options = options or {}
    
    local sliderFrame = Create("Frame", {
        Name = options.Name or "PulseSlider",
        Size = options.Size or UDim2.new(0, 200, 0, 50),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Label or "Slider",
        TextColor3 = Pulse.Config.TextColor,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sliderFrame
    })
    
    local valueLabel = Create("TextLabel", {
        Name = "ValueLabel",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(options.Default or 50),
        TextColor3 = Pulse.Config.AccentColor,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = sliderFrame
    })
    
    local sliderBar = Create("Frame", {
        Name = "SliderBar",
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Pulse.Config.SecondaryColor,
        Parent = sliderFrame
    })
    
    Roundify(sliderBar, 3)
    AddStroke(sliderBar, Pulse.Colors.Stroke, 1)
    
    local sliderFill = Create("Frame", {
        Name = "SliderFill",
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = Pulse.Config.AccentColor,
        Parent = sliderBar
    })
    
    Roundify(sliderFill, 3)
    
    local sliderHandle = Create("Frame", {
        Name = "SliderHandle",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0.5, -8, 0.5, -8),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = sliderBar
    })
    
    Roundify(sliderHandle, 8)
    AddStroke(sliderHandle, Pulse.Config.AccentColor, 2)
    
    local currentValue = options.Default or 50
    local minValue = options.Min or 0
    local maxValue = options.Max or 100
    
    local function updateSlider(value)
        currentValue = math.clamp(value, minValue, maxValue)
        local percentage = (currentValue - minValue) / (maxValue - minValue)
        
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderHandle.Position = UDim2.new(percentage, -8, 0.5, -8)
        valueLabel.Text = tostring(math.floor(currentValue))
        
        if options.OnChange then
            options.OnChange(currentValue)
        end
    end
    
    local isDragging = false
    
    local function startDrag()
        isDragging = true
        
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not isDragging then
                connection:Disconnect()
                return
            end
            
            local mouse = UserInputService:GetMouseLocation()
            local barPos = sliderBar.AbsolutePosition
            local barSize = sliderBar.AbsoluteSize
            
            local relativeX = math.clamp((mouse.X - barPos.X) / barSize.X, 0, 1)
            local value = minValue + relativeX * (maxValue - minValue)
            
            updateSlider(value)
        end)
        
        local release
        release = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
                connection:Disconnect()
                release:Disconnect()
            end
        end)
    end
    
    sliderBar.MouseButton1Down:Connect(startDrag)
    sliderHandle.MouseButton1Down:Connect(startDrag)
    
    updateSlider(currentValue)
    
    local sliderObj = {
        Frame = sliderFrame,
        Value = currentValue,
        SetValue = function(value)
            updateSlider(value)
        end
    }
    
    return sliderObj
end

function Pulse:CreateDropdown(parent, options)
    options = options or {}
    
    local dropdownFrame = Create("Frame", {
        Name = options.Name or "PulseDropdown",
        Size = options.Size or UDim2.new(0, 180, 0, 40),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Pulse.Config.SecondaryColor,
        BackgroundTransparency = 0.1,
        Parent = parent
    })
    
    Roundify(dropdownFrame, 8)
    AddStroke(dropdownFrame, Pulse.Colors.Stroke, 1)
    
    local label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.7, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Label or "Select Option",
        TextColor3 = Pulse.Config.TextColor,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownFrame
    })
    
    local arrowIcon = Create("ImageLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0.5, -10),
        BackgroundTransparency = 1,
        Image = Pulse:GetLucideIcon("chevronDown"),
        ImageColor3 = Pulse.Config.AccentColor,
        Rotation = 0,
        Parent = dropdownFrame
    })
    
    local dropdownList = Create("Frame", {
        Name = "DropdownList",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        BackgroundColor3 = Pulse.Config.MainColor,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false,
        Parent = dropdownFrame
    })
    
    Roundify(dropdownList, 8)
    AddStroke(dropdownList, Pulse.Colors.Stroke, 1)
    
    local listLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = dropdownList
    })
    
    local items = options.Items or {"Option 1", "Option 2", "Option 3"}
    local selectedItem = items[1]
    local isOpen = false
    
    local function updateDropdown()
        label.Text = selectedItem
    end
    
    local function toggleDropdown()
        isOpen = not isOpen
        
        if isOpen then
            dropdownList.Visible = true
            TweenService:Create(dropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = Pulse.Config.TransparencyLevel,
                Size = UDim2.new(1, 0, 0, #items * 35)
            }):Play()
            
            TweenService:Create(arrowIcon, TweenInfo.new(0.3), {
                Rotation = 180
            }):Play()
        else
            TweenService:Create(dropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()
            
            TweenService:Create(arrowIcon, TweenInfo.new(0.3), {
                Rotation = 0
            }):Play()
            
            task.wait(0.3)
            dropdownList.Visible = false
        end
    end
    
    for i, item in ipairs(items) do
        local itemButton = Create("TextButton", {
            Name = "Item" .. i,
            Size = UDim2.new(1, -10, 0, 35),
            Position = UDim2.new(0, 5, 0, (i-1)*35),
            BackgroundColor3 = Pulse.Config.SecondaryColor,
            BackgroundTransparency = 0.2,
            Text = item,
            TextColor3 = Pulse.Config.TextColor,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = dropdownList
        })
        
        Roundify(itemButton, 6)
        
        local indicator = CreatePulseIndicator(itemButton, UDim2.new(0.5, 0, 1, -2))
        
        itemButton.MouseEnter:Connect(function()
            TweenService:Create(itemButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        itemButton.MouseLeave:Connect(function()
            TweenService:Create(itemButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        itemButton.MouseButton1Click:Connect(function()
            PlayPulseAnimation(indicator)
            selectedItem = item
            updateDropdown()
            toggleDropdown()
            
            if options.OnSelect then
                options.OnSelect(item, i)
            end
        end)
    end
    
    updateDropdown()
    
    local indicator = CreatePulseIndicator(dropdownFrame, UDim2.new(0.5, 0, 1, -2))
    
    dropdownFrame.MouseButton1Click:Connect(function()
        PlayPulseAnimation(indicator)
        toggleDropdown()
    end)
    
    local dropdownObj = {
        Frame = dropdownFrame,
        SelectedItem = selectedItem,
        Items = items,
        Open = function()
            if not isOpen then toggleDropdown() end
        end,
        Close = function()
            if isOpen then toggleDropdown() end
        end,
        SetItems = function(newItems)
            items = newItems
            selectedItem = items[1]
            updateDropdown()
        end
    }
    
    return dropdownObj
end

function Pulse:CreateColorPicker(parent, options)
    options = options or {}
    
    local colorPickerFrame = Create("Frame", {
        Name = options.Name or "PulseColorPicker",
        Size = options.Size or UDim2.new(0, 200, 0, 150),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Pulse.Config.MainColor,
        BackgroundTransparency = Pulse.Config.TransparencyLevel,
        Parent = parent
    })
    
    Roundify(colorPickerFrame, 10)
    AddStroke(colorPickerFrame, Pulse.Colors.Stroke, 1)
    
    local previewColor = Create("Frame", {
        Name = "ColorPreview",
        Size = UDim2.new(0, 180, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = options.DefaultColor or Pulse.Config.AccentColor,
        Parent = colorPickerFrame
    })
    
    Roundify(previewColor, 8)
    AddStroke(previewColor, Pulse.Colors.Stroke, 2)
    
    local currentColor = options.DefaultColor or Pulse.Config.AccentColor
    
    local hueSlider = Create("Frame", {
        Name = "HueSlider",
        Size = UDim2.new(0, 180, 0, 20),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        Parent = colorPickerFrame
    })
    
    Roundify(hueSlider, 4)
    
    local hueGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }),
        Parent = hueSlider
    })
    
    local hueHandle = Create("Frame", {
        Name = "HueHandle",
        Size = UDim2.new(0, 8, 0, 24),
        Position = UDim2.new(0, 86, 0, -2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = hueSlider
    })
    
    Roundify(hueHandle, 2)
    
    local rgbSliders = Create("Frame", {
        Name = "RGBSliders",
        Size = UDim2.new(0, 180, 0, 60),
        Position = UDim2.new(0, 10, 0, 85),
        BackgroundTransparency = 1,
        Parent = colorPickerFrame
    })
    
    local rSlider = Create("Frame", {
        Name = "RSlider",
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = rgbSliders
    })
    
    local rTrack = Create("Frame", {
        Name = "RTrack",
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0.5, -3),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        Parent = rSlider
    })
    
    Roundify(rTrack, 3)
    
    local rHandle = Create("Frame", {
        Name = "RHandle",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(currentColor.R, -6, 0.5, -6),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = rSlider
    })
    
    Roundify(rHandle, 6)
    
    local rValue = Create("TextLabel", {
        Name = "RValue",
        Size = UDim2.new(0, 30, 0, 18),
        Position = UDim2.new(1, -35, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(math.floor(currentColor.R * 255)),
        TextColor3 = Color3.fromRGB(255, 100, 100),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = rSlider
    })
    
    local gSlider = Create("Frame", {
        Name = "GSlider",
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 21),
        BackgroundTransparency = 1,
        Parent = rgbSliders
    })
    
    local gTrack = Create("Frame", {
        Name = "GTrack",
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0.5, -3),
        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
        Parent = gSlider
    })
    
    Roundify(gTrack, 3)
    
    local gHandle = Create("Frame", {
        Name = "GHandle",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(currentColor.G, -6, 0.5, -6),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = gSlider
    })
    
    Roundify(gHandle, 6)
    
    local gValue = Create("TextLabel", {
        Name = "GValue",
        Size = UDim2.new(0, 30, 0, 18),
        Position = UDim2.new(1, -35, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(math.floor(currentColor.G * 255)),
        TextColor3 = Color3.fromRGB(100, 255, 100),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = gSlider
    })
    
    local bSlider = Create("Frame", {
        Name = "BSlider",
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = rgbSliders
    })
    
    local bTrack = Create("Frame", {
        Name = "BTrack",
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0.5, -3),
        BackgroundColor3 = Color3.fromRGB(0, 0, 255),
        Parent = bSlider
    })
    
    Roundify(bTrack, 3)
    
    local bHandle = Create("Frame", {
        Name = "BHandle",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(currentColor.B, -6, 0.5, -6),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = bSlider
    })
    
    Roundify(bHandle, 6)
    
    local bValue = Create("TextLabel", {
        Name = "BValue",
        Size = UDim2.new(0, 30, 0, 18),
        Position = UDim2.new(1, -35, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(math.floor(currentColor.B * 255)),
        TextColor3 = Color3.fromRGB(100, 100, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = bSlider
    })
    
    local function updateColor(r, g, b)
        currentColor = Color3.fromRGB(r, g, b)
        
        TweenService:Create(previewColor, TweenInfo.new(0.2), {
            BackgroundColor3 = currentColor
        }):Play()
        
        rValue.Text = tostring(r)
        gValue.Text = tostring(g)
        bValue.Text = tostring(b)
        
        if options.OnColorChange then
            options.OnColorChange(currentColor)
        end
    end
    
    local function setupSlider(slider, handle, valueLabel, colorComponent, updateFunc)
        slider.MouseButton1Down:Connect(function()
            local connection
            connection = RunService.Heartbeat:Connect(function()
                local mouse = UserInputService:GetMouseLocation()
                local sliderPos = slider.AbsolutePosition
                local sliderSize = slider.AbsoluteSize
                
                local relativeX = math.clamp((mouse.X - sliderPos.X) / sliderSize.X, 0, 1)
                local value = math.floor(relativeX * 255)
                handle.Position = UDim2.new(relativeX, -6, 0.5, -6)
                valueLabel.Text = tostring(value)
                updateFunc(value)
            end)
            
            local release
            release = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                    release:Disconnect()
                end
            end)
        end)
    end
    
    setupSlider(rSlider, rHandle, rValue, "R", function(value)
        updateColor(value, math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
    end)
    
    setupSlider(gSlider, gHandle, gValue, "G", function(value)
        updateColor(math.floor(currentColor.R * 255), value, math.floor(currentColor.B * 255))
    end)
    
    setupSlider(bSlider, bHandle, bValue, "B", function(value)
        updateColor(math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), value)
    end)
    
    hueSlider.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            local sliderPos = hueSlider.AbsolutePosition
            local sliderSize = hueSlider.AbsoluteSize
            
            local relativeX = math.clamp((mouse.X - sliderPos.X) / sliderSize.X, 0, 1)
            hueHandle.Position = UDim2.new(relativeX, -4, 0, -2)
            
            -- 使用正确的HSV到RGB转换
            local hue = relativeX
            local rgbColor = hsvToRgb(hue, 1, 1)
            updateColor(
                math.floor(rgbColor.R * 255),
                math.floor(rgbColor.G * 255),
                math.floor(rgbColor.B * 255)
            )
        end)
        
        local release
        release = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                release:Disconnect()
            end
        end)
    end)
    
    local colorPickerObj = {
        Frame = colorPickerFrame,
        CurrentColor = currentColor,
        SetColor = function(color)
            currentColor = color
            previewColor.BackgroundColor3 = color
            rHandle.Position = UDim2.new(color.R, -6, 0.5, -6)
            gHandle.Position = UDim2.new(color.G, -6, 0.5, -6)
            bHandle.Position = UDim2.new(color.B, -6, 0.5, -6)
            rValue.Text = tostring(math.floor(color.R * 255))
            gValue.Text = tostring(math.floor(color.G * 255))
            bValue.Text = tostring(math.floor(color.B * 255))
        end
    }
    
    return colorPickerObj
end

function Pulse:CreateTabSystem(parent, options)
    options = options or {}
    
    local tabSystemFrame = Create("Frame", {
        Name = "TabSystem",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local tabButtonsFrame = Create("Frame", {
        Name = "TabButtons",
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundTransparency = 1,
        Parent = tabSystemFrame
    })
    
    local tabContentFrame = Create("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, -170, 1, 0),
        Position = UDim2.new(0, 170, 0, 0),
        BackgroundTransparency = 1,
        Parent = tabSystemFrame
    })
    
    local tabs = options.Tabs or {}
    local currentTab = nil
    
    local function showTab(tabName)
        if currentTab then
            currentTab.Content.Visible = false
            TweenService:Create(currentTab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.8
            }):Play()
        end
        
        for _, tab in pairs(tabs) do
            if tab.Name == tabName then
                currentTab = tab
                tab.Content.Visible = true
                TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.2
                }):Play()
                break
            end
        end
    end
    
    local tabSystemObj = {
        Frame = tabSystemFrame,
        TabButtons = tabButtonsFrame,
        TabContent = tabContentFrame,
        Tabs = tabs,
        AddTab = function(options)
            local tabOptions = options or {}
            local tabName = tabOptions.Name or "New Tab"
            
            -- 创建标签按钮
            local tabButton = Create("TextButton", {
                Name = tabName .. "TabButton",
                Size = UDim2.new(1, -10, 0, 45),
                Position = UDim2.new(0, 5, 0, #tabs * 50),
                BackgroundColor3 = Pulse.Config.SecondaryColor,
                BackgroundTransparency = 0.8,
                Text = tabName,
                TextColor3 = Pulse.Config.TextColor,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                AutoButtonColor = false,
                Parent = tabButtonsFrame
            })
            
            Roundify(tabButton, 8)
            
            if tabOptions.Icon then
                tabButton.Text = "   " .. tabButton.Text
                local icon = Create("ImageLabel", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 10, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = Pulse:GetLucideIcon(tabOptions.Icon) or "rbxassetid://10723392055",
                    ImageColor3 = Pulse.Config.TextColor,
                    Parent = tabButton
                })
            end
            
            local indicator = CreatePulseIndicator(tabButton, UDim2.new(0.5, 0, 1, -2))
            
            -- 创建标签内容
            local tabContent = Create("Frame", {
                Name = tabName .. "Content",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Visible = false,
                Parent = tabContentFrame
            })
            
            tabButton.MouseButton1Click:Connect(function()
                PlayPulseAnimation(indicator)
                showTab(tabName)
            end)
            
            local tabObj = {
                Name = tabName,
                Button = tabButton,
                Content = tabContent,
                Show = function()
                    showTab(tabName)
                end
            }
            
            table.insert(tabs, tabObj)
            
            -- 如果是第一个标签，设置为当前标签
            if #tabs == 1 then
                showTab(tabName)
            end
            
            return tabObj
        end,
        ShowTab = function(tabName)
            showTab(tabName)
        end
    }
    
    return tabSystemObj
end

function Pulse:CreateLabel(parent, options)
    options = options or {}
    
    local labelFrame = Create("TextLabel", {
        Name = options.Name or "PulseLabel",
        Size = options.Size or UDim2.new(0, 200, 0, 30),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Text or "Label",
        TextColor3 = options.TextColor or Pulse.Config.TextColor,
        Font = options.Font or Enum.Font.Gotham,
        TextSize = options.TextSize or 14,
        TextXAlignment = options.Alignment or Enum.TextXAlignment.Left,
        Parent = parent
    })
    
    local labelObj = {
        Frame = labelFrame,
        SetText = function(text)
            labelFrame.Text = text
        end,
        SetColor = function(color)
            labelFrame.TextColor3 = color
        end
    }
    
    return labelObj
end

function Pulse:CreateTextBox(parent, options)
    options = options or {}
    
    local textBoxFrame = Create("Frame", {
        Name = options.Name or "PulseTextBox",
        Size = options.Size or UDim2.new(0, 200, 0, 40),
        Position = options.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Pulse.Config.SecondaryColor,
        BackgroundTransparency = 0.1,
        Parent = parent
    })
    
    Roundify(textBoxFrame, 8)
    AddStroke(textBoxFrame, Pulse.Colors.Stroke, 1)
    
    local textBox = Create("TextBox", {
        Name = "TextBox",
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Placeholder or "",
        PlaceholderText = options.Placeholder or "Enter text...",
        TextColor3 = Pulse.Config.TextColor,
        PlaceholderColor3 = Pulse.Config.SubTextColor,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = options.ClearTextOnFocus or false,
        Parent = textBoxFrame
    })
    
    if options.DefaultText then
        textBox.Text = options.DefaultText
    end
    
    local indicator = CreatePulseIndicator(textBoxFrame, UDim2.new(0.5, 0, 1, -2))
    
    textBox.Focused:Connect(function()
        PlayPulseAnimation(indicator)
        TweenService:Create(textBoxFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Pulse.Config.AccentColor,
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    textBox.FocusLost:Connect(function()
        TweenService:Create(textBoxFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Pulse.Config.SecondaryColor,
            BackgroundTransparency = 0.1
        }):Play()
        
        if options.OnTextChange then
            options.OnTextChange(textBox.Text)
        end
    end)
    
    local textBoxObj = {
        Frame = textBoxFrame,
        TextBox = textBox,
        GetText = function()
            return textBox.Text
        end,
        SetText = function(text)
            textBox.Text = text
        end
    }
    
    return textBoxObj
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
        Position = UDim2.new(0.5, -Pulse.Config.WindowSize.X/2, 0.5, -Pulse.Config.WindowSize.Y/2),
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
    
    Roundify(titleBar, {TopLeft = true, TopRight = true})
    AddStroke(titleBar, Pulse.Colors.Stroke, 1)
    
    local pulseIcon = Create("ImageLabel", {
        Name = "PulseIcon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 12, 0.5, -18),
        Image = Pulse:GetLucideIcon("zap") or "rbxassetid://10723392055",
        ImageColor3 = Pulse.Config.AccentColor,
        Parent = titleBar
    })
    
    local pulseTime = 0
    local pulseConnection = RunService.Heartbeat:Connect(function(delta)
        pulseTime = pulseTime + delta
        local pulse = math.sin(pulseTime * 1.5) * 0.1 + 0.9
        pulseIcon.Size = UDim2.new(0, 36 * pulse, 0, 36 * pulse)
        pulseIcon.Position = UDim2.new(0, 12 + (36 - 36 * pulse)/2, 0.5, -18 * pulse)
    end)
    table.insert(Pulse.Connections, pulseConnection)
    
    local titleLabel = Create("TextLabel", {
        Name = "UITitle",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 180, 0, 28),
        Position = UDim2.new(0, 55, 0, 10),
        Text = options.Title or "Pulse UI v2.1",
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
        Text = options.SubTitle or "With Lucide Icons",
        TextColor3 = Pulse.Config.SubTextColor,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    local closeButton = Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        BackgroundColor3 = Pulse.Colors.Red,
        BackgroundTransparency = 0.8,
        Text = "",
        Parent = titleBar
    })
    
    Roundify(closeButton, 15)
    AddStroke(closeButton, Pulse.Colors.Red, 1)
    
    local closeIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0.5, -10, 0.5, -10),
        BackgroundTransparency = 1,
        Image = Pulse:GetLucideIcon("x") or "rbxassetid://10723392055",
        ImageColor3 = Color3.new(1, 1, 1),
        Parent = closeButton
    })
    
    closeButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        task.wait(0.3)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, Pulse.Config.WindowSize.X, 0, Pulse.Config.WindowSize.Y)
    end)
    
    local minimizeButton = Create("TextButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -80, 0.5, -15),
        BackgroundColor3 = Pulse.Colors.Warning,
        BackgroundTransparency = 0.8,
        Text = "",
        Parent = titleBar
    })
    
    Roundify(minimizeButton, 15)
    AddStroke(minimizeButton, Pulse.Colors.Warning, 1)
    
    local minimizeIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0.5, -10, 0.5, -10),
        BackgroundTransparency = 1,
        Image = Pulse:GetLucideIcon("minimize") or "rbxassetid://10723392055",
        ImageColor3 = Color3.new(1, 1, 1),
        Parent = minimizeButton
    })
    
    local isMinimized = false
    
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        if isMinimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, Pulse.Config.WindowSize.X, 0, 65)
            }):Play()
            minimizeIcon.Image = Pulse:GetLucideIcon("maximize") or "rbxassetid://10723392055"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, Pulse.Config.WindowSize.X, 0, Pulse.Config.WindowSize.Y)
            }):Play()
            minimizeIcon.Image = Pulse:GetLucideIcon("minimize") or "rbxassetid://10723392055"
        end
    end)
    
    local contentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -85),
        Position = UDim2.new(0, 10, 0, 75),
        Parent = MainFrame
    })
    
    local Window = {
        MainFrame = MainFrame,
        ScreenGui = ScreenGui,
        TitleBar = titleBar,
        ContentArea = contentArea,
        Title = titleLabel,
        Subtitle = subtitleLabel,
        Close = function()
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.wait(0.3)
            MainFrame.Visible = false
        end,
        Show = function()
            MainFrame.Visible = true
            MainFrame.BackgroundTransparency = 1
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            
            TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                BackgroundTransparency = Pulse.Config.TransparencyLevel,
                Size = UDim2.new(0, Pulse.Config.WindowSize.X, 0, Pulse.Config.WindowSize.Y)
            }):Play()
        end,
        Hide = function()
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.wait(0.3)
            MainFrame.Visible = false
        end,
        Toggle = function()
            if MainFrame.Visible then
                Window:Hide()
            else
                Window:Show()
            end
        end,
        Minimize = function()
            minimizeButton.MouseButton1Click:Fire()
        end
    }
    
    table.insert(Pulse.Windows, Window)
    
    if Pulse.Config.AutoShow then
        task.wait(0.3)
        self:PulseNotify({
            Title = "Pulse UI Activated",
            Content = "Interface loaded successfully. Press RightControl to toggle.",
            Type = "success",
            Duration = 3
        })
    end
    
    return Window
end

function Pulse:CreateExampleUI()
    local window = self:CreateWindow({
        Title = "Pulse UI Demo",
        SubTitle = "Complete UI Component Showcase"
    })
    
    local tabSystem = self:CreateTabSystem(window.ContentArea)
    
    -- Tab 1: Controls
    local controlsTab = tabSystem:AddTab({
        Name = "Controls",
        Icon = "settings"
    })
    
    -- 创建容器用于滚动
    local controlsContainer = Create("ScrollingFrame", {
        Name = "ControlsContainer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5,
        CanvasSize = UDim2.new(0, 0, 0, 800),
        Parent = controlsTab.Content
    })
    
    local layout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 15),
        Parent = controlsContainer
    })
    
    -- Buttons Section
    local buttonsLabel = self:CreateLabel(controlsContainer, {
        Text = "Buttons",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    local buttonRow1 = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = controlsContainer
    })
    
    local button1 = self:CreateButton(buttonRow1, {
        Position = UDim2.new(0, 0, 0, 0),
        Text = "Primary Button",
        Icon = "zap",
        OnClick = function()
            self:PulseNotify({
                Title = "Button Clicked",
                Content = "Primary button was clicked!",
                Type = "success"
            })
        end
    })
    
    local button2 = self:CreateButton(buttonRow1, {
        Position = UDim2.new(0, 160, 0, 0),
        Text = "Secondary",
        Icon = "star",
        OnClick = function()
            button2:SetColor(Pulse.Colors.Green)
        end
    })
    
    local button3 = self:CreateButton(buttonRow1, {
        Position = UDim2.new(0, 320, 0, 0),
        Text = "Warning",
        Icon = "alertTriangle",
        OnClick = function()
            button3:SetColor(Pulse.Colors.Warning)
        end
    })
    
    -- Toggles Section
    local togglesLabel = self:CreateLabel(controlsContainer, {
        Text = "Toggle Switches",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = 2
    })
    
    local toggle1 = self:CreateToggle(controlsContainer, {
        Position = UDim2.new(0, 0, 0, 0),
        Label = "Enable Feature",
        Default = true,
        LayoutOrder = 3,
        OnToggle = function(state)
            self:PulseNotify({
                Title = "Toggle State",
                Content = "Feature is " .. (state and "enabled" or "disabled"),
                Type = "info"
            })
        end
    })
    
    local toggle2 = self:CreateToggle(controlsContainer, {
        Position = UDim2.new(0, 200, 0, 0),
        Label = "Dark Mode",
        Default = false,
        LayoutOrder = 4,
        OnToggle = function(state)
            self:PulseNotify({
                Title = "Theme Changed",
                Content = "Dark mode " .. (state and "enabled" or "disabled"),
                Type = "info"
            })
        end
    })
    
    -- Sliders Section
    local slidersLabel = self:CreateLabel(controlsContainer, {
        Text = "Sliders",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = 5
    })
    
    local slider1 = self:CreateSlider(controlsContainer, {
        Position = UDim2.new(0, 0, 0, 0),
        Label = "Volume Level",
        Default = 75,
        Min = 0,
        Max = 100,
        LayoutOrder = 6,
        OnChange = function(value)
            -- Volume change logic
        end
    })
    
    local slider2 = self:CreateSlider(controlsContainer, {
        Position = UDim2.new(0, 0, 0, 0),
        Label = "Brightness",
        Default = 50,
        Min = 0,
        Max = 100,
        LayoutOrder = 7,
        OnChange = function(value)
            -- Brightness change logic
        end
    })
    
    -- Dropdowns Section
    local dropdownsLabel = self:CreateLabel(controlsContainer, {
        Text = "Dropdowns",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = 8
    })
    
    local dropdownRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder = 9,
        Parent = controlsContainer
    })
    
    local dropdown1 = self:CreateDropdown(dropdownRow, {
        Position = UDim2.new(0, 0, 0, 0),
        Label = "Select Option",
        Items = {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5"},
        OnSelect = function(item, index)
            self:PulseNotify({
                Title = "Dropdown Selected",
                Content = "Selected: " .. item,
                Type = "info"
            })
        end
    })
    
    local dropdown2 = self:CreateDropdown(dropdownRow, {
        Position = UDim2.new(0, 190, 0, 0),
        Label = "Theme Color",
        Items = {"Blue", "Red", "Green", "Purple", "Orange"},
        OnSelect = function(item, index)
            self:PulseNotify({
                Title = "Theme Changed",
                Content = "Changed to " .. item .. " theme",
                Type = "success"
            })
        end
    })
    
    -- Text Input Section
    local textInputLabel = self:CreateLabel(controlsContainer, {
        Text = "Text Input",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = 10
    })
    
    local textBox1 = self:CreateTextBox(controlsContainer, {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0.5, -10, 0, 40),
        Placeholder = "Enter your name...",
        LayoutOrder = 11,
        OnTextChange = function(text)
            -- Text change logic
        end
    })
    
    -- Color Picker Section
    local colorPickerLabel = self:CreateLabel(controlsContainer, {
        Text = "Color Picker",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = 12
    })
    
    local colorPicker = self:CreateColorPicker(controlsContainer, {
        Position = UDim2.new(0, 0, 0, 0),
        LayoutOrder = 13,
        OnColorChange = function(color)
            self:PulseNotify({
                Title = "Color Selected",
                Content = "RGB: " .. math.floor(color.R * 255) .. ", " .. math.floor(color.G * 255) .. ", " .. math.floor(color.B * 255),
                Type = "info"
            })
        end
    })
    
    -- Tab 2: Info
    local infoTab = tabSystem:AddTab({
        Name = "Information",
        Icon = "info"
    })
    
    local infoContainer = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5,
        CanvasSize = UDim2.new(0, 0, 0, 400),
        Parent = infoTab.Content
    })
    
    local infoLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 20),
        Parent = infoContainer
    })
    
    local welcomeLabel = self:CreateLabel(infoContainer, {
        Text = "Welcome to Pulse UI",
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 40),
        Alignment = Enum.TextXAlignment.Center
    })
    
    local description = self:CreateLabel(infoContainer, {
        Text = "A modern, customizable UI library for Roblox with Lucide icons, glow effects, and smooth animations.",
        TextSize = 14,
        Font = Enum.Font.Gotham,
        Size = UDim2.new(1, -40, 0, 60),
        Position = UDim2.new(0, 20, 0, 0),
        TextColor3 = Pulse.Config.SubTextColor
    })
    
    local featuresLabel = self:CreateLabel(infoContainer, {
        Text = "Features:",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    local features = {
        "• Modern, sleek design",
        "• Lucide icons integration",
        "• Glow effects and animations",
        "• Pulse indicators for interaction",
        "• Color picker with HSV support",
        "• Tab system for organization",
        "• Notification system",
        "• Tooltips with dual language support",
        "• Customizable themes and colors"
    }
    
    for i, feature in ipairs(features) do
        self:CreateLabel(infoContainer, {
            Text = feature,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 20, 0, 0),
            TextColor3 = Pulse.Config.SubTextColor
        })
    end
    
    -- Tab 3: Settings
    local settingsTab = tabSystem:AddTab({
        Name = "Settings",
        Icon = "settings"
    })
    
    local settingsContainer = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5,
        CanvasSize = UDim2.new(0, 0, 0, 300),
        Parent = settingsTab.Content
    })
    
    local settingsLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 15),
        Parent = settingsContainer
    })
    
    local settingsLabel = self:CreateLabel(settingsContainer, {
        Text = "UI Settings",
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 40),
        Alignment = Enum.TextXAlignment.Center
    })
    
    local setting1 = self:CreateToggle(settingsContainer, {
        Label = "Enable Glow Effects",
        Default = Pulse.Config.GlowEffect,
        OnToggle = function(state)
            Pulse.Config.GlowEffect = state
            self:PulseNotify({
                Title = "Glow Effects",
                Content = state and "Enabled" or "Disabled",
                Type = "info"
            })
        end
    })
    
    local setting2 = self:CreateToggle(settingsContainer, {
        Label = "Show Pulse Indicators",
        Default = Pulse.Config.ShowInteractiveIndicators,
        OnToggle = function(state)
            Pulse.Config.ShowInteractiveIndicators = state
            self:PulseNotify({
                Title = "Pulse Indicators",
                Content = state and "Enabled" or "Disabled",
                Type = "info"
            })
        end
    })
    
    local setting3 = self:CreateToggle(settingsContainer, {
        Label = "Enable Click Animations",
        Default = Pulse.Config.ShowClickAnimation,
        OnToggle = function(state)
            Pulse.Config.ShowClickAnimation = state
            self:PulseNotify({
                Title = "Click Animations",
                Content = state and "Enabled" or "Disabled",
                Type = "info"
            })
        end
    })
    
    local setting4 = self:CreateToggle(settingsContainer, {
        Label = "Use Lucide Icons",
        Default = Pulse.Config.EnableLucide,
        OnToggle = function(state)
            Pulse.Config.EnableLucide = state
            self:PulseNotify({
                Title = "Lucide Icons",
                Content = state and "Enabled" or "Disabled",
                Type = "info"
            })
        end
    })
    
    -- Apply custom styles
    layout.Changed:Connect(function()
        controlsContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    infoLayout.Changed:Connect(function()
        infoContainer.CanvasSize = UDim2.new(0, 0, 0, infoLayout.AbsoluteContentSize.Y + 20)
    end)
    
    settingsLayout.Changed:Connect(function()
        settingsContainer.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y + 20)
    end)
    
    return window
end

function Pulse:Cleanup()
    for _, window in pairs(Pulse.Windows) do
        if window and window.ScreenGui then
            window.ScreenGui:Destroy()
        end
    end
    
    for _, conn in pairs(Pulse.Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    for _, notification in pairs(Pulse.Notifications) do
        if notification then
            pcall(function() notification:Destroy() end)
        end
    end
    
    for _, tooltip in pairs(Pulse.Tooltips) do
        if tooltip and tooltip.Frame then
            pcall(function() tooltip.Frame:Destroy() end)
        end
    end
    
    Pulse.Windows = {}
    Pulse.Connections = {}
    Pulse.Notifications = {}
    Pulse.Tooltips = {}
    Pulse.CurrentTutorial = nil
    
    self:PulseNotify({
        Title = "Pulse System Cleaned",
        Content = "All UI resources released",
        Type = "info",
        Duration = 2
    })
end

local function SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Pulse.Config.ToggleKey then
            for _, window in pairs(Pulse.Windows) do
                if window and window.MainFrame then
                    window:Toggle()
                end
            end
        end
        
        if input.KeyCode == Pulse.Config.MinimizeKey then
            for _, window in pairs(Pulse.Windows) do
                if window and window.MainFrame then
                    window:Minimize()
                end
            end
        end
    end)
end

SetupKeybinds()

return Pulse
