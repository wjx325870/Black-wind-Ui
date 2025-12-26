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
    
    if parent then
        parent.MouseEnter:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            tooltip.Position = UDim2.new(0, mouse.X + 10, 0, mouse.Y + 10)
            tooltip.Visible = true
            
            TweenService:Create(tooltip, TweenInfo.new(0.2), {
                BackgroundTransparency = Pulse.Config.TransparencyLevel
            }):Play()
        end)
        
        parent.MouseLeave:Connect(function()
            TweenService:Create(tooltip, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            
            task.wait(0.2)
            tooltip.Visible = false
        end)
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
    
    dropdownFrame.MouseButton1Click:Connect(function()
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
    
    local function updateColor(hue, r, g, b)
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
    
    local function updateFromHue(huePos)
        local hue = huePos
        local r, g, b = 255, 0, 0
        
        if hue < 0.17 then
            r = 255
            g = math.floor(hue * 6 * 255)
            b = 0
        elseif hue < 0.33 then
            r = math.floor((0.33 - hue) * 6 * 255)
            g = 255
            b = 0
        elseif hue < 0.5 then
            r = 0
            g = 255
            b = math.floor((hue - 0.33) * 6 * 255)
        elseif hue < 0.67 then
            r = 0
            g = math.floor((0.67 - hue) * 6 * 255)
            b = 255
        elseif hue < 0.83 then
            r = math.floor((hue - 0.67) * 6 * 255)
            g = 0
            b = 255
        else
            r = 255
            g = 0
            b = math.floor((1 - hue) * 6 * 255)
        end
        
        updateColor(hue, r, g, b)
    end
    
    hueSlider.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            local sliderPos = hueSlider.AbsolutePosition
            local sliderSize = hueSlider.AbsoluteSize
            
            local relativeX = math.clamp((mouse.X - sliderPos.X) / sliderSize.X, 0, 1)
            hueHandle.Position = UDim2.new(relativeX, -4, 0, -2)
            updateFromHue(relativeX)
        end)
        
        local release
        release = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                release:Disconnect()
            end
        end)
    end)
    
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
        currentColor = Color3.fromRGB(value, math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
        previewColor.BackgroundColor3 = currentColor
        if options.OnColorChange then options.OnColorChange(currentColor) end
    end)
    
    setupSlider(gSlider, gHandle, gValue, "G", function(value)
        currentColor = Color3.fromRGB(math.floor(currentColor.R * 255), value, math.floor(currentColor.B * 255))
        previewColor.BackgroundColor3 = currentColor
        if options.OnColorChange then options.OnColorChange(currentColor) end
    end)
    
    setupSlider(bSlider, bHandle, bValue, "B", function(value)
        currentColor = Color3.fromRGB(math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), value)
        previewColor.BackgroundColor3 = currentColor
        if options.OnColorChange then options.OnColorChange(currentColor) end
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
    
    local Window = {
        MainFrame = MainFrame,
        ScreenGui = ScreenGui,
        TitleBar = titleBar,
        ContentArea = contentArea,
        TabSidebar = tabSidebar,
        MainContent = mainContent
    }
    
    if Pulse.Config.AutoShow then
        task.wait(0.3)
        self:PulseNotify({
            Title = "Pulse UI Activated",
            Content = "Interface loaded successfully",
            Type = "success",
            Duration = 3
        })
    end
    
    return Window
end

