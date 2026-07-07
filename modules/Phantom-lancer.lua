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
    -- Main Image (PNG)
    --------------------------------------------------------
    local success, err = pcall(function()
        Images:AddImage({
            Image = getcustomasset("assets/phantom.png"),   -- ← PNG версия
            Height = 220,
            AspectRatio = 16/9,
            BackgroundTransparency = 0,
            BackgroundColor = Color3.fromRGB(25, 25, 25)
        })
    end)
    
    if success then
        Images:AddLabel({
            Text = "✅ Phantom Lancer PNG loaded"
        })
    else
        Images:AddLabel({
            Text = "❌ Failed to load PNG"
        })
        Images:AddLabel({
            Text = "Path: assets/phantom.png"
        })
        warn("Image Load Error:", err)
    end
    
    --------------------------------------------------------
    -- Info
    --------------------------------------------------------
    local Info = Visual:CreateSection({
        Name = "Information"
    })
    
    Info:AddLabel({ Text = "Current path: assets/phantom.png" })
    Info:AddLabel({ Text = "Make sure the file is PNG format" })
    
end
