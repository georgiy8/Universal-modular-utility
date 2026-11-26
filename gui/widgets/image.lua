--========================================================--
-- Universal-modular-utility GUI Library
-- Image Widget
--
-- Image = "rbxassetid://..", id, путь к файлу (png/jpg) или ПРЯМАЯ ссылка на png/jpg
-- Ссылки скачиваются в кэш и показываются; пока грузится - надпись, при ошибке - причина.
-- ScaleType = Enum.ScaleType.* или "Fit" / "Crop" / "Stretch"
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

local TweenService = game:GetService("TweenService")

local Image = {}

Image.__index = Image

local SCALE = {
    Fit = Enum.ScaleType.Fit,
    Crop = Enum.ScaleType.Crop,
    Stretch = Enum.ScaleType.Stretch,
    Slice = Enum.ScaleType.Slice,
    Tile = Enum.ScaleType.Tile,
}

local function ToScaleType(Value)
    if typeof(Value) == "EnumItem" then
        return Value
    end
    return SCALE[tostring(Value)] or Enum.ScaleType.Fit
end

------------------------------------------------------------
-- Create Image
------------------------------------------------------------

function Image.Create(Parent, Settings)

    Settings = Settings or {}

    local self = setmetatable({}, Image)

    local Height = Settings.Height or 160

    local IsButton = Settings.Button == true

    local Base = Settings.Transparency or 0

    local ImageObject

    if IsButton then
        ImageObject = Instance.new("ImageButton")
        ImageObject.AutoButtonColor = false
    else
        ImageObject = Instance.new("ImageLabel")
    end

    ImageObject.Name = "Image"
    ImageObject.Parent = Parent
    ImageObject.Size = UDim2.new(1,0,0,Height)
    ImageObject.BorderSizePixel = 0
    ImageObject.ScaleType = ToScaleType(Settings.ScaleType)
    ImageObject.ClipsDescendants = true
    ImageObject.Image = ""
    ImageObject.ImageTransparency = Base
    ImageObject.BackgroundColor3 = Settings.BackgroundColor or C("Field", Color3.fromRGB(23,25,30))
    ImageObject.BackgroundTransparency = Settings.BackgroundTransparency or 1

    if Settings.AspectRatio then
        local Constraint = Instance.new("UIAspectRatioConstraint")
        Constraint.AspectRatio = Settings.AspectRatio
        Constraint.Parent = ImageObject
    end

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = Settings.CornerRadius or UDim.new(0,6)
    Corner.Parent = ImageObject

    -- надпись «загрузка» / «ошибка»
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Parent = ImageObject
    Status.BackgroundTransparency = 1
    Status.Size = UDim2.fromScale(1,1)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 13
    Status.TextWrapped = true
    Status.TextColor3 = C("TextMuted", Color3.fromRGB(150,158,171))
    Status.Text = ""
    Status.Visible = false

    self.Instance = ImageObject
    self.Button = IsButton
    self.Status = Status
    self.Source = nil
    self._Token = 0

    --------------------------------------------------------
    -- Button
    --------------------------------------------------------

    if IsButton then

        local function Tint(Brightness)
            TweenService:Create(ImageObject, TweenInfo.new(0.1), {
                ImageColor3 = Color3.fromRGB(Brightness, Brightness, Brightness)
            }):Play()
        end

        ImageObject.MouseEnter:Connect(function() Tint(215) end)
        ImageObject.MouseLeave:Connect(function() Tint(255) end)
        ImageObject.MouseButton1Down:Connect(function() Tint(175) end)
        ImageObject.MouseButton1Up:Connect(function() Tint(215) end)

        local function PlayClick()

            local ClickSound = Settings.ClickSound

            if not ClickSound then
                return
            end

            if type(ClickSound) == "table" and ClickSound.Play then
                ClickSound:Play()
            elseif type(ClickSound) == "string" then
                local Sound = Instance.new("Sound")
                Sound.SoundId = ClickSound
                Sound.Parent = game:GetService("SoundService")
                Sound:Play()
                Sound.Ended:Once(function()
                    Sound:Destroy()
                end)
            end

        end

        ImageObject.MouseButton1Click:Connect(function()
            PlayClick()
            local Handler = Settings.OnClick or Settings.Callback
            if Handler then
                pcall(Handler, self)
            end
        end)

        if Settings.OnRightClick then
            ImageObject.MouseButton2Click:Connect(function()
                pcall(Settings.OnRightClick, self)
            end)
        end

        if Settings.OnHover then
            ImageObject.MouseEnter:Connect(function()
                pcall(Settings.OnHover, self)
            end)
        end

        if Settings.OnLeave then
            ImageObject.MouseLeave:Connect(function()
                pcall(Settings.OnLeave, self)
            end)
        end

    end

    self:SetImage(Settings.Image)

    return self

