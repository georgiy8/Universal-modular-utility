--========================================================--
-- Phantom Lancer Visual Module
--========================================================--

return function(Window)
    local Visual = Window:CreateTab({
        Name = "Phantom Lancer",
        Icon = "⚔️"
    })
    
    local Images = Visual:CreateSection({ Name = "Images" })
    
    local path = "assets/phantom.png"
    
    Images:AddLabel({ Text = "Trying to load: " .. path })
    
    local assetId = nil
    local success, err = pcall(function()
        assetId = getcustomasset(path)
    end)
    
    if success and assetId then
        Images:AddImage({
            Image = assetId,
            Height = 240,
            AspectRatio = 16/9
        })
        Images:AddLabel({ Text = "✅ Loaded!" })
    else
        Images:AddLabel({ Text = "❌ Failed" })
        Images:AddLabel({ Text = "Error: " .. tostring(err) })
        warn("GetCustomAsset Error:", err)
    end
end
