--========================================================--
-- Pilgrammed GUI Library
-- Image Widget
--========================================================--

local Image = {}

Image.__index = Image

------------------------------------------------------------
-- Create Image
------------------------------------------------------------

function Image.Create(Parent, Settings)

    Settings = Settings or {}

    local self = setmetatable({}, Image)

    --------------------------------------------------------

    local Height = Settings.Height or 160

    local ScaleType = Settings.ScaleType or Enum.ScaleType.Fit

    --------------------------------------------------------

    local IsButton = Settings.Button or false

local ImageObject

if IsButton then

    ImageObject = Instance.new("ImageButton")

    ImageObject.AutoButtonColor = false

else

    ImageObject = Instance.new("ImageLabel")

end

    ImageObject.Name = "Image"

    ImageObject.Parent = Parent

    ImageObject.Size = UDim2.new(1,-10,0,Height)

    ImageObject.BackgroundTransparency = 1

    ImageObject.BorderSizePixel = 0

    ImageObject.ScaleType = ScaleType

    ImageObject.Image = Settings.Image or ""

    ImageObject.ClipsDescendants = true

    if Settings.AspectRatio then

    local Constraint = Instance.new("UIAspectRatioConstraint")

    Constraint.AspectRatio = Settings.AspectRatio

    Constraint.Parent = ImageObject

end

    ImageObject.ImageTransparency = Settings.Transparency or 0

    ImageObject.BackgroundColor3 = Settings.BackgroundColor or Color3.new(1,1,1)

    ImageObject.BackgroundTransparency = Settings.BackgroundTransparency or 1

    Instance.new("UICorner",ImageObject).CornerRadius = UDim.new(0,6)

    --------------------------------------------------------

    self.Instance = ImageObject

    self.IsButton = IsButton

    --------------------------------------------------------
-- Button Events
--------------------------------------------------------

if IsButton then

    if Settings.ClickSound then

        ImageObject.MouseButton1Click:Connect(function()

            if typeof(Settings.ClickSound) == "table" then

                Settings.ClickSound:Play()

            elseif typeof(Settings.ClickSound) == "string" then

                local Sound = Instance.new("Sound")

                Sound.SoundId = Settings.ClickSound

                Sound.Parent = game:GetService("SoundService")

                Sound:Play()

                Sound.Ended:Connect(function()

                Sound:Destroy()

                end)

            end

        end)

    end

    if Settings.OnClick then

        ImageObject.MouseButton1Click:Connect(function()

            Settings.OnClick(self)

        end)

    end

    if Settings.OnRightClick then

        ImageObject.MouseButton2Click:Connect(function()

            Settings.OnRightClick(self)

        end)

    end

    if Settings.OnHover then

        ImageObject.MouseEnter:Connect(function()

            Settings.OnHover(self)

        end)

    end

    if Settings.OnLeave then

        ImageObject.MouseLeave:Connect(function()

            Settings.OnLeave(self)

        end)

    end

end

    return self

end

------------------------------------------------------------
-- Set Image
------------------------------------------------------------

function Image:SetImage(NewImage)

    self.Instance.Image = NewImage

end

------------------------------------------------------------
-- Get Image
------------------------------------------------------------

function Image:GetImage()

    return self.Instance.Image

end

------------------------------------------------------------
-- Set Height
------------------------------------------------------------

function Image:SetHeight(Height)

    self.Instance.Size = UDim2.new(1,-10,0,Height)

end

------------------------------------------------------------
-- Set Visible
------------------------------------------------------------

function Image:SetVisible(State)

    self.Instance.Visible = State

end

------------------------------------------------------------
-- Set ScaleType
------------------------------------------------------------

function Image:SetScaleType(ScaleType)

    ImageObject.ClipsDescendants = true

    self.Instance.ScaleType = ScaleType

end

------------------------------------------------------------
-- Set Transparency
------------------------------------------------------------

function Image:SetTransparency(Value)

    self.Instance.ImageTransparency = Value

end

------------------------------------------------------------
-- Set Background Transparency
------------------------------------------------------------

function Image:SetBackgroundTransparency(Value)

    self.Instance.BackgroundTransparency = Value

end

------------------------------------------------------------
-- Set Background Color
------------------------------------------------------------

function Image:SetBackgroundColor(Color)

    self.Instance.BackgroundColor3 = Color

end

------------------------------------------------------------
-- Set Corner Radius
------------------------------------------------------------

function Image:SetCornerRadius(Radius)

    local Corner = self.Instance:FindFirstChildOfClass("UICorner")

    if Corner then

        Corner.CornerRadius = Radius

    end

end

------------------------------------------------------------
-- Set Border
------------------------------------------------------------

function Image:SetBorder(Size, Color)

    self.Instance.BorderSizePixel = Size or 0

    if Color then

        self.Instance.BorderColor3 = Color

    end

end

------------------------------------------------------------
-- Set Padding
------------------------------------------------------------

function Image:SetPadding(Pixels)

    self.Instance.Size = UDim2.new(

        1,

        -Pixels,

        0,

        self.Instance.Size.Y.Offset

    )

end

------------------------------------------------------------
-- Set Aspect Ratio
------------------------------------------------------------

function Image:SetAspectRatio(Ratio)

    local Constraint = self.Instance:FindFirstChildOfClass("UIAspectRatioConstraint")

    if not Constraint then

        Constraint = Instance.new("UIAspectRatioConstraint")

        Constraint.Parent = self.Instance

    end

    Constraint.AspectRatio = Ratio

end

------------------------------------------------------------
-- Button API
------------------------------------------------------------

function Image:IsButton()

    return self.IsButton

end

function Image:OnClick(Callback)

    if self.IsButton then

        return self.Instance.MouseButton1Click:Connect(function()

            Callback(self)

        end)

    end

end

function Image:OnRightClick(Callback)

    if self.IsButton then

        return self.Instance.MouseButton2Click:Connect(function()

            Callback(self)

        end)

    end

end

function Image:OnHover(Callback)

    if self.IsButton then

        return self.Instance.MouseEnter:Connect(function()

            Callback(self)

        end)

    end

end

function Image:OnLeave(Callback)

    if self.IsButton then

        return self.Instance.MouseLeave:Connect(function()

            Callback(self)

        end)

    end

end

------------------------------------------------------------
-- Destroy
------------------------------------------------------------

function Image:Destroy()

    self.Instance:Destroy()

end

------------------------------------------------------------

return Image

