# Universal Utility

A modular Roblox utility framework built for executor environments.

---

# Create Window

```lua
local Window = GUI:CreateWindow({
    Title = "Universal Utility",
    Width = 650,
    Height = 420
})
```

| Option | Type | Default |
|--------|------|---------|
| Title | string | "Universal Utility" |
| Width | number | 650 |
| Height | number | 420 |

---

# Create Tab

```lua
local Main = Window:CreateTab({
    Name = "Main",
    Icon = "🏠"
})
```

| Option | Type |
|--------|------|
| Name | string |
| Icon | string |

---

# Create Section

```lua
local General = Main:CreateSection({
    Name = "General"
})
```

| Option | Type |
|--------|------|
| Name | string |

---

# Label

Displays text.

```lua
General:AddLabel({
    Text = "Hello World"
})
```

| Option | Type | Default |
|--------|------|---------|
| Text | string | "Label" |

---

# Button

Creates a clickable button.

```lua
General:AddButton({
    Text = "Print",
    Callback = function()
        print("Hello")
    end
})
```

| Option | Type |
|--------|------|
| Text | string |
| Callback | function |

---

# Toggle

Creates an ON/OFF switch.

```lua
General:AddToggle({
    Text = "God Mode",
    Default = false,
    Callback = function(Value)
        print(Value)
    end
})
```

| Option | Type |
|--------|------|
| Text | string |
| Default | boolean |
| Callback | function |

---

# Slider

Numeric slider.

```lua
General:AddSlider({
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

| Option | Type | Default |
|--------|------|---------|
| Text | string | "Slider" |
| Min | number | 0 |
| Max | number | 100 |
| Default | number | Min |
| Increment | number | 1 |
| Callback | function | |

---

# Dropdown

Selection list.

```lua
General:AddDropdown({
    Text = "Weapon",
    Options = {
        "Sword",
        "Bow",
        "Gun"
    },
    Callback = function(Value)
        print(Value)
    end
})
```

| Option | Type |
|--------|------|
| Text | string |
| Options | table |
| Callback | function |

---

# Textbox

Text input.

```lua
General:AddTextbox({
    Placeholder = "Type here...",
    Callback = function(Text)
        print(Text)
    end
})
```

| Option | Type |
|--------|------|
| Placeholder | string |
| Callback | function |

---

# Keybind

Keyboard shortcut.

```lua
General:AddKeybind({
    Text = "Fly",
    Default = Enum.KeyCode.F,
    Callback = function()
        print("Pressed")
    end
})
```

| Option | Type |
|--------|------|
| Text | string |
| Default | Enum.KeyCode |
| Callback | function |

---

# Separator

Horizontal separator.

```lua
General:AddSeparator()
```

No settings required.

---

# Image

Displays an image.

```lua
General:AddImage({
    Image = getcustomasset("assets/logo.png"),
    Height = 220
})
```

### Supports ImageButton mode

```lua
General:AddImage({
    Image = getcustomasset("assets/logo.png"),
    Button = true,

    OnClick = function()
        print("Clicked")
    end
})
```

| Option | Type | Default |
|--------|------|---------|
| Image | string | "" |
| Height | number | 160 |
| ScaleType | Enum.ScaleType | Fit |
| Transparency | number | 0 |
| BackgroundTransparency | number | 1 |
| BackgroundColor | Color3 | White |
| AspectRatio | number | nil |
| Button | boolean | false |
| ClickSound | string / SoundWidget | nil |
| OnClick | function | nil |
| OnRightClick | function | nil |
| OnHover | function | nil |
| OnLeave | function | nil |

---

# Sound

Sound utility widget.

```lua
local Click = Widgets.Sound.Create({
    Path = Assets:GetSound("click.mp3")
})

Click:Play()
```

### Options

| Option | Type | Default |
|--------|------|---------|
| Path | string | nil |
| Volume | number | 1 |
| Speed | number | 1 |
| Looped | boolean | false |
| Parent | Instance | SoundService |

### Methods

```lua
Sound:Play()
Sound:Stop()
Sound:Pause()
Sound:Resume()

Sound:SetVolume(0.5)
Sound:SetSpeed(1.2)

Sound:FadeIn(0.25)
Sound:FadeOut(0.25)

Sound:IsPlaying()
Sound:GetLength()

Sound:Destroy()
```

---

# Widget Methods

Every widget returns an object.

Example:

```lua
local Label = General:AddLabel({
    Text = "Loading..."
})

Label:SetText("Finished")
```

Image:

```lua
local Image = General:AddImage({
    Image = Assets:GetImage("logo.png")
})

Image:SetImage(Assets:GetImage("banner.png"))

Image:SetHeight(280)

Image:SetVisible(false)

Image:SetAspectRatio(16/9)
```

Button Image:

```lua
Image:OnClick(function()

end)

Image:OnHover(function()

end)

Image:OnLeave(function()

end)
```

---

# Window Methods

```lua
Window:SetTitle("New Title")

Window:SetSize(800,500)

Window:Show()

Window:Hide()

Window:ToggleMinimize()

Window:ToggleFullscreen()

Window:Close()

Window:Destroy()
```

---

# Tab Methods

```lua
Tab:Select()

Tab:Destroy()

Tab:GetSection("General")
```

---

# Section Methods

```lua
Section:Clear()

Section:Destroy()
```

---

# Asset Manager

Universal Utility includes an integrated Asset Manager.

Assets are downloaded, verified, indexed and available globally.

Folder structure:

```
assets/
    Universal/
        Images/
        Sounds/

    YourModule/
        Images/
        Sounds/
```

---

## Images

```lua
local Logo = Assets:GetImage("logo.png")
```

```lua
General:AddImage({
    Image = Logo
})
```

---

## Sounds

```lua
local Click = Assets:GetSound("click.mp3")
```

```lua
Widgets.Sound.Play(Click)
```

---

## Search

```lua
Assets:Search("phantom")
```

---

## Reload

```lua
Assets:Reload()
```

---

# Project Structure

```
loader.lua

config.lua

gui/

    core.lua
    init.lua
    theme.lua

    widgets/

        registry.lua

        label.lua
        button.lua
        toggle.lua
        slider.lua
        dropdown.lua
        textbox.lua
        keybind.lua
        separator.lua
        image.lua
        sound.lua

    services/

        drag.lua
        resize.lua
        animation.lua
        utility.lua
        assetmanager.lua

modules/

    main.lua
    fishing.lua
    mining.lua
    floating.lua
    settings.lua

assets/

    Universal/

        Images/

        Sounds/

    ModuleName/

        Images/

        Sounds/
```

---

# Features

- Modular GUI framework
- Modular module loader
- Automatic Asset Manager
- Image Widget
- Image Button Widget
- Sound Widget
- Custom Asset Support
- Automatic asset indexing
- Automatic GitHub synchronization
- Window dragging
- Window resizing
- Fullscreen mode
- Minimize support
- Theme support
- Designed for executor environments
