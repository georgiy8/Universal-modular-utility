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

    local ImageObject = Instance.new("ImageLabel")

    ImageObject.Name = "Image"

    ImageObject.Parent = Parent

    ImageObject.Size = UDim2.new(1,0,0,Height)

    ImageObject.BackgroundTransparency = 1

    ImageObject.BorderSizePixel = 0

    ImageObject.ClipsDescendants = true

    ImageObject.ScaleType = ScaleType

    ImageObject.Image = Settings.Image or ""

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

    return self

end

------------------------------------------------------------
-- Set Image
------------------------------------------------------------

function Image:SetImage(Image)

    self.Instance.Image = Image

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
-- Set ScaleType
------------------------------------------------------------

function Image:SetScaleType(ScaleType)

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
-- Set Visible
------------------------------------------------------------

function Image:SetVisible(State)

    self.Instance.Visible = State

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
-- Destroy
------------------------------------------------------------

function Image:Destroy()

    self.Instance:Destroy()

end

------------------------------------------------------------

return Image