end

------------------------------------------------------------
-- Image source
------------------------------------------------------------

function Image:SetImage(NewImage)

    self.Source = NewImage

    self._Token = self._Token + 1

    local Token = self._Token

    local Text = tostring(NewImage or "")

    -- готовый ассет ставим сразу, без задержки
    if Text == "" or Text:find("^rbxasset") or Text:find("^rbxthumb") or tonumber(Text) then

        local Final = Text

        if tonumber(Text) then
            Final = "rbxassetid://" .. Text
        end

        self.Instance.Image = Final

        self.Status.Visible = false

        return

    end

    local Loader = _G.Assets

    if not Loader then

        self.Instance.Image = Text

        return

    end

    self.Instance.Image = ""

    self.Status.Text = "Загрузка..."

    self.Status.Visible = true

    Loader:Resolve(Text, "image", function(Ok, Result)

        -- пришёл более новый SetImage или виджет уже удалён
        if Token ~= self._Token or not self.Instance or not self.Instance.Parent then
            return
        end

        if Ok then
            self.Instance.Image = Result
            self.Status.Visible = false
        else
            self.Status.Text = tostring(Result)
            self.Status.Visible = true
        end

    end)

end

function Image:GetImage()

    return self.Instance.Image

end

function Image:GetValue()

    return self.Source

end

------------------------------------------------------------
-- Properties
------------------------------------------------------------

function Image:SetHeight(Height)

    self.Instance.Size = UDim2.new(1,0,0,Height)

end

function Image:SetVisible(State)

    self.Instance.Visible = State

end

function Image:SetScaleType(ScaleType)

    self.Instance.ScaleType = ToScaleType(ScaleType)

end

function Image:SetTransparency(Value)

    self.Instance.ImageTransparency = Value

end

function Image:SetColor(Color)

    self.Instance.ImageColor3 = Color

end

function Image:SetBackgroundTransparency(Value)

    self.Instance.BackgroundTransparency = Value

end

function Image:SetBackgroundColor(Color)

    self.Instance.BackgroundColor3 = Color

end

function Image:SetCornerRadius(Radius)

    local Corner = self.Instance:FindFirstChildOfClass("UICorner")

    if Corner then
        Corner.CornerRadius = Radius
    end

end

function Image:SetBorder(Size, Color)

    self.Instance.BorderSizePixel = Size or 0

    if Color then
        self.Instance.BorderColor3 = Color
    end

end

function Image:SetPadding(Pixels)

    self.Instance.Size = UDim2.new(1, -Pixels, 0, self.Instance.Size.Y.Offset)

end

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

    return self.Button

end

function Image:OnClick(Callback)

    if self.Button then
        return self.Instance.MouseButton1Click:Connect(function()
            Callback(self)
        end)
    end

end

function Image:OnRightClick(Callback)

    if self.Button then
        return self.Instance.MouseButton2Click:Connect(function()
            Callback(self)
        end)
    end

end

function Image:OnHover(Callback)

    if self.Button then
        return self.Instance.MouseEnter:Connect(function()
            Callback(self)
        end)
    end

end

function Image:OnLeave(Callback)

    if self.Button then
        return self.Instance.MouseLeave:Connect(function()
            Callback(self)
        end)
    end

end

------------------------------------------------------------
-- Destroy
------------------------------------------------------------

function Image:Destroy()

    self._Token = self._Token + 1

    if self.Instance then
        self.Instance:Destroy()
        self.Instance = nil
    end

end

------------------------------------------------------------

return Image
