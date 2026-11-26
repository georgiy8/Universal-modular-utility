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

    -- привязка клавиши (даёт ядро): BindKey, OnBindChanged, OnToggled
    local BindKey = Settings.BindKey

    local OnBindChanged = Settings.OnBindChanged

    local OnToggled = Settings.OnToggled

    local UserInputService = game:GetService("UserInputService")

    local AllowBind = Settings.AllowBind ~= false and UserInputService.KeyboardEnabled

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

    Label.Size = UDim2.new(1, AllowBind and -96 or -50, 1, 0)

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
    -- Шестерёнка / клавиша
    --------------------------------------------------------

    local Capturing = false

    local Gear

    local function ShortKey(Key)

        local Name = Key.Name

        Name = Name:gsub("Control", "Ctrl"):gsub("Left", "L"):gsub("Right", "R")

        return Name

    end

    local function RefreshGear()

        if not Gear then

            return

        end

        if Capturing then

            Gear.Text = "..."

            Gear.TextSize = 12

            Gear.Size = UDim2.fromOffset(30,22)

            Gear.BackgroundColor3 = C("Accent", Color3.fromRGB(70,160,255))

            Gear.TextColor3 = Color3.fromRGB(12,21,34)

        elseif BindKey then

            local Name = ShortKey(BindKey)

            Gear.Text = Name

            Gear.TextSize = 11

            Gear.Size = UDim2.fromOffset(math.max(26, #Name * 7 + 12), 22)

            Gear.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))

            Gear.TextColor3 = C("Accent", Color3.fromRGB(70,160,255))

        else

            Gear.Text = "⚙"

            Gear.TextSize = 15

            Gear.Size = UDim2.fromOffset(26,22)

            Gear.BackgroundColor3 = C("Control", Color3.fromRGB(52,56,66))

            Gear.TextColor3 = C("TextDim", Color3.fromRGB(150,158,171))

        end

    end

    if AllowBind then

        Gear = Instance.new("TextButton")

        Gear.Name = "BindButton"

        Gear.Parent = Button

        Gear.AnchorPoint = Vector2.new(1,0.5)

        Gear.Position = UDim2.new(1,-56,0.5,0)

        Gear.BorderSizePixel = 0

        Gear.AutoButtonColor = false

        Gear.Font = Enum.Font.GothamBold

        Instance.new("UICorner",Gear).CornerRadius = UDim.new(0,5)

        RefreshGear()

        Gear.MouseButton1Click:Connect(function()

            Capturing = true

            _G.UMUCapturingKey = true

            RefreshGear()

        end)

    end

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
    -- Toggle (нажатие мышью, пальцем или назначенной клавишей)
    --------------------------------------------------------

    local function UserToggle()

        Value = not Value

        Update()

        local Success, Error = pcall(function()

            Callback(Value)

        end)

        if not Success then

            warn("[Toggle] "..tostring(Error))

        end

        if OnToggled then

            pcall(OnToggled, Value)

        end

    end

    Button.MouseButton1Click:Connect(UserToggle)

    local KeyConnection

    KeyConnection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)

        -- выбор клавиши
        if Capturing then

            if Input.UserInputType ~= Enum.UserInputType.Keyboard then

                return

            end

            if Input.KeyCode == Enum.KeyCode.Backspace or Input.KeyCode == Enum.KeyCode.Escape then

                BindKey = nil

            else

                BindKey = Input.KeyCode

            end

            Capturing = false

            task.delay(0.25, function()

                _G.UMUCapturingKey = false

            end)

            RefreshGear()

            if OnBindChanged then

                pcall(OnBindChanged, BindKey)

            end

            return

        end

        if GameProcessed or not BindKey or Input.KeyCode ~= BindKey then

            return

        end

        if UserInputService:GetFocusedTextBox() or _G.UMUCapturingKey then

            return

        end

        if not Button:IsDescendantOf(game) then

            if KeyConnection then

                KeyConnection:Disconnect()

            end

            return

        end

        UserToggle()

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

    function Object:UserToggle()

        UserToggle()

    end

    function Object:GetBind()

        return BindKey

    end

    function Object:SetBind(Key)

        BindKey = Key

        RefreshGear()

    end

    function Object:Destroy()

        if KeyConnection then

            KeyConnection:Disconnect()

        end

        Button:Destroy()

    end

    --------------------------------------------------------

    return Object

end

------------------------------------------------------------

return Toggle
