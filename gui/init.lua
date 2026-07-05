--========================================================--
-- Pilgrammed GUI Library
-- init.lua
-- Public API
--========================================================--

local REPO = "https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/"

local function Import(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(REPO .. path))()
    end)

    if not success then
        error("[GUI] Failed to load '" .. path .. "'\n" .. tostring(result))
    end

    return result
end

-- Core библиотеки
local Core = Import("gui/core.lua")

-- Тема (пока не используется, но сразу подключаем)
Core.Theme = Import("gui/theme.lua")

return Core
