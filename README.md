
```markdown
# Universal Utility

Modular Roblox GUI framework for executor environments.

Load via `loader.lua` (GitHub `HttpGet` + `loadstring`).

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

```lua
General:AddLabel({
    Text = "Hello World"
})
```

| Option | Type | Default |
|--------|------|---------|
| Text | string | "Label" |

Methods: `SetText`, `GetText`, `SetColor`, `SetVisible`, `Destroy`

---

# Button

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

Methods: `SetText`, `GetText`, `SetCallback`, `Fire`, `SetColor`, `SetVisible`, `SetEnabled`, `Destroy`

---

# Toggle

```lua
General:AddToggle({
    Text = "Feature",
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

Methods: `GetValue`, `SetValue`, `SetText`, `SetCallback`, `SetVisible`, `Destroy`

---

# Slider

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

Methods:

```lua
Slider:GetValue()
Slider:SetValue(value)
Slider:SetRange(min, max)
Slider:SetMin(min)
Slider:SetMax(max)
Slider:SetIncrement(step)
Slider:SetText(text)
Slider:SetCallback(fn)
Slider:SetVisible(state)
Slider:SetEnabled(state)
Slider:SetFillColor(color)
Slider:SetBarColor(color)
Slider:SetKnobColor(color)
Slider:SetTextColor(color)
Slider:SetValueColor(color)
Slider:Destroy()
```

---

# Dropdown

Accepts **Options** or **Values** (same thing).

```lua
General:AddDropdown({
    Text = "Weapon",
    Options = { "Sword", "Bow", "Gun" },
    -- Values = { "Sword", "Bow", "Gun" }, -- also works
    Default = "Sword",
    Callback = function(Value)
        print(Value)
    end
})
```

| Option | Type |
|--------|------|
| Text | string |
| Options | table |
| Values | table |
| Default | any |
| Callback | function |

Methods: `GetValue`, `SetValue`, `SetValues`, `SetText`, `SetCallback`, `SetVisible`, `Destroy`

---

# Textbox

```lua
General:AddTextbox({
    Text = "Name",
    Placeholder = "Type here...",
    Default = "",
    Callback = function(Text, EnterPressed)
        print(Text, EnterPressed)
    end
})
```

| Option | Type |
|--------|------|
| Text | string |
| Placeholder | string |
| Default | string |
| Callback | function |

Methods: `GetValue`, `SetValue`, `Clear`, `SetPlaceholder`, `SetText`, `SetCallback`, `SetVisible`, `Destroy`

---

# Keybind

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

Methods: `GetKey`, `SetKey`, `SetText`, `SetCallback`, `SetVisible`, `Destroy`

---

# Separator

```lua
General:AddSeparator()
-- or
General:AddSeparator({ Text = "Section" })
```

Methods: `SetText`, `GetText`, `SetVisible`, `Destroy`

---

# Image

```lua
General:AddImage({
    Image = Assets:GetImage("phantom.png"),
    Height = 220,
    AspectRatio = 16/9
})
```

ImageButton mode:

```lua
General:AddImage({
    Image = Assets:GetImage("phantom.png"),
    Height = 220,
    Button = true,
    ClickSound = Assets:GetSound("click.mp3"),
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
| ClickSound | string | nil |
| OnClick | function | nil |
| OnRightClick | function | nil |
| OnHover | function | nil |
| OnLeave | function | nil |

Methods: `SetImage`, `GetImage`, `SetHeight`, `SetVisible`, `SetScaleType`, `SetTransparency`, `SetBackgroundTransparency`, `SetBackgroundColor`, `SetCornerRadius`, `SetBorder`, `SetPadding`, `SetAspectRatio`, `IsButton`, `OnClick`, `OnRightClick`, `OnHover`, `OnLeave`, `Destroy`

---

# Sound

One `Play` for both instance and static (no recursion).

### Create

```lua
local s = SoundWidget.Create({
    Path = Assets:GetSound("track.mp3"),
    Volume = 1,
    Speed = 1,
    Looped = false,
    Parent = game:GetService("SoundService")
})
```

| Option | Type | Default |
|--------|------|---------|
| Path / Sound / Asset | string | nil |
| Volume | number | 1 |
| Speed | number | 1 |
| Looped | boolean | false |
| Parent | Instance | SoundService |
| Name | string | "WidgetSound" |

### Play (instance + static)

```lua
-- keep instance (pause / seek)
s:Play()
s:Pause()
s:Resume()
s:Stop()

-- one-shot (create → play → destroy on Ended)
SoundWidget.Play(Assets:GetSound("track.mp3"))
```

### Seek / state

```lua
s:IsPlaying()
s:GetTimePosition()
s:SetTimePosition(seconds)
s:GetLength()
```

### Other

```lua
s:SetVolume(0.5)
s:SetSpeed(1.2)
s:SetLooped(true)
s:SetEnabled(true)

s:FadeIn(0.5)
s:FadeOut(0.5)

s:OnEnded(function() end)
s:OnPlayed(function() end)
s:OnStopped(function() end)

s:Destroy()

SoundWidget.FromAsset(Assets, "track.mp3")
SoundWidget.Bind(buttonObject, { Click = assetId, Hover = assetId })
```

Also: `Section:AddSound({ Path = ... })` (Sound is not passed a Parent frame).

### Seek + Slider example

```lua
local s = SoundWidget.Create({
    Path = Assets:GetSound("Plance_lasthit_03_ru.mp3")
})

local dragging = false
local Seek = Section:AddSlider({
    Text = "Seek",
    Min = 0,
    Max = 1,
    Default = 0,
    Increment = 0.05,
    Callback = function(Value)
        dragging = true
        s:SetTimePosition(Value)
        task.defer(function()
            dragging = false
        end)
    end
})

task.spawn(function()
    for _ = 1, 50 do
        local len = s:GetLength()
        if len > 0 then
            Seek:SetRange(0, len)
            break
        end
        task.wait(0.1)
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if not dragging and s:IsPlaying() then
        Seek:SetValue(s:GetTimePosition())
    end
end)
```

---

# Window Methods

```lua
Window:SetTitle("New Title")
Window:SetSize(800, 500)
Window:Show()
Window:Hide()
Window:Minimize()
Window:Maximize()          -- restore from minimize
Window:ToggleMinimize()
Window:ToggleFullscreen()
Window:Close()
Window:Destroy()           -- fixed: single cleanup path
Window:GetTab("Main")
```

---

# Tab Methods

```lua
Tab:Select()
Tab:Destroy()
Tab:GetSection("General")
Tab:CreateSection({ Name = "..." })
```

---

# Section Methods

```lua
Section:Clear()
Section:Destroy()
Section:AddLabel / AddButton / AddToggle / AddSlider
Section:AddDropdown / AddTextbox / AddKeybind / AddSeparator
Section:AddImage / AddSound
```

---

# Asset Manager

Global: `_G.Assets` after GUI init.

```
assets/
  Universal/
    Images/
    Sounds/
  YourModule/
    Images/
    Sounds/
```

Prefer **ASCII filenames** (no Cyrillic / spaces) — `getcustomasset` may fail otherwise.

```lua
Assets:GetImage("phantom.png")
Assets:GetSound("track.mp3")
Assets:Get("Universal/Images/phantom.png")
Assets:GetByName("phantom.png")
Assets:Exists("phantom.png")
Assets:Search("phantom")
Assets:List()
Assets:ListImages()
Assets:ListSounds()
Assets:Reload()
Assets:PrintStatistics()
```

---

# Modules

`loader.lua` loads:

```lua
local Modules = {
    "main",
    "Phantom-lancer"
}
```

Each module:

```lua
return function(Window)
    local Tab = Window:CreateTab({ Name = "MyTab" })
    -- ...
end
```

---

# Project Structure

```
loader.lua
config.lua                 -- stub
gui/
  core.lua
  init.lua
  theme.lua                -- stub
  widgets/
    registry.lua
    label.lua button.lua toggle.lua slider.lua
    dropdown.lua textbox.lua keybind.lua separator.lua
    image.lua sound.lua
  services/
    drag.lua resize.lua assetmanager.lua
    animation.lua utility.lua   -- stubs
modules/
  main.lua
  settings.lua             -- stub
utilities/                 -- stubs
  movement.lua network.lua player.lua
assets/
  Universal/Images/
  Universal/Sounds/
```
---

# Notes

- Entry: `loader.lua` → `gui/init.lua` → `gui/core.lua`
- `_G.Assets`, `_G.SoundWidget` set at GUI load
- Dropdown: use `Options` or `Values`
- Sound: one `Play`; static path uses `Instance:Play()` only (no recursion)
- Asset names: ASCII recommended
```
