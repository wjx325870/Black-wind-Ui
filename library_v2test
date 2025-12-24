local Blackwind = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

Blackwind.Config = {
    ToggleKey = Enum.KeyCode.RightControl,
    AccentColor = Color3.fromRGB(0, 170, 255),
    BackgroundColor = Color3.fromRGB(15, 15, 15),
    MainColor = Color3.fromRGB(25, 25, 25),
    SecondaryColor = Color3.fromRGB(35, 35, 35),
    TextColor = Color3.fromRGB(240, 240, 240),
    SubTextColor = Color3.fromRGB(180, 180, 180),
    WindowSize = Vector2.new(550, 500),
    NotifyDuration = 3,
    Font = Enum.Font.Gotham,
    CornerRadius = 8,
    Version = "v2test",
    AutoShow = true,
    MinimizeKey = Enum.KeyCode.LeftControl
}

Blackwind.Colors = {
    Red = Color3.fromRGB(220, 70, 70),
    Green = Color3.fromRGB(70, 220, 70),
    Warning = Color3.fromRGB(255, 170, 0),
    Stroke = Color3.fromRGB(45, 45, 45)
}

Blackwind.Windows = {}
Blackwind.Connections = {}
Blackwind.Notifications = {}

local ScreenGui, MainFrame
local UIVisible = false
local Minimized = false
local OriginalSize = Blackwind.Config.WindowSize

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
        CornerRadius = UDim.new(0, radius or Blackwind.Config.CornerRadius),
        Parent = obj
    })
    return corner
end

local function AddStroke(obj, color, thickness)
    local stroke = Create("UIStroke", {
        Color = color or Blackwind.Colors.Stroke,
        Thickness = thickness or 1,
        Parent = obj
    })
    return stroke
end

local function MakeDraggable(frame, dragFrame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    table.insert(Blackwind.Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end))
end

function Blackwind:Notify(options)
    local title = options.Title or "通知"
    local content = options.Content or ""
    local duration = options.Duration or Blackwind.Config.NotifyDuration
    
    local notification = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 300, 0, 70),
        Position = UDim2.new(0.5, -150, 0.1, 0),
        BackgroundColor3 = Blackwind.Config.MainColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 99,
        Parent = ScreenGui
    })
    
    Roundify(notification, 8)
    AddStroke(notification)
    
    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 15, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Blackwind.Config.TextColor,
        Font = Blackwind.Config.Font,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    local contentLabel = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 15, 0, 35),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = Blackwind.Config.SubTextColor,
        Font = Blackwind.Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notification
    })
    
    TweenService:Create(notification, TweenInfo.new(0.3), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -150, 0.1, 0)
    }):Play()
    
    task.delay(duration, function()
        TweenService:Create(notification, TweenInfo.new(0.3), {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -150, 0, 0)
        }):Play()
        
        task.wait(0.3)
        notification:Destroy()
    end)
    
    table.insert(Blackwind.Notifications, notification)
    return notification
end

function Blackwind:ToggleUI()
    UIVisible = not UIVisible
    if MainFrame then
        if UIVisible then
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                BackgroundTransparency = 0
            }):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.3)
            MainFrame.Visible = false
        end
    end
end

function Blackwind:ToggleMinimize()
    if not MainFrame then return end
    
    Minimized = not Minimized
    if Minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, OriginalSize.X, 0, 40)
        }):Play()
        if MainFrame:FindFirstChild("ContentFrame") then
            MainFrame.ContentFrame.Visible = false
        end
        Blackwind:Notify({Title = "UI已最小化", Duration = 2})
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, OriginalSize.X, 0, OriginalSize.Y)
        }):Play()
        task.wait(0.3)
        if MainFrame:FindFirstChild("ContentFrame") then
            MainFrame.ContentFrame.Visible = true
        end
        Blackwind:Notify({Title = "UI已恢复", Duration = 2})
    end
end

