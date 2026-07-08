--========================================================--
-- Pilgrammed Modular Utility
-- Loader v1.0
--========================================================--

local REPO = "https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/"

-- Простая система импорта файлов из GitHub
local function Import(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(REPO .. path))()
    end)

    if not success then
        warn("[Loader] Failed to load: " .. path)
        warn(result)
        return nil
    end

    return result
end

-- Загружаем GUI
local GUI = Import("gui/init.lua")

if not GUI then
    error("[Loader] Failed to initialize GUI.")
end

-- Создаём окно
local Window = GUI:CreateWindow({
    Title = "Pilgrammed Utility",
    Width = 500,
    Height = 400
})

-- Загружаем игровые модули
local Modules = {
    "main",
    "fishing",
    "mining",
    "floating",
    "settings",
    "Phantom-lancer"
    "mp3player"
}

for _, moduleName in ipairs(Modules) do
    local module = Import("modules/" .. moduleName .. ".lua")

    if type(module) == "function" then
        local ok, err = pcall(module, Window)

        if not ok then
            warn("[Module Error] " .. moduleName)
            warn(err)
        end
    else
        warn("[Loader] Module '" .. moduleName .. "' is invalid.")
    end
end

print("[Pilgrammed Utility] Loaded successfully.")

