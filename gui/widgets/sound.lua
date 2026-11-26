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

    -- плейлист (необязательно): Tracks = { "путь", { Name = "Имя", Path = "путь" } }
    self.Tracks = {}
    self.Index = 1
    self.AutoNext = Settings.AutoNext ~= false

    self._Ended = self.Instance.Ended:Connect(function()

        if self.Instance and self.AutoNext and #self.Tracks > 1 and not self.Instance.Looped then

            self:Next(true)

        end

    end)

    if Settings.Tracks then

        self:SetTracks(Settings.Tracks)

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
-- Playlist
------------------------------------------------------------

local function ResolveTrack(Item)

    if type(Item) == "table" then

        return Item.Name or Item.Text or "Track", Item.Path or Item.Sound or Item.Asset

    end

    return tostring(Item):match("([^/\\]+)$") or "Track", Item

end

function SoundWidget:SetTrack(NewIndex, AutoPlay)

    if #self.Tracks == 0 or not self.Instance then
        return
    end

    self.Index = ((NewIndex - 1) % #self.Tracks) + 1

    local _, Path = ResolveTrack(self.Tracks[self.Index])

    self.Instance:Stop()

    self.Instance.SoundId = tostring(Path or "")

    self.Instance.TimePosition = 0

    if AutoPlay then

        self.Instance:Play()

    end

    if self.OnTrackChanged then

        pcall(self.OnTrackChanged, self:GetTrackName(), self.Index)

    end

end

function SoundWidget:SetTracks(Tracks, AutoPlay)

    self.Tracks = Tracks or {}

    self.Index = 1

    if #self.Tracks > 0 then

        self:SetTrack(1, AutoPlay == true)

    end

end

function SoundWidget:AddTrack(Track)

    table.insert(self.Tracks, Track)

    if #self.Tracks == 1 then

        self:SetTrack(1, false)

    end

end

function SoundWidget:Next(AutoPlay)

    self:SetTrack(self.Index + 1, AutoPlay == true or self.Instance.IsPlaying)

end

function SoundWidget:Previous(AutoPlay)

    self:SetTrack(self.Index - 1, AutoPlay == true or self.Instance.IsPlaying)

end

function SoundWidget:GetTrackName()

    if #self.Tracks == 0 then
        return nil
    end

    return (ResolveTrack(self.Tracks[self.Index]))

end

function SoundWidget:GetVolume()

    return self.Volume

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

    if self._Ended then

        self._Ended:Disconnect()

        self._Ended = nil

    end

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
