--========================================================--
-- Universal-modular-utility GUI Library
-- Keybind Widget
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

local UserInputService = game:GetService("UserInputService")

local Keybind = {}

------------------------------------------------------------
-- Create Keybind
------------------------------------------------------------

function Keybind.Create(Parent, Settings)

    Settings = Settings or {}

    local Text = Settings.Text or "Keybind"

    local Key = Settings.Default or Enum.KeyCode.Unknown

    local Callback = Settings.Callback or function()

    end

    local Waiting = false

    -- OnChanged(KeyCode): вызывается при выборе новой клавиши и при загрузке из конфига
    local OnChanged = Settings.OnChanged

    local function Notify()

        if OnChanged then

            pcall(OnChanged, Key)

        end

    end

    -- пока выбираешь клавишу, глобальные горячие клавиши окна не срабатывают
    local function SetCapturing(State)

        if State then

            _G.UMUCapturingKey = true

        else

            task.delay(0.25, function()

                _G.UMUCapturingKey = false

            end)

        end

    end

    local Object = {}

    --------------------------------------------------------
    -- Main
    --------------------------------------------------------

    local Frame = Instance.new("Frame")

    Frame.Parent = Parent

    Frame.Size = UDim2.new(1,0,0,30)

    Frame.BackgroundColor3 = C("Row", Color3.fromRGB(60,60,60))

    Frame.BorderSizePixel = 0

    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,4)

    --------------------------------------------------------
    -- Label
    --------------------------------------------------------

    local Label = Instance.new("TextLabel")

    Label.Parent = Frame

    Label.BackgroundTransparency = 1

    Label.Position = UDim2.fromOffset(10,0)

    Label.Size = UDim2.new(1,-90,1,0)

    Label.Font = Enum.Font.Gotham

    Label.Text = Text

    Label.TextColor3 = C("Text", Color3.new(1,1,1))

    Label.TextSize = 14

    Label.TextXAlignment = Enum.TextXAlignment.Left

    --------------------------------------------------------
    -- Button
    --------------------------------------------------------

    local Button = Instance.new("TextButton")

    Button.Parent = Frame

    Button.AnchorPoint = Vector2.new(1,0.5)

    Button.Position = UDim2.new(1,-8,0.5,0)

    Button.Size = UDim2.fromOffset(70,22)

    Button.BackgroundColor3 = C("Field", Color3.fromRGB(40,40,40))

    Button.BorderSizePixel = 0

    Button.Font = Enum.Font.GothamBold

    Button.TextColor3 = C("Text", Color3.new(1,1,1))

    Button.TextSize = 13

    Instance.new("UICorner",Button).CornerRadius = UDim.new(0,4)

    --------------------------------------------------------

    local function Update()

        if Waiting then

            Button.Text = "..."

        elseif Key == Enum.KeyCode.Unknown then

            Button.Text = "None"

        else

            Button.Text = Key.Name

        end

    end

    Update()

    --------------------------------------------------------
    -- Change Key
    --------------------------------------------------------

    Button.MouseButton1Click:Connect(function()

        Waiting = true

        SetCapturing(true)

        Update()

    end)

    --------------------------------------------------------
    -- Input
    --------------------------------------------------------

    UserInputService.InputBegan:Connect(function(Input, GameProcessed)

        if GameProcessed then

            return

        end

        if Waiting then

            if Input.UserInputType == Enum.UserInputType.Keyboard then

                if Input.KeyCode == Enum.KeyCode.Backspace or Input.KeyCode == Enum.KeyCode.Escape then
                    Key = Enum.KeyCode.Unknown
                else
                    Key = Input.KeyCode
                end

                Waiting = false

                SetCapturing(false)

                Update()

                Notify()

            end

            return

        end

        if Input.UserInputType == Enum.UserInputType.Keyboard then

            if Input.KeyCode == Key then

                local Success, Error = pcall(function()

                    Callback(Key)

                end)

                if not Success then

                    warn("[Keybind] "..tostring(Error))

                end

            end

        end

    end)

    --------------------------------------------------------
    -- API
    --------------------------------------------------------

    Object.Instance = Frame

    function Object:GetKey()

        return Key

    end

    function Object:SetKey(NewKey)

        Key = NewKey

        Update()

        Notify()

    end

    function Object:SetOnChanged(NewHandler)

        OnChanged = NewHandler

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

return Keybind
