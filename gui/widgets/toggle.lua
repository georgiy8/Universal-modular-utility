--========================================================--
-- Pilgrammed GUI Library
-- Toggle Widget
--========================================================--

local Toggle = {}

------------------------------------------------------------
-- Create Toggle
------------------------------------------------------------

function Toggle.Create(Parent, Settings)

    Settings = Settings or {}

    local Text = Settings.Text or "Toggle"

    local Value = Settings.Default or false

    local Callback = Settings.Callback or function()

    end

    --------------------------------------------------------

    local Object = {}

    --------------------------------------------------------
    -- Main Button
    --------------------------------------------------------

    local Button = Instance.new("TextButton")

    Button.Parent = Parent

    Button.Size = UDim2.new(1,0,0,30)

    Button.BackgroundColor3 = Color3.fromRGB(60,60,60)

    Button.BorderSizePixel = 0

    Button.AutoButtonColor = false

    Button.Text = ""

    Instance.new("UICorner",Button).CornerRadius = UDim.new(0,4)

    --------------------------------------------------------
    -- Label
    --------------------------------------------------------

    local Label = Instance.new("TextLabel")

    Label.Parent = Button

    Label.BackgroundTransparency = 1

    Label.Position = UDim2.fromOffset(10,0)

    Label.Size = UDim2.new(1,-50,1,0)

    Label.Font = Enum.Font.Gotham

    Label.Text = Text

    Label.TextColor3 = Color3.new(1,1,1)

    Label.TextSize = 14

    Label.TextXAlignment = Enum.TextXAlignment.Left

    --------------------------------------------------------
    -- Toggle Box
    --------------------------------------------------------

    local Box = Instance.new("Frame")

    Box.Parent = Button

    Box.AnchorPoint = Vector2.new(1,0.5)

    Box.Position = UDim2.new(1,-10,0.5,0)

    Box.Size = UDim2.fromOffset(18,18)

    Box.BackgroundColor3 = Color3.fromRGB(35,35,35)

    Box.BorderSizePixel = 0

    Instance.new("UICorner",Box).CornerRadius = UDim.new(0,4)

    --------------------------------------------------------

    local Indicator = Instance.new("Frame")

    Indicator.Parent = Box

    Indicator.AnchorPoint = Vector2.new(0.5,0.5)

    Indicator.Position = UDim2.fromScale(0.5,0.5)

    Indicator.Size = UDim2.fromOffset(12,12)

    Indicator.BorderSizePixel = 0

    Indicator.Visible = Value

    Indicator.BackgroundColor3 = Color3.fromRGB(0,170,255)

    Instance.new("UICorner",Indicator).CornerRadius = UDim.new(0,3)

    --------------------------------------------------------
    -- Update
    --------------------------------------------------------

    local function Update()

        Indicator.Visible = Value

    end

    Update()

    --------------------------------------------------------
    -- Hover
    --------------------------------------------------------

    Button.MouseEnter:Connect(function()

        Button.BackgroundColor3 = Color3.fromRGB(72,72,72)

    end)

    Button.MouseLeave:Connect(function()

        Button.BackgroundColor3 = Color3.fromRGB(60,60,60)

    end)

    --------------------------------------------------------
    -- Toggle
    --------------------------------------------------------

    Button.MouseButton1Click:Connect(function()

        Value = not Value

        Update()

        local Success, Error = pcall(function()

            Callback(Value)

        end)

        if not Success then

            warn("[Toggle] "..tostring(Error))

        end

    end)

    --------------------------------------------------------

    Object.Instance = Button

    ------------------------------------------------------------
    -- API
    ------------------------------------------------------------

    function Object:GetValue()

        return Value

    end

    function Object:SetValue(State)

        Value = State

        Update()

    end

    function Object:SetText(NewText)

        Label.Text = NewText

    end

    function Object:SetCallback(NewCallback)

        Callback = NewCallback

    end

    function Object:SetVisible(State)

        Button.Visible = State

    end

    function Object:Destroy()

        Button:Destroy()

    end

    --------------------------------------------------------

    return Object

end

------------------------------------------------------------

return Toggle
