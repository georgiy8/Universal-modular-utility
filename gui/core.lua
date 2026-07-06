--========================================================--
-- Pilgrammed GUI Library
-- Core.lua
--========================================================--

------------------------------------------------------------
-- Repository
------------------------------------------------------------

local REPO = "https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/"

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

local Drag = Import("gui/services/drag.lua")
local Resize = Import("gui/services/resize.lua")

------------------------------------------------------------
-- Widgets
------------------------------------------------------------

local Widgets = Import("gui/widgets/registry.lua")

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

    return self

end

------------------------------------------------------------
-- Create Window
------------------------------------------------------------

function Library:CreateWindow(Settings)

    Settings = Settings or {}

    local selfWindow = setmetatable({},Window)

    selfWindow.Library = self

    selfWindow.TitleText = Settings.Title or "Pilgrammed Utility"

    selfWindow.Width = Settings.Width or 650

    selfWindow.Height = Settings.Height or 420

    selfWindow.Tabs = {}

    selfWindow.ActiveTab = nil

    --------------------------------------------------------

    local ScreenGui = Instance.new("ScreenGui")

    ScreenGui.Name = "PilgrammedGUI"

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

    Main.BackgroundColor3 = Color3.fromRGB(35,35,35)

    Main.BorderSizePixel = 0

    Instance.new("UICorner",Main).CornerRadius = UDim.new(0,6)

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

    TitleBar.BackgroundColor3 = Color3.fromRGB(48,48,48)

    TitleBar.BorderSizePixel = 0

    Instance.new("UICorner",TitleBar).CornerRadius = UDim.new(0,6)

    selfWindow.TitleBar = TitleBar

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

    Title.TextColor3 = Color3.new(1,1,1)

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

    TabsPanel.BackgroundColor3 = Color3.fromRGB(45,45,45)

    TabsPanel.BorderSizePixel = 0

    TabsPanel.ScrollBarThickness = 4

    TabsPanel.CanvasSize = UDim2.new()

    Instance.new("UICorner",TabsPanel).CornerRadius = UDim.new(0,6)

    selfWindow.TabPanel = TabsPanel

    --------------------------------------------------------

    local TabsLayout = Instance.new("UIListLayout")

    TabsLayout.Parent = TabsPanel

    TabsLayout.Padding = UDim.new(0,5)

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

    Content.BackgroundColor3 = Color3.fromRGB(40,40,40)

    Content.BorderSizePixel = 0

    Instance.new("UICorner",Content).CornerRadius = UDim.new(0,6)

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

    Handle.BackgroundColor3 = Color3.fromRGB(90,90,90)

    Handle.BorderSizePixel = 0

    Instance.new("UICorner",Handle).CornerRadius = UDim.new(0,3)

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

    selfTab.Sections = {}

    --------------------------------------------------------
    -- Button
    --------------------------------------------------------

    local Button = Instance.new("TextButton")

    Button.Name = selfTab.Name

    Button.Parent = self.TabPanel

    Button.Size = UDim2.new(1,-10,0,32)

    Button.BackgroundColor3 = Color3.fromRGB(60,60,60)

    Button.BorderSizePixel = 0

    Button.Font = Enum.Font.Gotham

    Button.TextColor3 = Color3.new(1,1,1)

    Button.TextSize = 14

    Button.Text = selfTab.Icon .. " " .. selfTab.Name

    Instance.new("UICorner",Button).CornerRadius = UDim.new(0,4)

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

        CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(60,60,60)

    end

    self.Container.Visible = true

    self.Button.BackgroundColor3 = Color3.fromRGB(82,82,82)

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

    Frame.BackgroundColor3 = Color3.fromRGB(47,47,47)

    Frame.BorderSizePixel = 0

    Frame.AutomaticSize = Enum.AutomaticSize.Y

    Frame.Size = UDim2.new(1,0,0,0)

    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,6)

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

    Title.TextColor3 = Color3.new(1,1,1)

    Title.TextSize = 15

    Title.TextXAlignment = Enum.TextXAlignment.Left

    selfSection.Title = Title

    --------------------------------------------------------
    -- Container
    --------------------------------------------------------

    local Container = Instance.new("Frame")

    Container.Name = "Container"

    Container.Parent = Frame

    Container.Position = UDim2.fromOffset(0,28)

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

    "Keybind"

}

for _, WidgetName in ipairs(WidgetMethods) do

    Section["Add"..WidgetName] = function(self, Settings)

        local Widget = Widgets[WidgetName]

        assert(

            Widget,

            "Widget '"..WidgetName.."' is not registered."

        )

        return Widget.Create(

            self.Container,

            Settings or {}

        )

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

        function Window:Destroy()

    if self.Gui then

        self.Gui:Destroy()

        self.Gui = nil
        self.MainFrame = nil
        self.TitleBar = nil
        self.TitleLabel = nil
        self.TabPanel = nil
        self.Content = nil
        self.ResizeHandle = nil

    end

    for Index, Object in ipairs(self.Library.Windows) do

        if Object == self then

            table.remove(self.Library.Windows, Index)

            break

        end

    end

end
    end

    for Index, Object in ipairs(self.Library.Windows) do

        if Object == self then

            table.remove(self.Library.Windows, Index)

            break

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
-- Return
------------------------------------------------------------

return Library
