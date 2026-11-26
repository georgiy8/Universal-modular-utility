--========================================================--
-- Universal-modular-utility GUI Library
-- Core.lua
--========================================================--

------------------------------------------------------------
-- Repository
------------------------------------------------------------

local REPO = "https://raw.githubusercontent.com/georgiy8/Universal-modular-utility/main/"

local function Import(Path)

    local Success, Result = pcall(function()

        return loadstring(game:HttpGet(REPO .. Path))()

    end)

    if not Success then
        error(Result)
    end

    return Result

end

------------------------------------------------------------
-- Roblox Services
------------------------------------------------------------

local Players = game:GetService("Players")

local Player = Players.LocalPlayer

------------------------------------------------------------
-- Library Services
------------------------------------------------------------

local ThemeOk, Theme = pcall(Import, "gui/theme.lua")

if not ThemeOk or type(Theme) ~= "table" then
    Theme = { Colors = {}, Radius = 6, RadiusSmall = 4 }
end

local function CC(Name, Fallback)
    return Theme.Colors[Name] or Fallback
end

local Radius = UDim.new(0, Theme.Radius or 6)
local RadiusSmall = UDim.new(0, Theme.RadiusSmall or 4)

local TweenService = game:GetService("TweenService")

local function Fade(Object, Color)
    TweenService:Create(
        Object,
        TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { BackgroundColor3 = Color }
    ):Play()
end

local HEADER_HEIGHT = 48
local MAIN_ORDER_LIMIT = 60 -- Order меньше этого значения -> группа "Основное"

local Drag = Import("gui/services/drag.lua")
local Resize = Import("gui/services/resize.lua")
local AssetManager = Import("gui/services/assetmanager.lua")
local ConfigManager = Import("gui/services/Config-manager.lua")

_G.ConfigManager = ConfigManager
AssetManager:Init()
_G.Assets = AssetManager

------------------------------------------------------------
-- Widgets
------------------------------------------------------------

local Widgets = Import("gui/widgets/registry.lua")
_G.SoundWidget = Widgets.Sound

------------------------------------------------------------
-- Library
------------------------------------------------------------

local Library = {}

Library.__index = Library

------------------------------------------------------------
-- Window
------------------------------------------------------------

local Window = {}

Window.__index = Window

------------------------------------------------------------
-- Tab
------------------------------------------------------------

local Tab = {}

Tab.__index = Tab

------------------------------------------------------------
-- Section
------------------------------------------------------------

local Section = {}

Section.__index = Section

------------------------------------------------------------
-- Constructor
------------------------------------------------------------

function Library.new()

    local self = setmetatable({},Library)

    self.Windows = {}

    self.AssetManager = AssetManager

    return self

end

------------------------------------------------------------
-- Create Window
------------------------------------------------------------
function Library:CreateWindow(Settings)
    Settings = Settings or {}
    
    local selfWindow = setmetatable({}, Window)
    selfWindow.Library = self
    
    -- Защита (чтобы не падало, даже если забыли сделать Library.new())
    self.Windows = self.Windows or {}
    
    selfWindow.TitleText = Settings.Title or "Universal Utility"
    selfWindow.Width = Settings.Width or 650
    selfWindow.Height = Settings.Height or 420

    -- Окно не больше экрана (телефон / маленькое окно игры)
    do
        local Camera = workspace.CurrentCamera
        if Camera then
            local View = Camera.ViewportSize
            selfWindow.Width = math.max(300, math.min(selfWindow.Width, math.floor(View.X * 0.92)))
            selfWindow.Height = math.max(220, math.min(selfWindow.Height, math.floor(View.Y * 0.85)))
        end
    end
    selfWindow.Tabs = {}
    selfWindow.ActiveTab = nil
    
    --------------------------------------------------------
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Universal-modular-utility"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = Player.PlayerGui
    selfWindow.Gui = ScreenGui
    --------------------------------------------------------
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.Size = UDim2.fromOffset(
        selfWindow.Width,
        selfWindow.Height
    )
    Main.Position = UDim2.new(
        .5,
        -selfWindow.Width/2,
        .5,
        -selfWindow.Height/2
    )
    Main.BackgroundColor3 = CC("Window", Color3.fromRGB(35,35,35))
    Main.BorderSizePixel = 0
    Instance.new("UICorner",Main).CornerRadius = Radius
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = Main
    MainStroke.Color = CC("Stroke", Color3.fromRGB(58,63,75))
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.25
    selfWindow.MainFrame = Main
    --------------------------------------------------------
    -- Title Bar
    --------------------------------------------------------
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = Main
    TitleBar.Size = UDim2.new(
        1,
        0,
        0,
        38
    )
    TitleBar.BackgroundColor3 = CC("TitleBar", Color3.fromRGB(48,48,48))
    TitleBar.BorderSizePixel = 0
    Instance.new("UICorner",TitleBar).CornerRadius = Radius
    selfWindow.TitleBar = TitleBar
    
 --------------------------------------------------------
 -- Window Controls
 --------------------------------------------------------

local Controls = Instance.new("Frame")

Controls.Parent = TitleBar

Controls.AnchorPoint = Vector2.new(1,0)

Controls.Position = UDim2.new(1,-8,0,5)

Controls.Size = UDim2.fromOffset(90,28)

Controls.BackgroundTransparency = 1

--------------------------------------------------------

local Layout = Instance.new("UIListLayout")

Layout.Parent = Controls

Layout.FillDirection = Enum.FillDirection.Horizontal

Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right

Layout.Padding = UDim.new(0,4)

--------------------------------------------------------

local function CreateControl(Text)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.fromOffset(24,24)

    Button.BackgroundColor3 = CC("Control", Color3.fromRGB(52,56,66))

    Button.BorderSizePixel = 0

    Button.Font = Enum.Font.GothamBold

    Button.Text = Text

    Button.TextColor3 = CC("Text", Color3.new(1,1,1))

    Button.TextSize = 14

    Button.AutoButtonColor = false

    Instance.new("UICorner",Button).CornerRadius = RadiusSmall

    Button.Parent = Controls

    Button.MouseEnter:Connect(function()

        Fade(Button, (Text == "X") and CC("Danger", Color3.fromRGB(220,85,85)) or CC("ControlHover", Color3.fromRGB(72,77,90)))

    end)

    Button.MouseLeave:Connect(function()

        Fade(Button, CC("Control", Color3.fromRGB(52,56,66)))

    end)

    return Button

end

--------------------------------------------------------

local MinimizeButton = CreateControl("-")

local MaximizeButton = CreateControl("[]")

local CloseButton = CreateControl("X")

--------------------------------------------------------

selfWindow.MinimizeButton = MinimizeButton
selfWindow.MaximizeButton = MaximizeButton
selfWindow.CloseButton = CloseButton

--------------------------------------------------------
-- Window Buttons
--------------------------------------------------------

MinimizeButton.MouseButton1Click:Connect(function()

    selfWindow:ToggleMinimize()

end)

MaximizeButton.MouseButton1Click:Connect(function()

    selfWindow:ToggleFullscreen()

end)

