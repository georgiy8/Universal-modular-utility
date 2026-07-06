--========================================================--
-- Pilgrammed GUI Library
-- Dropdown Widget
--========================================================--

local Dropdown = {}

------------------------------------------------------------
-- Create Dropdown
------------------------------------------------------------

function Dropdown.Create(Parent, Settings)

    Settings = Settings or {}

    local Text = Settings.Text or "Dropdown"

    local Values = Settings.Values or {}

    local Value = Settings.Default or Values[1]

    local Callback = Settings.Callback or function()

    end

    local Expanded = false

    local Object = {}

    --------------------------------------------------------
    -- Main Frame
    --------------------------------------------------------

    local Frame = Instance.new("Frame")

    Frame.Parent = Parent

    Frame.Size = UDim2.new(1,0,0,34)

    Frame.AutomaticSize = Enum.AutomaticSize.Y

    Frame.BackgroundColor3 = Color3.fromRGB(60,60,60)

    Frame.BorderSizePixel = 0

    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,4)

    --------------------------------------------------------
    -- Main Button
    --------------------------------------------------------

    local Button = Instance.new("TextButton")

    Button.Parent = Frame

    Button.Size = UDim2.new(1,0,0,34)

    Button.BackgroundTransparency = 1

    Button.Text = ""

    --------------------------------------------------------
    -- Label
    --------------------------------------------------------

    local Label = Instance.new("TextLabel")

    Label.Parent = Button

    Label.BackgroundTransparency = 1

    Label.Position = UDim2.fromOffset(10,0)

    Label.Size = UDim2.new(1,-60,1,0)

    Label.Font = Enum.Font.Gotham

    Label.TextColor3 = Color3.new(1,1,1)

    Label.TextSize = 14

    Label.TextXAlignment = Enum.TextXAlignment.Left

    --------------------------------------------------------
    -- Value
    --------------------------------------------------------

    local Current = Instance.new("TextLabel")

    Current.Parent = Button

    Current.BackgroundTransparency = 1

    Current.AnchorPoint = Vector2.new(1,0)

    Current.Position = UDim2.new(1,-10,0,0)

    Current.Size = UDim2.new(0,120,1,0)

    Current.Font = Enum.Font.GothamBold

    Current.TextColor3 = Color3.new(1,1,1)

    Current.TextSize = 14

    Current.TextXAlignment = Enum.TextXAlignment.Right

    --------------------------------------------------------
    -- List
    --------------------------------------------------------

    local List = Instance.new("Frame")

    List.Parent = Frame

    List.Position = UDim2.fromOffset(0,34)

    List.Size = UDim2.new(1,0,0,0)

    List.AutomaticSize = Enum.AutomaticSize.Y

    List.BackgroundTransparency = 1

    List.Visible = false

    --------------------------------------------------------

    local Layout = Instance.new("UIListLayout")

    Layout.Parent = List

    Layout.Padding = UDim.new(0,2)

    --------------------------------------------------------

    local function Update()

        Label.Text = Text

        Current.Text = tostring(Value)

    end

    --------------------------------------------------------

    local function Rebuild()

        for _,Child in ipairs(List:GetChildren()) do

            if not Child:IsA("UIListLayout") then

                Child:Destroy()

            end

        end

        for _,Item in ipairs(Values) do

            local Option = Instance.new("TextButton")

            Option.Parent = List

            Option.Size = UDim2.new(1,-8,0,28)

            Option.Position = UDim2.fromOffset(4,0)

            Option.BackgroundColor3 = Color3.fromRGB(48,48,48)

            Option.BorderSizePixel = 0

            Option.Font = Enum.Font.Gotham

            Option.Text = tostring(Item)

            Option.TextColor3 = Color3.new(1,1,1)

            Option.TextSize = 13

            Instance.new("UICorner",Option).CornerRadius = UDim.new(0,4)

            Option.MouseButton1Click:Connect(function()

                Value = Item

                Update()

                Expanded = false

                List.Visible = false

                pcall(function()

                    Callback(Value)

                end)

            end)

        end

    end

    --------------------------------------------------------

    Button.MouseButton1Click:Connect(function()

        Expanded = not Expanded

        List.Visible = Expanded

    end)

    --------------------------------------------------------

    Rebuild()

    Update()

    --------------------------------------------------------
    -- API
    --------------------------------------------------------

    Object.Instance = Frame

    function Object:GetValue()

        return Value

    end

    function Object:SetValue(NewValue)

        Value = NewValue

        Update()

    end

    function Object:SetValues(NewValues)

        Values = NewValues

        Rebuild()

    end

    function Object:SetText(NewText)

        Text = NewText

        Update()

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

    return Object

end

------------------------------------------------------------

return Dropdown
