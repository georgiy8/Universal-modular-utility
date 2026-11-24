--========================================================--
-- Universal-modular-utility GUI Library
-- Toggle Widget
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

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

    Button.BackgroundColor3 = C("Row", Color3.fromRGB(60,60,60))

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

    Label.TextColor3 = C("Text", Color3.new(1,1,1))

    Label.TextSize = 14

    Label.TextXAlignment = Enum.TextXAlignment.Left

    --------------------------------------------------------
    -- Switch (переключатель-пилюля с бегунком)
    --------------------------------------------------------

    local TweenService = game:GetService("TweenService")

    local Track = Instance.new("Frame")

    Track.Name = "Track"

    Track.Parent = Button

    Track.AnchorPoint = Vector2.new(1,0.5)

    Track.Position = UDim2.new(1,-10,0.5,0)

    Track.Size = UDim2.fromOffset(38,20)

    Track.BackgroundColor3 = C("Control", Color3.fromRGB(52,56,66))

    Track.BorderSizePixel = 0

    Instance.new("UICorner",Track).CornerRadius = UDim.new(1,0)

    local Knob = Instance.new("Frame")

    Knob.Name = "Knob"

    Knob.Parent = Track

    Knob.AnchorPoint = Vector2.new(0,0.5)

    Knob.Position = UDim2.new(0,3,0.5,0)

    Knob.Size = UDim2.fromOffset(14,14)

    Knob.BackgroundColor3 = C("Knob", Color3.new(1,1,1))

    Knob.BorderSizePixel = 0

    Instance.new("UICorner",Knob).CornerRadius = UDim.new(1,0)

    --------------------------------------------------------
    -- Update
    --------------------------------------------------------

    local function Apply(Animate)

        local TrackColor = Value and C("Accent", Color3.fromRGB(70,160,255)) or C("Control", Color3.fromRGB(52,56,66))

        local KnobPosition = Value and UDim2.new(1,-17,0.5,0) or UDim2.new(0,3,0.5,0)

        if Animate then

            local Info = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            TweenService:Create(Track, Info, { BackgroundColor3 = TrackColor }):Play()

            TweenService:Create(Knob, Info, { Position = KnobPosition }):Play()

        else

            Track.BackgroundColor3 = TrackColor

            Knob.Position = KnobPosition

        end

    end

    local function Update()

        Apply(true)

    end

    Apply(false)

    --------------------------------------------------------
    -- Hover
    --------------------------------------------------------

    Button.MouseEnter:Connect(function()

        Button.BackgroundColor3 = C("RowHover", Color3.fromRGB(72,72,72))

    end)

    Button.MouseLeave:Connect(function()

        Button.BackgroundColor3 = C("Row", Color3.fromRGB(60,60,60))

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

    -- вызывает Callback с текущим значением (ConfigManager использует после загрузки профиля)
    function Object:Fire()

        pcall(Callback, Value)

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
