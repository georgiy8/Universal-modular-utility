--========================================================--
-- Universal-modular-utility GUI Library
-- Theme.lua
--========================================================--

local Theme = {}

Theme.Name = "Midnight"

Theme.Colors = {
    -- Окно
    Window      = Color3.fromRGB(24, 26, 31),
    TitleBar    = Color3.fromRGB(31, 34, 41),
    TabsPanel   = Color3.fromRGB(28, 31, 37),
    Content     = Color3.fromRGB(26, 28, 34),
    Section     = Color3.fromRGB(34, 37, 45),

    -- Строки виджетов
    Row         = Color3.fromRGB(45, 49, 58),
    RowHover    = Color3.fromRGB(56, 61, 72),
    Field       = Color3.fromRGB(23, 25, 30),
    Option      = Color3.fromRGB(39, 43, 51),

    -- Линии и контуры
    Line        = Color3.fromRGB(70, 76, 89),
    Stroke      = Color3.fromRGB(58, 63, 75),

    -- Текст
    Text        = Color3.fromRGB(235, 238, 244),
    TextDim     = Color3.fromRGB(150, 158, 171),
    TextMuted   = Color3.fromRGB(184, 190, 201),

    -- Акцент
    Accent      = Color3.fromRGB(70, 160, 255),
    Knob        = Color3.fromRGB(255, 255, 255),

    -- Кнопки окна
    Control      = Color3.fromRGB(52, 56, 66),
    ControlHover = Color3.fromRGB(72, 77, 90),
    Danger       = Color3.fromRGB(220, 85, 85),
}

Theme.Radius = 8
Theme.RadiusSmall = 5

-- Цвет по имени; fallback берётся, если имя неизвестно или тема не загружена
function Theme.Get(Name, Fallback)
    return Theme.Colors[Name] or Fallback
end

-- Подмена цветов (например, другой темой): Theme.Apply({ Accent = Color3.fromRGB(...) })
function Theme.Apply(Overrides)
    if type(Overrides) ~= "table" then
        return
    end
    for Name, Value in pairs(Overrides) do
        if typeof(Value) == "Color3" then
            Theme.Colors[Name] = Value
        end
    end
end

-- Доступ из любого файла библиотеки и из модулей
_G.UMUTheme = Theme

return Theme
