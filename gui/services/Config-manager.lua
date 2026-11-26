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
-- Общие файлы (не привязаны к профилю): настройки окна и т.п.
-- Лежат рядом с профилями: Universal-assets-by-gk/Configs/<имя>.json
------------------------------------------------------------

function ConfigManager.LoadGlobal(name)
    name = safeName(name)
    if not name then
        return {}
    end
    return readJson(ROOT .. "/" .. name .. ".json") or {}
end

function ConfigManager.SaveGlobal(name, tbl)
    name = safeName(name)
    if not name or type(tbl) ~= "table" then
        return false
    end
    return writeJson(ROOT .. "/" .. name .. ".json", tbl)
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

-- клавиша на переключателе хранится рядом со значением: "<ключ>#bind"
local function applyBind(entry, key)
    local w = entry.Widget
    if not w or not w.SetBind then
        return
    end
    local name = ConfigManager.Data[key .. "#bind"]
    if name == nil then
        return
    end
    local code = (type(name) == "string" and name ~= "") and Enum.KeyCode[name] or nil
    pcall(function()
        w:SetBind(code)
    end)
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
    -- SetValue меняет только вид виджета; чтобы модуль тоже получил значение,
    -- вызываем Callback. У слайдера SetValue уже вызывает Callback сам.
    if w.Fire and (entry.Kind == "Toggle" or entry.Kind == "Textbox" or entry.Kind == "Dropdown") then
        pcall(function()
            w:Fire()
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
    -- откладываем до конца текущего модуля, чтобы его колбэки видели свои переменные
    if ConfigManager.Data[key] ~= nil then
        local entry = ConfigManager.Registry[key]
        task.defer(function()
            if ConfigManager.Registry[key] == entry and ConfigManager.Data[key] ~= nil then
                writeWidget(entry, ConfigManager.Data[key])
                applyBind(entry, key)
            end
        end)
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
        if entry.Widget and entry.Widget.GetBind then
            local okBind, code = pcall(entry.Widget.GetBind, entry.Widget)
            if okBind then
                ConfigManager.Data[key .. "#bind"] = (typeof(code) == "EnumItem") and code.Name or ""
            end
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
        applyBind(entry, key)
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
-- Экспорт / импорт профиля строкой ("UMU1:...")
------------------------------------------------------------

local B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local B64_LOOKUP = {}
for i = 1, #B64_CHARS do
    B64_LOOKUP[B64_CHARS:sub(i, i)] = i - 1
end

local function b64encode(data)
    local out = {}
    for i = 1, #data, 3 do
        local a, b, c = data:byte(i, i + 2)
        local n = a * 65536 + (b or 0) * 256 + (c or 0)
        local c1 = math.floor(n / 262144) % 64
        local c2 = math.floor(n / 4096) % 64
        local c3 = math.floor(n / 64) % 64
        local c4 = n % 64
        table.insert(out, B64_CHARS:sub(c1 + 1, c1 + 1))
        table.insert(out, B64_CHARS:sub(c2 + 1, c2 + 1))
        table.insert(out, b and B64_CHARS:sub(c3 + 1, c3 + 1) or "=")
        table.insert(out, c and B64_CHARS:sub(c4 + 1, c4 + 1) or "=")
    end
    return table.concat(out)
end

local function b64decode(text)
    text = text:gsub("[^%w%+/=]", "")
    local out = {}
    for i = 1, #text, 4 do
        local c1 = B64_LOOKUP[text:sub(i, i)]
        local c2 = B64_LOOKUP[text:sub(i + 1, i + 1)]
        local c3 = B64_LOOKUP[text:sub(i + 2, i + 2)]
        local c4 = B64_LOOKUP[text:sub(i + 3, i + 3)]
        if not c1 or not c2 then
            return nil
        end
        local n = c1 * 262144 + c2 * 4096 + (c3 or 0) * 64 + (c4 or 0)
        table.insert(out, string.char(math.floor(n / 65536) % 256))
        if c3 then
            table.insert(out, string.char(math.floor(n / 256) % 256))
        end
        if c4 then
            table.insert(out, string.char(n % 256))
        end
    end
    return table.concat(out)
end

local EXPORT_PREFIX = "UMU1:"
local IMPORT_MAX_CHARS = 400000

-- Строка с текущими настройками всех виджетов (то же, что попало бы в профиль)
function ConfigManager.ExportString(name)
    ConfigManager.Capture()
    local payload = {
        v = 1,
        name = name or ConfigManager.CurrentName,
        placeId = game.PlaceId,
        data = ConfigManager.Data,
    }
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    if not ok then
        return nil
    end
    return EXPORT_PREFIX .. b64encode(encoded)
end

-- пропускаем только простые значения, чужая строка не должна приносить ничего лишнего
local function cleanValue(value, depth)
    local kind = type(value)
    if kind == "boolean" or kind == "number" then
        return value, true
    end
    if kind == "string" then
        if #value > 2000 then
            return nil, false
        end
        return value, true
    end
    if kind == "table" and depth < 2 then
        local list = {}
        for index, item in pairs(value) do
            if type(index) == "number" then
                local clean, ok = cleanValue(item, depth + 1)
                if ok then
                    list[index] = clean
                end
            end
        end
        return list, true
    end
    return nil, false
end

-- Импорт: применяет настройки из строки. saveName - сохранить как профиль с этим именем.
-- Возвращает: ok, сообщение, количество значений
function ConfigManager.ImportString(text, saveName)
    text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then
        return false, "строка пустая", 0
    end
    if #text > IMPORT_MAX_CHARS then
        return false, "строка слишком длинная", 0
    end
    if text:sub(1, #EXPORT_PREFIX) ~= EXPORT_PREFIX then
        return false, "это не строка профиля UMU", 0
    end

    local raw = b64decode(text:sub(#EXPORT_PREFIX + 1))
    if not raw then
        return false, "строка повреждена", 0
    end

    local ok, payload = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not ok or type(payload) ~= "table" or type(payload.data) ~= "table" then
        return false, "строка повреждена", 0
    end

    local clean, count = {}, 0
    for key, value in pairs(payload.data) do
        if type(key) == "string" and #key <= 200 then
            local item, valid = cleanValue(value, 0)
            if valid then
                clean[key] = item
                count = count + 1
            end
        end
    end

    if count == 0 then
        return false, "в строке нет настроек", 0
    end

    ConfigManager.Data = clean
    ConfigManager.Apply()

    local note = ""
    if payload.placeId and tonumber(payload.placeId) ~= game.PlaceId then
        note = " (профиль из другой игры: " .. tostring(payload.placeId) .. ")"
    end

    if saveName and saveName ~= "" then
        if ConfigManager.Save(saveName) then
            note = note .. ", сохранено как " .. tostring(ConfigManager.CurrentName)
        end
    end

    return true, "применено значений: " .. count .. note, count
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
