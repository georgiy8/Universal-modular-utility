--========================================================--
-- Pilgrammed GUI Library
-- Widgets Registry
--========================================================--

local REPO = "https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/"

local function Import(path)

    local Success, Result = pcall(function()

        return loadstring(game:HttpGet(REPO .. path))()

    end)

    if not Success then
        error(Result)
    end

    return Result

end

------------------------------------------------------------

local Widgets = {}

------------------------------------------------------------
-- Register Widgets
------------------------------------------------------------

Widgets.Label = Import("gui/widgets/label.lua")

Widgets.Button = Import("gui/widgets/button.lua")

Widgets.Toggle = Import("gui/widgets/toggle.lua")

Widgets.Slider = Import("gui/widgets/slider.lua")

Widgets.Dropdown = Import("gui/widgets/dropdown.lua")

Widgets.Textbox = Import("gui/widgets/textbox.lua")

Widgets.Separator = Import("gui/widgets/separator.lua")

Widgets.Keybind = Import("gui/widgets/keybind.lua")

Widgets.Image = Import("gui/widgets/image.lua")

Widgets.Sound = Import("gui/widgets/sound.lua")

------------------------------------------------------------

return Widgets
