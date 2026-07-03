-- loader.lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Загрузка конфига
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/ТВОЙ_НИК/ТВОЙ_РЕПОЗИТОРИЙ/main/config.lua"))()
-- Или если тестируешь локально:
-- local Config = require(script.Parent.config)

print("✅ Pilgrammed Utility v" .. Config.Version .. " - Loading...")

-- Загрузка UI системы
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ТВОЙ_НИК/ТВОЙ_РЕПОЗИТОРИЙ/main/utils/ui.lua"))()

-- Создание главного GUI
local MainGui = UI.CreateMainGui()

-- Функция загрузки модулей
local function LoadModule(name)
    local success, module = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ТВОЙ_НИК/ТВОЙ_РЕПОЗИТОРИЙ/main/modules/" .. name .. ".lua"))()
    end)
    
    if success and module then
        pcall(module, MainGui) -- Передаём GUI в модуль
        print("✅ Module loaded: " .. name)
    else
        warn("❌ Failed to load module: " .. name)
    end
end

-- Загрузка всех модулей
wait(0.5)
LoadModule("settings")
LoadModule("main")
LoadModule("floating")
LoadModule("fishing")
LoadModule("mining")

print("🎉 Pilgrammed Utility fully loaded!")
