--========================================================--
-- Universal-modular-utility GUI Library
-- List Widget (список / таблица с выбором строки, не сохраняется в профили)
-- Items = { "текст", ... } или { {"колонка1","колонка2"}, ... }
-- Columns = { "Имя", "Значение" } (необязательно, рисует шапку)
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

local List = {}

function List.Create(Parent, Settings)

    Settings = Settings or {}

    local Text = Settings.Text
    local Columns = Settings.Columns
    local Items = {}
    local Height = Settings.Height or 140
    local RowHeight = Settings.RowHeight or 26
    local Callback = Settings.Callback or function() end
    local Selected = nil
    local RowObjects = {}

    local Object = {}

    local Frame = Instance.new("Frame")
    Frame.Name = "List"
    Frame.Parent = Parent
    Frame.Size = UDim2.new(1,0,0,0)
    Frame.AutomaticSize = Enum.AutomaticSize.Y
    Frame.BackgroundColor3 = C("Row", Color3.fromRGB(45,49,58))
    Frame.BorderSizePixel = 0
    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,6)

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Frame
    Layout.Padding = UDim.new(0,4)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local Pad = Instance.new("UIPadding")
    Pad.Parent = Frame
    Pad.PaddingTop = UDim.new(0,6)
    Pad.PaddingBottom = UDim.new(0,6)
    Pad.PaddingLeft = UDim.new(0,6)
    Pad.PaddingRight = UDim.new(0,6)

    local Title
    if Text then
        Title = Instance.new("TextLabel")
        Title.Parent = Frame
        Title.LayoutOrder = 1
        Title.BackgroundTransparency = 1
        Title.Size = UDim2.new(1,0,0,18)
        Title.Font = Enum.Font.Gotham
        Title.TextSize = 14
        Title.Text = Text
        Title.TextColor3 = C("Text", Color3.new(1,1,1))
        Title.TextXAlignment = Enum.TextXAlignment.Left
    end

    local Header = Instance.new("Frame")
    Header.Parent = Frame
    Header.LayoutOrder = 2
    Header.BackgroundTransparency = 1
    Header.Size = UDim2.new(1,0,0,20)
    Header.Visible = false

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Parent = Frame
    Scroll.LayoutOrder = 3
    Scroll.Size = UDim2.new(1,0,0,Height)
    Scroll.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.CanvasSize = UDim2.new()
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    Instance.new("UICorner",Scroll).CornerRadius = UDim.new(0,5)

    local ScrollLayout = Instance.new("UIListLayout")
    ScrollLayout.Parent = Scroll
    ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function Cells(Item)
        if type(Item) == "table" then
            return Item
        end
        return { tostring(Item) }
    end

    local function ColumnCount()
        if Columns then
            return #Columns
        end
        local Max = 1
        for _, Item in ipairs(Items) do
            Max = math.max(Max, #Cells(Item))
        end
        return Max
    end

    local function MakeCells(Row, Values, Count, Font, Color)
        for Index = 1, Count do
            local Cell = Instance.new("TextLabel")
            Cell.Parent = Row
            Cell.BackgroundTransparency = 1
            Cell.Position = UDim2.new((Index - 1) / Count, 8, 0, 0)
            Cell.Size = UDim2.new(1 / Count, -10, 1, 0)
            Cell.Font = Font
            Cell.TextSize = 13
            Cell.TextTruncate = Enum.TextTruncate.AtEnd
            Cell.TextXAlignment = Enum.TextXAlignment.Left
            Cell.TextColor3 = Color
            Cell.Text = tostring(Values[Index] or "")
        end
    end

    local function Highlight()
        for Index, Row in ipairs(RowObjects) do
            Row.BackgroundTransparency = (Index == Selected) and 0.7 or 1
            Row.BackgroundColor3 = C("Accent", Color3.fromRGB(70,160,255))
        end
    end

    local function Rebuild()
        for _, Row in ipairs(RowObjects) do
            Row:Destroy()
        end
        RowObjects = {}

        local Count = ColumnCount()

        for _, Child in ipairs(Header:GetChildren()) do
            Child:Destroy()
        end
        if Columns then
            Header.Visible = true
            MakeCells(Header, Columns, Count, Enum.Font.GothamBold, C("TextMuted", Color3.fromRGB(184,190,201)))
        else
            Header.Visible = false
        end

        for Index, Item in ipairs(Items) do
            local Row = Instance.new("TextButton")
            Row.Parent = Scroll
            Row.LayoutOrder = Index
            Row.Size = UDim2.new(1,0,0,RowHeight)
            Row.BorderSizePixel = 0
            Row.BackgroundTransparency = 1
            Row.Text = ""
            Row.AutoButtonColor = false
            MakeCells(Row, Cells(Item), Count, Enum.Font.Gotham, C("Text", Color3.new(1,1,1)))

            Row.MouseButton1Click:Connect(function()
                Selected = Index
                Highlight()
                pcall(Callback, Items[Index], Index)
            end)

            RowObjects[Index] = Row
        end

        if Selected and Selected > #Items then
            Selected = nil
        end
        Highlight()
    end

    Items = Settings.Items or {}
    Rebuild()

    Object.Instance = Frame

    function Object:SetItems(NewItems)
        Items = NewItems or {}
        Selected = nil
        Rebuild()
    end

    function Object:AddItem(Item)
        table.insert(Items, Item)
        Rebuild()
    end

    function Object:RemoveItem(Index)
        if Items[Index] ~= nil then
            table.remove(Items, Index)
            Rebuild()
        end
    end

    function Object:Clear()
        Items = {}
        Selected = nil
        Rebuild()
    end

    function Object:GetItems()
        return Items
    end

    function Object:GetSelected()
        if Selected then
            return Items[Selected], Selected
        end
        return nil, nil
    end

    function Object:GetValue()
        return (Object:GetSelected())
    end

    function Object:SetSelected(Index)
        Selected = (Index and Items[Index] ~= nil) and Index or nil
        Highlight()
    end

    function Object:SetColumns(NewColumns)
        Columns = NewColumns
        Rebuild()
    end

    function Object:SetCallback(NewCallback)
        Callback = NewCallback or function() end
    end

    function Object:SetText(NewText)
        if Title then
            Title.Text = tostring(NewText)
        end
    end

    function Object:SetVisible(State)
        Frame.Visible = State
    end

    function Object:Destroy()
        Frame:Destroy()
    end

    return Object

end

return List
