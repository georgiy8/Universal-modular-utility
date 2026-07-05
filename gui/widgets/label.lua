--========================================================--
-- Pilgrammed GUI Library
-- Label Widget
--========================================================--

local Label = {}

------------------------------------------------------------
-- Create Label
------------------------------------------------------------

function Label.Create(Parent, Settings)

    Settings = Settings or {}

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

    return LabelObject

end

------------------------------------------------------------

return Label
