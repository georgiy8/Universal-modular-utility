-- loader.lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🔄 Pilgrammed Utility Modular Loader")

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/utils/ui.lua", true))()
local guiSystem = UI.CreateMainGui()

print("✅ GUI создан успешно")

-- Загрузка модулей
local modules = {"settings"}  -- Добавляй сюда новые: "main", "fishing" и т.д.

for _, moduleName in ipairs(modules) do
    local success, err = pcall(function()
        local url = "https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/modules/" .. moduleName .. ".lua"
        local code = game:HttpGet(url, true)
        loadstring(code)(guiSystem)
        print("✅ Module loaded: " .. moduleName)
    end)
    
    if not success then
        warn("❌ Ошибка загрузки " .. moduleName .. ": " .. tostring(err))
    end
end

print("🎉 Полная загрузка завершена!")
