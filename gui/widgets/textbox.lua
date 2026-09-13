--========================================================--
-- Universal-modular-utility GUI Library
-- Textbox Widget
--========================================================--

local Textbox = {}

------------------------------------------------------------
-- Create Textbox
------------------------------------------------------------

function Textbox.Create(Parent, Settings)

    Settings = Settings or {}

    local Text = Settings.Text or "Textbox"

    local Placeholder = Settings.Placeholder or ""

    local Value = Settings.Default or ""

    local Callback = Settings.Callback or function()

    end

    --------------------------------------------------------

    local Object = {}

    --------------------------------------------------------
    -- Main Frame
    --------------------------------------------------------

    local Frame = Instance.new("Frame")

    Frame.Parent = Parent

    Frame.Size = UDim2.new(1,0,0,56)

    Frame.BackgroundColor3 = Color3.fromRGB(60,60,60)

    Frame.BorderSizePixel = 0

    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,4)

    --------------------------------------------------------
    -- Label
    --------------------------------------------------------

    local Label = Instance.new("TextLabel")

    Label.Parent = Frame

    Label.BackgroundTransparency = 1

    Label.Position = UDim2.fromOffset(10,4)

    Label.Size = UDim2.new(1,-20,0,18)

    Label.Font = Enum.Font.Gotham

    Label.Text = Text

    Label.TextColor3 = Color3.new(1,1,1)

    Label.TextSize = 14

    Label.TextXAlignment = Enum.TextXAlignment.Left

    --------------------------------------------------------
    -- Input
    --------------------------------------------------------

    local Input = Instance.new("TextBox")

    Input.Parent = Frame

    Input.Position = UDim2.fromOffset(10,26)

    Input.Size = UDim2.new(1,-20,0,22)

    Input.BackgroundColor3 = Color3.fromRGB(40,40,40)

    Input.BorderSizePixel = 0

    Input.ClearTextOnFocus = false

    Input.Font = Enum.Font.Gotham

    Input.Text = Value

    Input.PlaceholderText = Placeholder

    Input.PlaceholderColor3 = Color3.fromRGB(160,160,160)

    Input.TextColor3 = Color3.new(1,1,1)

    Input.TextSize = 13

    Instance.new("UICorner",Input).CornerRadius = UDim.new(0,4)

    --------------------------------------------------------
    -- Submit
    --------------------------------------------------------

    Input.FocusLost:Connect(function(EnterPressed)

        Value = Input.Text

        local Success, Error = pcall(function()

            Callback(Value, EnterPressed)

        end)

        if not Success then

            warn("[Textbox] "..tostring(Error))

        end

    end)

    --------------------------------------------------------
    -- API
    --------------------------------------------------------

    Object.Instance = Frame

    function Object:GetValue()

        return Value

    end

    function Object:SetValue(NewValue)

        Value = tostring(NewValue)

        Input.Text = Value

    end

    function Object:Clear()

        Value = ""

        Input.Text = ""

    end

    function Object:SetPlaceholder(Text)

        Placeholder = tostring(Text)

        Input.PlaceholderText = Placeholder

    end

    function Object:SetText(NewText)

        Text = tostring(NewText)

        Label.Text = Text

    end

    function Object:SetCallback(NewCallback)

        Callback = NewCallback

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

return Textbox
