# Pilgrammed GUI Library

A modular Roblox GUI library focused on simplicity, performance and easy customization.

---

# Features

- Modular architecture
- Lightweight
- Easy to extend
- Draggable window
- Resizable window
- Minimize / Restore
- Fullscreen mode
- Close button
- Tabs
- Sections
- Widget Registry
- Theme support
- Clean API

---


# Creating a Window

```lua
local Window = GUI:CreateWindow({

    Title = "Pilgrammed Utility",

    Width = 650,

    Height = 420

})
```

| Property | Description |
|----------|-------------|
| Title | Window title |
| Width | Window width |
| Height | Window height |

---

# Creating Tabs

```lua
local Main = Window:CreateTab({

    Name = "Main"

})
```

```lua
local Visual = Window:CreateTab({

    Name = "Visual"

})
```

---

# Creating Sections

```lua
local Combat = Main:CreateSection({

    Name = "Combat"

})
```

Every widget is created inside a Section.

---

# Widgets

## Label

```lua
Combat:AddLabel({

    Text = "Hello World"

})
```

---

## Button

```lua
Combat:AddButton({

    Text = "Click Me",

    Callback = function()

        print("Clicked")

    end

})
```

---

## Toggle

```lua
Combat:AddToggle({

    Text = "Enabled",

    Default = false,

    Callback = function(State)

        print(State)

    end

})
```

---

## Slider

```lua
Combat:AddSlider({

    Text = "WalkSpeed",

    Min = 0,

    Max = 100,

    Default = 16,

    Increment = 1,

    Callback = function(Value)

        print(Value)

    end

})
```

---

## Dropdown

```lua
Combat:AddDropdown({

    Text = "Mode",

    Values = {

        "Normal",

        "Fast",

        "Ultra"

    },

    Default = "Normal",

    Callback = function(Value)

        print(Value)

    end

})
```

---

## Textbox

```lua
Combat:AddTextbox({

    Text = "Username",

    Placeholder = "Player",

    Callback = function(Text)

        print(Text)

    end

})
```

---

## Separator

```lua
Combat:AddSeparator({

    Text = "Advanced"

})
```

---

## Keybind

```lua
Combat:AddKeybind({

    Text = "Open GUI",

    Default = Enum.KeyCode.RightShift,

    Callback = function(Key)

        print(Key.Name)

    end

})
```

---

# Window API

## Show

```lua
Window:Show()
```

Shows the window.

---

## Hide

```lua
Window:Hide()
```

Hides the window.

---

## Set Title

```lua
Window:SetTitle("New Title")
```

Changes the window title.

---

## Set Size

```lua
Window:SetSize(700,500)
```

Changes the window size.

---

## Minimize

```lua
Window:Minimize()
```

Minimizes the window.

---

## Restore

```lua
Window:Maximize()
```

Restores the minimized window.

---

## Toggle Minimize

```lua
Window:ToggleMinimize()
```

Switches between minimized and restored state.

---

## Fullscreen

```lua
Window:ToggleFullscreen()
```

Enters or exits fullscreen mode.

---

## Close

```lua
Window:Close()
```

Destroys the window.

---

# Folder Structure

```
gui/

├── init.lua
├── core.lua
├── theme.lua

├── services/
│   ├── drag.lua
│   └── resize.lua

└── widgets/
    ├── registry.lua
    ├── label.lua
    ├── button.lua
    ├── toggle.lua
    ├── slider.lua
    ├── dropdown.lua
    ├── textbox.lua
    ├── separator.lua
    └── keybind.lua
```

---

# Creating Custom Widgets

Every widget is located inside

```
gui/widgets/
```

Each widget must return a table.

```lua
local Widget = {}

function Widget.Create(Parent, Settings)

    ...

end

return Widget
```

Register the widget inside

```lua
gui/widgets/registry.lua
```

Example:

```lua
Widgets.ColorPicker = Import("gui/widgets/colorpicker.lua")
```

Now register it inside **core.lua**

```lua
local WidgetMethods = {

    ...

    "ColorPicker"

}
```

Your widget will automatically become available as

```lua
Section:AddColorPicker({

})
```

---

# License

This project is open-source.

Feel free to modify, improve and contribute.