CloseButton.MouseButton1Click:Connect(function()

    selfWindow:Close()

end)
    
    --------------------------------------------------------
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(12,0)
    Title.Size = UDim2.new(
        1,
        -24,
        1,
        0
    )
    Title.Text = selfWindow.TitleText
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = CC("Text", Color3.new(1,1,1))
    Title.TextSize = 17
    Title.TextXAlignment = Enum.TextXAlignment.Left
    selfWindow.TitleLabel = Title
    --------------------------------------------------------
    -- Sidebar (вкладки + индикатор модулей)
    --------------------------------------------------------
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.Position = UDim2.fromOffset(8,46)
    Sidebar.Size = UDim2.new(0,156,1,-54)
    Sidebar.BackgroundColor3 = CC("TabsPanel", Color3.fromRGB(45,45,45))
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner",Sidebar).CornerRadius = Radius
    selfWindow.Sidebar = Sidebar
    --------------------------------------------------------
    local TabsPanel = Instance.new("ScrollingFrame")
    TabsPanel.Name = "Tabs"
    TabsPanel.Parent = Sidebar
    TabsPanel.Position = UDim2.fromOffset(0,0)
    TabsPanel.Size = UDim2.new(1,0,1,-40)
    TabsPanel.BackgroundTransparency = 1
    TabsPanel.BorderSizePixel = 0
    TabsPanel.ScrollBarThickness = 3
    TabsPanel.CanvasSize = UDim2.new()
    selfWindow.TabPanel = TabsPanel
    --------------------------------------------------------
    local TabsPadding = Instance.new("UIPadding")
    TabsPadding.Parent = TabsPanel
    TabsPadding.PaddingTop = UDim.new(0,8)
    TabsPadding.PaddingBottom = UDim.new(0,6)
    TabsPadding.PaddingLeft = UDim.new(0,8)
    TabsPadding.PaddingRight = UDim.new(0,8)
    --------------------------------------------------------
    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.Parent = TabsPanel
    TabsLayout.Padding = UDim.new(0,3)
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabsPanel.CanvasSize = UDim2.fromOffset(
            0,
            TabsLayout.AbsoluteContentSize.Y+16
        )
    end)
    --------------------------------------------------------
    -- Заголовки групп вкладок
    --------------------------------------------------------
    local function GroupHeader(Name, Text, Order)
        local Header = Instance.new("TextLabel")
        Header.Name = Name
        Header.Parent = TabsPanel
        Header.LayoutOrder = Order
        Header.Size = UDim2.new(1,0,0,20)
        Header.BackgroundTransparency = 1
        Header.Font = Enum.Font.GothamBold
        Header.Text = Text
        Header.TextSize = 11
        Header.TextColor3 = CC("TextDim", Color3.fromRGB(150,158,171))
        Header.TextXAlignment = Enum.TextXAlignment.Left
        Header.Visible = false
        local HeaderPadding = Instance.new("UIPadding")
        HeaderPadding.Parent = Header
        HeaderPadding.PaddingLeft = UDim.new(0,6)
        return Header
    end
    selfWindow.MainHeader = GroupHeader("MainHeader", "ОСНОВНОЕ", 0)
    selfWindow.SecondaryHeader = GroupHeader("SecondaryHeader", "ДОПОЛНИТЕЛЬНОЕ", 1000)
    --------------------------------------------------------
    -- Индикатор загрузки модулей
    --------------------------------------------------------
    local Footer = Instance.new("TextButton")
    Footer.Name = "ModuleStatus"
    Footer.Parent = Sidebar
    Footer.AnchorPoint = Vector2.new(0,1)
    Footer.Position = UDim2.new(0,0,1,0)
    Footer.Size = UDim2.new(1,0,0,40)
    Footer.BackgroundTransparency = 1
    Footer.AutoButtonColor = false
    Footer.Text = ""
    local FooterLine = Instance.new("Frame")
    FooterLine.Parent = Footer
    FooterLine.Position = UDim2.fromOffset(10,0)
    FooterLine.Size = UDim2.new(1,-20,0,1)
    FooterLine.BackgroundColor3 = CC("Line", Color3.fromRGB(70,76,89))
    FooterLine.BackgroundTransparency = 0.4
    FooterLine.BorderSizePixel = 0
    local Dot = Instance.new("Frame")
    Dot.Name = "Dot"
    Dot.Parent = Footer
    Dot.AnchorPoint = Vector2.new(0,0.5)
    Dot.Position = UDim2.new(0,16,0.5,1)
    Dot.Size = UDim2.fromOffset(9,9)
    Dot.BackgroundColor3 = CC("Warning", Color3.fromRGB(240,180,60))
    Dot.BorderSizePixel = 0
    Instance.new("UICorner",Dot).CornerRadius = UDim.new(1,0)
    local FooterText = Instance.new("TextLabel")
    FooterText.Name = "Text"
    FooterText.Parent = Footer
    FooterText.BackgroundTransparency = 1
    FooterText.Position = UDim2.fromOffset(32,1)
    FooterText.Size = UDim2.new(1,-38,1,-1)
    FooterText.Font = Enum.Font.Gotham
    FooterText.Text = "Загрузка..."
    FooterText.TextSize = 12
    FooterText.TextColor3 = CC("TextMuted", Color3.fromRGB(184,190,201))
    FooterText.TextXAlignment = Enum.TextXAlignment.Left
    FooterText.TextTruncate = Enum.TextTruncate.AtEnd
    selfWindow.StatusDot = Dot
    selfWindow.StatusText = FooterText
    selfWindow.StatusButton = Footer
    selfWindow.ModuleReports = {}
    selfWindow.ModulesExpected = 0
    --------------------------------------------------------
    -- Content
    --------------------------------------------------------
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Parent = Main
    Content.Position = UDim2.fromOffset(172,46)
    Content.Size = UDim2.new(
        1,
        -180,
        1,
        -54
    )
    Content.BackgroundColor3 = CC("Content", Color3.fromRGB(40,40,40))
    Content.BorderSizePixel = 0
    Instance.new("UICorner",Content).CornerRadius = Radius
    selfWindow.Content = Content
    --------------------------------------------------------
    -- Заголовок страницы
    --------------------------------------------------------
    local PageHeader = Instance.new("Frame")
    PageHeader.Name = "PageHeader"
    PageHeader.Parent = Content
    PageHeader.Size = UDim2.new(1,0,0,HEADER_HEIGHT)
    PageHeader.BackgroundTransparency = 1
    local PageTitle = Instance.new("TextLabel")
    PageTitle.Name = "Title"
    PageTitle.Parent = PageHeader
    PageTitle.BackgroundTransparency = 1
    PageTitle.Position = UDim2.fromOffset(16,8)
    PageTitle.Size = UDim2.new(1,-32,0,22)
    PageTitle.Font = Enum.Font.GothamBold
    PageTitle.Text = ""
    PageTitle.TextSize = 18
    PageTitle.TextColor3 = CC("Text", Color3.new(1,1,1))
    PageTitle.TextXAlignment = Enum.TextXAlignment.Left
    local PageSub = Instance.new("TextLabel")
    PageSub.Name = "Subtitle"
    PageSub.Parent = PageHeader
    PageSub.BackgroundTransparency = 1
    PageSub.Position = UDim2.fromOffset(16,30)
    PageSub.Size = UDim2.new(1,-32,0,14)
    PageSub.Font = Enum.Font.Gotham
    PageSub.Text = ""
    PageSub.TextSize = 12
    PageSub.TextColor3 = CC("TextDim", Color3.fromRGB(150,158,171))
    PageSub.TextXAlignment = Enum.TextXAlignment.Left
    selfWindow.PageTitle = PageTitle
    selfWindow.PageSubtitle = PageSub
    --------------------------------------------------------
    -- Resize
    --------------------------------------------------------
    local Handle = Instance.new("Frame")
    Handle.Parent = Main
    Handle.AnchorPoint = Vector2.new(1,1)
    Handle.Position = UDim2.new(
        1,
        -3,
        1,
        -3
    )
    local TouchDevice = game:GetService("UserInputService").TouchEnabled
    Handle.Size = TouchDevice and UDim2.fromOffset(26,26) or UDim2.fromOffset(14,14)
    Handle.BackgroundColor3 = CC("Line", Color3.fromRGB(90,90,90))
    Handle.BorderSizePixel = 0
    Instance.new("UICorner",Handle).CornerRadius = RadiusSmall
    selfWindow.ResizeHandle = Handle
    --------------------------------------------------------
    Drag.Enable(
        TitleBar,
        Main
    )
    Resize.Enable(
        Main,
        Handle
    )
    
    selfWindow:_BuildStatusPopup()

    selfWindow:_BuildVisibilityControls(Settings)

    selfWindow:_BuildNotifications()

    table.insert(
        self.Windows,
        selfWindow
    )
    
    return selfWindow
