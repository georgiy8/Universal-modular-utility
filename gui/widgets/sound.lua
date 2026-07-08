--========================================================--
-- Pilgrammed GUI Library
-- Advanced Sound Widget
--========================================================--

local SoundWidget = {}
SoundWidget.__index = SoundWidget

function SoundWidget.Create(Parent, Settings)
    Settings = Settings or {}
    local self = setmetatable({}, SoundWidget)
    
    self.Sound = Instance.new("Sound")
    self.Sound.SoundId = Settings.SoundId or ""
    self.Sound.Volume = Settings.Volume or 0.5
    self.Sound.PlaybackSpeed = Settings.Speed or 1
    self.Sound.Looped = Settings.Looped or false
    self.Sound.Parent = game:GetService("SoundService")
    
    self.IsPlaying = false
    self.CurrentProgress = 0
    
    -- Slider for progress
    if Settings.ShowProgress then
        self.ProgressSlider = Parent:AddSlider({
            Text = "Progress",
            Min = 0,
            Max = 100,
            Default = 0,
            Callback = function(Value)
                if self.Sound then
                    self.Sound.TimePosition = (Value / 100) * self.Sound.TimeLength
                end
            end
        })
    end
    
    -- Auto update progress
    self.UpdateConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if self.IsPlaying and self.Sound.TimeLength > 0 then
            local Progress = (self.Sound.TimePosition / self.Sound.TimeLength) * 100
            if self.ProgressSlider then
                self.ProgressSlider:SetValue(Progress)
            end
        end
    end)
    
    return self
end

function SoundWidget:Play()
    if self.Sound then
        self.Sound:Play()
        self.IsPlaying = true
    end
end

function SoundWidget:Pause()
    if self.Sound then
        self.Sound:Pause()
        self.IsPlaying = false
    end
end

function SoundWidget:Stop()
    if self.Sound then
        self.Sound:Stop()
        self.IsPlaying = false
    end
end

function SoundWidget:SetVolume(Volume)
    if self.Sound then
        self.Sound.Volume = Volume
    end
end

function SoundWidget:SetPlaybackSpeed(Speed)
    if self.Sound then
        self.Sound.PlaybackSpeed = Speed
    end
end

function SoundWidget:SetLooped(Looped)
    if self.Sound then
        self.Sound.Looped = Looped
    end
end

function SoundWidget:SetSoundId(SoundId)
    if self.Sound then
        self.Sound.SoundId = SoundId
    end
end

function SoundWidget:Destroy()
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
    end
    if self.Sound then
        self.Sound:Destroy()
    end
end

return SoundWidget
