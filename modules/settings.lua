-- modules/settings.lua
return function(UI)
    print("📌 Загрузка Settings модуля...")

    local settingsTab = UI.CreateTab("Settings", "⚙️", 1)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "🎨 Настройки интерфейса"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = settingsTab

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 60)
    label.BackgroundTransparency = 1
    label.Text = "Настройки цветов скоро будут здесь"
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.Parent = settingsTab

    print("✅ Settings tab успешно создан")
end
