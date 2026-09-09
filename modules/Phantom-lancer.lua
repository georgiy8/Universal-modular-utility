return function(Window)

    local Assets = _G.Assets
    local SoundWidget = _G.SoundWidget

    local Tab = Window:CreateTab({
        Name = "Widget Test",
        Icon = "🧪"
    })

    ------------------------------------------------------------
    -- Labels
    ------------------------------------------------------------

    local Labels = Tab:CreateSection({
        Name = "Labels"
    })

    Labels:AddLabel({
        Text = "Default Label"
    })

    Labels:AddSeparator()

    ------------------------------------------------------------
    -- Buttons
    ------------------------------------------------------------

    local Buttons = Tab:CreateSection({
        Name = "Buttons"
    })

    Buttons:AddButton({
        Text = "Click Me",
        Callback = function()
            print("Button clicked")
        end
    })

    ------------------------------------------------------------
    -- Toggles
    ------------------------------------------------------------

    local Toggles = Tab:CreateSection({
        Name = "Toggles"
    })

    Toggles:AddToggle({
        Text = "Enable Feature",
        Default = false,
        Callback = function(Value)
            print("Toggle:", Value)
        end
    })

    ------------------------------------------------------------
    -- Slider
    ------------------------------------------------------------

    local Sliders = Tab:CreateSection({
        Name = "Sliders"
    })

    Sliders:AddSlider({
        Text = "WalkSpeed",
        Min = 0,
        Max = 100,
        Default = 50,
        Increment = 1,
        Callback = function(Value)
            print("Slider:", Value)
        end
    })

    ------------------------------------------------------------
    -- Dropdown
    ------------------------------------------------------------

    local Dropdowns = Tab:CreateSection({
        Name = "Dropdown"
    })

    Dropdowns:AddDropdown({
        Text = "Choose",
        Options = {
            "Apple",
            "Orange",
            "Banana",
            "Kiwi"
        },
        Callback = function(Value)
            print("Dropdown:", Value)
        end
    })

    ------------------------------------------------------------
    -- Textbox
    ------------------------------------------------------------

    local Textboxes = Tab:CreateSection({
        Name = "Textbox"
    })

    Textboxes:AddTextbox({
        Placeholder = "Type here...",
        Callback = function(Text)
            print("Textbox:", Text)
        end
    })

    ------------------------------------------------------------
    -- Keybind
    ------------------------------------------------------------

    local Keybinds = Tab:CreateSection({
        Name = "Keybind"
    })

    Keybinds:AddKeybind({
        Text = "Open Menu",
        Default = Enum.KeyCode.F,
        Callback = function()
            print("Key pressed")
        end
    })

    ------------------------------------------------------------
    -- Image
    ------------------------------------------------------------

    local Images = Tab:CreateSection({
        Name = "Image"
    })

    Images:AddImage({
        Image = Assets:GetImage("phantom.png"),
        Height = 220,
        AspectRatio = 16/9
    })

    ------------------------------------------------------------
    -- Image Button
    ------------------------------------------------------------

    local ImageButtons = Tab:CreateSection({
        Name = "Image Button"
    })

    ImageButtons:AddImage({
        Image = Assets:GetImage("phantom.png"),
        Height = 220,
        AspectRatio = 16/9,
        Button = true,
        ClickSound = Assets:GetSound("Я_сын_тайской.ogg"),
        OnClick = function()
            print("Image Button Click")
        end
    })

    ------------------------------------------------------------
    -- Sound Widget
    ------------------------------------------------------------

    local Sounds = Tab:CreateSection({
        Name = "Sound"
    })

    Sounds:AddButton({
        Text = "Play Sound",
        Callback = function()

            SoundWidget.Play(
                Assets:GetSound("Plance_lasthit_03_ru.mp3")
            )

        end
    })

end

------------------------------------------------------------
-- Audio
------------------------------------------------------------

local Audio = Tab:CreateSection({
    Name = "Audio"
})

local s = SoundWidget.Create({
    Path = Assets:GetSound("Plance_lasthit_03_ru.mp3")
})

Audio:AddButton({
    Text = "Play",
    Callback = function()
        s:Play()
    end
})

Audio:AddButton({
    Text = "Pause",
    Callback = function()
        s:Pause()
    end
})

Audio:AddButton({
    Text = "Resume",
    Callback = function()
        s:Resume()
    end
})

Audio:AddButton({
    Text = "Stop",
    Callback = function()
        s:Stop()
    end
})

local dragging = false

local SeekSlider = Audio:AddSlider({
    Text = "Seek",
    Min = 0,
    Max = 1,
    Default = 0,
    Increment = 0.05,
    Callback = function(Value)
        dragging = true
        s:SetTimePosition(Value)
        task.defer(function()
            dragging = false
        end)
    end
})

-- длина часто 0 до загрузки
task.spawn(function()
    for _ = 1, 50 do
        local len = s:GetLength()
        if len > 0 then
            if SeekSlider.SetRange then
                SeekSlider:SetRange(0, len)
            elseif SeekSlider.SetMax then
                SeekSlider:SetMax(len)
            end
            break
        end
        task.wait(0.1)
    end
end)

local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
    if dragging then
        return
    end
    if s:IsPlaying() then
        SeekSlider:SetValue(s:GetTimePosition())
    end
end)

end
