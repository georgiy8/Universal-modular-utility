--========================================================--
-- Universal-modular-utility GUI Library
-- ColorPicker Widget (поле насыщенность/яркость + полоса оттенка + HEX)
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

local UserInputService = game:GetService("UserInputService")

local ColorPicker = {}

local function ToHex(Color)
    return string.format(
        "#%02X%02X%02X",
        math.floor(Color.R * 255 + 0.5),
        math.floor(Color.G * 255 + 0.5),
        math.floor(Color.B * 255 + 0.5)
    )
end

local function FromHex(Text)
    Text = tostring(Text or ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("^#", "")
    if #Text ~= 6 then
        return nil
    end
    local R = tonumber(Text:sub(1, 2), 16)
    local G = tonumber(Text:sub(3, 4), 16)
    local B = tonumber(Text:sub(5, 6), 16)
    if not R or not G or not B then
        return nil
    end
    return Color3.fromRGB(R, G, B)
end

local function IsPointer(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch
end

function ColorPicker.Create(Parent, Settings)

    Settings = Settings or {}

    local Text = Settings.Text or "Color"

    local Value = Settings.Default or Color3.fromRGB(255,255,255)

    local Callback = Settings.Callback or function() end

    local Hue, Sat, Val = Value:ToHSV()

    local Expanded = false

    local Object = {}

    --------------------------------------------------------
    -- Frame
    --------------------------------------------------------

    local Frame = Instance.new("Frame")
    Frame.Name = "ColorPicker"
    Frame.Parent = Parent
    Frame.Size = UDim2.new(1,0,0,32)
    Frame.AutomaticSize = Enum.AutomaticSize.Y
    Frame.BackgroundColor3 = C("Row", Color3.fromRGB(45,49,58))
    Frame.BorderSizePixel = 0
    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,5)

    local Header = Instance.new("TextButton")
    Header.Parent = Frame
    Header.Size = UDim2.new(1,0,0,32)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.AutoButtonColor = false

    local Label = Instance.new("TextLabel")
    Label.Parent = Header
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(10,0)
    Label.Size = UDim2.new(1,-70,1,0)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Text = Text
    Label.TextColor3 = C("Text", Color3.new(1,1,1))
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Swatch = Instance.new("Frame")
    Swatch.Parent = Header
    Swatch.AnchorPoint = Vector2.new(1,0.5)
    Swatch.Position = UDim2.new(1,-10,0.5,0)
    Swatch.Size = UDim2.fromOffset(44,20)
    Swatch.BackgroundColor3 = Value
    Swatch.BorderSizePixel = 0
    Instance.new("UICorner",Swatch).CornerRadius = UDim.new(0,5)
    local SwatchStroke = Instance.new("UIStroke")
    SwatchStroke.Parent = Swatch
    SwatchStroke.Color = C("Stroke", Color3.fromRGB(58,63,75))

    --------------------------------------------------------
    -- Panel
    --------------------------------------------------------

    local Panel = Instance.new("Frame")
    Panel.Parent = Frame
    Panel.Position = UDim2.fromOffset(0,32)
    Panel.Size = UDim2.new(1,0,0,0)
    Panel.AutomaticSize = Enum.AutomaticSize.Y
    Panel.BackgroundTransparency = 1
    Panel.Visible = false

    local PanelLayout = Instance.new("UIListLayout")
    PanelLayout.Parent = Panel
    PanelLayout.Padding = UDim.new(0,8)
    PanelLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local PanelPadding = Instance.new("UIPadding")
    PanelPadding.Parent = Panel
    PanelPadding.PaddingLeft = UDim.new(0,10)
    PanelPadding.PaddingRight = UDim.new(0,10)
    PanelPadding.PaddingBottom = UDim.new(0,10)
    PanelPadding.PaddingTop = UDim.new(0,2)

    -- поле насыщенность (X) / яркость (Y)
    local SV = Instance.new("Frame")
    SV.Parent = Panel
    SV.LayoutOrder = 1
    SV.Size = UDim2.new(1,0,0,110)
    SV.BorderSizePixel = 0
    SV.BackgroundColor3 = Color3.fromHSV(Hue,1,1)
    Instance.new("UICorner",SV).CornerRadius = UDim.new(0,5)

    local White = Instance.new("Frame")
    White.Parent = SV
    White.Size = UDim2.fromScale(1,1)
    White.BorderSizePixel = 0
    White.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner",White).CornerRadius = UDim.new(0,5)
    local WhiteGradient = Instance.new("UIGradient")
    WhiteGradient.Parent = White
    WhiteGradient.Transparency = NumberSequence.new(0,1)

    local Black = Instance.new("Frame")
    Black.Parent = SV
    Black.Size = UDim2.fromScale(1,1)
    Black.BorderSizePixel = 0
    Black.BackgroundColor3 = Color3.new(0,0,0)
    Instance.new("UICorner",Black).CornerRadius = UDim.new(0,5)
    local BlackGradient = Instance.new("UIGradient")
    BlackGradient.Parent = Black
    BlackGradient.Rotation = 90
    BlackGradient.Transparency = NumberSequence.new(1,0)

    local SVCursor = Instance.new("Frame")
    SVCursor.Parent = SV
    SVCursor.AnchorPoint = Vector2.new(0.5,0.5)
    SVCursor.Size = UDim2.fromOffset(12,12)
    SVCursor.BackgroundTransparency = 1
    SVCursor.ZIndex = 3
    Instance.new("UICorner",SVCursor).CornerRadius = UDim.new(1,0)
    local SVCursorStroke = Instance.new("UIStroke")
    SVCursorStroke.Parent = SVCursor
    SVCursorStroke.Color = Color3.new(1,1,1)
    SVCursorStroke.Thickness = 2

    -- полоса оттенка
    local HueBar = Instance.new("Frame")
    HueBar.Parent = Panel
    HueBar.LayoutOrder = 2
    HueBar.Size = UDim2.new(1,0,0,16)
    HueBar.BorderSizePixel = 0
    HueBar.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner",HueBar).CornerRadius = UDim.new(0,5)
    local HueGradient = Instance.new("UIGradient")
    HueGradient.Parent = HueBar
    local Stops = {}
    for Index = 0, 6 do
        table.insert(Stops, ColorSequenceKeypoint.new(Index / 6, Color3.fromHSV(Index / 6 == 1 and 0.9999 or Index / 6, 1, 1)))
    end
    HueGradient.Color = ColorSequence.new(Stops)

    local HueCursor = Instance.new("Frame")
    HueCursor.Parent = HueBar
    HueCursor.AnchorPoint = Vector2.new(0.5,0.5)
    HueCursor.Size = UDim2.fromOffset(6,22)
    HueCursor.BackgroundColor3 = Color3.new(1,1,1)
    HueCursor.BorderSizePixel = 0
    HueCursor.ZIndex = 3
    Instance.new("UICorner",HueCursor).CornerRadius = UDim.new(0,3)
    local HueCursorStroke = Instance.new("UIStroke")
    HueCursorStroke.Parent = HueCursor
    HueCursorStroke.Color = Color3.new(0,0,0)
    HueCursorStroke.Transparency = 0.5

    -- HEX
    local Hex = Instance.new("TextBox")
    Hex.Parent = Panel
    Hex.LayoutOrder = 3
    Hex.Size = UDim2.new(1,0,0,26)
    Hex.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))
    Hex.BorderSizePixel = 0
    Hex.Font = Enum.Font.Gotham
    Hex.TextSize = 13
    Hex.TextColor3 = C("Text", Color3.new(1,1,1))
    Hex.PlaceholderText = "#RRGGBB"
    Hex.PlaceholderColor3 = C("TextDim", Color3.fromRGB(150,158,171))
    Hex.ClearTextOnFocus = false
    Hex.Text = ""
    Instance.new("UICorner",Hex).CornerRadius = UDim.new(0,5)

    --------------------------------------------------------
    -- Update
    --------------------------------------------------------

    local function Refresh(SkipHex)

        Value = Color3.fromHSV(Hue, Sat, Val)

        Swatch.BackgroundColor3 = Value

        SV.BackgroundColor3 = Color3.fromHSV(Hue,1,1)

        SVCursor.Position = UDim2.fromScale(Sat, 1 - Val)

        HueCursor.Position = UDim2.fromScale(math.clamp(Hue,0,1), 0.5)

        if not SkipHex then

            Hex.Text = ToHex(Value)

        end

    end

    local function Emit()

        pcall(Callback, Value)

    end

    Refresh()

    --------------------------------------------------------
    -- Input
    --------------------------------------------------------

    local Dragging = nil

    local function Apply(Input)

        if Dragging == "sv" then

            Sat = math.clamp((Input.Position.X - SV.AbsolutePosition.X) / math.max(SV.AbsoluteSize.X,1), 0, 1)

            Val = 1 - math.clamp((Input.Position.Y - SV.AbsolutePosition.Y) / math.max(SV.AbsoluteSize.Y,1), 0, 1)

        elseif Dragging == "hue" then

            Hue = math.clamp((Input.Position.X - HueBar.AbsolutePosition.X) / math.max(HueBar.AbsoluteSize.X,1), 0, 1)

        else

            return

        end

        Refresh()

        Emit()

    end

    SV.InputBegan:Connect(function(Input)

        if IsPointer(Input) then

            Dragging = "sv"

            Apply(Input)

        end

    end)

    HueBar.InputBegan:Connect(function(Input)

        if IsPointer(Input) then

            Dragging = "hue"

            Apply(Input)

        end

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

    Hex.FocusLost:Connect(function()

        local Color = FromHex(Hex.Text)

        if Color then

            Hue, Sat, Val = Color:ToHSV()

            Refresh()

            Emit()

        else

            Hex.Text = ToHex(Value)

        end

    end)

    Header.MouseButton1Click:Connect(function()

        Expanded = not Expanded

        Panel.Visible = Expanded

    end)

    --------------------------------------------------------
    -- API
    --------------------------------------------------------

    Object.Instance = Frame

    function Object:GetValue()

        return Value

    end

    function Object:GetHex()

        return ToHex(Value)

    end

    -- принимает Color3 или строку "#RRGGBB"; Callback не вызывает (как у Toggle)
    function Object:SetValue(NewValue)

        local Color = NewValue

        if type(NewValue) == "string" then

            Color = FromHex(NewValue)

        end

        if typeof(Color) ~= "Color3" then

            return

        end

        Hue, Sat, Val = Color:ToHSV()

        Refresh()

    end

    function Object:Fire()

        Emit()

    end

    function Object:SetCallback(NewCallback)

        Callback = NewCallback or function() end

    end

    function Object:SetText(NewText)

        Text = tostring(NewText)

        Label.Text = Text

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

return ColorPicker
