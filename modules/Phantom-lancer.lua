return function(Window, meta)

    local Assets = _G.Assets
    local SoundWidget = _G.SoundWidget

    local Tab = Window:CreateTab({
        Name = "Widget Test",
        Icon = "🧪",
        Order = (meta and meta.Order) or 50,
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
        MultiSelect = true,
        Callback = function(Value)
           print("Dropdown:", table.concat(Value, ", "))
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

    local TestImage = Images:AddImage({
        Image = Assets:GetImage("phantom.png"),
        Height = 220,
        AspectRatio = 16/9
    })

    Images:AddTextbox({
        Text = "Image link / file / id",
        Placeholder = "https://.../image.png",
        NoConfig = true,
        Callback = function(Value)
            TestImage:SetImage(Value)
        end
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

------------------------------------------------------------
-- Audio
------------------------------------------------------------

local Audio = Tab:CreateSection({
    Name = "Audio"
})

local s = SoundWidget.Create({
    Name = "WidgetTestSound",
    Volume = 0.5,
    Tracks = {
        { Name = "Plance lasthit", Path = Assets:GetSound("Plance_lasthit_03_ru.mp3") }
    }
})

local NowPlaying = Audio:AddLabel({
    Text = "Now: " .. tostring(s:GetTrackName())
})

s.OnTrackChanged = function(Name)
    NowPlaying:SetText("Now: " .. tostring(Name))
end

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

Audio:AddButton({
    Text = "Prev track",
    Callback = function()
        s:Previous()
    end
})

Audio:AddButton({
    Text = "Next track",
    Callback = function()
        s:Next()
    end
})

Audio:AddSlider({
    Text = "Volume",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Increment = 0.05,
    NoConfig = true,
    Callback = function(Value)
        s:SetVolume(Value)
    end
})

Audio:AddToggle({
    Text = "Loop",
    Default = false,
    NoConfig = true,
    Callback = function(State)
        s:SetLooped(State)
    end
})

Audio:AddTextbox({
    Text = "Add track (path / rbxassetid)",
    Placeholder = "rbxassetid://...",
    NoConfig = true,
    Callback = function(Value)
        if Value and Value ~= "" then
            s:AddTrack({ Name = Value, Path = Value })
        end
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


------------------------------------------------------------
-- Batch 3 widgets
------------------------------------------------------------

local Batch3 = Tab:CreateSection({
    Name = "Colors / Progress / Range / List"
})

local Bar = Batch3:AddProgressBar({
    Text = "Progress",
    Min = 0,
    Max = 100,
    Value = 25
})

Batch3:AddColorPicker({
    Text = "Accent color",
    Default = Color3.fromRGB(70,160,255),
    Callback = function(Color)
        Bar:SetColor(Color)
    end
})

Batch3:AddRangeSlider({
    Text = "Progress range",
    Min = 0,
    Max = 100,
    Default = { 20, 80 },
    Callback = function(Low, High)
        Bar:SetValue(High)
        Bar:SetValueText(Low .. " - " .. High)
    end
})

Batch3:AddList({
    Text = "Players",
    Columns = { "Name", "Distance" },
    Height = 120,
    Items = { { "Alpha", "12" }, { "Bravo", "48" }, { "Charlie", "95" } },
    Callback = function(Item)
        print("[List] selected:", Item[1])
    end
})


------------------------------------------------------------
-- Batch 4 widgets (media)
------------------------------------------------------------

local Media = Tab:CreateSection({
    Name = "Media"
})

local Viewer = Media:AddViewer3D({
    Text = "Your character",
    Height = 220,
    AutoRotate = true,
    Simple = true
})

local LocalCharacter = game:GetService("Players").LocalPlayer.Character
if LocalCharacter then
    Viewer:SetModel(LocalCharacter, { ImportPlaying = true })
end

Media:AddButton({
    Text = "Reload character in viewer",
    Callback = function()
        local Character = game:GetService("Players").LocalPlayer.Character
        if Character then
            Viewer:ClearAnimations()
            Viewer:SetModel(Character, { ImportPlaying = true })
        end
    end
})

local Video = Media:AddVideoPlayer({
    Text = "Video",
    Height = 160
})

Media:AddTextbox({
    Text = "Video path / asset id",
    Placeholder = "link .mp4/.webm, file or rbxassetid",
    NoConfig = true,
    Callback = function(Value)
        Video:SetVideo(Value, true)
    end
})

end
