-- modules/settings.lua
return function(UI)
    local Config = shared.PilgrammedConfig or {DefaultSettings = {}}

    local settingsTab = UI.CreateTab("Settings", "⚙️", 1)

    local title = Instance.new("TextLabel", settingsTab.Container)
    title.Size = UDim2.new(1, -20, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🎨 Настройки интерфейса"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left

    print("✅ Settings tab loaded")
end
