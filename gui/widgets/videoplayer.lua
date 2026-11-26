--========================================================--
-- Universal-modular-utility GUI Library
-- VideoPlayer Widget (VideoFrame: пауза, перемотка, громкость)
-- Path = "rbxassetid://..." или путь к локальному файлу (.webm/.mp4) в папке executor
-- Не сохраняется в профили.
--========================================================--

local function C(Name, Fallback)
    local T = _G.UMUTheme
    return (T and T.Colors[Name]) or Fallback
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local VideoPlayer = {}

local function IsPointer(Input)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch
end

local function FormatTime(Seconds)
    Seconds = math.max(0, math.floor(Seconds or 0))
    return string.format("%d:%02d", Seconds // 60, Seconds % 60)
end

-- локальный файл превращаем в asset через getcustomasset, остальное отдаём как есть
local function ResolveVideo(Path)

    Path = tostring(Path or "")

    if Path == "" then
        return ""
    end

    if Path:find("^rbxasset") or Path:find("^http") then
        return Path
    end

    if tonumber(Path) then
        return "rbxassetid://" .. Path
    end

    if getcustomasset and isfile and isfile(Path) then
        local Ok, Result = pcall(getcustomasset, Path)
        if Ok then
            return Result
        end
    end

    return Path

end

function VideoPlayer.Create(Parent, Settings)

    Settings = Settings or {}

    local Height = Settings.Height or 180
    local Volume = Settings.Volume or 0.5
    local Object = {}

    local Frame = Instance.new("Frame")
    Frame.Name = "VideoPlayer"
    Frame.Parent = Parent
    Frame.Size = UDim2.new(1,0,0,Height + 66)
    Frame.BackgroundColor3 = C("Row", Color3.fromRGB(45,49,58))
    Frame.BorderSizePixel = 0
    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,6)

    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(10,4)
    Title.Size = UDim2.new(1,-20,0,18)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextColor3 = C("Text", Color3.new(1,1,1))
    Title.Text = Settings.Text or "Video"

    local Video = Instance.new("VideoFrame")
    Video.Parent = Frame
    Video.Position = UDim2.fromOffset(8,26)
    Video.Size = UDim2.new(1,-16,0,Height)
    Video.BackgroundColor3 = Color3.new(0,0,0)
    Video.BorderSizePixel = 0
    Video.Looped = Settings.Looped == true
    Video.Volume = Volume
    Instance.new("UICorner",Video).CornerRadius = UDim.new(0,5)

    local Placeholder = Instance.new("TextLabel")
    Placeholder.Parent = Video
    Placeholder.BackgroundTransparency = 1
    Placeholder.Size = UDim2.fromScale(1,1)
    Placeholder.Font = Enum.Font.Gotham
    Placeholder.TextSize = 13
    Placeholder.TextColor3 = Color3.fromRGB(150,158,171)
    Placeholder.Text = "Нет видео"
    Placeholder.ZIndex = 0

    local Y = Height + 38

    local SeekBar = Instance.new("Frame")
    SeekBar.Parent = Frame
    SeekBar.Position = UDim2.new(0,10,0,Y + 4)
    SeekBar.Size = UDim2.new(1,-100,0,6)
    SeekBar.BorderSizePixel = 0
    SeekBar.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))
    Instance.new("UICorner",SeekBar).CornerRadius = UDim.new(1,0)

    local SeekFill = Instance.new("Frame")
    SeekFill.Parent = SeekBar
    SeekFill.Size = UDim2.new(0,0,1,0)
    SeekFill.BorderSizePixel = 0
    SeekFill.BackgroundColor3 = C("Accent", Color3.fromRGB(70,160,255))
    Instance.new("UICorner",SeekFill).CornerRadius = UDim.new(1,0)

    local SeekHit = Instance.new("TextButton")
    SeekHit.Parent = Frame
    SeekHit.BackgroundTransparency = 1
    SeekHit.Text = ""
    SeekHit.AutoButtonColor = false
    SeekHit.Position = UDim2.new(0,10,0,Y - 4)
    SeekHit.Size = UDim2.new(1,-100,0,22)

    local TimeLabel = Instance.new("TextLabel")
    TimeLabel.Parent = Frame
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.AnchorPoint = Vector2.new(1,0)
    TimeLabel.Position = UDim2.new(1,-10,0,Y - 4)
    TimeLabel.Size = UDim2.fromOffset(80,18)
    TimeLabel.Font = Enum.Font.Gotham
    TimeLabel.TextSize = 12
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
    TimeLabel.TextColor3 = C("TextMuted", Color3.fromRGB(184,190,201))
    TimeLabel.Text = "0:00 / 0:00"

    local Play = Instance.new("TextButton")
    Play.Parent = Frame
    Play.Position = UDim2.new(0,10,0,Y + 16)
    Play.Size = UDim2.fromOffset(44,26)
    Play.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))
    Play.BorderSizePixel = 0
    Play.AutoButtonColor = false
    Play.Font = Enum.Font.GothamBold
    Play.TextSize = 13
    Play.Text = "▶"
    Play.TextColor3 = C("Text", Color3.new(1,1,1))
    Instance.new("UICorner",Play).CornerRadius = UDim.new(0,6)

    local VolBar = Instance.new("Frame")
    VolBar.Parent = Frame
    VolBar.Position = UDim2.new(0,100,0,Y + 26)
    VolBar.Size = UDim2.new(1,-116,0,6)
    VolBar.BorderSizePixel = 0
    VolBar.BackgroundColor3 = C("Field", Color3.fromRGB(23,25,30))
    Instance.new("UICorner",VolBar).CornerRadius = UDim.new(1,0)

    local VolFill = Instance.new("Frame")
    VolFill.Parent = VolBar
    VolFill.Size = UDim2.new(Volume,0,1,0)
    VolFill.BorderSizePixel = 0
    VolFill.BackgroundColor3 = C("Accent", Color3.fromRGB(70,160,255))
    Instance.new("UICorner",VolFill).CornerRadius = UDim.new(1,0)

    local VolHit = Instance.new("TextButton")
    VolHit.Parent = Frame
    VolHit.BackgroundTransparency = 1
    VolHit.Text = ""
    VolHit.AutoButtonColor = false
    VolHit.Position = UDim2.new(0,100,0,Y + 18)
    VolHit.Size = UDim2.new(1,-116,0,22)

    local VolText = Instance.new("TextLabel")
    VolText.Parent = Frame
    VolText.BackgroundTransparency = 1
    VolText.Position = UDim2.new(0,60,0,Y + 16)
    VolText.Size = UDim2.fromOffset(36,26)
    VolText.Font = Enum.Font.Gotham
    VolText.TextSize = 12
    VolText.Text = "Vol"
    VolText.TextColor3 = C("TextMuted", Color3.fromRGB(184,190,201))

    local function Refresh()

        local Length = Video.TimeLength

        SeekFill.Size = UDim2.new(Length > 0 and math.clamp(Video.TimePosition / Length,0,1) or 0, 0, 1, 0)

        TimeLabel.Text = FormatTime(Video.TimePosition) .. " / " .. FormatTime(Length)

        Play.Text = Video.Playing and "II" or "▶"

        VolFill.Size = UDim2.new(math.clamp(Volume,0,1), 0, 1, 0)

    end

    Play.MouseButton1Click:Connect(function()

        if Video.Video == "" then
            return
        end

        if Video.Playing then
            Video:Pause()
        else
            Video:Play()
        end

        Refresh()

    end)

    local Dragging = nil

    local function Apply(Input)

        if Dragging == "seek" then

            local A = math.clamp((Input.Position.X - SeekBar.AbsolutePosition.X) / math.max(SeekBar.AbsoluteSize.X,1), 0, 1)

            if Video.TimeLength > 0 then
                Video.TimePosition = A * Video.TimeLength
            end

        elseif Dragging == "vol" then

            Volume = math.clamp((Input.Position.X - VolBar.AbsolutePosition.X) / math.max(VolBar.AbsoluteSize.X,1), 0, 1)

            Video.Volume = Volume

        end

        Refresh()

    end

    SeekHit.InputBegan:Connect(function(Input)
        if IsPointer(Input) then
            Dragging = "seek"
            Apply(Input)
        end
    end)

    VolHit.InputBegan:Connect(function(Input)
        if IsPointer(Input) then
            Dragging = "vol"
            Apply(Input)
        end
    end)

    local Moved = UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch) then
            Apply(Input)
        end
    end)

    local Ended = UserInputService.InputEnded:Connect(function(Input)
        if IsPointer(Input) then
            Dragging = nil
        end
    end)

    local Step = RunService.Heartbeat:Connect(function()
        if Frame.Parent and Frame.Visible and Dragging ~= "seek" then
            Refresh()
        end
    end)

    --------------------------------------------------------
    -- API
    --------------------------------------------------------

    Object.Instance = Frame
    Object.Video = Video

    function Object:SetVideo(Path, AutoPlay)

        Video:Pause()

        Video.Video = ResolveVideo(Path)

        Placeholder.Visible = (Video.Video == "")

        Video.TimePosition = 0

        if AutoPlay and Video.Video ~= "" then
            Video:Play()
        end

        Refresh()

    end

    function Object:Play()
        if Video.Video ~= "" then
            Video:Play()
            Refresh()
        end
    end

    function Object:Pause()
        Video:Pause()
        Refresh()
    end

    function Object:SetVolume(Value)
        Volume = math.clamp(Value, 0, 1)
        Video.Volume = Volume
        Refresh()
    end

    function Object:SetLooped(State)
        Video.Looped = State == true
    end

    function Object:IsPlaying()
        return Video.Playing
    end

    function Object:GetValue()
        return Video.Video
    end

    function Object:SetText(NewText)
        Title.Text = tostring(NewText)
    end

    function Object:SetVisible(State)
        Frame.Visible = State
        if not State then
            Video:Pause()
        end
    end

    function Object:Destroy()
        Moved:Disconnect()
        Ended:Disconnect()
        Step:Disconnect()
        Video:Pause()
        Frame:Destroy()
    end

    Object:SetVideo(Settings.Path or Settings.Video, Settings.AutoPlay == true)

    return Object

end

return VideoPlayer
