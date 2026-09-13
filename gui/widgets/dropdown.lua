--========================================================--
-- Universal-modular-utility GUI Library
-- Dropdown Widget
--========================================================--

local Dropdown = {}
 
------------------------------------------------------------
-- Create Dropdown
------------------------------------------------------------
 
function Dropdown.Create(Parent, Settings)
 
    Settings = Settings or {}
 
    local Text = Settings.Text or "Dropdown"
 
    local Values = Settings.Values or Settings.Options or {}
 
    local MultiSelect = Settings.MultiSelect == true
 
    -- single-select mode uses `Value`; multi-select mode uses the `Selected` set
    local Value = nil
    local Selected = {}
 
    if MultiSelect then
        if type(Settings.Default) == "table" then
            for _, v in ipairs(Settings.Default) do
                Selected[v] = true
            end
        end
    else
        Value = Settings.Default or Values[1]
    end
 
    local Callback = Settings.Callback or function()
 
    end
 
    local Expanded = false
 
    local Object = {}
 
    --------------------------------------------------------
    -- Multi-select helpers
    --------------------------------------------------------
 
    local function GetSelectedList()
 
        local List = {}
 
        for _, Item in ipairs(Values) do
 
            if Selected[Item] then
 
                table.insert(List, Item)
 
            end
 
        end
 
        return List
 
    end
 
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
 
    local ListPadding = Instance.new("UIPadding")
    ListPadding.Parent = List
    ListPadding.PaddingLeft = UDim.new(0, 4)
    ListPadding.PaddingRight = UDim.new(0, 4)
    ListPadding.PaddingTop = UDim.new(0, 2)
    ListPadding.PaddingBottom = UDim.new(0, 4)
 
    --------------------------------------------------------
 
    local function Update()
 
        Label.Text = Text
 
        if MultiSelect then
 
            local Names = GetSelectedList()
 
            if #Names == 0 then
 
                Current.Text = "None"
 
            elseif #Names <= 2 then
 
                Current.Text = table.concat(Names, ", ")
 
            else
 
                Current.Text = #Names .. " selected"
 
            end
 
        else
 
            Current.Text = tostring(Value)
 
        end
 
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
 
            Option.Size = UDim2.new(1, 0, 0, 28)
 
            Option.BackgroundColor3 = Color3.fromRGB(48,48,48)
 
            Option.BorderSizePixel = 0
 
            Option.Font = Enum.Font.Gotham
 
            Option.Text = tostring(Item)
 
            Option.TextColor3 = Color3.new(1,1,1)
 
            Option.TextSize = 13
 
            Instance.new("UICorner",Option).CornerRadius = UDim.new(0,4)
 
            local Indicator
 
            if MultiSelect then
 
                Option.TextXAlignment = Enum.TextXAlignment.Left
 
                local OptionPadding = Instance.new("UIPadding")
                OptionPadding.Parent = Option
                OptionPadding.PaddingLeft = UDim.new(0, 8)
                OptionPadding.PaddingRight = UDim.new(0, 28)
 
                local Box = Instance.new("Frame")
 
                Box.Parent = Option
 
                Box.AnchorPoint = Vector2.new(1,0.5)
 
                Box.Position = UDim2.new(1,-8,0.5,0)
 
                Box.Size = UDim2.fromOffset(16,16)
 
                Box.BackgroundColor3 = Color3.fromRGB(35,35,35)
 
                Box.BorderSizePixel = 0
 
                Instance.new("UICorner",Box).CornerRadius = UDim.new(0,4)
 
                Indicator = Instance.new("Frame")
 
                Indicator.Parent = Box
 
                Indicator.AnchorPoint = Vector2.new(0.5,0.5)
 
                Indicator.Position = UDim2.fromScale(0.5,0.5)
 
                Indicator.Size = UDim2.fromOffset(10,10)
 
                Indicator.BorderSizePixel = 0
 
                Indicator.BackgroundColor3 = Color3.fromRGB(0,170,255)
 
                Indicator.Visible = Selected[Item] == true
 
                Instance.new("UICorner",Indicator).CornerRadius = UDim.new(0,3)
 
            end
 
            Option.MouseButton1Click:Connect(function()
 
                if MultiSelect then
 
                    Selected[Item] = not Selected[Item]
 
                    if Indicator then
 
                        Indicator.Visible = Selected[Item] == true
 
                    end
 
                    Update()
 
                    -- stays open: user can tick several options in a row
 
                    pcall(function()
 
                        Callback(GetSelectedList())
 
                    end)
 
                else
 
                    Value = Item
 
                    Update()
 
                    Expanded = false
 
                    List.Visible = false
 
                    pcall(function()
 
                        Callback(Value)
 
                    end)
 
                end
 
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
 
        if MultiSelect then
 
            return GetSelectedList()
 
        end
 
        return Value
 
    end
 
    -- alias, reads better at the call site when MultiSelect = true
    function Object:GetValues()
 
        return Object:GetValue()
 
    end
 
    function Object:SetValue(NewValue)
 
        if MultiSelect then
 
            Selected = {}
 
            if type(NewValue) == "table" then
 
                for _, v in ipairs(NewValue) do
 
                    Selected[v] = true
 
                end
 
            end
 
            Rebuild()
 
        else
 
            Value = NewValue
 
        end
 
        Update()
 
    end
 
    function Object:SetValues(NewValues)
 
        Values = NewValues
 
        if MultiSelect then
 
            local Filtered = {}
 
            for _, v in ipairs(Values) do
 
                if Selected[v] then
 
                    Filtered[v] = true
 
                end
 
            end
 
            Selected = Filtered
 
        end
 
        Rebuild()
 
        Update()
 
    end
 
    function Object:IsMultiSelect()
 
        return MultiSelect
 
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
