--========================================================--
-- Universal-modular-utility GUI Library
-- Button Widget
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

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

    ButtonObject.Size = UDim2.new(1, 0, 0, 28)

    local Style = Settings.Style

    local BaseColor = C("Row", Color3.fromRGB(60,60,60))
    local HoverColor = C("RowHover", Color3.fromRGB(72,77,90))
    local TextColor = C("Text", Color3.fromRGB(255,255,255))

    if Style == "Primary" then
        BaseColor = C("Accent", Color3.fromRGB(70,160,255))
        HoverColor = Color3.fromRGB(100,180,255)
        TextColor = Color3.fromRGB(12,21,34)
    elseif Style == "Danger" then
        BaseColor = C("Danger", Color3.fromRGB(220,85,85))
        HoverColor = Color3.fromRGB(235,110,110)
        TextColor = Color3.new(1,1,1)
    end

    self.BaseColor = BaseColor
    self.HoverColor = HoverColor
    self.Enabled = true

    ButtonObject.BackgroundColor3 = BaseColor

    ButtonObject.AutoButtonColor = false

    ButtonObject.BorderSizePixel = 0

    ButtonObject.Font = Enum.Font.Gotham

    ButtonObject.Text = Text

    ButtonObject.TextSize = 14

    ButtonObject.TextColor3 = TextColor

    Instance.new("UICorner", ButtonObject).CornerRadius = UDim.new(0,5)

    local TweenService = game:GetService("TweenService")

    local function Fade(Color)
        TweenService:Create(
            ButtonObject,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundColor3 = Color }
        ):Play()
    end

    ButtonObject.MouseEnter:Connect(function()
        if self.Enabled then Fade(self.HoverColor) end
    end)

    ButtonObject.MouseLeave:Connect(function()
        Fade(self.BaseColor)
    end)

    -- нажатие: на мгновение темнее
    ButtonObject.MouseButton1Down:Connect(function()
        if self.Enabled then Fade(self.BaseColor) end
    end)

    ButtonObject.MouseButton1Up:Connect(function()
        if self.Enabled then Fade(self.HoverColor) end
    end)

    ButtonObject.MouseButton1Click:Connect(function()

        if not self.Enabled then
            return
        end

        local Success, Error = pcall(self.Callback)

        if not Success then
            warn("[Button] " .. tostring(Error))
        end

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

    self.BaseColor = Color

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

    self.Enabled = State

    self.Instance.Active = State

    self.Instance.TextTransparency = State and 0 or 0.5

    self.Instance.BackgroundColor3 = self.BaseColor

end

------------------------------------------------------------
-- Destroy
------------------------------------------------------------

function Button:Destroy()

    self.Instance:Destroy()

end

------------------------------------------------------------

return Button
