--========================================================--
-- Universal-modular GUI Library
-- init.lua
-- Public API
--========================================================--

local REPO = "https://raw.githubusercontent.com/georgiy8/Universal-modular-utility/main/"

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

-- Тема уже загружена ядром (_G.UMUTheme); грузим заново, только если её нет
Core.Theme = _G.UMUTheme or Import("gui/theme.lua")

return Core
