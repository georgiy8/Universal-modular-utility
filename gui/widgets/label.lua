--========================================================--
-- Pilgrammed GUI Library
-- Label Widget
--========================================================--

local Label = {}

Label.__index = Label

------------------------------------------------------------
-- Create Label
------------------------------------------------------------

function Label.Create(Parent, Settings)

    Settings = Settings or {}

    local self = setmetatable({}, Label)

    local Text = Settings.Text or "Label"

    local LabelObject = Instance.new("TextLabel")

    LabelObject.Name = "Label"

    LabelObject.Parent = Parent

    LabelObject.Size = UDim2.new(1, -10, 0, 24)

    LabelObject.BackgroundTransparency = 1

    LabelObject.Font = Enum.Font.Gotham

    LabelObject.Text = Text

    LabelObject.TextSize = 14

    LabelObject.TextColor3 = Color3.fromRGB(255,255,255)

    LabelObject.TextXAlignment = Enum.TextXAlignment.Left

    self.Instance = LabelObject

    return self

end

------------------------------------------------------------
-- Set Text
------------------------------------------------------------

function Label:SetText(Text)

    self.Instance.Text = Text

end

------------------------------------------------------------
-- Get Text
------------------------------------------------------------

function Label:GetText()

    return self.Instance.Text

end

------------------------------------------------------------
-- Set Color
------------------------------------------------------------

function Label:SetColor(Color)

    self.Instance.TextColor3 = Color

end

------------------------------------------------------------
-- Set Visible
------------------------------------------------------------

function Label:SetVisible(State)

    self.Instance.Visible = State

end

------------------------------------------------------------
-- Destroy
------------------------------------------------------------

function Label:Destroy()

    self.Instance:Destroy()

end

------------------------------------------------------------

return Label
