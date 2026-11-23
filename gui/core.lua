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
    -- Tabs Panel
    --------------------------------------------------------
    local TabsPanel = Instance.new("ScrollingFrame")
    TabsPanel.Parent = Main
    TabsPanel.Position = UDim2.fromOffset(10,48)
    TabsPanel.Size = UDim2.new(
        0,
        145,
        1,
        -58
    )
    TabsPanel.BackgroundColor3 = CC("TabsPanel", Color3.fromRGB(45,45,45))
    TabsPanel.BorderSizePixel = 0
    TabsPanel.ScrollBarThickness = 4
    TabsPanel.CanvasSize = UDim2.new()
    Instance.new("UICorner",TabsPanel).CornerRadius = Radius
    selfWindow.TabPanel = TabsPanel
    --------------------------------------------------------
    local TabsLayout = Instance.new("UIListLayout")
    TabsLayout.Parent = TabsPanel
    TabsLayout.Padding = UDim.new(0,5)
    TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabsPanel.CanvasSize = UDim2.fromOffset(
            0,
            TabsLayout.AbsoluteContentSize.Y+8
        )
    end)
    --------------------------------------------------------
    -- Content
    --------------------------------------------------------
    local Content = Instance.new("Frame")
    Content.Parent = Main
    Content.Position = UDim2.fromOffset(165,48)
    Content.Size = UDim2.new(
        1,
        -175,
        1,
        -58
    )
    Content.BackgroundColor3 = CC("Content", Color3.fromRGB(40,40,40))
    Content.BorderSizePixel = 0
    Instance.new("UICorner",Content).CornerRadius = Radius
    selfWindow.Content = Content
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
    Handle.Size = UDim2.fromOffset(14,14)
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

    selfTab.Sections = {}

    --------------------------------------------------------
    -- Button
    --------------------------------------------------------

    local Button = Instance.new("TextButton")

    Button.Name = selfTab.Name

    Button.Parent = self.TabPanel

    Button.Size = UDim2.new(1,-12,0,32)

    Button.BackgroundColor3 = CC("Row", Color3.fromRGB(60,60,60))

    Button.BorderSizePixel = 0

    Button.Font = Enum.Font.Gotham

    Button.TextColor3 = CC("Text", Color3.new(1,1,1))

    Button.TextSize = 14

    Button.Text = selfTab.Icon .. " " .. selfTab.Name

    Button.AutoButtonColor = false

    Button.TextXAlignment = Enum.TextXAlignment.Left

    local ButtonPadding = Instance.new("UIPadding")

    ButtonPadding.Parent = Button

    ButtonPadding.PaddingLeft = UDim.new(0,14)

    local Bar = Instance.new("Frame")

    Bar.Name = "AccentBar"

    Bar.Parent = Button

    Bar.AnchorPoint = Vector2.new(0,0.5)

    Bar.Position = UDim2.new(0,4,0.5,0)

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

    Button.LayoutOrder = selfTab.Order

    selfTab.Button = Button

    --------------------------------------------------------
    -- Container
    --------------------------------------------------------

    local Container = Instance.new("ScrollingFrame")

    Container.Name = selfTab.Name

    Container.Parent = self.Content

    Container.Size = UDim2.fromScale(1,1)

    Container.CanvasSize = UDim2.new()

    Container.ScrollBarThickness = 4

    Container.BackgroundTransparency = 1

    Container.BorderSizePixel = 0

    Container.Visible = false

    selfTab.Container = Container

    --------------------------------------------------------

    local Padding = Instance.new("UIPadding")

    Padding.Parent = Container

    Padding.PaddingTop = UDim.new(0,8)

    Padding.PaddingBottom = UDim.new(0,8)

    Padding.PaddingLeft = UDim.new(0,8)

    Padding.PaddingRight = UDim.new(0,8)

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

local WidgetMethods = {

    "Label",

    "Button",

    "Toggle",

    "Slider",

    "Dropdown",

    "Textbox",

    "Separator",

    "Keybind",
    
    "Image",

    "Sound"

}

for _, WidgetName in ipairs(WidgetMethods) do

    Section["Add"..WidgetName] = function(self, Settings)

        local Widget = Widgets[WidgetName]

        assert(
            Widget,
            "Widget '"..WidgetName.."' is not registered."
        )

        Settings = Settings or {}

        local object

        if WidgetName == "Sound" then
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
 

