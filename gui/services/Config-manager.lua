-- gui/services/config-manager.lua

local HttpService = game:GetService("HttpService")

local ConfigManager = {}

ConfigManager.Data = {}
ConfigManager.CurrentName = nil
ConfigManager.Registry = {} -- key -> entry

local ROOT = "Universal-assets-by-gk/Configs"
local PROFILES = ROOT .. "/Profiles"
local AUTOLOAD_PATH = ROOT .. "/Autoload.json"

-- widgets that store state
local SAVEABLE = {
    Toggle = true,
    Slider = true,
    Dropdown = true,
    Textbox = true,
    Keybind = true,
}

------------------------------------------------------------
-- FS
------------------------------------------------------------

local function ensureDir(path)
    if makefolder and isfolder and not isfolder(path) then
        makefolder(path)
    end
end

local function ensureTree()
    ensureDir("Universal-assets-by-gk")
    ensureDir(ROOT)
    ensureDir(PROFILES)
end

local function profilePath(name)
    return PROFILES .. "/" .. name .. ".json"
end

local function safeName(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("[^%w%-%_ ]", "")
    name = name:gsub("%s+", "_")
    if name == "" then
        return nil
    end
    return name
end

local function readJson(path)
    if not isfile or not isfile(path) then
        return nil
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if ok and type(data) == "table" then
        return data
    end
    return nil
end

local function writeJson(path, tbl)
    ensureTree()
    if not writefile then
        warn("[ConfigManager] writefile missing")
        return false
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(tbl)
    end)
    if not ok then
        warn("[ConfigManager] encode failed")
        return false
    end
    writefile(path, encoded)
    return true
end

------------------------------------------------------------
-- Init / basic data
------------------------------------------------------------

function ConfigManager.Init()
    ensureTree()
    ConfigManager.Data = ConfigManager.Data or {}
    ConfigManager.Registry = ConfigManager.Registry or {}
    return true
end

function ConfigManager.Get(key, default)
    local v = ConfigManager.Data[key]
    if v == nil then
        return default
    end
    return v
end

function ConfigManager.Set(key, value)
    ConfigManager.Data[key] = value
end

function ConfigManager.GetCurrentName()
    return ConfigManager.CurrentName
end

------------------------------------------------------------
-- Widget registry
------------------------------------------------------------

local function defaultKey(info)
    if info.ConfigKey and info.ConfigKey ~= "" then
        return tostring(info.ConfigKey)
    end
    if info.Flag and info.Flag ~= "" then
        return tostring(info.Flag)
    end
    local tab = info.Tab or "Tab"
    local section = info.Section or "Section"
    local text = info.Text or info.Placeholder or info.Kind or "Widget"
    return string.format("%s/%s/%s", tab, section, text)
end

local function readWidget(entry)
    local w = entry.Widget
    if not w then
        return nil
    end
    if entry.Kind == "Keybind" then
        if w.GetKey then
            local k = w:GetKey()
            if typeof(k) == "EnumItem" then
                return k.Name
            end
            return tostring(k)
        end
        return nil
    end
    if w.GetValue then
        return w:GetValue()
    end
    return nil
end

local function writeWidget(entry, value)
    local w = entry.Widget
    if not w or value == nil then
        return
    end
    if entry.Kind == "Keybind" then
        if w.SetKey then
            local enumVal = value
            if type(value) == "string" and Enum.KeyCode[value] then
                enumVal = Enum.KeyCode[value]
            end
            pcall(function()
                w:SetKey(enumVal)
            end)
        end
        return
    end
    if w.SetValue then
        pcall(function()
            w:SetValue(value)
        end)
    end
end

-- called from core after widget Create
function ConfigManager.RegisterWidget(info)
    if type(info) ~= "table" then
        return
    end

    local kind = info.Kind or "Unknown"
    local explicit = (info.ConfigKey and info.ConfigKey ~= "") or (info.Flag and info.Flag ~= "")

    if not SAVEABLE[kind] and not explicit then
        return
    end

    local key = defaultKey(info)
    if not key then
        return
    end

    ConfigManager.Registry[key] = {
        Key = key,
        Kind = kind,
        Widget = info.Widget,
        Tab = info.Tab,
        Section = info.Section,
        Text = info.Text,
    }

    -- if data already loaded (autoload before widget existed — rare), apply now
    if ConfigManager.Data[key] ~= nil then
        writeWidget(ConfigManager.Registry[key], ConfigManager.Data[key])
    end
end

function ConfigManager.Unregister(key)
    ConfigManager.Registry[key] = nil
end

function ConfigManager.ClearRegistry()
    table.clear(ConfigManager.Registry)
end

-- pull all widget values into Data
function ConfigManager.Capture()
    for key, entry in pairs(ConfigManager.Registry) do
        local ok, value = pcall(readWidget, entry)
        if ok and value ~= nil then
            ConfigManager.Data[key] = value
        end
    end
    return ConfigManager.Data
