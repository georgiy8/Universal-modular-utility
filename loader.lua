-- loader.lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🔄 Pilgrammed Utility Modular Loader")

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/utils/ui.lua", true))()

local guiSystem = UI.CreateMainGui()
print("✅ GUI создан успешно")

-- Тестовая вкладка
local testTab = guiSystem.CreateTab("Test Tab", "🧪", 1)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -40, 0, 100)
label.Position = UDim2.new(0, 20, 0, 20)
label.BackgroundTransparency = 1
label.Text = "Если ты это видишь — система работает!"
label.TextColor3 = Color3.fromRGB(0, 255, 100)
label.TextSize = 18
label.Font = Enum.Font.GothamBold
label.TextWrapped = true
label.Parent = testTab.Container

print("✅ Тестовая вкладка добавлена")
