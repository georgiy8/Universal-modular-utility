--========================================================--
-- Sound Widget Test Module
--========================================================--

return function(Window)
    local Tab = Window:CreateTab({
        Name = "Sound Test",
        Icon = "🔊"
    })
    
    local Section = Tab:CreateSection({
        Name = "Sound Controls"
    })
    
    -- Создаём Sound Widget
    local Music = Section:AddSound({
        SoundId = getcustomasset("assets/sounds/music.mp3"), -- замени на свой файл
        ShowProgress = true,
        Volume = 0.7
    })
    
    Section:AddButton({
        Text = "▶ Play",
        Callback = function()
            Music:Play()
        end
    })
    
    Section:AddButton({
        Text = "⏸ Pause",
        Callback = function()
            Music:Pause()
        end
    })
    
    Section:AddButton({
        Text = "⏹ Stop",
        Callback = function()
            Music:Stop()
        end
    })
    
    Section:AddSlider({
        Text = "Volume",
        Min = 0,
        Max = 1,
        Default = 0.7,
        Increment = 0.05,
        Callback = function(Value)
            Music:SetVolume(Value)
        end
    })
    
    Section:AddSlider({
        Text = "Speed",
        Min = 0.5,
        Max = 2,
        Default = 1,
        Increment = 0.1,
        Callback = function(Value)
            Music:SetPlaybackSpeed(Value)
        end
    })
    
    Section:AddToggle({
        Text = "Loop",
        Default = false,
        Callback = function(State)
            Music:SetLooped(State)
        end
    })
end