end

------------------------------------------------------------
-- Create Tab
------------------------------------------------------------

function Window:CreateTab(Settings)

    Settings = Settings or {}

    local selfTab = setmetatable({}, Tab)

    selfTab.Window = self

    selfTab.Name = Settings.Name or "Tab"

    selfTab.Icon = Settings.Icon or ""

    selfTab.Order = Settings.Order or 50

    selfTab.Description = Settings.Description

    -- Группа: "Main" (основное) или "Secondary" (дополнительное).
    -- Не указана - решает Order (модули отдельно менять не нужно).
    local GroupSetting = Settings.Group
    if type(GroupSetting) == "string" then
        GroupSetting = string.lower(GroupSetting)
    end
    if GroupSetting == "secondary" or GroupSetting == "extra" or GroupSetting == "second" then
        selfTab.Group = "Secondary"
    elseif GroupSetting == "main" or GroupSetting == "primary" then
        selfTab.Group = "Main"
    elseif Settings.Secondary == true then
        selfTab.Group = "Secondary"
    else
        selfTab.Group = (selfTab.Order < MAIN_ORDER_LIMIT) and "Main" or "Secondary"
    end

    selfTab.Sections = {}

    --------------------------------------------------------
    -- Button
    --------------------------------------------------------

    local Button = Instance.new("TextButton")

    Button.Name = selfTab.Name

    Button.Parent = self.TabPanel

    Button.Size = UDim2.new(1,0,0,32)

    Button.BackgroundColor3 = CC("Row", Color3.fromRGB(60,60,60))

    Button.BorderSizePixel = 0

    Button.Font = Enum.Font.Gotham

    Button.TextColor3 = CC("Text", Color3.new(1,1,1))

    Button.TextSize = 14

    Button.Text = (selfTab.Icon ~= "" and (selfTab.Icon .. " ") or "") .. selfTab.Name

    Button.AutoButtonColor = false

    Button.TextXAlignment = Enum.TextXAlignment.Left

    local ButtonPadding = Instance.new("UIPadding")

    ButtonPadding.Parent = Button

    ButtonPadding.PaddingLeft = UDim.new(0,18)

    local Bar = Instance.new("Frame")

    Bar.Name = "AccentBar"

    Bar.Parent = Button

    Bar.AnchorPoint = Vector2.new(0,0.5)

    Bar.Position = UDim2.new(0,-14,0.5,0)

    Bar.Size = UDim2.fromOffset(3,18)

    Bar.BackgroundColor3 = CC("Accent", Color3.fromRGB(70,160,255))

    Bar.BorderSizePixel = 0

    Bar.Visible = false

    Instance.new("UICorner",Bar).CornerRadius = UDim.new(1,0)

    selfTab.AccentBar = Bar

    Button.MouseEnter:Connect(function()

        if selfTab.Window.ActiveTab ~= selfTab then

            Fade(Button, CC("RowHover", Color3.fromRGB(56,61,72)))

        end

    end)

    Button.MouseLeave:Connect(function()

        if selfTab.Window.ActiveTab ~= selfTab then

            Fade(Button, CC("Row", Color3.fromRGB(45,49,58)))

        end

    end)

    Instance.new("UICorner",Button).CornerRadius = RadiusSmall

    selfTab.Button = Button

    selfTab:_ApplyGroupOrder()

    selfTab.Button = Button

    --------------------------------------------------------
    -- Container
    --------------------------------------------------------

    local Container = Instance.new("ScrollingFrame")

    Container.Name = selfTab.Name

    Container.Parent = self.Content

    Container.Position = UDim2.fromOffset(0,HEADER_HEIGHT)

    Container.Size = UDim2.new(1,0,1,-HEADER_HEIGHT)

    Container.CanvasSize = UDim2.new()

    Container.ScrollBarThickness = 4

    Container.BackgroundTransparency = 1

    Container.BorderSizePixel = 0

    Container.Visible = false

    selfTab.Container = Container

    --------------------------------------------------------

    local Padding = Instance.new("UIPadding")

    Padding.Parent = Container

    Padding.PaddingTop = UDim.new(0,2)

    Padding.PaddingBottom = UDim.new(0,10)

    Padding.PaddingLeft = UDim.new(0,10)

    Padding.PaddingRight = UDim.new(0,10)

    --------------------------------------------------------

    local Layout = Instance.new("UIListLayout")

    Layout.Parent = Container

    Layout.Padding = UDim.new(0,8)

    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

        Container.CanvasSize = UDim2.fromOffset(

            0,

            Layout.AbsoluteContentSize.Y + 10

        )

    end)

    --------------------------------------------------------

    Button.MouseButton1Click:Connect(function()

        selfTab:Select()

    end)

    --------------------------------------------------------

    table.insert(

        self.Tabs,

        selfTab

    )

    self:_RefreshGroups()

    if #self.Tabs == 1 then

        selfTab:Select()

    end

    return selfTab

end

------------------------------------------------------------
-- Select Tab
------------------------------------------------------------

