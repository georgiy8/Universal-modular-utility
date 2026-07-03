-- utils/ui.lua
local UI = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local zoneGap, titleHeight = 10, 45

local tabs = {}

function UI.CreateMainGui()
    local gui = Instance.new("ScreenGui")
    gui.ResetOnSpawn = false
    gui.Name = "PilgrammedUtility"
    gui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame", gui)
    mainFrame.Size = UDim2.new(0, 600, 0, 460)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -230)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainFrame.BorderSizePixel = 0
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    -- Title Bar
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Size = UDim2.new(1, -20, 0, titleHeight)
    titleBar.Position = UDim2.new(0, 10, 0, 10)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    titleBar.Active = true
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1, -180, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🛠️ Pilgrammed Utility"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Title Buttons
    local function createTitleBtn(text, xOffset, callback)
        local btn = Instance.new("TextButton", titleBar)
        btn.Size = UDim2.new(0, 36, 0, 36)
        btn.Position = UDim2.new(1, xOffset, 0, 4)
        btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        btn.Text = text
        btn.TextSize = 22
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(callback)
    end

    createTitleBtn("🔽", -82, function() mainFrame.Visible = false end)
    createTitleBtn("❌", -42, function() gui:Destroy() end)

    -- ==================== RESIZE HANDLE ====================
    local resizeHandle = Instance.new("Frame", mainFrame)
    resizeHandle.Size = UDim2.new(0, 30, 0, 30)
    resizeHandle.Position = UDim2.new(1, -30, 1, -30)
    resizeHandle.BackgroundTransparency = 0.3
    resizeHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    resizeHandle.ZIndex = 100
    Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 6)

    local resizeLabel = Instance.new("TextLabel", resizeHandle)
    resizeLabel.Size = UDim2.new(1, 0, 1, 0)
    resizeLabel.BackgroundTransparency = 1
    resizeLabel.Text = "↘"
    resizeLabel.TextSize = 24
    resizeLabel.Font = Enum.Font.GothamBold
    resizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

    local resizing = false

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local guiInset = GuiService:GetGuiInset()
            
            local newW = math.clamp(mousePos.X - mainFrame.AbsolutePosition.X + 15, 520, 950)
            local newH = math.clamp(mousePos.Y - mainFrame.AbsolutePosition.Y - guiInset.Y + 15, 420, 750)
            
            mainFrame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)

    -- Tab Panel
    local tabPanel = Instance.new("ScrollingFrame", mainFrame)
    tabPanel.Name = "TabPanel"
    tabPanel.Position = UDim2.new(0, 10, 0, titleHeight + 18)
    tabPanel.Size = UDim2.new(0, 140, 1, -(titleHeight + 55))
    tabPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    tabPanel.BorderSizePixel = 0
    tabPanel.ScrollBarThickness = 6
    Instance.new("UICorner", tabPanel).CornerRadius = UDim.new(0, 8)

    Instance.new("UIListLayout", tabPanel).Padding = UDim.new(0, 6)

    -- Content
    local contentZone = Instance.new("ScrollingFrame", mainFrame)
    contentZone.Name = "ContentZone"
    contentZone.Position = UDim2.new(0, 160, 0, titleHeight + 18)
    contentZone.Size = UDim2.new(1, -170, 1, -(titleHeight + 55))
    contentZone.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentZone.BorderSizePixel = 0
    contentZone.ScrollBarThickness = 6
    Instance.new("UICorner", contentZone).CornerRadius = UDim.new(0, 8)

    Instance.new("UIListLayout", contentZone).Padding = UDim.new(0, 12)

    -- Drag Title Bar
    local dragging = false
    local dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    UI.MainFrame = mainFrame
    UI.TabPanel = tabPanel
    UI.ContentZone = contentZone
    UI.Tabs = tabs
    UI.Gui = gui

    print("✅ UI + Ресайз загружен!")
    return UI
end

function UI.CreateTab(name, icon, order)
    local tab = {Name = name, Container = nil, Button = nil}

    local btn = Instance.new("TextButton", UI.TabPanel)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = (icon or "⚡") .. "   " .. name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.LayoutOrder = order or #tabs + 1

    local container = Instance.new("Frame", UI.ContentZone)
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Visible = false
    container.LayoutOrder = #tabs + 1

    Instance.new("UIListLayout", container).Padding = UDim.new(0, 10)

    tab.Button = btn
    tab.Container = container

    table.insert(tabs, tab)

    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do t.Container.Visible = false end
        container.Visible = true
    end)

    if #tabs == 1 then container.Visible = true end

    return container
end

return UI
