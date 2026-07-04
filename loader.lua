-- loader.lua
-- Точка входа утилиты. Собирает GUI-каркас и настройки, ничего не знает
-- о конкретных игровых функциях — те регистрируются отдельными модулями
-- через Core.NewTab / gui.ui.lua.

local root = script.Parent

local Config = require(root.config)
local Core = require(root.gui.core)
local UI = require(root.gui.ui)

local Loader = {}

-- Список модулей функций, которые нужно инициализировать после GUI.
-- Каждый модуль — ModuleScript в папке modules/, который возвращает
-- таблицу с функцией Init(Core, UI, Config).
-- Пока modules/*.lua — пустые заглушки, поэтому вызов обёрнут в pcall,
-- чтобы отсутствие реализации не ломало загрузку GUI.
local MODULES_TO_LOAD = {
    -- { instance = root.modules.main,     name = "main" },
    -- { instance = root.modules.fishing,  name = "fishing" },
    -- { instance = root.modules.mining,   name = "mining" },
    -- { instance = root.modules.floating, name = "floating" },
}

function Loader.Init()
    Core.CreateGUI("Modular Utility")

    -- Вкладка настроек темы — всегда доступна, ни от каких модулей не зависит
    UI.CreateSettingsTab()

    -- Инициализация функциональных модулей (если/когда они появятся)
    for _, entry in ipairs(MODULES_TO_LOAD) do
        local ok, moduleOrErr = pcall(require, entry.instance)
        if not ok then
            warn(("[Loader] Не удалось загрузить модуль '%s': %s"):format(entry.name, tostring(moduleOrErr)))
        elseif type(moduleOrErr) == "table" and type(moduleOrErr.Init) == "function" then
            local initOk, initErr = pcall(moduleOrErr.Init, Core, UI, Config)
            if not initOk then
                warn(("[Loader] Ошибка инициализации модуля '%s': %s"):format(entry.name, tostring(initErr)))
            end
        else
            warn(("[Loader] Модуль '%s' не возвращает таблицу с Init(Core, UI, Config)"):format(entry.name))
        end
    end

    Core.ApplyColors()
    Core.UpdateLayout()
    Core.ShowDefaultTab()

    print("✅ Modular Utility loaded")
end

Loader.Init()

return Loader
