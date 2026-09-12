local HttpService = game:GetService("HttpService")

local ConfigManager = {}
ConfigManager.Name = "Universal"
ConfigManager.Data = {}

local function root()
    return "Gk_config"
end

local function profileDir()
    return root() .. "/" .. ConfigManager.Name
end

local function placeFile()
    return profileDir() .. "/" .. tostring(game.PlaceId) .. ".json"
end

local function ensureFolders()
    if makefolder then
        if isfolder and not isfolder(root()) then
            makefolder(root())
        end
        if isfolder and not isfolder(profileDir()) then
            makefolder(profileDir())
        end
    end
end

function ConfigManager.Init(settings)
    settings = settings or {}
    ConfigManager.Name = settings.Name or "Universal"
    ConfigManager.Data = {}
    ensureFolders()
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

function ConfigManager.Save()
    ensureFolders()
    if not writefile then
        warn("[ConfigManager] writefile missing")
        return false
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(ConfigManager.Data)
    end)
    if not ok then
        warn("[ConfigManager] encode failed")
        return false
    end
    writefile(placeFile(), encoded)
    return true
end

function ConfigManager.Load()
    local path = placeFile()
    if not isfile or not isfile(path) then
        ConfigManager.Data = {}
        return false
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(data) ~= "table" then
        warn("[ConfigManager] load failed:", path)
        ConfigManager.Data = {}
        return false
    end
    ConfigManager.Data = data
    return true
end

function ConfigManager.Reset()
    ConfigManager.Data = {}
    return ConfigManager.Save()
end

function ConfigManager.GetPath()
    return placeFile()
end

return ConfigManager
