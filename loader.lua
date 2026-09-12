--========================================================--
-- Universal Modular Utility
-- Loader v1.0
--========================================================--

local REPO = "https://raw.githubusercontent.com/georgiy8/Universal-modular-utility/main/"

-- Простая система импорта файлов из GitHub
local function Import(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(REPO .. path))()
    end)

    if not success then
        warn("[Loader] Failed to load: " .. path)
        warn(result)
        return nil
    end

    return result
end

-- Загружаем GUI
local GUI = Import("gui/init.lua")

if not GUI then
    error("[Loader] Failed to initialize GUI.")
end

-- Создаём окно
local Window = GUI:CreateWindow({
    Title = "Pilgrammed Utility",
    Width = 500,
    Height = 400
})

-- Загружаем игровые модули
------------------------------------------------------------
-- Base modules (always)
------------------------------------------------------------

local BaseModules = {
    { Name = "main", Order = 10 },
    { Name = "Console", Order = 90 },
    { Name = "settings", Order = 100 },
}

------------------------------------------------------------
-- Places (optional external repo modules)
------------------------------------------------------------

local Places = Import("places.lua") or {}

local function normalize(entry, fallbackOrder)
    if type(entry) == "string" then
        return { Name = entry, Order = fallbackOrder or 50 }
    end
    return {
        Name = entry.Name,
        Order = entry.Order or fallbackOrder or 50,
        Repo = entry.Repo,
    }
end

local seen = {}
local queue = {}

local function enqueue(list, defaultRepo)
    if not list then
        return
    end
    for _, raw in ipairs(list) do
        local mod = normalize(raw, 50)
        mod.Repo = mod.Repo or defaultRepo
        if mod.Name and not seen[mod.Name] then
            seen[mod.Name] = true
            table.insert(queue, mod)
        end
    end
end

enqueue(BaseModules, REPO)

local place = Places[game.PlaceId]
if place then
    local placeRepo = place.Repo or REPO
    enqueue(place.Modules, placeRepo)
    print("[Loader] Place matched:", game.PlaceId)
else
    print("[Loader] No place config for", game.PlaceId, "- base only")
end

table.sort(queue, function(a, b)
    if a.Order == b.Order then
        return tostring(a.Name) < tostring(b.Name)
    end
    return a.Order < b.Order
end)

local function ImportFrom(repo, path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(repo .. path))()
    end)
    if not success then
        warn("[Loader] Failed:", repo .. path)
        warn(result)
        return nil
    end
    return result
end

for _, mod in ipairs(queue) do
    local repo = mod.Repo or REPO
    local module = ImportFrom(repo, "modules/" .. mod.Name .. ".lua")
    if type(module) == "function" then
        local ok, err = pcall(module, Window, mod)
        if not ok then
            warn("[Module Error]", mod.Name, err)
        end
    else
        warn("[Loader] Module invalid:", mod.Name)
    end
end

------------------------------------------------------------
-- Config autoload: Gk_config/Autoload.json
------------------------------------------------------------

local HttpService = game:GetService("HttpService")
local ConfigManager = Import("gui/services/config-manager.lua")

if ConfigManager then
    _G.ConfigManager = ConfigManager

    local autoloadProfile = "Universal"
    local shouldLoad = false

    if isfile and isfile("Gk_config/Autoload.json") then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile("Gk_config/Autoload.json"))
        end)
        if ok and type(data) == "table" then
            autoloadProfile = data.profile or autoloadProfile
            if data.enabled then
                local placeKey = tostring(game.PlaceId)
                if data.places and data.places[placeKey] ~= nil then
                    shouldLoad = data.places[placeKey] == true
                else
                    shouldLoad = true
                end
            end
        end
    end

    if ConfigManager.Init then
        ConfigManager.Init({ Name = autoloadProfile })
    end

    if shouldLoad and ConfigManager.Load then
        ConfigManager.Load()
        print("[Loader] Config autoload:", autoloadProfile, game.PlaceId)
    end
end

print("[Pilgrammed Utility] Loaded successfully.")

