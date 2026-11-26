--========================================================--
-- Universal-modular-utility GUI Library
-- RangeSlider Widget (два бегунка: от и до)
-- Default = { low, high }, Callback(low, high)
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

local UserInputService = game:GetService("UserInputService")

local RangeSlider = {}

local function IsPointer(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch
end

function RangeSlider.Create(Parent, Settings)

    Settings = Settings or {}

    local Text = Settings.Text or "Range"

    local Min = Settings.Min or 0

    local Max = Settings.Max or 100

    local Increment = Settings.Increment or 1

    local Callback = Settings.Callback or function() end

    local Default = Settings.Default or { Min, Max }

    local Low = math.clamp(Default[1] or Min, Min, Max)

    local High = math.clamp(Default[2] or Max, Min, Max)

    if Low > High then

        Low, High = High, Low

    end

    local Enabled = true

    local Object = {}

    local Frame = Instance.new("Frame")
    Frame.Name = "RangeSlider"
    Frame.Parent = Parent
    Frame.Size = UDim2.new(1,0,0,56)
    Frame.BackgroundColor3 = C("Row", Color3.fromRGB(45,49,58))
    Frame.BorderSizePixel = 0
    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,6)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(10,6)
    Label.Size = UDim2.new(1,-110,0,18)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Text = Text
    Label.TextColor3 = C("Text", Color3.new(1,1,1))
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = Frame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.AnchorPoint = Vector2.new(1,0)
    ValueLabel.Position = UDim2.new(1,-10,0,6)
    ValueLabel.Size = UDim2.fromOffset(100,18)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 14
    ValueLabel.TextColor3 = C("Text", Color3.new(1,1,1))
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Bar = Instance.new("Frame")
    Bar.Parent = Frame
    Bar.Position = UDim2.new(0,14,0,34)
    Bar.Size = UDim2.new(1,-28,0,8)
    Bar.BorderSizePixel = 0
    Bar.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))
    Instance.new("UICorner",Bar).CornerRadius = UDim.new(1,0)

    local Fill = Instance.new("Frame")
    Fill.Parent = Bar
    Fill.BorderSizePixel = 0
    Fill.BackgroundColor3 = C("Accent", Color3.fromRGB(70,160,255))

    local function MakeKnob()

        local Knob = Instance.new("Frame")
        Knob.Parent = Bar
        Knob.AnchorPoint = Vector2.new(0.5,0.5)
        Knob.Size = UDim2.fromOffset(14,14)
        Knob.BorderSizePixel = 0
        Knob.BackgroundColor3 = C("Knob", Color3.new(1,1,1))
        Knob.ZIndex = 2
        Instance.new("UICorner",Knob).CornerRadius = UDim.new(1,0)

        return Knob

    end

    local LowKnob = MakeKnob()

    local HighKnob = MakeKnob()

    local Hit = Instance.new("TextButton")
    Hit.Parent = Frame
    Hit.BackgroundTransparency = 1
    Hit.Text = ""
    Hit.AutoButtonColor = false
    Hit.Position = UDim2.new(0,4,0,26)
    Hit.Size = UDim2.new(1,-8,0,26)

    local function Format(Number)

        if Increment > 0 and Increment < 1 then

            return tostring(math.floor(Number * 100 + 0.5) / 100)

        end

        return tostring(math.floor(Number * 1000 + 0.5) / 1000)

    end

    local function Alpha(Number)

        local Range = Max - Min

        if Range == 0 then

            return 0

        end

        return math.clamp((Number - Min) / Range, 0, 1)

    end

    local function Refresh()

        local A1 = Alpha(Low)

        local A2 = Alpha(High)

        Fill.Position = UDim2.new(A1,0,0,0)

        Fill.Size = UDim2.new(A2 - A1,0,1,0)

        LowKnob.Position = UDim2.new(A1,0,0.5,0)

        HighKnob.Position = UDim2.new(A2,0,0.5,0)

        ValueLabel.Text = Format(Low) .. " - " .. Format(High)

    end

    local function Snap(Number)

        Number = math.clamp(Number, Min, Max)

        if Increment > 0 then

            Number = math.floor(Number / Increment + 0.5) * Increment

        end

        return math.clamp(Number, Min, Max)

    end

    local function Emit()

        pcall(Callback, Low, High)

    end

    Refresh()

    --------------------------------------------------------
    -- Input: двигаем тот бегунок, что ближе к касанию
    --------------------------------------------------------

    local Dragging = nil

    local function Apply(Input)

        if not Dragging or not Enabled then

            return

        end

        local A = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / math.max(Bar.AbsoluteSize.X,1), 0, 1)

        local Number = Snap(Min + (Max - Min) * A)

        local OldLow, OldHigh = Low, High

        if Dragging == "low" then

            Low = math.min(Number, High)

        else

            High = math.max(Number, Low)

        end

        if Low ~= OldLow or High ~= OldHigh then

            Refresh()

            Emit()

        end

    end

    Hit.InputBegan:Connect(function(Input)

        if not IsPointer(Input) or not Enabled then

            return

        end

        local A = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / math.max(Bar.AbsoluteSize.X,1), 0, 1)

        local Number = Min + (Max - Min) * A

        -- ближе к нижнему или верхнему бегунку; на равных - в сторону касания
        local ToLow = math.abs(Number - Low)

        local ToHigh = math.abs(Number - High)

        if ToLow < ToHigh or (ToLow == ToHigh and Number < Low) then

            Dragging = "low"

        else

            Dragging = "high"

        end

        Apply(Input)

    end)

    local Moved = UserInputService.InputChanged:Connect(function(Input)

        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch) then

            Apply(Input)

        end

    end)

    local Ended = UserInputService.InputEnded:Connect(function(Input)

        if IsPointer(Input) then

            Dragging = nil

        end

    end)

    --------------------------------------------------------
    -- API
    --------------------------------------------------------

    Object.Instance = Frame

    function Object:GetValue()

        return { Low, High }

    end

    function Object:GetLow()

        return Low

    end

    function Object:GetHigh()

        return High

    end

    -- SetValue({low, high}) или SetValue(low, high); Callback вызывается, если значения изменились
    function Object:SetValue(A, B)

        local NewLow, NewHigh

        if type(A) == "table" then

            NewLow, NewHigh = A[1], A[2]

        else

            NewLow, NewHigh = A, B

        end

        NewLow = Snap(tonumber(NewLow) or Low)

        NewHigh = Snap(tonumber(NewHigh) or High)

        if NewLow > NewHigh then

            NewLow, NewHigh = NewHigh, NewLow

        end

        if NewLow == Low and NewHigh == High then

            return

        end

        Low, High = NewLow, NewHigh

        Refresh()

        Emit()

    end

    function Object:SetRange(NewMin, NewMax)

        Min, Max = NewMin, NewMax

        Low = math.clamp(Low, Min, Max)

        High = math.clamp(High, Min, Max)

        Refresh()

    end

    function Object:SetText(NewText)

        Text = tostring(NewText)

        Label.Text = Text

    end

    function Object:SetCallback(NewCallback)

        Callback = NewCallback or function() end

    end

    function Object:SetEnabled(State)

        Enabled = State

        Hit.Active = State

    end

    function Object:SetVisible(State)

        Frame.Visible = State

    end

    function Object:Destroy()

        Moved:Disconnect()

        Ended:Disconnect()

        Frame:Destroy()

    end

    return Object

end

return RangeSlider
