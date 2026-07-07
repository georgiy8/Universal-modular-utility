--========================================================--
-- Phantom Lancer Module
--========================================================--

return function(Window)
    local Visual = Window:CreateTab({
        Name = "Phantom Lancer",
        Icon = "⚔️"
    })
    
    local Preview = Visual:CreateSection({
        Name = "Preview"
    })
    
    local ImageUrl = "https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/assets/phantom.png"
    
    -- Прямая загрузка
    Preview:AddImage({
        Image = ImageUrl,
        Height = 320,
        AspectRatio = 16/9
    })
    
    Preview:AddLabel({ Text = "Image URL: " .. ImageUrl })
end
