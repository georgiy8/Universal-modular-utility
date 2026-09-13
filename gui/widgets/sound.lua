--========================================================--
-- Universal-modular-utility GUI Library
-- Sound Widget
--========================================================--

local SoundWidget = {}
SoundWidget.__index = SoundWidget

------------------------------------------------------------
-- Create
------------------------------------------------------------

function SoundWidget.Create(Settings)

    Settings = Settings or {}

    local self = setmetatable({}, SoundWidget)

    self.Path = Settings.Path
        or Settings.Sound
        or Settings.Asset

    self.Volume = Settings.Volume or 1
    self.Speed = Settings.Speed or 1
    self.Looped = Settings.Looped or false

    self.Enabled = true

    self.Instance = Instance.new("Sound")

    self.Instance.Name = Settings.Name or "WidgetSound"

    self.Instance.Volume = self.Volume
    self.Instance.PlaybackSpeed = self.Speed
    self.Instance.Looped = self.Looped

    if typeof(self.Path) == "string" then

        self.Instance.SoundId = self.Path

    end

    if Settings.Parent then

        self.Instance.Parent = Settings.Parent

    else

        self.Instance.Parent = game:GetService("SoundService")

    end

    return self

end

------------------------------------------------------------
-- Playback
------------------------------------------------------------

function SoundWidget.Play(selfOrPath, Parent)

    if type(selfOrPath) == "table"
        and selfOrPath.Instance then

        if not selfOrPath.Enabled then
            return
        end

        selfOrPath.Instance:Play()

        return selfOrPath

    end

    local Sound = SoundWidget.Create({

        Path = selfOrPath,

        Parent = Parent

    })

    Sound.Instance:Play()

    Sound.Instance.Ended:Once(function()

        Sound:Destroy()

    end)

    return Sound

end

function SoundWidget:Stop()

    self.Instance:Stop()

end

function SoundWidget:Pause()

    self.Instance:Pause()

end

function SoundWidget:Resume()

    self.Instance:Resume()

end

function SoundWidget:IsPlaying()

    return self.Instance.IsPlaying

end

function SoundWidget:GetTimePosition()

    return self.Instance.TimePosition

end

function SoundWidget:SetTimePosition(Time)

    self.Instance.TimePosition = Time

end

function SoundWidget:GetLength()

    return self.Instance.TimeLength

end

------------------------------------------------------------
-- Properties
------------------------------------------------------------

function SoundWidget:SetVolume(Volume)

    self.Volume = Volume

    self.Instance.Volume = Volume

end

function SoundWidget:SetSpeed(Speed)

    self.Speed = Speed

    self.Instance.PlaybackSpeed = Speed

end

function SoundWidget:SetLooped(Looped)

    self.Looped = Looped

    self.Instance.Looped = Looped

end

function SoundWidget:SetEnabled(Enabled)

    self.Enabled = Enabled

end

------------------------------------------------------------
-- Fade
------------------------------------------------------------

function SoundWidget:FadeIn(Duration, TargetVolume)

    Duration = Duration or 0.5
    TargetVolume = TargetVolume or self.Volume

    self.Instance.Volume = 0

    self.Instance:Play()

    local Start = tick()

    while tick() - Start < Duration do

        local Alpha = (tick() - Start) / Duration

        self.Instance.Volume =
            TargetVolume * math.clamp(Alpha, 0, 1)

        task.wait()

    end

    self.Instance.Volume = TargetVolume

end

function SoundWidget:FadeOut(Duration)

    Duration = Duration or 0.5

    local StartVolume = self.Instance.Volume
    local Start = tick()

    while tick() - Start < Duration do

        local Alpha = (tick() - Start) / Duration

        self.Instance.Volume =
            StartVolume * (1 - math.clamp(Alpha, 0, 1))

        task.wait()

    end

    self.Instance.Volume = 0

    self.Instance:Stop()

end

------------------------------------------------------------
-- Events
------------------------------------------------------------

function SoundWidget:OnEnded(Callback)

    return self.Instance.Ended:Connect(Callback)

end

function SoundWidget:OnPlayed(Callback)

    return self.Instance.Played:Connect(Callback)

end

function SoundWidget:OnStopped(Callback)

    return self.Instance.Stopped:Connect(Callback)

end

------------------------------------------------------------
-- Destroy
------------------------------------------------------------

function SoundWidget:Destroy()

    if self.Instance then

        self.Instance:Destroy()

        self.Instance = nil

    end

end

------------------------------------------------------------
-- From Asset
------------------------------------------------------------

function SoundWidget.FromAsset(AssetManager, Name, Parent)

    local Asset = AssetManager:Get(Name)

    if not Asset then

        warn("[SoundWidget] Asset not found:", Name)

        return nil

    end

    return SoundWidget.Create({

        Path = Asset,

        Parent = Parent

    })

end

------------------------------------------------------------
-- GUI Binding
------------------------------------------------------------

function SoundWidget.Bind(Object, Sounds)

    if not Object or not Sounds then
        return
    end

    if Object.Instance then
        Object = Object.Instance
    end

    local function PlaySound(Path)

        if not Path then
            return
        end

        SoundWidget.Play(Path)

    end

    if Sounds.Click and Object:IsA("GuiButton") then

        Object.MouseButton1Click:Connect(function()

            PlaySound(Sounds.Click)

        end)

    end

    if Sounds.RightClick then

        Object.InputBegan:Connect(function(Input)

            if Input.UserInputType == Enum.UserInputType.MouseButton2 then

                PlaySound(Sounds.RightClick)

            end

        end)

    end

    if Sounds.Hover then

        Object.MouseEnter:Connect(function()

            PlaySound(Sounds.Hover)

        end)

    end

    if Sounds.Leave then

        Object.MouseLeave:Connect(function()

            PlaySound(Sounds.Leave)

        end)

    end

    if Sounds.Press then

        Object.InputBegan:Connect(function(Input)

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then

                PlaySound(Sounds.Press)

            end

        end)

    end

    if Sounds.Release then

        Object.InputEnded:Connect(function(Input)

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then

                PlaySound(Sounds.Release)

            end

        end)

    end

end

------------------------------------------------------------

return SoundWidget