function Tab:Select()

    local Window = self.Window

    for _,CurrentTab in ipairs(Window.Tabs) do

        CurrentTab.Container.Visible = false

        CurrentTab.Button.BackgroundColor3 = CC("Row", Color3.fromRGB(45,49,58))

        if CurrentTab.AccentBar then

            CurrentTab.AccentBar.Visible = false

        end

    end

    self.Container.Visible = true

    self.Button.BackgroundColor3 = CC("RowHover", Color3.fromRGB(56,61,72))

    if self.AccentBar then

        self.AccentBar.Visible = true

    end

    Window.ActiveTab = self

    if Window.PageTitle then

        Window.PageTitle.Text = self.Name

        Window.PageSubtitle.Text = self.Description or ""

    end

end

------------------------------------------------------------
-- Tab groups (Основное / Дополнительное)
------------------------------------------------------------

function Tab:_ApplyGroupOrder()

    if self.Button then

        if self.Group == "Secondary" then

            self.Button.LayoutOrder = 1100 + self.Order

        else

            self.Button.LayoutOrder = 100 + self.Order

        end

    end

end

function Window:_RefreshGroups()

    local MainCount, SecondaryCount = 0, 0

    for _, TabObject in ipairs(self.Tabs) do

        if TabObject.Group == "Secondary" then

            SecondaryCount = SecondaryCount + 1

        else

            MainCount = MainCount + 1

        end

    end

    if self.MainHeader then

        -- заголовки нужны, только если есть обе группы

        local Both = MainCount > 0 and SecondaryCount > 0

        self.MainHeader.Visible = Both

        self.SecondaryHeader.Visible = Both

    end

end

-- Window:SetTabGroup("Console", "Secondary")
function Window:SetTabGroup(Name, Group)

    local TabObject = self:GetTab(Name)

    if not TabObject then

        return false

    end

    TabObject.Group = (string.lower(tostring(Group)) == "secondary") and "Secondary" or "Main"

    TabObject:_ApplyGroupOrder()

    self:_RefreshGroups()

    return true

end

------------------------------------------------------------
-- Destroy Tab
------------------------------------------------------------

function Tab:Destroy()

    if self.Button then

        self.Button:Destroy()

    end

    if self.Container then

        self.Container:Destroy()

    end

    for Index,TabObject in ipairs(self.Window.Tabs) do

        if TabObject == self then

            table.remove(

                self.Window.Tabs,

                Index

            )

            break

        end

    end

end

------------------------------------------------------------
-- Create Section
------------------------------------------------------------

function Tab:CreateSection(Settings)

    Settings = Settings or {}

    local selfSection = setmetatable({}, Section)

    selfSection.Tab = self

    selfSection.Name = Settings.Name or "Section"

    --------------------------------------------------------
    -- Section Frame
    --------------------------------------------------------

    local Frame = Instance.new("Frame")

    Frame.Name = selfSection.Name

    Frame.Parent = self.Container

    Frame.BackgroundColor3 = CC("Section", Color3.fromRGB(47,47,47))

    Frame.BorderSizePixel = 0

    Frame.AutomaticSize = Enum.AutomaticSize.Y

    Frame.Size = UDim2.new(1,0,0,0)

    Instance.new("UICorner",Frame).CornerRadius = Radius

    selfSection.Frame = Frame

    --------------------------------------------------------
    -- Padding
    --------------------------------------------------------

    local Padding = Instance.new("UIPadding")

    Padding.Parent = Frame

    Padding.PaddingTop = UDim.new(0,8)

    Padding.PaddingBottom = UDim.new(0,8)

    Padding.PaddingLeft = UDim.new(0,8)

    Padding.PaddingRight = UDim.new(0,8)

    --------------------------------------------------------
    -- Title
    --------------------------------------------------------

    local Title = Instance.new("TextLabel")

    Title.Parent = Frame

    Title.BackgroundTransparency = 1

    Title.Size = UDim2.new(1,0,0,22)

    Title.Font = Enum.Font.GothamBold

    Title.Text = selfSection.Name

    Title.TextColor3 = CC("Text", Color3.new(1,1,1))

    Title.TextSize = 15

    Title.TextXAlignment = Enum.TextXAlignment.Left

    selfSection.Title = Title

    local TitleLine = Instance.new("Frame")

    TitleLine.Parent = Frame

    TitleLine.Position = UDim2.fromOffset(0,24)

    TitleLine.Size = UDim2.new(1,0,0,1)

    TitleLine.BackgroundColor3 = CC("Line", Color3.fromRGB(70,76,89))

    TitleLine.BackgroundTransparency = 0.5

    TitleLine.BorderSizePixel = 0

    --------------------------------------------------------
    -- Container
    --------------------------------------------------------

    local Container = Instance.new("Frame")

    Container.Name = "Container"

    Container.Parent = Frame

    Container.Position = UDim2.fromOffset(0,32)

    Container.Size = UDim2.new(1,0,0,0)

    Container.BackgroundTransparency = 1

    Container.AutomaticSize = Enum.AutomaticSize.Y

    selfSection.Container = Container

    --------------------------------------------------------
    -- Layout
    --------------------------------------------------------

    local Layout = Instance.new("UIListLayout")

    Layout.Parent = Container

    Layout.Padding = UDim.new(0,6)

    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    selfSection.Layout = Layout

    --------------------------------------------------------

    table.insert(

        self.Sections,

        selfSection

    )

    return selfSection

end

------------------------------------------------------------
-- Destroy Section
------------------------------------------------------------

function Section:Destroy()

    if self.Frame then

        self.Frame:Destroy()

    end

    for Index,Object in ipairs(self.Tab.Sections) do

        if Object == self then

            table.remove(

                self.Tab.Sections,

                Index

            )

            break

        end

    end

end

------------------------------------------------------------
-- Clear Section
------------------------------------------------------------

function Section:Clear()

    for _,Child in ipairs(self.Container:GetChildren()) do

        if not Child:IsA("UIListLayout") then

            Child:Destroy()

        end

    end

end

------------------------------------------------------------
-- Widget API
------------------------------------------------------------

-- Методы Section:Add<Имя> создаются автоматически для каждого виджета из registry.lua.
-- Новый виджет: файл gui/widgets/<имя>.lua + одна строка в registry.lua, ядро не трогаем.
local WidgetMethods = {}

for RegisteredName, RegisteredWidget in pairs(Widgets) do

    if type(RegisteredName) == "string"
        and type(RegisteredWidget) == "table"
        and type(RegisteredWidget.Create) == "function" then

        table.insert(WidgetMethods, RegisteredName)

    end

end

table.sort(WidgetMethods)

