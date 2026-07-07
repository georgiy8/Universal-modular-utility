--========================================================--
-- Phantom Lancer Module
--========================================================--

return function(Window)

    local Tab = Window:CreateTab({
        Name = "Phantom Lancer",
        Icon = "⚔️"
    })

    local Preview = Tab:CreateSection({
        Name = "Preview"
    })

    Preview:AddImage({

        Image = "https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/assets/phantom.png",

        Height = 320,

        ScaleType = Enum.ScaleType.Fit

    })

    Preview:AddSeparator()

    Preview:AddLabel({

        Text = "Testing image from GitHub..."

    })

end
