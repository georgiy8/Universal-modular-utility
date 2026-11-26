--========================================================--
-- Universal-modular-utility GUI Library
-- ProgressBar Widget (только показывает значение, не сохраняется в профили)
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

local TweenService = game:GetService("TweenService")

local ProgressBar = {}

function ProgressBar.Create(Parent, Settings)

    Settings = Settings or {}

    local Text = Settings.Text or "Progress"

    local Min = Settings.Min or 0

    local Max = Settings.Max or 100

    local Value = math.clamp(Settings.Value or Settings.Default or Min, Min, Max)

    local ShowPercent = Settings.ShowPercent ~= false

    local CustomValueText = nil

    local Object = {}

    local Frame = Instance.new("Frame")
    Frame.Name = "ProgressBar"
    Frame.Parent = Parent
    Frame.Size = UDim2.new(1,0,0,44)
    Frame.BackgroundColor3 = C("Row", Color3.fromRGB(45,49,58))
    Frame.BorderSizePixel = 0
    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,5)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(10,5)
    Label.Size = UDim2.new(1,-90,0,18)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Text = Text
    Label.TextColor3 = C("Text", Color3.new(1,1,1))
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = Frame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.AnchorPoint = Vector2.new(1,0)
    ValueLabel.Position = UDim2.new(1,-10,0,5)
    ValueLabel.Size = UDim2.fromOffset(80,18)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextSize = 13
    ValueLabel.TextColor3 = C("TextMuted", Color3.fromRGB(184,190,201))
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Track = Instance.new("Frame")
    Track.Parent = Frame
    Track.Position = UDim2.new(0,10,0,29)
    Track.Size = UDim2.new(1,-20,0,8)
    Track.BorderSizePixel = 0
    Track.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))
    Instance.new("UICorner",Track).CornerRadius = UDim.new(1,0)

    local Fill = Instance.new("Frame")
    Fill.Parent = Track
    Fill.Size = UDim2.new(0,0,1,0)
    Fill.BorderSizePixel = 0
    Fill.BackgroundColor3 = Settings.Color or C("Accent", Color3.fromRGB(70,160,255))
    Instance.new("UICorner",Fill).CornerRadius = UDim.new(1,0)

    local function Alpha()

        local Range = Max - Min

        if Range <= 0 then

            return 0

        end

        return math.clamp((Value - Min) / Range, 0, 1)

    end

    local function Refresh(Animate)

        local A = Alpha()

        if Animate then

            TweenService:Create(
                Fill,
                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size = UDim2.new(A,0,1,0) }
            ):Play()

        else

            Fill.Size = UDim2.new(A,0,1,0)

        end

        if CustomValueText then

            ValueLabel.Text = CustomValueText

        elseif ShowPercent then

            ValueLabel.Text = math.floor(A * 100 + 0.5) .. "%"

        else

            ValueLabel.Text = tostring(math.floor(Value * 100 + 0.5) / 100) .. " / " .. tostring(Max)

        end

    end

    Refresh(false)

    Object.Instance = Frame

    function Object:GetValue()

        return Value

    end

    function Object:SetValue(NewValue)

        Value = math.clamp(tonumber(NewValue) or Min, Min, Max)

        Refresh(true)

    end

    function Object:SetRange(NewMin, NewMax)

        Min = NewMin

        Max = NewMax

        Value = math.clamp(Value, Min, Max)

        Refresh(false)

    end

    -- свой текст справа вместо процентов (nil - вернуть проценты)
    function Object:SetValueText(NewText)

        CustomValueText = NewText

        Refresh(false)

    end

    function Object:SetText(NewText)

        Text = tostring(NewText)

        Label.Text = Text

    end

    function Object:SetColor(Color)

        Fill.BackgroundColor3 = Color

    end

    function Object:SetVisible(State)

        Frame.Visible = State

    end

    function Object:Destroy()

        Frame:Destroy()

    end

    return Object

end

return ProgressBar