for _, WidgetName in ipairs(WidgetMethods) do

    Section["Add"..WidgetName] = function(self, Settings)

        local Widget = Widgets[WidgetName]

        assert(
            Widget,
            "Widget '"..WidgetName.."' is not registered."
        )

        Settings = Settings or {}

        -- Toggle: клавиша на шестерёнке и уведомления о переключении
        if WidgetName == "Toggle" then

            local Win = self.Tab and self.Tab.Window

            local TabName = self.Tab and self.Tab.Name or "Tab"

            local ToggleId = TabName .. "/" .. self.Name .. "/" .. tostring(Settings.Text or "Toggle")

            local Copy = {}

            for Key, Value in pairs(Settings) do

                Copy[Key] = Value

            end

            if Win and Win.Prefs then

                Copy.OnToggled = function(State)

                    Win:NotifyToggle(Settings.Text or "Toggle", State, ToggleId)

                end

            end

            Settings = Copy

        end

        local object

        if WidgetName == "Sound" or Widget.NoParent == true then
            object = Widget.Create(Settings)
        else
            object = Widget.Create(self.Container, Settings)
        end

        local CM = _G.ConfigManager
        if CM and CM.RegisterWidget and object then
            local tabName = self.Tab and self.Tab.Name or "Tab"
            CM.RegisterWidget({
                Kind = WidgetName,
                Widget = object,
                Tab = tabName,
                Section = self.Name,
                Text = Settings.Text or Settings.Placeholder,
                Placeholder = Settings.Placeholder,
                ConfigKey = Settings.ConfigKey or Settings.Flag,
                Flag = Settings.Flag,
            })
        end

        return object

    end

end

------------------------------------------------------------
-- Индикатор загрузки модулей
-- Window:BeginModules(total) - сколько модулей ожидается
-- Window:ReportModule(name, ok, err) - результат загрузки одного модуля
------------------------------------------------------------

