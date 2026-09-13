
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

### Extra info & maintenance

```lua
Assets:GetInfo("phantom.png")
-- -> { Name, Path, Extension, AssetId }

Assets:Init()                       -- (re)builds the folder tree + index, called automatically on load
Assets:CreateFolder()               -- creates Assets/Images, Assets/Sounds, Configs/Profiles, Themes
Assets:Download(URL, LocalPath)     -- downloads a single file via HttpGet and writes it to disk
Assets:ScanFolder(GithubPath, LocalPath)  -- recursively mirrors a GitHub folder to disk, skipping files that already exist
Assets:IndexFolder(Path)            -- recursively (re)indexes an already-downloaded local folder
Assets:RegisterAsset(File)          -- registers a single local file (by extension) into the asset index
```

---

# Config Manager

Global: `_G.ConfigManager` after GUI init. Handles widget persistence (save/load profiles) and per-place autoload, stored on disk under `Universal-assets-by-gk/Configs/`.

### Auto-save for widgets

Any `Toggle`, `Slider`, `Dropdown`, `Textbox`, or `Keybind` is **automatically tracked** for saving — no extra code needed. Give it an explicit key if you want a stable name across UI changes:

```lua
General:AddToggle({
    Text = "God Mode",
    Flag = "godmode",       -- or ConfigKey = "godmode"
    Default = false,
    Callback = function(v) end
})
```

Without `Flag`/`ConfigKey`, the key falls back to `"Tab/Section/Text"`.

### Key/value store

```lua
ConfigManager.Get(key, default)
ConfigManager.Set(key, value)
```

### Widget registry (internal, used by `core.lua` automatically)

```lua
ConfigManager.RegisterWidget(info)   -- called by core.lua right after a widget is created
ConfigManager.Unregister(key)
ConfigManager.ClearRegistry()
ConfigManager.Capture()              -- pulls current values from all registered widgets into memory
ConfigManager.Apply()                -- pushes in-memory values back onto all registered widgets
ConfigManager.ListBound()            -- -> [{ Key, Kind, Value }, ...] currently tracked widgets
```

### Profiles

```lua
ConfigManager.ListProfiles()         -- -> { "name1", "name2", ... }
ConfigManager.Save(name)             -- captures widget state and writes Configs/Profiles/<name>.json
ConfigManager.Load(name)             -- reads the profile and applies it to all registered widgets
ConfigManager.Delete(name)
ConfigManager.GetCurrentName()       -- name of the currently loaded/saved profile
```

### Autoload (per Roblox place)

```lua
ConfigManager.GetAutoload(placeId)          -- -> enabled, configName, themeName
ConfigManager.SetAutoload(enabled, configName, themeName, placeId)
ConfigManager.TryAutoload()                 -- loads the configured profile for the current PlaceId, if enabled
ConfigManager.GetAutoloadTable()            -- raw table, keyed by PlaceId
ConfigManager.GetPaths()                    -- -> { Root, Profiles, Autoload } filesystem paths
```

The `settings` module (see below) ships a ready-made UI for all of this: profile save/load/delete/refresh, and an autoload toggle per place.

---

# Window Dragging & Resizing

Used internally by `gui/core.lua` to make windows draggable/resizable; exposed if you need to wire up a custom frame.

```lua
Drag.Enable(DragObject, Target)     -- makes Target follow drag input on DragObject (e.g. a title bar)
Resize.Enable(Target, Handle)       -- makes Target resize by dragging Handle (e.g. a corner grip)
```

---

# Built-in Modules

Shipped with the loader (`BaseModules` in `loader.lua`), loaded into every window by default:

- **`main`** — Session tab: player name, place name, `PlaceId`/`JobId` textboxes with one-click clipboard copy (`setclipboard`/`toclipboard`), and a live Performance section (FPS counter, network ping, clock).
- **`Console`** — Developer console tab: live-streams `LogService` output (info/warning/error color-coded), keeps up to 250 messages, supports filtering by text, autoscroll, and running/executing code from the console input.
- **`settings`** — Settings tab: full UI over the Config Manager — save/load/delete named profiles, refresh the profile list, and enable/configure per-place autoload.
- **`Phantom-lancer`** — a demo/test tab exercising every widget type; useful as a copy-paste template for a new module.

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
