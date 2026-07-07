--========================================================--
-- Phantom Lancer Module (Working version)
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
    
    -- Рабочий способ
    local success, imageData = pcall(function()
        return game:HttpGet(ImageUrl)
    end)
    
    if success then
        -- Создаём ImageLabel напрямую
        local ImageLabel = Instance.new("ImageLabel")
        ImageLabel.Size = UDim2.new(1, -20, 0, 320)
        ImageLabel.BackgroundTransparency = 1
        ImageLabel.ScaleType = Enum.ScaleType.Fit
        ImageLabel.Image = ImageUrl  -- или используем data если нужно
        ImageLabel.Parent = Preview.Container or Preview.Instance
        
        Instance.new("UICorner", ImageLabel).CornerRadius = UDim.new(0, 8)
        
        Preview:AddLabel({ Text = "✅ Image loaded via HttpGet" })
    else
        Preview:AddLabel({ Text = "❌ HttpGet failed" })
    end
end
