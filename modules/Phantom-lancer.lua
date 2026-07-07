--========================================================--
-- Phantom Lancer Module
--========================================================--

return function(Window)

    --------------------------------------------------------
    -- Tab
    --------------------------------------------------------

    local Phantom = Window:CreateTab({

        Name = "Phantom Lancer"

    })

    --------------------------------------------------------
    -- Image
    --------------------------------------------------------

    local Preview = Phantom:CreateSection({

        Name = "Preview"

    })

    local PhantomImage = Preview:AddImage({

        Image = getcustomasset("assets/phantom.png"),

        Height = 300,

        Transparency = 0,

        BackgroundTransparency = 1,

        ScaleType = Enum.ScaleType.Fit

    })


    PhantomImage:SetAspectRatio(1, 1)

end
