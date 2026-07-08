--========================================================--
-- MP3 Player Module
--========================================================--

return function(Window)
    local Tab = Window:CreateTab({
        Name = "Sound Test",
        Icon = "🎵"
    })
    
    local Section = Tab:CreateSection({
        Name = "Phantom Lancer Sounds"
    })
    
    local CurrentSound = nil
    
    Section:AddButton({
        Text = "Play Last Hit Sound",
        Callback = function()
            if CurrentSound then
                CurrentSound:Stop()
            end
            
            local path = "assets/Phantom-lancer/Sounds/Plance_lasthit_03_ru.mp3.mpeg"
            
            CurrentSound = Instance.new("Sound")
            CurrentSound.SoundId = getcustomasset(path)
            CurrentSound.Volume = 0.8
            CurrentSound.Parent = game:GetService("SoundService")
            CurrentSound:Play()
            
            print("Playing:", path)
        end
    })
    
    Section:AddButton({
        Text = "Stop",
        Callback = function()
            if CurrentSound then
                CurrentSound:Stop()
            end
        end
    })
    
    Section:AddLabel({
        Text = "Path: assets/Phantom-lancer/Sounds/Plance_lasthit_03_ru.mp3.mpeg"
    })
end