function Window:_RefreshStatus()

    if not self.StatusDot then

        return

    end

    local Done, Failed = 0, 0

    for _, Report in ipairs(self.ModuleReports) do

        if Report.Ok then

            Done = Done + 1

        else

            Failed = Failed + 1

        end

    end

    local Total = math.max(self.ModulesExpected or 0, Done + Failed)

    if Failed > 0 then

        self.StatusDot.BackgroundColor3 = CC("Danger", Color3.fromRGB(220,85,85))

        self.StatusText.Text = "Ошибки: " .. Failed .. " из " .. Total

    elseif (self.ModulesExpected or 0) > Done then

        self.StatusDot.BackgroundColor3 = CC("Warning", Color3.fromRGB(240,180,60))

        self.StatusText.Text = "Загрузка " .. Done .. "/" .. self.ModulesExpected

    else

        self.StatusDot.BackgroundColor3 = CC("Success", Color3.fromRGB(70,194,138))

        self.StatusText.Text = "Все модули загружены (" .. Done .. ")"

    end

    -- список в окошке, если оно открыто
    if self.StatusPopupText then

        local Lines = {}

        for _, Report in ipairs(self.ModuleReports) do

            local Line = (Report.Ok and "+ " or "x ") .. tostring(Report.Name)

            if not Report.Ok and Report.Error then

                Line = Line .. ": " .. tostring(Report.Error)

            end

            table.insert(Lines, Line)

        end

        self.StatusPopupText.Text = (#Lines > 0) and table.concat(Lines, "\n") or "Пока нет данных"

    end

end

function Window:BeginModules(Total)

    self.ModulesExpected = tonumber(Total) or 0

    self:_RefreshStatus()

end

function Window:ReportModule(Name, Ok, Err)

    table.insert(self.ModuleReports, { Name = Name, Ok = Ok and true or false, Error = Err })

    self:_RefreshStatus()

    if not Ok then

        self:Notify({
            Title = "Модуль не загрузился: " .. tostring(Name),
            Text = tostring(Err or "неизвестная ошибка"),
            Type = "error",
            Duration = 8,
        })

    elseif (self.ModulesExpected or 0) > 0 and #self.ModuleReports >= self.ModulesExpected then

        local Failed = 0

        for _, Report in ipairs(self.ModuleReports) do

            if not Report.Ok then

                Failed = Failed + 1

            end

        end

        if Failed == 0 then

            self:Notify({
                Title = "UMU",
                Text = "Все модули загружены (" .. #self.ModuleReports .. ")",
                Type = "success",
                Key = "modules-loaded",
            })

        end

    end

end

function Window:_BuildStatusPopup()

    local Popup = Instance.new("Frame")

    Popup.Name = "ModulePopup"

    Popup.Parent = self.MainFrame

    Popup.AnchorPoint = Vector2.new(0,1)

    Popup.Position = UDim2.new(0,8,1,-48)

    Popup.Size = UDim2.fromOffset(220,0)

    Popup.AutomaticSize = Enum.AutomaticSize.Y

    Popup.BackgroundColor3 = CC("Option", Color3.fromRGB(39,43,51))

    Popup.BorderSizePixel = 0

    Popup.Visible = false

    Popup.ZIndex = 20

    Instance.new("UICorner",Popup).CornerRadius = RadiusSmall

    local PopupStroke = Instance.new("UIStroke")

    PopupStroke.Parent = Popup

    PopupStroke.Color = CC("Stroke", Color3.fromRGB(58,63,75))

    local PopupPadding = Instance.new("UIPadding")

    PopupPadding.Parent = Popup

    PopupPadding.PaddingTop = UDim.new(0,8)

    PopupPadding.PaddingBottom = UDim.new(0,8)

    PopupPadding.PaddingLeft = UDim.new(0,10)

    PopupPadding.PaddingRight = UDim.new(0,10)

    local PopupText = Instance.new("TextLabel")

    PopupText.Parent = Popup

    PopupText.BackgroundTransparency = 1

    PopupText.Size = UDim2.new(1,0,0,0)

    PopupText.AutomaticSize = Enum.AutomaticSize.Y

    PopupText.Font = Enum.Font.Gotham

    PopupText.TextSize = 12

    PopupText.TextWrapped = true

    PopupText.TextColor3 = CC("Text", Color3.new(1,1,1))

    PopupText.TextXAlignment = Enum.TextXAlignment.Left

    PopupText.TextYAlignment = Enum.TextYAlignment.Top

    PopupText.ZIndex = 21

    PopupText.Text = ""

    self.StatusPopup = Popup

    self.StatusPopupText = PopupText

    self.StatusButton.MouseButton1Click:Connect(function()

        Popup.Visible = not Popup.Visible

        self:_RefreshStatus()

    end)

    -- если загрузчик не сообщает о модулях, не висим на "Загрузка..."
    task.delay(8, function()

        if self.StatusDot and (self.ModulesExpected or 0) == 0 and #self.ModuleReports == 0 then

            self.StatusDot.BackgroundColor3 = CC("Success", Color3.fromRGB(70,194,138))

            self.StatusText.Text = "Вкладок: " .. #self.Tabs

        end

    end)

end

------------------------------------------------------------
-- Показать / скрыть окно
-- Кнопка на экране (по умолчанию только на телефоне) и клавиша (по умолчанию RightShift).
-- Settings: ToggleKey = Enum.KeyCode.X | false, ShowButton = true | false
------------------------------------------------------------

function Window:ToggleVisible()

    if self.MainFrame then

        self.MainFrame.Visible = not self.MainFrame.Visible

    end

end

-- Настройки окна (клавиша, кнопка) хранятся в отдельном файле и общие для всех профилей
local PREFS_FILE = "UMU_Window.json"

local function LoadPrefs()

    local HttpService = game:GetService("HttpService")

    local Prefs = {}

    local CM = _G.ConfigManager

    if CM and CM.LoadGlobal then

        return CM.LoadGlobal("Window")

    end

    pcall(function()

        if isfile and isfile(PREFS_FILE) then

            local Data = HttpService:JSONDecode(readfile(PREFS_FILE))

            if type(Data) == "table" then

                Prefs = Data

            end

        end

    end)

    return Prefs

end

function Window:_SavePrefs()

    local CM = _G.ConfigManager

    if CM and CM.SaveGlobal then

        CM.SaveGlobal("Window", self.Prefs)

        return

    end

    local HttpService = game:GetService("HttpService")

    pcall(function()

        if writefile then

            writefile(PREFS_FILE, HttpService:JSONEncode(self.Prefs))

        end

    end)

end

function Window:GetToggleKey()

    return self.ToggleKeyCode

end

-- Window:SetToggleKey(Enum.KeyCode.F4)   nil / Unknown - клавиша отключена
function Window:SetToggleKey(Key)

    if typeof(Key) ~= "EnumItem" or Key == Enum.KeyCode.Unknown then

        Key = nil

    end

    self.ToggleKeyCode = Key

    self.Prefs.ToggleKey = Key and Key.Name or "None"

    self:_SavePrefs()

end

function Window:GetToggleButton()

    return self.ToggleButton ~= nil and self.ToggleButton.Visible

end

function Window:SetToggleButton(State)

    State = State and true or false

    if self.ToggleButton then

        self.ToggleButton.Visible = State

    end

    self.Prefs.ShowButton = State

    self:_SavePrefs()

end

function Window:GetToggleButtonSize()

    return self.Prefs.ButtonSize or 44

end

function Window:SetToggleButtonSize(Size)

    Size = math.clamp(tonumber(Size) or 44, 28, 80)

    if self.ToggleButton then

        self.ToggleButton.Size = UDim2.fromOffset(Size, Size)

    end

    self.Prefs.ButtonSize = Size

    self:_SavePrefs()

end

function Window:ResetToggleButtonPosition()

    self.Prefs.ButtonX = nil

    self.Prefs.ButtonY = nil

    if self.ToggleButton then

        self.ToggleButton.Position = UDim2.new(0,6,0.5,0)

        self.ToggleButton.AnchorPoint = Vector2.new(0,0.5)

    end

    self:_SavePrefs()

end

function Window:_BuildVisibilityControls(Settings)

    local UserInputService = game:GetService("UserInputService")

    self.Prefs = LoadPrefs()

    -- клавиша: сохранённая > из Settings.ToggleKey > RightShift
    local KeyName = self.Prefs.ToggleKey

    local Key

    if KeyName == "None" then

        Key = nil

    elseif type(KeyName) == "string" and Enum.KeyCode[KeyName] then

        Key = Enum.KeyCode[KeyName]

    elseif Settings.ToggleKey == false then

        Key = nil

    elseif typeof(Settings.ToggleKey) == "EnumItem" then

        Key = Settings.ToggleKey

    else

        Key = Enum.KeyCode.RightShift

    end

    self.ToggleKeyCode = Key

    self.ToggleConnection = UserInputService.InputBegan:Connect(function(Input)

        local Current = self.ToggleKeyCode

        if not Current or Input.KeyCode ~= Current then

            return

        end

        -- не реагируем, пока пишешь в поле или выбираешь клавишу
        if UserInputService:GetFocusedTextBox() or _G.UMUCapturingKey then

            return

        end

        self:ToggleVisible()

    end)

    -- кнопка на экране: сохранённое > Settings.ShowButton > только на телефоне
    local ShowButton = self.Prefs.ShowButton

    if ShowButton == nil then

        ShowButton = Settings.ShowButton

    end

    if ShowButton == nil then

        ShowButton = UserInputService.TouchEnabled

    end

    local Size = math.clamp(tonumber(self.Prefs.ButtonSize) or 44, 28, 80)

    local Open = Instance.new("TextButton")

    Open.Name = "ToggleButton"

    Open.Parent = self.Gui

    Open.BackgroundColor3 = CC("Accent", Color3.fromRGB(70,160,255))

    Open.BackgroundTransparency = 0.15

    Open.BorderSizePixel = 0

    Open.AutoButtonColor = false

    Open.Font = Enum.Font.GothamBold

    Open.Text = "UMU"

    Open.TextSize = 12

    Open.TextColor3 = Color3.fromRGB(12,21,34)

    Open.ZIndex = 30

    Open.Size = UDim2.fromOffset(Size, Size)

    Open.Visible = ShowButton and true or false

    Instance.new("UICorner",Open).CornerRadius = UDim.new(0,12)

    if type(self.Prefs.ButtonX) == "number" and type(self.Prefs.ButtonY) == "number" then

        Open.AnchorPoint = Vector2.new(0.5,0.5)

        Open.Position = UDim2.fromScale(
            math.clamp(self.Prefs.ButtonX, 0.02, 0.98),
            math.clamp(self.Prefs.ButtonY, 0.02, 0.98)
        )

    else

        Open.AnchorPoint = Vector2.new(0,0.5)

        Open.Position = UDim2.new(0,6,0.5,0)

    end

    -- перетаскивание: короткое касание - показать/скрыть, сдвиг - переместить кнопку
    local Pressing = false
    local Moved = false
    local StartPointer, StartCenter

    Open.InputBegan:Connect(function(Input)

        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
            and Input.UserInputType ~= Enum.UserInputType.Touch then

            return

        end

        Pressing = true

        Moved = false

        StartPointer = Vector2.new(Input.Position.X, Input.Position.Y)

        StartCenter = Open.AbsolutePosition + Open.AbsoluteSize / 2

    end)

    local ChangedConnection = UserInputService.InputChanged:Connect(function(Input)

        if not Pressing then

            return

        end

        if Input.UserInputType ~= Enum.UserInputType.MouseMovement
            and Input.UserInputType ~= Enum.UserInputType.Touch then

            return

        end

        local Pointer = Vector2.new(Input.Position.X, Input.Position.Y)

        if not Moved and (Pointer - StartPointer).Magnitude > 8 then

            Moved = true

        end

        if Moved and self.Gui then

            local Screen = self.Gui.AbsoluteSize

            local Center = StartCenter + (Pointer - StartPointer)

            local PX = math.clamp(Center.X / Screen.X, 0.02, 0.98)

            local PY = math.clamp(Center.Y / Screen.Y, 0.02, 0.98)

            Open.AnchorPoint = Vector2.new(0.5,0.5)

            Open.Position = UDim2.fromScale(PX, PY)

            self.Prefs.ButtonX = PX

            self.Prefs.ButtonY = PY

        end

    end)

    local EndedConnection = UserInputService.InputEnded:Connect(function(Input)

        if not Pressing then

            return

        end

        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
            and Input.UserInputType ~= Enum.UserInputType.Touch then

            return

        end

        Pressing = false

        if Moved then

            self:_SavePrefs()

        else

            self:ToggleVisible()

        end

    end)

    self.ToggleButton = Open

    self.ExtraConnections = { ChangedConnection, EndedConnection }

end

------------------------------------------------------------
-- Уведомления справа
-- Window:Notify({ Title = "...", Text = "...", Type = "info|success|warn|error",
--                 Duration = 3.5, Key = "для замены прошлого", Sound = "rbxassetid://..." })
------------------------------------------------------------

local NOTIFY_MAX = 5

function Window:_BuildNotifications()

    local Host = Instance.new("Frame")

    Host.Name = "Notifications"

    Host.Parent = self.Gui

    Host.AnchorPoint = Vector2.new(1,1)

    Host.Position = UDim2.new(1,-14,1,-14)

    Host.Size = UDim2.new(0,270,1,-28)

    Host.BackgroundTransparency = 1

    Host.ZIndex = 40

    local HostLayout = Instance.new("UIListLayout")

    HostLayout.Parent = Host

    HostLayout.Padding = UDim.new(0,6)

    HostLayout.SortOrder = Enum.SortOrder.LayoutOrder

    HostLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

    self.NotifyHost = Host

    self.NotifyList = {}

    self.NotifyByKey = {}

    self.NotifyCounter = 0

end

function Window:GetNotifications()

    return self.Prefs.Notifications ~= false

end

function Window:SetNotifications(State)

    self.Prefs.Notifications = State and true or false

    self:_SavePrefs()

end

function Window:GetNotifyToggles()

    return self.Prefs.NotifyToggles ~= false

end

function Window:SetNotifyToggles(State)

    self.Prefs.NotifyToggles = State and true or false

    self:_SavePrefs()

end

function Window:GetNotifyDuration()

    return tonumber(self.Prefs.NotifyDuration) or 3.5

end

function Window:SetNotifyDuration(Seconds)

    self.Prefs.NotifyDuration = math.clamp(tonumber(Seconds) or 3.5, 1, 15)

    self:_SavePrefs()

end

function Window:_DismissNotification(Entry)

    if Entry.Dismissed then

        return

    end

    Entry.Dismissed = true

    for Index, Other in ipairs(self.NotifyList) do

        if Other == Entry then

            table.remove(self.NotifyList, Index)

            break

        end

    end

    if Entry.Key and self.NotifyByKey[Entry.Key] == Entry then

        self.NotifyByKey[Entry.Key] = nil

    end

    local Tween = TweenService:Create(
        Entry.Card,
        TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(1,24,0,0) }
    )

    Tween:Play()

    Tween.Completed:Once(function()

        Entry.Holder:Destroy()

    end)

