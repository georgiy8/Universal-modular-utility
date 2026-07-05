local REPO = "https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/"

local function Import(path)

    local Success, Result = pcall(function()

        return loadstring(game:HttpGet(REPO .. path))()

    end)

    if not Success then
        error(Result)
    end

    return Result

end

--========================================================--
-- Pilgrammed GUI Library
-- core.lua
--========================================================--

local Core = {}
Core.__index = Core

------------------------------------------------------------
-- Services
------------------------------------------------------------

local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Drag = Import("gui/services/drag.lua")

local Resize = Import("gui/services/resize.lua")
------------------------------------------------------------
-- Window Class
------------------------------------------------------------

local Window = {}
Window.__index = Window

------------------------------------------------------------
-- Create Window
------------------------------------------------------------

function Core:CreateWindow(Settings)

    Settings = Settings or {}

    local self = setmetatable({}, Window)

    self.Title = Settings.Title or "Pilgrammed Utility"
    self.Width = Settings.Width or 500
    self.Height = Settings.Height or 400

    --------------------------------------------------------

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PilgrammedGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")

    self.Gui = ScreenGui

    --------------------------------------------------------

    local MainFrame = Instance.new("Frame")

    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.fromOffset(self.Width, self.Height)
    MainFrame.Position = UDim2.new(.5,-self.Width/2,.5,-self.Height/2)

    MainFrame.BorderSizePixel = 0
    MainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)

    Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,6)

    self.MainFrame = MainFrame

    --------------------------------------------------------

    local TitleBar = Instance.new("Frame")

    TitleBar.Parent = MainFrame
    TitleBar.Size = UDim2.new(1,0,0,40)

    TitleBar.BorderSizePixel = 0
    TitleBar.BackgroundColor3 = Color3.fromRGB(50,50,50)

    Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,6)

    self.TitleBar = TitleBar

    Drag.Enable(TitleBar, MainFrame)

    --------------------------------------------------------

    local Title = Instance.new("TextLabel")

    Title.Parent = TitleBar
    Title.Size = UDim2.new(1,-20,1,0)
    Title.Position = UDim2.fromOffset(10,0)

    Title.BackgroundTransparency = 1

    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18

    Title.TextColor3 = Color3.new(1,1,1)

    Title.TextXAlignment = Enum.TextXAlignment.Left

    Title.Text = self.Title

    --------------------------------------------------------

    local TabPanel = Instance.new("ScrollingFrame")

    TabPanel.Parent = MainFrame

    TabPanel.Position = UDim2.fromOffset(10,50)
    TabPanel.Size = UDim2.new(0,120,1,-80)

    TabPanel.BorderSizePixel = 0

    TabPanel.BackgroundColor3 = Color3.fromRGB(45,45,45)

    TabPanel.ScrollBarThickness = 5

    Instance.new("UICorner",TabPanel).CornerRadius=UDim.new(0,6)

    self.TabPanel = TabPanel

    --------------------------------------------------------

    local Layout = Instance.new("UIListLayout")

    Layout.Parent = TabPanel

    Layout.Padding = UDim.new(0,5)

    --------------------------------------------------------

    local Content = Instance.new("Frame")

    Content.Parent = MainFrame

    Content.Position = UDim2.fromOffset(140,50)
    Content.Size = UDim2.new(1,-150,1,-80)

    Content.BackgroundColor3 = Color3.fromRGB(40,40,40)

    Content.BorderSizePixel = 0

    Instance.new("UICorner",Content).CornerRadius=UDim.new(0,6)

    self.Content = Content

    --------------------------------------------------------
     Resize Handle
    --------------------------------------------------------

    local ResizeHandle = Instance.new("Frame")

    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Parent = MainFrame

    ResizeHandle.Size = UDim2.fromOffset(14,14)
    ResizeHandle.AnchorPoint = Vector2.new(1,1)
    ResizeHandle.Position = UDim2.new(1,-3,1,-3)

    ResizeHandle.BackgroundColor3 = Color3.fromRGB(90,90,90)
    ResizeHandle.BorderSizePixel = 0

    Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0,3)

    Resize.Enable(MainFrame, ResizeHandle)

    --------------------------------------------------------

    self.Tabs = {}

    return self

end

------------------------------------------------------------
-- Create Tab
------------------------------------------------------------

function Window:CreateTab(Settings)

    Settings = Settings or {}

    local Name = Settings.Name or "Tab"
    local Icon = Settings.Icon or ""

    local Button = Instance.new("TextButton")

    Button.Parent = self.TabPanel

    Button.Size = UDim2.new(1,-8,0,30)

    Button.BackgroundColor3 = Color3.fromRGB(60,60,60)

    Button.BorderSizePixel = 0

    Button.Font = Enum.Font.Gotham

    Button.TextColor3 = Color3.new(1,1,1)

    Button.TextSize = 15

    Button.Text = Icon.." "..Name

    Instance.new("UICorner",Button).CornerRadius=UDim.new(0,4)

    --------------------------------------------------------

    local Container = Instance.new("Frame")

    Container.Parent = self.Content

    Container.Size = UDim2.fromScale(1,1)

    Container.BackgroundTransparency = 1

    Container.Visible = false

    --------------------------------------------------------

    Button.MouseButton1Click:Connect(function()

        for _,Tab in pairs(self.Tabs) do
            Tab.Container.Visible=false
        end

        Container.Visible=true

    end)

    --------------------------------------------------------

    local Tab={

        Button=Button,

        Container=Container

    }

    table.insert(self.Tabs,Tab)

    if #self.Tabs==1 then
        Container.Visible=true
    end

    return Tab

end

------------------------------------------------------------

return Core
