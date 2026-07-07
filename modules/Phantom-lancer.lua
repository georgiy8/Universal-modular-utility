--========================================================--
-- Phantom Lancer Visual Module
--========================================================--

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

return function(Window)
    --------------------------------------------------------
    -- Tab
    --------------------------------------------------------
    local Visual = Window:CreateTab({
        Name = "Phantom Lancer",
        Icon = "⚔️"
    })
    
    --------------------------------------------------------
    -- Images Section
    --------------------------------------------------------
    local Images = Visual:CreateSection({
        Name = "Images"
    })
    
    --------------------------------------------------------
    -- Main Image with error handling
    --------------------------------------------------------
    local success, err = pcall(function()
        Images:AddImage({
            Image = getcustomasset("assets/Phantom-lancer/Images/phantom_lancer_pl.jpg"),
            Height = 220,
            AspectRatio = 16/9,
            BackgroundTransparency = 0,
            BackgroundColor = Color3.fromRGB(30, 30, 30)
        })
    end)
    
    if not success then
        Images:AddLabel({
            Text = "❌ Failed to load image"
        })
        Images:AddLabel({
            Text = "Path: assets/Phantom-lancer/Images/phantom_lancer_pl.jpg"
        })
        warn("Image load error:", err)
    else
        Images:AddLabel({
            Text = "✅ Phantom Lancer image loaded"
        })
    end
    
end