end

function Window:Notify(Options)

    if not self.NotifyHost or not self.Gui then

        return

    end

    Options = Options or {}

    local Kind = Options.Type or "info"

    -- при выключенных уведомлениях показываем только ошибки
    if not self:GetNotifications() and Kind ~= "error" then

        return

    end

    local Colors = {
        info = CC("Accent", Color3.fromRGB(70,160,255)),
        success = CC("Success", Color3.fromRGB(70,194,138)),
        warn = CC("Warning", Color3.fromRGB(240,180,60)),
        error = CC("Danger", Color3.fromRGB(220,85,85)),
    }

    local Accent = Colors[Kind] or Colors.info

    local Duration = tonumber(Options.Duration) or self:GetNotifyDuration()

    if Options.Sound and _G.SoundWidget then

        pcall(_G.SoundWidget.Play, Options.Sound)

    end

    -- то же событие (Key) обновляет прошлое уведомление, а не копится стопкой
    local Existing = Options.Key and self.NotifyByKey[Options.Key]

    if Existing and not Existing.Dismissed then

        Existing.Title.Text = tostring(Options.Title or "")

        Existing.Body.Text = tostring(Options.Text or "")

        Existing.Bar.BackgroundColor3 = Accent

        Existing.Token = Existing.Token + 1

        local Token = Existing.Token

        task.delay(Duration, function()

            if Existing.Token == Token then

                self:_DismissNotification(Existing)

            end

        end)

        return Existing

    end

    self.NotifyCounter = self.NotifyCounter + 1

    local Holder = Instance.new("Frame")

    Holder.Name = "Notice"

    Holder.Parent = self.NotifyHost

    Holder.LayoutOrder = self.NotifyCounter

    Holder.BackgroundTransparency = 1

    Holder.Size = UDim2.new(1,0,0,0)

    Holder.AutomaticSize = Enum.AutomaticSize.Y

    local Card = Instance.new("TextButton")

    Card.Parent = Holder

    Card.Text = ""

    Card.AutoButtonColor = false

    Card.Position = UDim2.new(1,24,0,0)

    Card.Size = UDim2.new(1,0,0,0)

    Card.AutomaticSize = Enum.AutomaticSize.Y

    Card.BackgroundColor3 = CC("Option", Color3.fromRGB(39,43,51))

    Card.BorderSizePixel = 0

    Card.ZIndex = 41

    Instance.new("UICorner",Card).CornerRadius = RadiusSmall

    local CardStroke = Instance.new("UIStroke")

    CardStroke.Parent = Card

    CardStroke.Color = CC("Stroke", Color3.fromRGB(58,63,75))

    local Bar = Instance.new("Frame")

    Bar.Parent = Card

    Bar.Size = UDim2.new(0,3,1,0)

    Bar.BackgroundColor3 = Accent

    Bar.BorderSizePixel = 0

    Bar.ZIndex = 42

    local Inner = Instance.new("Frame")

    Inner.Parent = Card

    Inner.BackgroundTransparency = 1

    Inner.Position = UDim2.fromOffset(12,0)

    Inner.Size = UDim2.new(1,-12,0,0)

    Inner.AutomaticSize = Enum.AutomaticSize.Y

    local InnerLayout = Instance.new("UIListLayout")

    InnerLayout.Parent = Inner

    InnerLayout.Padding = UDim.new(0,2)

    local InnerPadding = Instance.new("UIPadding")

    InnerPadding.Parent = Inner

    InnerPadding.PaddingTop = UDim.new(0,8)

    InnerPadding.PaddingBottom = UDim.new(0,8)

    InnerPadding.PaddingRight = UDim.new(0,10)

    local Title = Instance.new("TextLabel")

    Title.Parent = Inner

    Title.BackgroundTransparency = 1

    Title.Size = UDim2.new(1,0,0,0)

    Title.AutomaticSize = Enum.AutomaticSize.Y

    Title.Font = Enum.Font.GothamBold

    Title.TextSize = 13

    Title.TextWrapped = true

    Title.TextXAlignment = Enum.TextXAlignment.Left

    Title.TextColor3 = CC("Text", Color3.new(1,1,1))

    Title.Text = tostring(Options.Title or "")

    Title.ZIndex = 42

    Title.LayoutOrder = 1

    local Body = Instance.new("TextLabel")

    Body.Parent = Inner

    Body.BackgroundTransparency = 1

    Body.Size = UDim2.new(1,0,0,0)

    Body.AutomaticSize = Enum.AutomaticSize.Y

    Body.Font = Enum.Font.Gotham

    Body.TextSize = 12

    Body.TextWrapped = true

    Body.TextXAlignment = Enum.TextXAlignment.Left

    Body.TextColor3 = CC("TextMuted", Color3.fromRGB(184,190,201))

    Body.Text = tostring(Options.Text or "")

    Body.ZIndex = 42

    Body.LayoutOrder = 2

    local Entry = {
        Holder = Holder,
        Card = Card,
        Title = Title,
        Body = Body,
        Bar = Bar,
        Key = Options.Key,
        Token = 1,
        Dismissed = false,
    }

    table.insert(self.NotifyList, Entry)

    if Options.Key then

        self.NotifyByKey[Options.Key] = Entry

    end

    TweenService:Create(
        Card,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = UDim2.new(0,0,0,0) }
    ):Play()

    Card.MouseButton1Click:Connect(function()

        self:_DismissNotification(Entry)

    end)

    while #self.NotifyList > NOTIFY_MAX do

        self:_DismissNotification(self.NotifyList[1])

    end

    task.delay(Duration, function()

        if Entry.Token == 1 then

            self:_DismissNotification(Entry)

        end

    end)

    return Entry