function Pulse:CreateTutorial(window)
    local tutorialSteps = {
        {
            title = "Welcome to Pulse UI",
            content = "This tutorial will guide you through all features",
            target = window.TitleBar,
            position = "top"
        },
        {
            title = "Lucide Icons",
            content = "All icons are from Lucide icon set",
            target = window.TabSidebar,
            position = "left"
        },
        {
            title = "Interactive Components",
            content = "Try clicking on the interactive elements",
            target = window.MainContent,
            position = "right"
        }
    }
    
    local currentStep = 1
    local tutorialFrame = Create("Frame", {
        Name = "TutorialOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        ZIndex = 9998,
        Visible = false,
        Parent = window.ScreenGui
    })
    
    local highlightFrame = Create("Frame", {
        Name = "TutorialHighlight",
        BackgroundTransparency = 1,
        BorderColor3 = Pulse.Config.AccentColor,
        BorderSizePixel = 3,
        ZIndex = 9999,
        Parent = tutorialFrame
    })
    
    Roundify(highlightFrame, 8)
    
    local tutorialBox = Create("Frame", {
        Name = "TutorialBox",
        Size = UDim2.new(0, 300, 0, 180),
        BackgroundColor3 = Pulse.Config.MainColor,
        BackgroundTransparency = Pulse.Config.TransparencyLevel,
        ZIndex = 10000,
        Parent = tutorialFrame
    })
    
    Roundify(tutorialBox, 12)
    AddStroke(tutorialBox, Pulse.Config.AccentColor, 2)
    
    local tutorialGlow = CreateGlowEffect(tutorialBox, Pulse.Config.AccentColor, 0.5)
    
    local titleLabel = Create("TextLabel", {
        Name = "TutorialTitle",
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Pulse.Config.TextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tutorialBox
    })
    
    local contentLabel = Create("TextLabel", {
        Name = "TutorialContent",
        Size = UDim2.new(1, -40, 0, 80),
        Position = UDim2.new(0, 20, 0, 70),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Pulse.Config.SubTextColor,
        Font = Pulse.Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = tutorialBox
    })
    
    local prevButton = Create("TextButton", {
        Name = "PrevButton",
        Size = UDim2.new(0, 100, 0, 35),
        Position = UDim2.new(0, 20, 1, -45),
        BackgroundColor3 = Pulse.Config.SecondaryColor,
        BackgroundTransparency = 0.2,
        Text = "Previous",
        TextColor3 = Pulse.Config.TextColor,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Parent = tutorialBox
    })
    
    Roundify(prevButton, 6)
    
    local nextButton = Create("TextButton", {
        Name = "NextButton",
        Size = UDim2.new(0, 100, 0, 35),
        Position = UDim2.new(1, -120, 1, -45),
        BackgroundColor3 = Pulse.Config.AccentColor,
        BackgroundTransparency = 0.2,
        Text = "Next",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = tutorialBox
    })
    
    Roundify(nextButton, 6)
    
    local stepIndicator = Create("TextLabel", {
        Name = "StepIndicator",
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.new(0, 20, 1, -70),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Pulse.Config.SubTextColor,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        Parent = tutorialBox
    })
    
    local function showStep(stepIndex)
        if stepIndex < 1 or stepIndex > #tutorialSteps then
            tutorialFrame.Visible = false
            return
        end
        
        local step = tutorialSteps[stepIndex]
        currentStep = stepIndex
        
        titleLabel.Text = step.title
        contentLabel.Text = step.content
        stepIndicator.Text = "Step " .. stepIndex .. " of " .. #tutorialSteps
        
        if step.target then
            local targetPos = step.target.AbsolutePosition
            local targetSize = step.target.AbsoluteSize
            
            highlightFrame.Position = UDim2.new(0, targetPos.X, 0, targetPos.Y)
            highlightFrame.Size = UDim2.new(0, targetSize.X, 0, targetSize.Y)
            
            local tutorialPos
            if step.position == "top" then
                tutorialPos = UDim2.new(0, targetPos.X + targetSize.X/2 - 150, 0, targetPos.Y - 200)
            elseif step.position == "bottom" then
                tutorialPos = UDim2.new(0, targetPos.X + targetSize.X/2 - 150, 0, targetPos.Y + targetSize.Y + 20)
            elseif step.position == "left" then
                tutorialPos = UDim2.new(0, targetPos.X - 320, 0, targetPos.Y + targetSize.Y/2 - 90)
            else
                tutorialPos = UDim2.new(0, targetPos.X + targetSize.X + 20, 0, targetPos.Y + targetSize.Y/2 - 90)
            end
            
            tutorialBox.Position = tutorialPos
        end
        
        prevButton.Visible = stepIndex > 1
        nextButton.Text = stepIndex == #tutorialSteps and "Finish" or "Next"
        
        tutorialFrame.Visible = true
    end
    
    prevButton.MouseButton1Click:Connect(function()
        showStep(currentStep - 1)
    end)
    
    nextButton.MouseButton1Click:Connect(function()
        if currentStep == #tutorialSteps then
            tutorialFrame.Visible = false
        else
            showStep(currentStep + 1)
        end
    end)
    
    local tutorialObj = {
        Start = function()
            showStep(1)
        end,
        Next = function()
            showStep(currentStep + 1)
        end,
        Previous = function()
            showStep(currentStep - 1)
        end,
        ShowStep = function(step)
            showStep(step)
        end,
        End = function()
            tutorialFrame.Visible = false
        end
    }
    
    Pulse.CurrentTutorial = tutorialObj
    return tutorialObj
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
                    window.MainFrame.Visible = not window.MainFrame.Visible
                end
            end
        end
        
        if input.KeyCode == Pulse.Config.MinimizeKey then
            for _, window in pairs(Pulse.Windows) do
                if window and window.MainFrame then
                    local isVisible = window.MainFrame.Visible
                    if isVisible then
                        TweenService:Create(window.MainFrame, TweenInfo.new(0.3), {
                            Size = UDim2.new(0, Pulse.Config.WindowSize.X, 0, 65)
                        }):Play()
                    else
                        TweenService:Create(window.MainFrame, TweenInfo.new(0.3), {
                            Size = UDim2.new(0, Pulse.Config.WindowSize.X, 0, Pulse.Config.WindowSize.Y)
                        }):Play()
                    end
                end
            end
        end
    end)
end

SetupKeybinds()

return Pulse
