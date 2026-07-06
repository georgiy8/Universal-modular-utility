--========================================================--
-- Pilgrammed GUI Library
-- Separator Widget
--========================================================--

local Separator = {}

------------------------------------------------------------
-- Create Separator
------------------------------------------------------------

function Separator.Create(Parent, Settings)

    Settings = Settings or {}

    local Text = Settings.Text or ""

    --------------------------------------------------------

    local Object = {}

    --------------------------------------------------------
    -- Main
    --------------------------------------------------------

    local Frame = Instance.new("Frame")

    Frame.Parent = Parent

    Frame.Size = UDim2.new(1,0,0,24)

    Frame.BackgroundTransparency = 1

    --------------------------------------------------------
    -- Left Line
    --------------------------------------------------------

    local Left = Instance.new("Frame")

    Left.Parent = Frame

    Left.AnchorPoint = Vector2.new(0,0.5)

    Left.Position = UDim2.new(0,0,0.5,0)

    Left.Size = UDim2.new(0.45,0,0,1)

    Left.BackgroundColor3 = Color3.fromRGB(95,95,95)

    Left.BorderSizePixel = 0

    --------------------------------------------------------
    -- Right Line
    --------------------------------------------------------

    local Right = Instance.new("Frame")

    Right.Parent = Frame

    Right.AnchorPoint = Vector2.new(1,0.5)

    Right.Position = UDim2.new(1,0,0.5,0)

    Right.Size = UDim2.new(0.45,0,0,1)

    Right.BackgroundColor3 = Color3.fromRGB(95,95,95)

    Right.BorderSizePixel = 0

    --------------------------------------------------------
    -- Text
    --------------------------------------------------------

    local Label = Instance.new("TextLabel")

    Label.Parent = Frame

    Label.AnchorPoint = Vector2.new(0.5,0.5)

    Label.Position = UDim2.new(0.5,0,0.5,0)

    Label.AutomaticSize = Enum.AutomaticSize.X

    Label.Size = UDim2.new(0,0,1,0)

    Label.BackgroundColor3 = Color3.fromRGB(47,47,47)

    Label.BorderSizePixel = 0

    Label.Font = Enum.Font.Gotham

    Label.Text = Text

    Label.TextColor3 = Color3.fromRGB(190,190,190)

    Label.TextSize = 13

    --------------------------------------------------------
    -- Padding
    --------------------------------------------------------

    local Padding = Instance.new("UIPadding")

    Padding.Parent = Label

    Padding.PaddingLeft = UDim.new(0,8)

    Padding.PaddingRight = UDim.new(0,8)

    --------------------------------------------------------
    -- API
    --------------------------------------------------------

    Object.Instance = Frame

    function Object:SetText(NewText)

        Text = tostring(NewText)

        Label.Text = Text

    end

    function Object:GetText()

        return Text

    end

    function Object:SetVisible(State)

        Frame.Visible = State

    end

    function Object:Destroy()

        Frame:Destroy()

    end

    --------------------------------------------------------

    return Object

end

------------------------------------------------------------

return Separator
