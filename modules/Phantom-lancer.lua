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
        ClickSound = Assets:GetSound("Plance_lasthit_03_ru.mp3"),
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
