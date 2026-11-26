--========================================================--
-- Universal-modular-utility GUI Library
-- Viewer3D Widget (3D просмотр модели в ViewportFrame)
--
-- Model = Instance (Model/Part/Character) - показывается КОПИЯ, оригинал не трогается
-- Animations = { Idle = "rbxassetid://..", Attack = "rbxassetid://.." }
-- ImportPlaying = true - взять анимации, которые сейчас играют у оригинала
--
-- Управление: тянуть - вращать, колесо / щипок / кнопки +/- - приблизить.
-- Не сохраняется в профили.
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Viewer3D = {}

local function IsPointer(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch
end

function Viewer3D.Create(Parent, Settings)

    Settings = Settings or {}

    local Height = Settings.Height or 220
    local AutoRotate = Settings.AutoRotate == true
    local RotateSpeed = Settings.RotateSpeed or 0.6

    local Object = {}

    local Clone = nil
    local Animator = nil
    local Tracks = {}        -- [name] = AnimationTrack
    local AnimationIds = {}  -- [name] = id
    local AnimationOrder = {}
    local CurrentTrack = nil

    local Center = Vector3.zero
    local Distance = 8
    local MinDistance, MaxDistance = 1, 100
    local Yaw, Pitch = math.rad(25), math.rad(-10)

    --------------------------------------------------------
    -- GUI
    --------------------------------------------------------

    local Frame = Instance.new("Frame")
    Frame.Name = "Viewer3D"
    Frame.Parent = Parent
    Frame.Size = UDim2.new(1,0,0,0)
    Frame.AutomaticSize = Enum.AutomaticSize.Y
    Frame.BackgroundColor3 = C("Row", Color3.fromRGB(45,49,58))
    Frame.BorderSizePixel = 0
    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,6)

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Frame
    Layout.Padding = UDim.new(0,6)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local Pad = Instance.new("UIPadding")
    Pad.Parent = Frame
    Pad.PaddingTop = UDim.new(0,6)
    Pad.PaddingBottom = UDim.new(0,6)
    Pad.PaddingLeft = UDim.new(0,6)
    Pad.PaddingRight = UDim.new(0,6)

    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.LayoutOrder = 1
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1,0,0,18)
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = C("Text", Color3.new(1,1,1))
    Title.Text = Settings.Text or "Model"
    Title.Visible = Settings.Text ~= false

    local Viewport = Instance.new("ViewportFrame")
    Viewport.Parent = Frame
    Viewport.LayoutOrder = 2
    Viewport.Size = UDim2.new(1,0,0,Height)
    Viewport.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))
    Viewport.BorderSizePixel = 0
    Viewport.Ambient = Color3.fromRGB(170,170,170)
    Viewport.LightColor = Color3.fromRGB(255,255,255)
    Instance.new("UICorner",Viewport).CornerRadius = UDim.new(0,5)

    local Camera = Instance.new("Camera")
    Camera.FieldOfView = 50
    Camera.Parent = Viewport
    Viewport.CurrentCamera = Camera

    local World = Instance.new("WorldModel")
    World.Parent = Viewport

    local Empty = Instance.new("TextLabel")
    Empty.Parent = Viewport
    Empty.BackgroundTransparency = 1
    Empty.Size = UDim2.fromScale(1,1)
    Empty.Font = Enum.Font.Gotham
    Empty.TextSize = 13
    Empty.TextColor3 = Color3.fromRGB(150,158,171)
    Empty.Text = "Нет модели"

    -- кнопки зума поверх вьюпорта
    local function ZoomButton(Text, Y)
        local B = Instance.new("TextButton")
        B.Parent = Viewport
        B.AnchorPoint = Vector2.new(1,0)
        B.Position = UDim2.new(1,-6,0,Y)
        B.Size = UDim2.fromOffset(26,26)
        B.BackgroundColor3 = C("Row", Color3.fromRGB(45,49,58))
        B.BackgroundTransparency = 0.2
        B.BorderSizePixel = 0
        B.AutoButtonColor = false
        B.Font = Enum.Font.GothamBold
        B.TextSize = 16
        B.Text = Text
        B.TextColor3 = C("Text", Color3.new(1,1,1))
        B.ZIndex = 5
        Instance.new("UICorner",B).CornerRadius = UDim.new(0,6)
        return B
    end

    local ZoomIn = ZoomButton("+", 6)
    local ZoomOut = ZoomButton("-", 38)

    local Chips = Instance.new("ScrollingFrame")
    Chips.Parent = Frame
    Chips.LayoutOrder = 3
    Chips.Size = UDim2.new(1,0,0,30)
    Chips.BackgroundTransparency = 1
    Chips.BorderSizePixel = 0
    Chips.ScrollBarThickness = 0
    Chips.AutomaticCanvasSize = Enum.AutomaticSize.X
    Chips.CanvasSize = UDim2.new()
    Chips.ScrollingDirection = Enum.ScrollingDirection.X
    Chips.Visible = false

    local ChipLayout = Instance.new("UIListLayout")
    ChipLayout.Parent = Chips
    ChipLayout.FillDirection = Enum.FillDirection.Horizontal
    ChipLayout.Padding = UDim.new(0,6)
    ChipLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    --------------------------------------------------------
    -- Camera
    --------------------------------------------------------

    local function UpdateCamera()

        Camera.CFrame = CFrame.new(Center)
            * CFrame.Angles(0, Yaw, 0)
            * CFrame.Angles(Pitch, 0, 0)
            * CFrame.new(0, 0, Distance)

    end

    local function Zoom(Factor)

        Distance = math.clamp(Distance * Factor, MinDistance, MaxDistance)

        UpdateCamera()

    end

    ZoomIn.MouseButton1Click:Connect(function() Zoom(0.8) end)
    ZoomOut.MouseButton1Click:Connect(function() Zoom(1.25) end)

    UpdateCamera()

    --------------------------------------------------------
    -- Input
    --------------------------------------------------------

    local Dragging = false
    local LastPos = nil
    local Hover = false
    local PinchBase = nil

    Viewport.InputBegan:Connect(function(Input)
        if IsPointer(Input) then
            Dragging = true
            LastPos = Input.Position
        end
    end)

    Viewport.MouseEnter:Connect(function() Hover = true end)
    Viewport.MouseLeave:Connect(function() Hover = false end)

    local Moved = UserInputService.InputChanged:Connect(function(Input)

        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch) then

            local Delta = Input.Position - LastPos
            LastPos = Input.Position

            Yaw = Yaw - Delta.X * 0.01
            Pitch = math.clamp(Pitch - Delta.Y * 0.01, math.rad(-80), math.rad(80))

            UpdateCamera()

        elseif Hover and Input.UserInputType == Enum.UserInputType.MouseWheel then

            Zoom(Input.Position.Z > 0 and 0.9 or 1.1)

        end

    end)

    local Ended = UserInputService.InputEnded:Connect(function(Input)
        if IsPointer(Input) then
            Dragging = false
        end
    end)

    local Pinch = UserInputService.TouchPinch:Connect(function(Positions, Scale, _, State)

        local P = Positions[1]

        if not P then
            return
        end

        local Pos, Size = Viewport.AbsolutePosition, Viewport.AbsoluteSize

        if P.X < Pos.X or P.X > Pos.X + Size.X or P.Y < Pos.Y or P.Y > Pos.Y + Size.Y then
            return
        end

        if State == Enum.UserInputState.Begin or not PinchBase then
            PinchBase = Distance
        end

        Distance = math.clamp(PinchBase / math.max(Scale, 0.05), MinDistance, MaxDistance)

        UpdateCamera()

        if State == Enum.UserInputState.End then
            PinchBase = nil
        end

    end)

    local Step = RunService.RenderStepped:Connect(function(Delta)
        if AutoRotate and not Dragging and Clone and Frame.Visible then
            Yaw = Yaw + Delta * RotateSpeed
            UpdateCamera()
        end
    end)

    --------------------------------------------------------
    -- Animations
    --------------------------------------------------------

    local function RebuildChips()

        for _, Child in ipairs(Chips:GetChildren()) do
            if Child:IsA("TextButton") then
                Child:Destroy()
            end
        end

        Chips.Visible = #AnimationOrder > 0

        local function Chip(Text, Callback)
            local B = Instance.new("TextButton")
            B.Parent = Chips
            B.Size = UDim2.fromOffset(0,24)
            B.AutomaticSize = Enum.AutomaticSize.X
            B.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))
            B.BorderSizePixel = 0
            B.AutoButtonColor = false
            B.Font = Enum.Font.Gotham
            B.TextSize = 13
            B.Text = Text
            B.TextColor3 = C("Text", Color3.new(1,1,1))
            Instance.new("UICorner",B).CornerRadius = UDim.new(0,6)
            local P = Instance.new("UIPadding")
            P.Parent = B
            P.PaddingLeft = UDim.new(0,10)
            P.PaddingRight = UDim.new(0,10)
            B.MouseButton1Click:Connect(Callback)
        end

        for _, Name in ipairs(AnimationOrder) do
            Chip(Name, function() Object:Play(Name) end)
        end

        if #AnimationOrder > 0 then
            Chip("Stop", function() Object:StopAnimation() end)
        end

    end

    local function FindAnimator(Model)

        local Found = Model:FindFirstChildWhichIsA("Animator", true)

        if Found then
            return Found
        end

        local Holder = Model:FindFirstChildWhichIsA("Humanoid", true)
            or Model:FindFirstChildWhichIsA("AnimationController", true)

        if not Holder then
            Holder = Instance.new("AnimationController")
            Holder.Parent = Model
        end

        local New = Instance.new("Animator")
        New.Parent = Holder

        return New

    end

    --------------------------------------------------------
    -- Model
    --------------------------------------------------------

    local function ClearModel()

        if CurrentTrack then
            pcall(function() CurrentTrack:Stop(0) end)
            CurrentTrack = nil
        end

        Tracks = {}
        Animator = nil

        if Clone then
            Clone:Destroy()
            Clone = nil
        end

    end

    function Object:AddAnimation(Name, Id)

        if not AnimationIds[Name] then
            table.insert(AnimationOrder, Name)
        end

        AnimationIds[Name] = Id

        Tracks[Name] = nil

        RebuildChips()

    end

    function Object:ClearAnimations()

        self:StopAnimation()

        Tracks = {}
        AnimationIds = {}
        AnimationOrder = {}

        RebuildChips()

    end

    -- забирает анимации, которые сейчас играют у оригинала (враг, персонаж)
    function Object:ImportPlaying(Source)

        local Found = Source and Source:FindFirstChildWhichIsA("Animator", true)

        if not Found then
            return 0
        end

        local Count = 0

        for _, Track in ipairs(Found:GetPlayingAnimationTracks()) do
            local Anim = Track.Animation
            if Anim and Anim.AnimationId ~= "" then
                local Name = (Track.Name ~= "" and Track.Name) or Anim.Name
                self:AddAnimation(Name, Anim.AnimationId)
                Count = Count + 1
            end
        end

        return Count

    end

    function Object:SetModel(Source, Options)

        Options = Options or {}

        ClearModel()

        if typeof(Source) ~= "Instance" then
            Empty.Visible = true
            return false
        end

        local WasArchivable = Source.Archivable
        Source.Archivable = true
        local Ok, Copy = pcall(function() return Source:Clone() end)
        Source.Archivable = WasArchivable

        if not Ok or not Copy then
            Empty.Visible = true
            return false
        end

        -- скрипты, звуки и интерфейс из копии убираем, нужна только картинка
        for _, Item in ipairs(Copy:GetDescendants()) do
            if Item:IsA("BaseScript") or Item:IsA("Sound") or Item:IsA("ForceField")
                or Item:IsA("BillboardGui") or Item:IsA("SurfaceGui") then
                Item:Destroy()
            elseif Item:IsA("BasePart") then
                Item.Anchored = true
            end
        end

        if Copy:IsA("BasePart") then
            Copy.Anchored = true
        end

        if Options.ImportPlaying or Settings.ImportPlaying then
            self:ImportPlaying(Source)
        end

        Copy.Parent = World

        Clone = Copy

        local Cf, Size
        if Copy:IsA("Model") then
            Cf, Size = Copy:GetBoundingBox()
        else
            Cf, Size = Copy.CFrame, Copy.Size
        end

        -- модель стоит в начале координат, взгляд в центр
        if Copy:IsA("Model") then
            Copy:PivotTo(Copy:GetPivot() - Cf.Position)
            Cf, Size = Copy:GetBoundingBox()
        end

        Center = Cf.Position

        local Radius = math.max(Size.Magnitude / 2, 0.5)

        Distance = Radius / math.tan(math.rad(Camera.FieldOfView / 2)) * 1.15
        MinDistance = Radius * 0.4
        MaxDistance = Distance * 6

        UpdateCamera()

        Empty.Visible = false

        Animator = FindAnimator(Copy)

        if #AnimationOrder > 0 then
            RebuildChips()
            if Options.AutoPlay ~= false and Settings.AutoPlay ~= false then
                Object:Play(AnimationOrder[1])
            end
        end

        return true

    end

    function Object:Play(Name, Looped)

        if not Animator then
            return false
        end

        local Track = Tracks[Name]

        if not Track then

            local Id = AnimationIds[Name]

            if not Id then
                return false
            end

            local Anim = Instance.new("Animation")
            Anim.AnimationId = Id

            local Ok, Loaded = pcall(function()
                return Animator:LoadAnimation(Anim)
            end)

            if not Ok or not Loaded then
                return false
            end

            Track = Loaded
            Tracks[Name] = Track

        end

        if CurrentTrack and CurrentTrack ~= Track then
            pcall(function() CurrentTrack:Stop(0.15) end)
        end

        Track.Looped = Looped ~= false

        Track:Play(0.15)

        CurrentTrack = Track

        return true

    end

    function Object:StopAnimation()

        if CurrentTrack then
            pcall(function() CurrentTrack:Stop(0.15) end)
            CurrentTrack = nil
        end

    end

    --------------------------------------------------------
    -- API
    --------------------------------------------------------

    Object.Instance = Frame
    Object.Viewport = Viewport

    function Object:GetModel()
        return Clone
    end

    function Object:GetValue()
        return Clone
    end

    function Object:SetAutoRotate(State)
        AutoRotate = State == true
    end

    function Object:SetRotateSpeed(Value)
        RotateSpeed = tonumber(Value) or RotateSpeed
    end

    function Object:SetView(NewYaw, NewPitch)
        Yaw = math.rad(NewYaw or 0)
        Pitch = math.rad(NewPitch or 0)
        UpdateCamera()
    end

    function Object:SetText(NewText)
        Title.Text = tostring(NewText)
    end

    function Object:SetVisible(State)
        Frame.Visible = State
    end

    function Object:Destroy()
        Moved:Disconnect()
        Ended:Disconnect()
        Pinch:Disconnect()
        Step:Disconnect()
        ClearModel()
        Frame:Destroy()
    end

    --------------------------------------------------------
    -- Init
    --------------------------------------------------------

    local Names = {}
    for Name in pairs(Settings.Animations or {}) do
        table.insert(Names, Name)
    end
    table.sort(Names)
    for _, Name in ipairs(Names) do
        Object:AddAnimation(Name, Settings.Animations[Name])
    end

    if Settings.Model then
        Object:SetModel(Settings.Model)
    end

    return Object

end

return Viewer3D
