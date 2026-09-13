--========================================================--
-- Universal-modular-utility GUI Library
-- Button Widget
--========================================================--

local Button = {}

Button.__index = Button

------------------------------------------------------------
-- Create Button
------------------------------------------------------------

function Button.Create(Parent, Settings)

    Settings = Settings or {}

    local self = setmetatable({}, Button)

    local Text = Settings.Text or "Button"

    self.Callback = Settings.Callback or function() end

    local ButtonObject = Instance.new("TextButton")

    ButtonObject.Name = "Button"

    ButtonObject.Parent = Parent

    ButtonObject.Size = UDim2.new(1, -10, 0, 28)

    ButtonObject.BackgroundColor3 = Color3.fromRGB(60,60,60)

    ButtonObject.BorderSizePixel = 0

    ButtonObject.Font = Enum.Font.Gotham

    ButtonObject.Text = Text

    ButtonObject.TextSize = 14

    ButtonObject.TextColor3 = Color3.fromRGB(255,255,255)

    Instance.new("UICorner", ButtonObject).CornerRadius = UDim.new(0,4)

    ButtonObject.MouseButton1Click:Connect(function()

        self.Callback()

    end)

    self.Instance = ButtonObject

    return self

end

------------------------------------------------------------
-- Set Text
------------------------------------------------------------

function Button:SetText(Text)

    self.Instance.Text = Text

end

------------------------------------------------------------
-- Get Text
------------------------------------------------------------

function Button:GetText()

    return self.Instance.Text

end

------------------------------------------------------------
-- Set Callback
------------------------------------------------------------

function Button:SetCallback(Callback)

    self.Callback = Callback or function() end

end

------------------------------------------------------------
-- Fire
------------------------------------------------------------

function Button:Fire()

    self.Callback()

end

------------------------------------------------------------
-- Set Color
------------------------------------------------------------

function Button:SetColor(Color)

    self.Instance.BackgroundColor3 = Color

end

------------------------------------------------------------
-- Set Visible
------------------------------------------------------------

function Button:SetVisible(State)

    self.Instance.Visible = State

end

------------------------------------------------------------
-- Set Enabled
------------------------------------------------------------

function Button:SetEnabled(State)

    self.Instance.Active = State

    self.Instance.AutoButtonColor = State

end

------------------------------------------------------------
-- Destroy
------------------------------------------------------------

function Button:Destroy()

    self.Instance:Destroy()

end

------------------------------------------------------------

return Button