function Blackwind:CreateWindow(options)
    options = options or {}
    
    ScreenGui = Create("ScreenGui", {
        Name = "Blackwind_" .. tick(),
        DisplayOrder = 999,
        ResetOnSpawn = false,
        Parent = CoreGui
    })
    
    MainFrame = Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Blackwind.Config.BackgroundColor,
        BackgroundTransparency = Blackwind.Config.AutoShow and 0 or 1,
        Position = UDim2.new(0.5, -OriginalSize.X/2, 0.5, -OriginalSize.Y/2),
        Size = UDim2.new(0, OriginalSize.X, 0, Blackwind.Config.AutoShow and OriginalSize.Y or 0),
        Visible = Blackwind.Config.AutoShow,
        ZIndex = 10,
        Parent = ScreenGui
    })
    
    Roundify(MainFrame, 10)
    AddStroke(MainFrame, Blackwind.Colors.Stroke, 2)
    
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = Blackwind.Config.MainColor,
        Size = UDim2.new(1, 0, 0, 60),
        Parent = MainFrame
    })
    
    Roundify(titleBar, {TopLeft = true, TopRight = true})
    
    local uiIcon = Create("ImageLabel", {
        Name = "UIIcon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 5, 0, 5),
        Image = options.Icon or "rbxassetid://7072717365",
        ImageColor3 = Blackwind.Config.AccentColor,
        Parent = titleBar
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "UITitle",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 150, 0, 25),
        Position = UDim2.new(0, 42, 0, 5),
        Text = options.Title or "Black Wind UI",
        TextColor3 = Blackwind.Config.TextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    local subtitleLabel = Create("TextLabel", {
        Name = "UISubtitle",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 42, 0, 30),
        Text = options.SubTitle or "v2test - 高级UI系统",
        TextColor3 = Blackwind.Config.SubTextColor,
        Font = Blackwind.Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    local compactTabContainer = Create("Frame", {
        Name = "CompactTabContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 130, 0, 25),
        Position = UDim2.new(1, -150, 0, 5),
        Parent = titleBar
    })
    
    local compactTabs = options.CompactTabs or {"主页", "设置"}
    local compactTabButtons = {}
    
    for i, tabName in ipairs(compactTabs) do
        local tabButton = Create("TextButton", {
            Name = "CompactTab" .. i,
            Size = UDim2.new(0, 60, 1, 0),
            Position = UDim2.new((i-1) * 0.5, 5 * (i-1), 0, 0),
            BackgroundColor3 = i == 1 and Blackwind.Config.AccentColor or Blackwind.Config.SecondaryColor,
            Text = tabName,
            TextColor3 = i == 1 and Color3.new(1,1,1) or Blackwind.Config.TextColor,
            Font = Blackwind.Config.Font,
            TextSize = 12,
            Parent = compactTabContainer
        })
        
        Roundify(tabButton, 4)
        
        tabButton.MouseButton1Click:Connect(function()
            for j, btn in pairs(compactTabButtons) do
                if j == i then
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.AccentColor,
                        TextColor3 = Color3.new(1,1,1)
                    }):Play()
                else
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.SecondaryColor,
                        TextColor3 = Blackwind.Config.TextColor
                    }):Play()
                end
            end
        end)
        
        compactTabButtons[i] = tabButton
    end
    
    local closeBtn = Create("TextButton", {
        Name = "Close",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -30, 0, 5),
        Text = "✕",
        TextColor3 = Blackwind.Config.SubTextColor,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        Parent = titleBar
    })
    
    local controlContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 0, 25),
        Position = UDim2.new(1, -90, 0, 30),
        Parent = titleBar
    })
    
    local minimizeBtn = Create("TextButton", {
        Name = "Minimize",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "─",
        TextColor3 = Blackwind.Config.SubTextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Parent = controlContainer
    })
    
    local bottomBar = Create("Frame", {
        Name = "BottomBar",
        BackgroundColor3 = Blackwind.Config.MainColor,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 1, -40),
        Visible = options.BottomText ~= nil,
        Parent = MainFrame
    })
    
    Roundify(bottomBar, {BottomLeft = true, BottomRight = true})
    AddStroke(bottomBar)
    
    local bottomLabel = Create("TextLabel", {
        Name = "BottomLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = options.BottomText or "",
        TextColor3 = Blackwind.Config.SubTextColor,
        Font = Blackwind.Config.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bottomBar
    })
    
    local contentFrame = Create("Frame", {
        Name = "ContentFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -100),
        Position = UDim2.new(0, 10, 0, 70),
        Parent = MainFrame
    })
    
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = Blackwind.Config.SecondaryColor,
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = contentFrame
    })
    
    Roundify(tabContainer, 8)
    AddStroke(tabContainer)
    
    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Blackwind.Config.AccentColor,
        ScrollBarImageTransparency = 0.5,
        Parent = tabContainer
    })
    
    local tabListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList
    })
    
    local rightContent = Create("Frame", {
        Name = "RightContent",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -170, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        Parent = contentFrame
    })
    
    local rightContentScrolling = Create("ScrollingFrame", {
        Name = "RightContentScrolling",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = Blackwind.Config.AccentColor,
        ScrollBarImageTransparency = 0.5,
        Parent = rightContent
    })
    
    local rightContentLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 15),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = rightContentScrolling
    })
    
    rightContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        rightContentScrolling.CanvasSize = UDim2.new(0, 0, 0, rightContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    MakeDraggable(MainFrame, titleBar)
    
    minimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {
            TextColor3 = Blackwind.Config.AccentColor
        }):Play()
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {
            TextColor3 = Blackwind.Config.SubTextColor
        }):Play()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {
            TextColor3 = Blackwind.Colors.Red
        }):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {
            TextColor3 = Blackwind.Config.SubTextColor
        }):Play()
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        Blackwind:ToggleMinimize()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Blackwind:ToggleUI()
    end)
    
    table.insert(Blackwind.Connections, UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Blackwind.Config.ToggleKey then
            Blackwind:ToggleUI()
        elseif input.KeyCode == Blackwind.Config.MinimizeKey then
            Blackwind:ToggleMinimize()
        end
    end))
    
    local Window = {
        MainFrame = MainFrame,
        ContentFrame = contentFrame,
        TabContainer = tabContainer,
        TabList = tabList,
        RightContent = rightContentScrolling,
        TitleLabel = titleLabel,
        SubtitleLabel = subtitleLabel,
        BottomLabel = bottomLabel,
        BottomBar = bottomBar,
        CompactTabs = compactTabButtons,
        Tabs = {},
        CurrentTab = nil,
        Boxes = {}
    }
    
    function Window:CreateTab(name, icon)
        local tabId = #self.Tabs + 1
        
        local tabButton = Create("TextButton", {
            Name = name .. "Tab",
            BackgroundColor3 = tabId == 1 and Blackwind.Config.AccentColor or Blackwind.Config.SecondaryColor,
            BackgroundTransparency = 0,
            Size = UDim2.new(0.9, 0, 0, 40),
            LayoutOrder = tabId,
            Text = "",
            Parent = self.TabList
        })
        
        Roundify(tabButton, 6)
        AddStroke(tabButton)
        
        local tabIcon
        if icon then
            tabIcon = Create("ImageLabel", {
                Name = "TabIcon",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(0, 10, 0.5, -12),
                Image = string.find(icon, "rbxassetid://") and icon or "rbxassetid://" .. icon,
                ImageColor3 = tabId == 1 and Color3.new(1,1,1) or Blackwind.Config.TextColor,
                Parent = tabButton
            })
        end
        
        local tabNameLabel = Create("TextLabel", {
            Name = "TabName",
            BackgroundTransparency = 1,
            Size = icon and UDim2.new(1, -45, 1, 0) or UDim2.new(1, -20, 1, 0),
            Position = icon and UDim2.new(0, 40, 0, 0) or UDim2.new(0, 10, 0, 0),
            Text = name,
            TextColor3 = tabId == 1 and Color3.new(1,1,1) or Blackwind.Config.TextColor,
            Font = Blackwind.Config.Font,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabButton
        })
        
        local tabContent = Create("Frame", {
            Name = name .. "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = tabId == 1,
            Parent = self.RightContent
        })
        
        local contentLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabContent
        })
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        tabButton.MouseButton1Click:Connect(function()
            for _, otherTab in pairs(self.Tabs) do
                if otherTab.Content then
                    otherTab.Content.Visible = false
                end
                if otherTab.Button then
                    TweenService:Create(otherTab.Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.SecondaryColor,
                        BackgroundTransparency = 0
                    }):Play()
                    
                    if otherTab.Icon then
                        TweenService:Create(otherTab.Icon, TweenInfo.new(0.2), {
                            ImageColor3 = Blackwind.Config.TextColor
                        }):Play()
                    end
                    
                    if otherTab.NameLabel then
                        TweenService:Create(otherTab.NameLabel, TweenInfo.new(0.2), {
                            TextColor3 = Blackwind.Config.TextColor
                        }):Play()
                    end
                end
            end
            
            tabContent.Visible = true
            TweenService:Create(tabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Blackwind.Config.AccentColor,
                BackgroundTransparency = 0
            }):Play()
            
            if tabIcon then
                TweenService:Create(tabIcon, TweenInfo.new(0.2), {
                    ImageColor3 = Color3.new(1,1,1)
                }):Play()
            end
            
            TweenService:Create(tabNameLabel, TweenInfo.new(0.2), {
                TextColor3 = Color3.new(1,1,1)
            }):Play()
            
            self.CurrentTab = tabId
        end)
        
        if tabId == 1 then
            self.CurrentTab = 1
        end
        
        self.TabList.CanvasSize = UDim2.new(0, 0, 0, (#self.Tabs * 50) + 60)
        
        local Tab = {
            Name = name,
            Button = tabButton,
            Icon = tabIcon,
            NameLabel = tabNameLabel,
            Content = tabContent,
            Sections = {}
        }
        
        function Tab:CreateMainBox(name, text)
            local boxFrame = Create("Frame", {
                Name = name .. "MainBox",
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                BackgroundTransparency = 0.1,
                Size = UDim2.new(1, 0, 0, 60),
                LayoutOrder = #self.Sections + 1,
                Parent = self.Content
            })
            
            Roundify(boxFrame, 8)
            AddStroke(boxFrame)
            
            local boxName = Create("TextLabel", {
                Name = "BoxName",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                Text = name,
                TextColor3 = Blackwind.Config.TextColor,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = boxFrame
            })
            
            local boxText = Create("TextLabel", {
                Name = "BoxText",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, -35),
                Position = UDim2.new(0, 10, 0, 30),
                Text = text or "",
                TextColor3 = Blackwind.Config.SubTextColor,
                Font = Blackwind.Config.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                Parent = boxFrame
            })
            
            local MainBox = {
                Frame = boxFrame,
                NameLabel = boxName,
                TextLabel = boxText,
                
                SetName = function(newName)
                    boxName.Text = newName
                end,
                
                SetText = function(newText)
                    boxText.Text = newText
                end,
                
                SetVisible = function(visible)
                    boxFrame.Visible = visible
                end
            }
            
            table.insert(self.Sections, MainBox)
            table.insert(Window.Boxes, MainBox)
            return MainBox
        end
        
        function Tab:CreateTabBox(name, tab1Name, tab2Name)
            local boxFrame = Create("Frame", {
                Name = name .. "TabBox",
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                BackgroundTransparency = 0.1,
                Size = UDim2.new(1, 0, 0, 100),
                LayoutOrder = #self.Sections + 1,
                Parent = self.Content
            })
            
            Roundify(boxFrame, 8)
            AddStroke(boxFrame)
            
            local boxName = Create("TextLabel", {
                Name = "BoxName",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.7, 0, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                Text = name,
                TextColor3 = Blackwind.Config.TextColor,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = boxFrame
            })
            
            local toggleFrame = Create("Frame", {
                Name = "ToggleFrame",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.3, 0, 0, 25),
                Position = UDim2.new(0.7, -10, 0, 5),
                Parent = boxFrame
            })
            
            local toggleName = Create("TextLabel", {
                Name = "ToggleName",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.6, 0, 1, 0),
                Text = "开关",
                TextColor3 = Blackwind.Config.TextColor,
                Font = Blackwind.Config.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame
            })
            
            local toggleButton = Create("TextButton", {
                Name = "Toggle",
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -45, 0.5, -10),
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                Text = "",
                Parent = toggleFrame
            })
            
            Roundify(toggleButton, 10)
            
            local toggleCircle = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Parent = toggleButton
            })
            
            Roundify(toggleCircle, 8)
            
            local isToggled = false
            
            local function updateToggle()
                if isToggled then
                    TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.AccentColor
                    }):Play()
                    TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                        Position = UDim2.new(1, -18, 0.5, -8)
                    }):Play()
                else
                    TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.SecondaryColor
                    }):Play()
                    TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, 2, 0.5, -8)
                    }):Play()
                end
            end
            
            updateToggle()
            
            toggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                updateToggle()
            end)
            
            local tabSelector = Create("Frame", {
                Name = "TabSelector",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, 55),
                Parent = boxFrame
            })
            
            local tab1 = Create("TextButton", {
                Name = "Tab1",
                Size = UDim2.new(0.45, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Blackwind.Config.AccentColor,
                Text = tab1Name or "Tab1",
                TextColor3 = Color3.new(1, 1, 1),
                Font = Blackwind.Config.Font,
                TextSize = 14,
                Parent = tabSelector
            })
            
            Roundify(tab1, 6)
            
            local tab2 = Create("TextButton", {
                Name = "Tab2",
                Size = UDim2.new(0.45, 0, 1, 0),
                Position = UDim2.new(1, -0.45, 0, 0),
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                Text = tab2Name or "Tab2",
                TextColor3 = Blackwind.Config.TextColor,
                Font = Blackwind.Config.Font,
                TextSize = 14,
                Parent = tabSelector
            })
            
            Roundify(tab2, 6)
            
            local selectedTab = 1
            
            local function selectTab(tabNum)
                selectedTab = tabNum
                if tabNum == 1 then
                    TweenService:Create(tab1, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.AccentColor,
                        TextColor3 = Color3.new(1, 1, 1)
                    }):Play()
                    TweenService:Create(tab2, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.SecondaryColor,
                        TextColor3 = Blackwind.Config.TextColor
                    }):Play()
                else
                    TweenService:Create(tab1, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.SecondaryColor,
                        TextColor3 = Blackwind.Config.TextColor
                    }):Play()
                    TweenService:Create(tab2, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.AccentColor,
                        TextColor3 = Color3.new(1, 1, 1)
                    }):Play()
                end
            end
            
            tab1.MouseButton1Click:Connect(function()
                selectTab(1)
            end)
            
            tab2.MouseButton1Click:Connect(function()
                selectTab(2)
            end)
            
            local TabBox = {
                Frame = boxFrame,
                Toggle = toggleButton,
                ToggleState = isToggled,
                Tab1 = tab1,
                Tab2 = tab2,
                SelectedTab = selectedTab,
                
                SetName = function(newName)
                    boxName.Text = newName
                end,
                
                SetTab1Name = function(name)
                    tab1.Text = name
                end,
                
                SetTab2Name = function(name)
                    tab2.Text = name
                end,
                
                SetToggle = function(value)
                    isToggled = value
                    updateToggle()
                end,
                
                GetToggle = function()
                    return isToggled
                end,
                
                SelectTab = function(tabNum)
                    selectTab(tabNum)
                end,
                
                OnToggleChanged = function(callback)
                    toggleButton.MouseButton1Click:Connect(function()
                        isToggled = not isToggled
                        updateToggle()
                        if callback then
                            callback(isToggled)
                        end
                    end)
                end,
                
                OnTabChanged = function(callback)
                    tab1.MouseButton1Click:Connect(function()
                        selectTab(1)
                        if callback then
                            callback(1)
                        end
                    end)
                    
                    tab2.MouseButton1Click:Connect(function()
                        selectTab(2)
                        if callback then
                            callback(2)
                        end
                    end)
                end
            }
            
            table.insert(self.Sections, TabBox)
            table.insert(Window.Boxes, TabBox)
            return TabBox
        end
        
        function Tab:CreateMultiTabBox(name, tabCount)
            local boxFrame = Create("Frame", {
                Name = name .. "MultiTabBox",
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                BackgroundTransparency = 0.1,
                Size = UDim2.new(1, 0, 0, 130 + math.ceil(tabCount / 3) * 40),
                LayoutOrder = #self.Sections + 1,
                Parent = self.Content
            })
            
            Roundify(boxFrame, 8)
            AddStroke(boxFrame)
            
            local boxName = Create("TextLabel", {
                Name = "BoxName",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.7, 0, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                Text = name,
                TextColor3 = Blackwind.Config.TextColor,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = boxFrame
            })
            
            local toggleFrame = Create("Frame", {
                Name = "ToggleFrame",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.3, 0, 0, 25),
                Position = UDim2.new(0.7, -10, 0, 5),
                Parent = boxFrame
            })
            
            local toggleName = Create("TextLabel", {
                Name = "ToggleName",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.6, 0, 1, 0),
                Text = "开关",
                TextColor3 = Blackwind.Config.TextColor,
                Font = Blackwind.Config.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame
            })
            
            local toggleButton = Create("TextButton", {
                Name = "Toggle",
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -45, 0.5, -10),
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                Text = "",
                Parent = toggleFrame
            })
            
            Roundify(toggleButton, 10)
            
            local toggleCircle = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Parent = toggleButton
            })
            
            Roundify(toggleCircle, 8)
            
            local isToggled = false
            
            local function updateToggle()
                if isToggled then
                    TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.AccentColor
                    }):Play()
                    TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                        Position = UDim2.new(1, -18, 0.5, -8)
                    }):Play()
                else
                    TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.SecondaryColor
                    }):Play()
                    TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, 2, 0.5, -8)
                    }):Play()
                end
            end
            
            updateToggle()
            
            toggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                updateToggle()
            end)
            
            local tabsContainer = Create("Frame", {
                Name = "TabsContainer",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, math.ceil(tabCount / 3) * 40 + 10),
                Position = UDim2.new(0, 10, 0, 55),
                Parent = boxFrame
            })
            
            local tabs = {}
            local selectedTab = 1
            
            for i = 1, tabCount do
                local row = math.ceil(i / 3) - 1
                local col = (i - 1) % 3
                
                local tabButton = Create("TextButton", {
                    Name = "Tab" .. i,
                    Size = UDim2.new(0.32, 0, 0, 35),
                    Position = UDim2.new(col * 0.33, 0, row * 0.33, 0),
                    BackgroundColor3 = i == 1 and Blackwind.Config.AccentColor or Blackwind.Config.SecondaryColor,
                    Text = "Tab" .. i,
                    TextColor3 = i == 1 and Color3.new(1, 1, 1) or Blackwind.Config.TextColor,
                    Font = Blackwind.Config.Font,
                    TextSize = 14,
                    Parent = tabsContainer
                })
                
                Roundify(tabButton, 6)
                
                tabButton.MouseButton1Click:Connect(function()
                    selectedTab = i
                    for j, tab in pairs(tabs) do
                        if j == i then
                            TweenService:Create(tab, TweenInfo.new(0.2), {
                                BackgroundColor3 = Blackwind.Config.AccentColor,
                                TextColor3 = Color3.new(1, 1, 1)
                            }):Play()
                        else
                            TweenService:Create(tab, TweenInfo.new(0.2), {
                                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                                TextColor3 = Blackwind.Config.TextColor
                            }):Play()
                        end
                    end
                end)
                
                tabs[i] = tabButton
            end
            
            local MultiTabBox = {
                Frame = boxFrame,
                Toggle = toggleButton,
                ToggleState = isToggled,
                Tabs = tabs,
                SelectedTab = selectedTab,
                
                SetName = function(newName)
                    boxName.Text = newName
                end,
                
                SetTabName = function(index, name)
                    if tabs[index] then
                        tabs[index].Text = name
                    end
                end,
                
                SetToggle = function(value)
                    isToggled = value
                    updateToggle()
                end,
                
                GetToggle = function()
                    return isToggled
                end,
                
                SelectTab = function(tabNum)
                    if tabs[tabNum] then
                        tabs[tabNum]:MouseButton1Click()
                    end
                end,
                
                OnToggleChanged = function(callback)
                    toggleButton.MouseButton1Click:Connect(function()
                        isToggled = not isToggled
                        updateToggle()
                        if callback then
                            callback(isToggled)
                        end
                    end)
                end,
                
                OnTabChanged = function(callback)
                    for i, tab in pairs(tabs) do
                        tab.MouseButton1Click:Connect(function()
                            selectedTab = i
                            if callback then
                                callback(i)
                            end
                        end)
                    end
                end
            }
            
            table.insert(self.Sections, MultiTabBox)
            table.insert(Window.Boxes, MultiTabBox)
            return MultiTabBox
        end
        
        function Tab:CreateDropdown(name, options, default, callback)
            local dropdownFrame = Create("Frame", {
                Name = name .. "Dropdown",
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                BackgroundTransparency = 0.1,
                Size = UDim2.new(1, 0, 0, 50),
                LayoutOrder = #self.Sections + 1,
                Parent = self.Content
            })
            
            Roundify(dropdownFrame, 8)
            AddStroke(dropdownFrame)
            
            local dropdownName = Create("TextLabel", {
                Name = "DropdownName",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                Text = name,
                TextColor3 = Blackwind.Config.TextColor,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownFrame
            })
            
            local dropdownButton = Create("TextButton", {
                Size = UDim2.new(0.4, 0, 0, 30),
                Position = UDim2.new(0.6, -10, 0.5, -15),
                BackgroundColor3 = Blackwind.Config.MainColor,
                Text = default or "选择...",
                TextColor3 = Blackwind.Config.TextColor,
                Font = Blackwind.Config.Font,
                TextSize = 14,
                Parent = dropdownFrame
            })
            
            Roundify(dropdownButton, 6)
            AddStroke(dropdownButton)
            
            local dropdownList = Create("Frame", {
                Name = "DropdownList",
                BackgroundColor3 = Blackwind.Config.MainColor,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 5),
                Visible = false,
                Parent = dropdownFrame
            })
            
            Roundify(dropdownList, 6)
            AddStroke(dropdownList)
            
            local listLayout = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = dropdownList
            })
            
            local isOpen = false
            local selected = default
            
            local function toggleDropdown()
                isOpen = not isOpen
                dropdownList.Visible = isOpen
                
                if isOpen then
                    TweenService:Create(dropdownList, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, #options * 30)
                    }):Play()
                else
                    TweenService:Create(dropdownList, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, 0)
                    }):Play()
                end
            end
            
            dropdownButton.MouseButton1Click:Connect(toggleDropdown)
            
            for i, option in pairs(options) do
                local optionButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Blackwind.Config.MainColor,
                    Text = option,
                    TextColor3 = Blackwind.Config.TextColor,
                    Font = Blackwind.Config.Font,
                    TextSize = 14,
                    LayoutOrder = i,
                    Parent = dropdownList
                })
                
                optionButton.MouseEnter:Connect(function()
                    TweenService:Create(optionButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.SecondaryColor,
                        TextColor3 = Blackwind.Config.TextColor
                    }):Play()
                end)
                
                optionButton.MouseLeave:Connect(function()
                    TweenService:Create(optionButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.MainColor,
                        TextColor3 = Blackwind.Config.TextColor
                    }):Play()
                end)
                
                optionButton.MouseButton1Click:Connect(function()
                    selected = option
                    dropdownButton.Text = option
                    toggleDropdown()
                    if callback then
                        callback(option)
                    end
                end)
            end
            
            local Dropdown = {
                Frame = dropdownFrame,
                Button = dropdownButton,
                List = dropdownList,
                Selected = selected,
                
                Set = function(value)
                    selected = value
                    dropdownButton.Text = value
                    if callback then
                        callback(value)
                    end
                end,
                
                Get = function()
                    return selected
                end
            }
            
            table.insert(self.Sections, Dropdown)
            table.insert(Window.Boxes, Dropdown)
            return Dropdown
        end
        
        function Tab:CreateButton(name, callback)
            local buttonFrame = Create("Frame", {
                Name = name .. "Button",
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                BackgroundTransparency = 0.1,
                Size = UDim2.new(1, 0, 0, 45),
                LayoutOrder = #self.Sections + 1,
                Parent = self.Content
            })
            
            Roundify(buttonFrame, 8)
            AddStroke(buttonFrame)
            
            local button = Create("TextButton", {
                Size = UDim2.new(1, -20, 0, 35),
                Position = UDim2.new(0, 10, 0.5, -17.5),
                BackgroundColor3 = Blackwind.Config.AccentColor,
                BackgroundTransparency = 0.1,
                Text = name,
                TextColor3 = Blackwind.Config.TextColor,
                Font = Blackwind.Config.Font,
                TextSize = 14,
                Parent = buttonFrame
            })
            
            Roundify(button, 6)
            
            button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)
            
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0
                }):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.1
                }):Play()
            end)
            
            local Button = {
                Frame = buttonFrame,
                Button = button,
                
                SetText = function(text)
                    button.Text = text
                end
            }
            
            table.insert(self.Sections, Button)
            table.insert(Window.Boxes, Button)
            return Button
        end
        
        function Tab:CreateSlider(name, min, max, default, callback)
            local sliderFrame = Create("Frame", {
                Name = name .. "Slider",
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                BackgroundTransparency = 0.1,
                Size = UDim2.new(1, 0, 0, 70),
                LayoutOrder = #self.Sections + 1,
                Parent = self.Content
            })
            
            Roundify(sliderFrame, 8)
            AddStroke(sliderFrame)
            
            local sliderName = Create("TextLabel", {
                Name = "SliderName",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                Text = name,
                TextColor3 = Blackwind.Config.TextColor,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sliderFrame
            })
            
            local valueLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -70, 0, 5),
                Text = tostring(default or min),
                TextColor3 = Blackwind.Config.SubTextColor,
                Font = Blackwind.Config.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = sliderFrame
            })
            
            local sliderTrack = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 0, 40),
                BackgroundColor3 = Blackwind.Config.MainColor,
                Parent = sliderFrame
            })
            
            Roundify(sliderTrack, 3)
            
            local sliderFill = Create("Frame", {
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Blackwind.Config.AccentColor,
                Parent = sliderTrack
            })
            
            Roundify(sliderFill, 3)
            
            local sliderButton = Create("TextButton", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, -8, 0.5, -8),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Text = "",
                Parent = sliderTrack
            })
            
            Roundify(sliderButton, 8)
            
            local currentValue = default or min
            local isDragging = false
            
            local function updateSlider(value)
                currentValue = math.clamp(value, min, max)
                local percentage = (currentValue - min) / (max - min)
                
                TweenService:Create(sliderFill, TweenInfo.new(0.1), {
                    Size = UDim2.new(percentage, 0, 1, 0)
                }):Play()
                
                TweenService:Create(sliderButton, TweenInfo.new(0.1), {
                    Position = UDim2.new(percentage, -8, 0.5, -8)
                }):Play()
                
                valueLabel.Text = string.format("%.1f", currentValue)
                
                if callback then
                    callback(currentValue)
                end
            end
            
            updateSlider(currentValue)
            
            local function updateFromMouse()
                if not isDragging then return end
                
                local mousePos = UserInputService:GetMouseLocation()
                local trackPos = sliderTrack.AbsolutePosition
                local trackSize = sliderTrack.AbsoluteSize
                
                local relativeX = math.clamp((mousePos.X - trackPos.X) / trackSize.X, 0, 1)
                local value = min + (relativeX * (max - min))
                updateSlider(value)
            end
            
            sliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                end
            end)
            
            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    updateFromMouse()
                end
            end)
            
            table.insert(Blackwind.Connections, UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateFromMouse()
                end
            end))
            
            table.insert(Blackwind.Connections, UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end))
            
            local Slider = {
                Frame = sliderFrame,
                Value = currentValue,
                
                Set = function(value)
                    updateSlider(value)
                end,
                
                Get = function()
                    return currentValue
                end
            }
            
            table.insert(self.Sections, Slider)
            table.insert(Window.Boxes, Slider)
            return Slider
        end
        
        function Tab:CreateToggle(name, default, callback)
            local toggleFrame = Create("Frame", {
                Name = name .. "Toggle",
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                BackgroundTransparency = 0.1,
                Size = UDim2.new(1, 0, 0, 40),
                LayoutOrder = #self.Sections + 1,
                Parent = self.Content
            })
            
            Roundify(toggleFrame, 8)
            AddStroke(toggleFrame)
            
            local toggleName = Create("TextLabel", {
                Name = "ToggleName",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.7, 0, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                Text = name,
                TextColor3 = Blackwind.Config.TextColor,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame
            })
            
            local toggleButton = Create("TextButton", {
                Name = "Toggle",
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -60, 0.5, -10),
                BackgroundColor3 = default and Blackwind.Config.AccentColor or Blackwind.Config.SecondaryColor,
                Text = "",
                Parent = toggleFrame
            })
            
            Roundify(toggleButton, 10)
            
            local toggleCircle = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Parent = toggleButton
            })
            
            Roundify(toggleCircle, 8)
            
            local isToggled = default
            
            local function updateToggle()
                if isToggled then
                    TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.AccentColor
                    }):Play()
                    TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                        Position = UDim2.new(1, -18, 0.5, -8)
                    }):Play()
                else
                    TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Blackwind.Config.SecondaryColor
                    }):Play()
                    TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, 2, 0.5, -8)
                    }):Play()
                end
            end
            
            toggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                updateToggle()
                if callback then
                    callback(isToggled)
                end
            end)
            
            local Toggle = {
                Frame = toggleFrame,
                State = isToggled,
                
                Set = function(value)
                    isToggled = value
                    updateToggle()
                    if callback then
                        callback(isToggled)
                    end
                end,
                
                Get = function()
                    return isToggled
                end
            }
            
            table.insert(self.Sections, Toggle)
            table.insert(Window.Boxes, Toggle)
            return Toggle
        end
        
        function Tab:CreateInput(name, placeholder, default, callback)
            local inputFrame = Create("Frame", {
                Name = name .. "Input",
                BackgroundColor3 = Blackwind.Config.SecondaryColor,
                BackgroundTransparency = 0.1,
                Size = UDim2.new(1, 0, 0, 50),
                LayoutOrder = #self.Sections + 1,
                Parent = self.Content
            })
            
            Roundify(inputFrame, 8)
            AddStroke(inputFrame)
            
            local inputName = Create("TextLabel", {
                Name = "InputName",
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, 0, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                Text = name,
                TextColor3 = Blackwind.Config.TextColor,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = inputFrame
            })
            
            local textBox = Create("TextBox", {
                Size = UDim2.new(0.5, 0, 0, 30),
                Position = UDim2.new(0.5, -10, 0, 5),
                BackgroundColor3 = Blackwind.Config.MainColor,
                Text = default or "",
                PlaceholderText = placeholder or "输入文本...",
                TextColor3 = Blackwind.Config.TextColor,
                PlaceholderColor3 = Blackwind.Config.SubTextColor,
                Font = Blackwind.Config.Font,
                TextSize = 14,
                Parent = inputFrame
            })
            
            Roundify(textBox, 6)
            AddStroke(textBox)
            
            textBox.Focused:Connect(function()
                TweenService:Create(textBox, TweenInfo.new(0.2), {
                    BackgroundColor3 = Blackwind.Config.AccentColor
                }):Play()
            end)
            
            textBox.FocusLost:Connect(function()
                TweenService:Create(textBox, TweenInfo.new(0.2), {
                    BackgroundColor3 = Blackwind.Config.MainColor
                }):Play()
                
                if callback then
                    callback(textBox.Text)
                end
            end)
            
            local Input = {
                Frame = inputFrame,
                TextBox = textBox,
                Value = default or "",
                
                Set = function(value)
                    textBox.Text = value
                end,
                
                Get = function()
                    return textBox.Text
                end
            }
            
            table.insert(self.Sections, Input)
            table.insert(Window.Boxes, Input)
            return Input
        end
        
        self.Tabs[#self.Tabs + 1] = Tab
        return Tab
    end
    
    function Window:Toggle(visible)
        if visible ~= nil then
            UIVisible = visible
            if MainFrame then
                MainFrame.Visible = visible
                TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                    BackgroundTransparency = visible and 0 or 1
                }):Play()
            end
        else
            Blackwind:ToggleUI()
        end
    end
    
    function Window:ShowBottomText(text)
        if self.BottomBar then
            self.BottomBar.Visible = true
            self.BottomLabel.Text = text
        end
    end
    
    function Window:HideBottomText()
        if self.BottomBar then
            self.BottomBar.Visible = false
        end
    end
    
    function Window:SetTitle(title)
        if self.TitleLabel then
            self.TitleLabel.Text = title
        end
    end
    
    function Window:SetSubtitle(subtitle)
        if self.SubtitleLabel then
            self.SubtitleLabel.Text = subtitle
        end
    end
    
    function Window:SetIcon(iconId)
        if ScreenGui and ScreenGui:FindFirstChild("MainFrame") then
            local titleBar = ScreenGui.MainFrame:FindFirstChild("TitleBar")
            if titleBar then
                local uiIcon = titleBar:FindFirstChild("UIIcon")
                if uiIcon then
                    uiIcon.Image = string.find(iconId, "rbxassetid://") and iconId or "rbxassetid://" .. iconId
                end
            end
        end
    end
    
    function Window:Destroy()
        if ScreenGui then
            ScreenGui:Destroy()
        end
        for _, conn in pairs(Blackwind.Connections) do
            if conn and typeof(conn) == "RBXScriptConnection" then
                pcall(function() conn:Disconnect() end)
            end
        end
    end
    
    table.insert(Blackwind.Windows, Window)
    
    if Blackwind.Config.AutoShow then
        task.wait(0.5)
        Blackwind:Notify({
            Title = "Black Wind UI v2test",
            Content = "UI加载成功！按右Ctrl切换界面",
            Duration = 5
        })
    end
    
    return Window
end

function Blackwind:UpdateConfig(config)
    for key, value in pairs(config) do
        if Blackwind.Config[key] ~= nil then
            Blackwind.Config[key] = value
        end
    end
end

function Blackwind:Unload()
    for _, Window in pairs(Blackwind.Windows) do
        Window:Destroy()
    end
    Blackwind.Windows = {}
    
    for _, conn in pairs(Blackwind.Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    Blackwind.Connections = {}
    
    for _, notification in pairs(Blackwind.Notifications) do
        if notification and notification.Parent then
            notification:Destroy()
        end
    end
    Blackwind.Notifications = {}
    
    warn("Black Wind UI 已卸载")
end

return Blackwind