end

-- Уведомление о переключателе (вызывается самим тоглом при нажатии или по клавише)
function Window:NotifyToggle(Name, State, Id)

    if not self:GetNotifyToggles() then

        return

    end

    self:Notify({
        Title = tostring(Name),
        Text = State and "Включено" or "Выключено",
        Type = State and "success" or "info",
        Key = "toggle:" .. tostring(Id or Name),
        Duration = 2.2,
    })

end

------------------------------------------------------------
-- Window Show
------------------------------------------------------------

function Window:Show()

    if self.Gui then

        self.Gui.Enabled = true

    end

end

------------------------------------------------------------
-- Window Hide
------------------------------------------------------------

function Window:Hide()

    if self.Gui then

        self.Gui.Enabled = false

    end

end

------------------------------------------------------------
-- Window Destroy
------------------------------------------------------------

function Window:Destroy()

    if self.ToggleConnection then

        self.ToggleConnection:Disconnect()

        self.ToggleConnection = nil

    end

    if self.ExtraConnections then

        for _, Connection in ipairs(self.ExtraConnections) do

            Connection:Disconnect()

        end

        self.ExtraConnections = nil

    end

    if self.Gui then

        self.Gui:Destroy()

    end

    self.Gui = nil
    self.MainFrame = nil
    self.TitleBar = nil
    self.TitleLabel = nil
    self.TabPanel = nil
    self.Content = nil
    self.ResizeHandle = nil

    if self.Library and self.Library.Windows then

        for Index, Object in ipairs(self.Library.Windows) do

            if Object == self then

                table.remove(
                    self.Library.Windows,
                    Index
                )

                break

            end

        end

    end

end

------------------------------------------------------------
-- Window GetTab
------------------------------------------------------------

function Window:GetTab(Name)

    for _, TabObject in ipairs(self.Tabs) do

        if TabObject.Name == Name then

            return TabObject
        end

    end

    return nil

end

------------------------------------------------------------
-- Tab GetSection
------------------------------------------------------------

function Tab:GetSection(Name)

    for _, SectionObject in ipairs(self.Sections) do

        if SectionObject.Name == Name then

            return SectionObject
        end

    end

    return nil

end

------------------------------------------------------------
-- Window SetTitle
------------------------------------------------------------

function Window:SetTitle(Text)

    self.TitleText = Text

    self.TitleLabel.Text = Text

end

------------------------------------------------------------
-- Window SetSize
------------------------------------------------------------

function Window:SetSize(X,Y)

    self.Width = X

    self.Height = Y

    self.MainFrame.Size = UDim2.fromOffset(X,Y)

end

------------------------------------------------------------
-- Library Destroy
------------------------------------------------------------

function Library:Destroy()

    for _, WindowObject in ipairs(self.Windows) do

        if WindowObject.Gui then

            WindowObject.Gui:Destroy()

        end

    end

    table.clear(self.Windows)

end

------------------------------------------------------------
-- Window Control Methods
------------------------------------------------------------

------------------------------------------------------------
-- Minimize
------------------------------------------------------------

function Window:Minimize()

    if not self.MainFrame or self.IsMinimized then

        return

    end

    self.IsMinimized = true

    self.OriginalSize = self.MainFrame.Size

    for _, Child in ipairs(self.MainFrame:GetChildren()) do

        if Child:IsA("GuiObject") and Child ~= self.TitleBar then

            Child.Visible = false

        end

    end

    self.MainFrame.Size = UDim2.fromOffset(

        self.MainFrame.Size.X.Offset,

        self.TitleBar.AbsoluteSize.Y

    )

end

------------------------------------------------------------
-- Restore Window
------------------------------------------------------------

function Window:Maximize()

    if not self.MainFrame or not self.IsMinimized then

        return

    end

    self.IsMinimized = false

    for _, Child in ipairs(self.MainFrame:GetChildren()) do

        if Child:IsA("GuiObject") then

            Child.Visible = true

        end

    end

    if self.OriginalSize then

        self.MainFrame.Size = self.OriginalSize

    end

    if self.StatusPopup then

        self.StatusPopup.Visible = false

    end

end

------------------------------------------------------------
-- Toggle Minimize
------------------------------------------------------------

function Window:ToggleMinimize()

    if self.IsMinimized then

        self:Maximize()

    else

        self:Minimize()

    end

end

------------------------------------------------------------
-- Toggle Fullscreen
------------------------------------------------------------

function Window:ToggleFullscreen()

    if not self.MainFrame then

        return

    end

    if not self.IsFullscreen then

        self.PreviousSize = self.MainFrame.Size

        self.PreviousPosition = self.MainFrame.Position

        self.MainFrame.Position = UDim2.new(

            0,

            0,

            0,

            0

        )

        self.MainFrame.Size = UDim2.new(

            1,

            0,

            1,

            0

        )

    else

        if self.PreviousPosition then

            self.MainFrame.Position = self.PreviousPosition

        end

        if self.PreviousSize then

            self.MainFrame.Size = self.PreviousSize

        end

    end

    self.IsFullscreen = not self.IsFullscreen

end

------------------------------------------------------------
-- Close
------------------------------------------------------------

function Window:Close()

    if self.ToggleConnection then

        self.ToggleConnection:Disconnect()

        self.ToggleConnection = nil

    end

    if self.ExtraConnections then

        for _, Connection in ipairs(self.ExtraConnections) do

            Connection:Disconnect()

        end

        self.ExtraConnections = nil

    end

    if self.Gui then

        self.Gui:Destroy()

    end

    self.Gui = nil

    self.MainFrame = nil

    self.TitleBar = nil

    self.Content = nil

    self.TabPanel = nil

    if self.Library and self.Library.Windows then

        for Index, WindowObject in ipairs(self.Library.Windows) do

            if WindowObject == self then

                table.remove(

                    self.Library.Windows,

                    Index

                )

                break

            end

        end

    end

end

------------------------------------------------------------
-- Return
------------------------------------------------------------

return Library
 

