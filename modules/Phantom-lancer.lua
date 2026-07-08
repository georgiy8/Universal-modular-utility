return function(Window)

    local Tab = Window:CreateTab({
        Name = "Asset Test",
        Icon = "🖼️"
    })

    local Section = Tab:CreateSection({
        Name = "PNG Test"
    })

    local AssetId = getcustomasset("assets/phantom.png")

    Section:AddLabel({
        Text = tostring(AssetId)
    })

    Section:AddImage({
        Image = AssetId,
        Height = 320
    })

end
