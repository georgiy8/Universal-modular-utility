--========================================================--
-- Pilgrammed GUI Library
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

    -- Instance call:
    -- Sound:Play()
    if type(selfOrPath) == "table"
        and getmetatable(selfOrPath) == SoundWidget then

        local self = selfOrPath

        if not self.Enabled then
            return
        end

        self.Instance:Play()

        return self
    end

    -- Static call:
    -- SoundWidget.Play(Path, Parent)
    local Path = selfOrPath

    local Sound = SoundWidget.Create({

        Path = Path,

        Parent = Parent

    })

    Sound:Play()

    Sound.Instance.Ended:Once(function()

        Sound:Destroy()

    end)

    return Sound

end

function SoundWidget:Stop()

    self.Instance:Stop()

end

------------------------------------------------------------
-- Setters
------------------------------------------------------------

function SoundWidget:SetSound(Path)

    self.Path = Path

    self.Instance.SoundId = Path

end

function SoundWidget:SetVolume(Value)

    self.Volume = Value

    self.Instance.Volume = Value

end

function SoundWidget:SetSpeed(Value)

    self.Speed = Value

    self.Instance.PlaybackSpeed = Value

end

function SoundWidget:SetLooped(State)

    self.Looped = State

    self.Instance.Looped = State

end

function SoundWidget:SetEnabled(State)

    self.Enabled = State

end

function SoundWidget:SetParent(Parent)

    self.Instance.Parent = Parent

end

------------------------------------------------------------
-- Fade
------------------------------------------------------------

function SoundWidget:FadeIn(Time)

    Time = Time or 0.25

    local Target = self.Volume

    self.Instance.Volume = 0

    self:Play()

    task.spawn(function()

        local Start = tick()

        while tick() - Start < Time do

            local Alpha = (tick() - Start) / Time

            self.Instance.Volume = Target * Alpha

            task.wait()

        end

        self.Instance.Volume = Target

    end)

end

function SoundWidget:FadeOut(Time)

    Time = Time or 0.25

    local StartVolume = self.Instance.Volume

    task.spawn(function()

        local Start = tick()

        while tick() - Start < Time do

            local Alpha = (tick() - Start) / Time

            self.Instance.Volume = StartVolume * (1 - Alpha)

            task.wait()

        end

        self.Instance.Volume = StartVolume

        self:Stop()

    end)

end

------------------------------------------------------------
-- Events
------------------------------------------------------------

function SoundWidget:IsPlaying()

    return self.Instance.IsPlaying

end

function SoundWidget:GetTimePosition()

    return self.Instance.TimePosition

end

function SoundWidget:SetTimePosition(Value)

    self.Instance.TimePosition = Value

end

function SoundWidget:GetLength()

    return self.Instance.TimeLength

end

function SoundWidget:Ended(Callback)

    return self.Instance.Ended:Connect(Callback)

end

function SoundWidget:Loaded(Callback)

    return self.Instance.Loaded:Connect(Callback)

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
-- Static Helpers
------------------------------------------------------------

function SoundWidget.Play(Path, Parent)

    local Sound = SoundWidget.Create({

        Path = Path,

        Parent = Parent

    })

    Sound:Play()

    Sound.Instance.Ended:Once(function()

        Sound:Destroy()

    end)

    return Sound

end

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
