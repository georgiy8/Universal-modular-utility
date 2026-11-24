--========================================================--
-- Universal-modular-utility GUI Library
-- Dropdown Widget (поиск, прокрутка длинных списков, подсветка выбранного)
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

local MAX_LIST_HEIGHT = 210
local SEARCH_FROM = 7 -- поиск появляется автоматически, если вариантов не меньше

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

    local function IsSeparator(Item)
        return type(Item) == "table" and Item.Separator == true
    end

    if MultiSelect then
        if type(Settings.Default) == "table" then
            for _, v in ipairs(Settings.Default) do
                Selected[v] = true
            end
        end
    else
        if Settings.Default ~= nil then
            Value = Settings.Default
        else
            for _, Item in ipairs(Values) do
                if not IsSeparator(Item) then
                    Value = Item
                    break
                end
            end
        end
    end

    local Callback = Settings.Callback or function() end

    local Expanded = false

    local Object = {}

    local Entries = {} -- { Item = ..., Gui = ..., Button = ... }

    --------------------------------------------------------
    -- Multi-select helpers
    --------------------------------------------------------

    local function GetSelectedList()
        local List = {}
        for _, Item in ipairs(Values) do
            if not IsSeparator(Item) and Selected[Item] then
                table.insert(List, Item)
            end
        end
        return List
    end

    --------------------------------------------------------
    -- Main Frame
    --------------------------------------------------------

    local Frame = Instance.new("Frame")
    Frame.Name = "Dropdown"
    Frame.Parent = Parent
    Frame.Size = UDim2.new(1,0,0,34)
    Frame.AutomaticSize = Enum.AutomaticSize.Y
    Frame.BackgroundColor3 = C("Row", Color3.fromRGB(60,60,60))
    Frame.BorderSizePixel = 0
    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,5)

    --------------------------------------------------------
    -- Main Button
    --------------------------------------------------------

    local Button = Instance.new("TextButton")
    Button.Parent = Frame
    Button.Size = UDim2.new(1,0,0,34)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.AutoButtonColor = false

    local Label = Instance.new("TextLabel")
    Label.Parent = Button
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(10,0)
    Label.Size = UDim2.new(0.5,-10,1,0)
    Label.Font = Enum.Font.Gotham
    Label.TextColor3 = C("Text", Color3.new(1,1,1))
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd

    local Arrow = Instance.new("TextLabel")
    Arrow.Parent = Button
    Arrow.BackgroundTransparency = 1
    Arrow.AnchorPoint = Vector2.new(1,0)
    Arrow.Position = UDim2.new(1,-8,0,0)
    Arrow.Size = UDim2.fromOffset(14,34)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.Text = "v"
    Arrow.TextColor3 = C("TextDim", Color3.fromRGB(150,158,171))
    Arrow.TextSize = 12

    local Current = Instance.new("TextLabel")
    Current.Parent = Button
    Current.BackgroundTransparency = 1
    Current.AnchorPoint = Vector2.new(1,0)
    Current.Position = UDim2.new(1,-26,0,0)
    Current.Size = UDim2.new(0.5,-26,1,0)
    Current.Font = Enum.Font.GothamBold
    Current.TextColor3 = C("Text", Color3.new(1,1,1))
    Current.TextSize = 14
    Current.TextXAlignment = Enum.TextXAlignment.Right
    Current.TextTruncate = Enum.TextTruncate.AtEnd

    --------------------------------------------------------
    -- List: [поиск] + прокручиваемый список
    --------------------------------------------------------

    local List = Instance.new("Frame")
    List.Name = "List"
    List.Parent = Frame
    List.Position = UDim2.fromOffset(0,34)
    List.Size = UDim2.new(1,0,0,0)
    List.AutomaticSize = Enum.AutomaticSize.Y
    List.BackgroundTransparency = 1
    List.Visible = false

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = List
    ListLayout.Padding = UDim.new(0,4)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local ListPadding = Instance.new("UIPadding")
    ListPadding.Parent = List
    ListPadding.PaddingLeft = UDim.new(0,4)
    ListPadding.PaddingRight = UDim.new(0,4)
    ListPadding.PaddingTop = UDim.new(0,2)
    ListPadding.PaddingBottom = UDim.new(0,5)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "Search"
    SearchBox.Parent = List
    SearchBox.LayoutOrder = 1
    SearchBox.Size = UDim2.new(1,0,0,28)
    SearchBox.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))
    SearchBox.BorderSizePixel = 0
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 13
    SearchBox.TextColor3 = C("Text", Color3.new(1,1,1))
    SearchBox.PlaceholderText = "Поиск..."
    SearchBox.PlaceholderColor3 = C("TextDim", Color3.fromRGB(150,158,171))
    SearchBox.Text = ""
    SearchBox.ClearTextOnFocus = false
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.Visible = false
    Instance.new("UICorner",SearchBox).CornerRadius = UDim.new(0,5)
    local SearchPadding = Instance.new("UIPadding")
    SearchPadding.Parent = SearchBox
    SearchPadding.PaddingLeft = UDim.new(0,8)
    SearchPadding.PaddingRight = UDim.new(0,8)

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Name = "Items"
    Scroll.Parent = List
    Scroll.LayoutOrder = 2
    Scroll.Size = UDim2.new(1,0,0,0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.CanvasSize = UDim2.new()
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.ScrollingDirection = Enum.ScrollingDirection.Y

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Scroll
    Layout.Padding = UDim.new(0,2)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function FitScroll()
        Scroll.Size = UDim2.new(1,0,0,math.min(Layout.AbsoluteContentSize.Y, MAX_LIST_HEIGHT))
    end

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(FitScroll)

    local Empty = Instance.new("TextLabel")
    Empty.Name = "Empty"
    Empty.Parent = Scroll
    Empty.LayoutOrder = 1000000
    Empty.Size = UDim2.new(1,0,0,26)
    Empty.BackgroundTransparency = 1
    Empty.Font = Enum.Font.Gotham
    Empty.TextSize = 13
    Empty.TextColor3 = C("TextDim", Color3.fromRGB(150,158,171))
    Empty.Text = "Ничего не найдено"
    Empty.Visible = false

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

        -- подсветка выбранного варианта
        if not MultiSelect then
            for _, Entry in ipairs(Entries) do
                if Entry.Button then
                    local IsCurrent = (Entry.Item == Value)
                    Entry.Button.BackgroundColor3 = IsCurrent and C("RowHover", Color3.fromRGB(56,61,72)) or C("Option", Color3.fromRGB(48,48,48))
                    Entry.Button.TextColor3 = IsCurrent and C("Accent", Color3.fromRGB(70,160,255)) or C("Text", Color3.new(1,1,1))
                end
            end
        end

    end

    --------------------------------------------------------
    -- Поиск
    --------------------------------------------------------

    local function ApplyFilter()
        local Query = string.lower(SearchBox.Text or "")
        Query = Query:match("^%s*(.-)%s*$") or ""
        local Shown = 0
        for _, Entry in ipairs(Entries) do
            if Entry.Button then
                local Match = Query == "" or string.find(string.lower(tostring(Entry.Item)), Query, 1, true) ~= nil
                Entry.Button.Visible = Match
                if Match then
                    Shown = Shown + 1
                end
            else
                Entry.Gui.Visible = (Query == "")
            end
        end
        Empty.Visible = (Query ~= "" and Shown == 0)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(ApplyFilter)

    local function SetExpanded(State)
        Expanded = State
        List.Visible = State
        Arrow.Text = State and "^" or "v"
        if not State and SearchBox.Text ~= "" then
            SearchBox.Text = ""
        end
        if State and SearchBox.Visible then
            task.defer(function()
                if Expanded then
                    pcall(function() SearchBox:CaptureFocus() end)
                end
            end)
        end
    end

    --------------------------------------------------------

    local function Rebuild()

        for _,Child in ipairs(Scroll:GetChildren()) do
            if not Child:IsA("UIListLayout") and Child ~= Empty then
                Child:Destroy()
            end
        end

        Entries = {}

        local OrderIndex = 0
        local OptionCount = 0

        for _,Item in ipairs(Values) do

            OrderIndex = OrderIndex + 1

            if IsSeparator(Item) then

                local Sep = Instance.new("Frame")
                Sep.Parent = Scroll
                Sep.LayoutOrder = OrderIndex
                Sep.BackgroundTransparency = 1
                Sep.Size = UDim2.new(1, 0, 0, (Item.Text and Item.Text ~= "") and 22 or 9)

                if Item.Text and Item.Text ~= "" then
                    local SepLabel = Instance.new("TextLabel")
                    SepLabel.Parent = Sep
                    SepLabel.BackgroundTransparency = 1
                    SepLabel.Position = UDim2.fromOffset(2, 0)
                    SepLabel.Size = UDim2.new(1, -2, 1, -6)
                    SepLabel.Font = Enum.Font.GothamBold
                    SepLabel.TextColor3 = C("TextDim", Color3.fromRGB(150,150,150))
                    SepLabel.TextSize = 12
                    SepLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SepLabel.Text = tostring(Item.Text)
                end

                local Line = Instance.new("Frame")
                Line.Parent = Sep
                Line.AnchorPoint = Vector2.new(0,1)
                Line.Position = UDim2.new(0,0,1,0)
                Line.Size = UDim2.new(1,0,0,1)
                Line.BackgroundColor3 = C("Line", Color3.fromRGB(80,80,80))
                Line.BorderSizePixel = 0

                table.insert(Entries, { Item = Item, Gui = Sep })

            else

                OptionCount = OptionCount + 1

                local Option = Instance.new("TextButton")
                Option.Parent = Scroll
                Option.LayoutOrder = OrderIndex
                Option.Size = UDim2.new(1, 0, 0, 28)
                Option.BackgroundColor3 = C("Option", Color3.fromRGB(48,48,48))
                Option.BorderSizePixel = 0
                Option.AutoButtonColor = false
                Option.Font = Enum.Font.Gotham
                Option.Text = tostring(Item)
                Option.TextColor3 = C("Text", Color3.new(1,1,1))
                Option.TextSize = 13
                Option.TextTruncate = Enum.TextTruncate.AtEnd
                Instance.new("UICorner",Option).CornerRadius = UDim.new(0,5)

                local OptionPadding = Instance.new("UIPadding")
                OptionPadding.Parent = Option
                OptionPadding.PaddingLeft = UDim.new(0, 8)
                OptionPadding.PaddingRight = UDim.new(0, MultiSelect and 28 or 8)
                Option.TextXAlignment = Enum.TextXAlignment.Left

                local Indicator

                if MultiSelect then

                    local Box = Instance.new("Frame")
                    Box.Parent = Option
                    Box.AnchorPoint = Vector2.new(1,0.5)
                    Box.Position = UDim2.new(1,20,0.5,0)
                    Box.Size = UDim2.fromOffset(16,16)
                    Box.BackgroundColor3 = C("Field", Color3.fromRGB(35,35,35))
                    Box.BorderSizePixel = 0
                    Instance.new("UICorner",Box).CornerRadius = UDim.new(0,4)

                    Indicator = Instance.new("Frame")
                    Indicator.Parent = Box
                    Indicator.AnchorPoint = Vector2.new(0.5,0.5)
                    Indicator.Position = UDim2.fromScale(0.5,0.5)
                    Indicator.Size = UDim2.fromOffset(10,10)
                    Indicator.BorderSizePixel = 0
                    Indicator.BackgroundColor3 = C("Accent", Color3.fromRGB(0,170,255))
                    Indicator.Visible = Selected[Item] == true
                    Instance.new("UICorner",Indicator).CornerRadius = UDim.new(0,3)

                end

                Option.MouseEnter:Connect(function()
                    if MultiSelect or Item ~= Value then
                        Option.BackgroundColor3 = C("RowHover", Color3.fromRGB(56,61,72))
                    end
                end)

                Option.MouseLeave:Connect(function()
                    if MultiSelect or Item ~= Value then
                        Option.BackgroundColor3 = C("Option", Color3.fromRGB(48,48,48))
                    end
                end)

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

                        SetExpanded(false)

                        pcall(function()
                            Callback(Value)
                        end)

                    end

                end)

                table.insert(Entries, { Item = Item, Button = Option })

            end

        end

        local WantSearch = Settings.Searchable
        if WantSearch == nil then
            WantSearch = OptionCount >= SEARCH_FROM
        end
        SearchBox.Visible = WantSearch == true

        ApplyFilter()

    end

    --------------------------------------------------------

    Button.MouseButton1Click:Connect(function()
        SetExpanded(not Expanded)
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

    -- вызывает Callback с текущим значением (ConfigManager использует после загрузки профиля)
    function Object:Fire()
        if MultiSelect then
            pcall(Callback, GetSelectedList())
        elseif Value ~= nil then
            pcall(Callback, Value)
        end
    end

    function Object:SetCallback(NewCallback)
        Callback = NewCallback
    end

    function Object:SetVisible(State)
        Frame.Visible = State
    end

    function Object:Close()
        SetExpanded(false)
    end

    function Object:Destroy()
        Frame:Destroy()
    end

    return Object

end

------------------------------------------------------------

return Dropdown
