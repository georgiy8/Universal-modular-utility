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
    -- Main Image
    --------------------------------------------------------
    Images:AddImage({
        Image = getcustomasset("assets/Phantom-lancer/Images/phantom_lancer_pl.jpg"),
        Height = 220,
        AspectRatio = 16/9
    })
    
    --------------------------------------------------------
    -- Info
    --------------------------------------------------------
    local Info = Visual:CreateSection({
        Name = "Information"
    })
    
    Info:AddLabel({
        Text = "Phantom Lancer Skin Preview"
    })
    
    Info:AddLabel({
        Text = "✅ Loaded successfully"
    })
end