end

-- push Data into widgets
function ConfigManager.Apply()
    for key, entry in pairs(ConfigManager.Registry) do
        local value = ConfigManager.Data[key]
        if value ~= nil then
            writeWidget(entry, value)
        end
    end
end

function ConfigManager.ListBound()
    local list = {}
    for key, entry in pairs(ConfigManager.Registry) do
        table.insert(list, {
            Key = key,
            Kind = entry.Kind,
            Value = ConfigManager.Data[key],
        })
    end
    table.sort(list, function(a, b)
        return a.Key < b.Key
    end)
    return list
end

------------------------------------------------------------
-- Profiles
------------------------------------------------------------

function ConfigManager.ListProfiles()
    ensureTree()
    local result = {}
    if not listfiles then
        return result
    end
    local ok, files = pcall(listfiles, PROFILES)
    if not ok or type(files) ~= "table" then
        return result
    end
    for _, file in ipairs(files) do
        local name = file:match("([^/\\]+)%.json$")
        if name and name:lower() ~= "jsons" then
            table.insert(result, name)
        end
    end
    table.sort(result)
    return result
end

function ConfigManager.Save(name)
    name = safeName(name or ConfigManager.CurrentName)
    if not name then
        warn("[ConfigManager] Invalid profile name")
        return false
    end

    ConfigManager.Capture()

    local payload = {
        name = name,
        placeId = game.PlaceId,
        updatedAt = os.time(),
        theme = ConfigManager.Data["__theme"] or nil,
        data = ConfigManager.Data,
    }

    if not writeJson(profilePath(name), payload) then
        return false
    end

    ConfigManager.CurrentName = name
    print("[ConfigManager] Saved profile:", name)
    return true
end

function ConfigManager.Load(name)
    name = safeName(name)
    if not name then
        warn("[ConfigManager] Invalid profile name")
        return false
    end

    local payload = readJson(profilePath(name))
    if not payload then
        warn("[ConfigManager] Not found:", name)
        return false
    end

    if type(payload.data) == "table" then
        ConfigManager.Data = payload.data
    else
        ConfigManager.Data = payload
    end

    ConfigManager.CurrentName = name
    ConfigManager.Apply()

    print("[ConfigManager] Loaded profile:", name)
    return true
end

function ConfigManager.Delete(name)
    name = safeName(name)
    if not name then
        return false
    end
    local path = profilePath(name)
    if isfile and isfile(path) and delfile then
        pcall(delfile, path)
        if ConfigManager.CurrentName == name then
            ConfigManager.CurrentName = nil
        end
        print("[ConfigManager] Deleted:", name)
        return true
    end
    return false
end

------------------------------------------------------------
-- Autoload
-- {
--   "placeId": { "enabled": true, "config": "name", "theme": null }
-- }
------------------------------------------------------------

function ConfigManager.GetAutoloadTable()
    ensureTree()
    return readJson(AUTOLOAD_PATH) or {}
end

function ConfigManager.GetAutoload(placeId)
    placeId = tostring(placeId or game.PlaceId)
    local entry = ConfigManager.GetAutoloadTable()[placeId]
    if type(entry) == "table" then
        return entry.enabled == true, entry.config, entry.theme
    end
    return false, nil, nil
end

function ConfigManager.SetAutoload(enabled, configName, themeName, placeId)
    placeId = tostring(placeId or game.PlaceId)
    configName = safeName(configName or ConfigManager.CurrentName)
    ensureTree()

    local all = ConfigManager.GetAutoloadTable()
    all[placeId] = {
        enabled = enabled and true or false,
        config = configName,
        theme = themeName or (ConfigManager.Data and ConfigManager.Data["__theme"]) or nil,
    }

    if enabled and not configName then
        warn("[ConfigManager] Autoload enabled but no config name")
        return false
    end

    if not writeJson(AUTOLOAD_PATH, all) then
        return false
    end

    print("[ConfigManager] Autoload:", placeId, enabled, configName, themeName)
    return true
end

function ConfigManager.TryAutoload()
    local enabled, name, theme = ConfigManager.GetAutoload(game.PlaceId)
    if not enabled or not name then
        return false
    end
    local ok = ConfigManager.Load(name)
    -- theme apply later when ThemeManager exists
    if ok and theme then
        ConfigManager.Data["__theme"] = theme
        if _G.ThemeManager and _G.ThemeManager.Load then
            pcall(_G.ThemeManager.Load, theme)
        end
    end
    return ok
end

function ConfigManager.GetPaths()
    return {
        Root = ROOT,
        Profiles = PROFILES,
        Autoload = AUTOLOAD_PATH,
    }
end

ConfigManager.Init()

return ConfigManager
