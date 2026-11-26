--========================================================--
-- Universal-modular-utility GUI Library
-- Asset Manager v2
--========================================================--

local AssetManager = {}

------------------------------------------------------------
-- Statistics
------------------------------------------------------------

AssetManager.Downloaded = 0
AssetManager.Verified = 0

AssetManager.ImagesIndexed = 0
AssetManager.SoundsIndexed = 0
AssetManager.OtherIndexed = 0

------------------------------------------------------------
-- Asset Database
------------------------------------------------------------

AssetManager.Images = {}
AssetManager.Sounds = {}

AssetManager.ByName = {}
AssetManager.ByPath = {}

AssetManager.Duplicates = {}

------------------------------------------------------------
-- Repository
------------------------------------------------------------

local USER = "georgiy8"
local REPO = "Universal-modular-utility"
local BRANCH = "main"

------------------------------------------------------------
-- Local workspace root
------------------------------------------------------------

local ROOT = "Universal-assets-by-gk"
local ASSETS_GITHUB = "Universal-assets-by-gk/Assets"
local ASSETS_LOCAL  = "Universal-assets-by-gk/Assets"

------------------------------------------------------------
-- Supported Extensions
------------------------------------------------------------

local IMAGE_EXTENSIONS = {

    png = true,
    jpg = true,
    jpeg = true,
    webp = true

}

local SOUND_EXTENSIONS = {

    mp3 = true,
    wav = true,
    ogg = true,
    m4a = true,
    flac = true

}

------------------------------------------------------------
-- Create assets folder
------------------------------------------------------------

function AssetManager:CreateFolder()

    local function ensure(path)
        if isfolder and not isfolder(path) then
            makefolder(path)
            print("[AssetManager] Created:", path)
        end
    end

    ensure(ROOT)
    ensure(ROOT .. "/Assets")
    ensure(ROOT .. "/Assets/Images")
    ensure(ROOT .. "/Assets/Sounds")
    ensure(ROOT .. "/Configs")
    ensure(ROOT .. "/Configs/Profiles")
    ensure(ROOT .. "/Themes")

end

------------------------------------------------------------
-- Download File
------------------------------------------------------------

function AssetManager:Download(URL, LocalPath)

    print("[AssetManager] Downloading:", LocalPath)

    local Success, Data = pcall(function()

        return game:HttpGet(URL)

    end)

    if not Success then

        warn("[AssetManager] Download failed:", LocalPath)

        return false

    end

    local Directory = LocalPath:match("(.*/)")

    if Directory and not isfolder(Directory) then

        makefolder(Directory)

    end

    local Saved = pcall(function()

        writefile(LocalPath, Data)

    end)

    if Saved then

        self.Downloaded += 1

        print("[AssetManager] Saved:", LocalPath)

        return true

    end

    warn("[AssetManager] Failed to save:", LocalPath)

    return false

end

------------------------------------------------------------
-- GitHub Recursive Scan
------------------------------------------------------------

function AssetManager:ScanFolder(GithubPath, LocalPath)

    local URL =
        "https://api.github.com/repos/"
        .. USER
        .. "/"
        .. REPO
        .. "/contents/"
        .. GithubPath
        .. "?ref="
        .. BRANCH

    local Success, Response = pcall(function()

        return game:HttpGet(URL)

    end)

    if not Success then

        warn("[AssetManager] Failed to scan:", GithubPath)

        return

    end

    local HttpService = game:GetService("HttpService")

    local Items = HttpService:JSONDecode(Response)

    for _, Item in ipairs(Items) do

        local GithubItem = GithubPath .. "/" .. Item.name
        local LocalItem = LocalPath .. "/" .. Item.name

        ----------------------------------------------------
        -- File
        ----------------------------------------------------

        if Item.type == "file" then

            if isfile(LocalItem) then

                self.Verified += 1

                print("[AssetManager] Verified:", LocalItem)

            else

                self:Download(Item.download_url, LocalItem)

            end

        ----------------------------------------------------
        -- Directory
        ----------------------------------------------------

        elseif Item.type == "dir" then

            print("[AssetManager] Entering:", GithubItem)

            self:ScanFolder(
                GithubItem,
                LocalItem
            )

        end

    end

end

------------------------------------------------------------
-- Local Recursive Scan
------------------------------------------------------------

function AssetManager:IndexFolder(Path)

    local Files = listfiles(Path)

    for _, File in ipairs(Files) do

        if isfolder(File) then

            self:IndexFolder(File)

        else

            self:RegisterAsset(File)

        end

    end

end

------------------------------------------------------------
-- Register Asset
------------------------------------------------------------

function AssetManager:RegisterAsset(File)

    local Extension = File:match("%.([^.]+)$")

    if not Extension then
        return
    end

    Extension = Extension:lower()

    --------------------------------------------------------
    -- AssetId
    --------------------------------------------------------

    local Success, Asset = pcall(function()

        return getcustomasset(File)

    end)

    if not Success or not Asset then

        warn("[AssetManager] Failed to register:", File)

        return

    end

    --------------------------------------------------------
    -- Name
    --------------------------------------------------------

    local Name = File:match("[^\\/]+$")

    --------------------------------------------------------
    -- Relative Path
    --------------------------------------------------------

    local Relative = File
        :gsub("\\","/")
        :gsub("^Universal%-assets%-by%-gk/Assets/","")

    --------------------------------------------------------
    -- Duplicate Check
    --------------------------------------------------------

    if self.ByName[Name] then

        warn("[AssetManager] Duplicate asset name:", Name)

        self.Duplicates[Name] = true

    end

    --------------------------------------------------------
    -- Global Index
    --------------------------------------------------------

    self.ByName[Name] = Asset

    self.ByPath[Relative] = Asset

    --------------------------------------------------------
    -- Images
    --------------------------------------------------------

    if IMAGE_EXTENSIONS[Extension] then

        self.Images[Name] = Asset

        self.ImagesIndexed += 1

        print("[Image]", Name)

        return

    end

    --------------------------------------------------------
    -- Sounds
    --------------------------------------------------------

    if SOUND_EXTENSIONS[Extension] then

        self.Sounds[Name] = Asset

        self.SoundsIndexed += 1

        print("[Sound]", Name)

        return

    end

    --------------------------------------------------------
    -- Other
    --------------------------------------------------------

    self.OtherIndexed += 1

    print("[Other]", Name)

end

------------------------------------------------------------
-- Get Asset By Relative Path
------------------------------------------------------------

function AssetManager:Get(Path)

    return self.ByPath[Path]

end

------------------------------------------------------------
-- Get Image
------------------------------------------------------------

function AssetManager:GetImage(Name)

    return self.Images[Name]

end

------------------------------------------------------------
-- Get Sound
------------------------------------------------------------

function AssetManager:GetSound(Name)

    return self.Sounds[Name]

end

------------------------------------------------------------
-- Get By Name
------------------------------------------------------------

function AssetManager:GetByName(Name)

    return self.ByName[Name]

end

------------------------------------------------------------
-- Exists
------------------------------------------------------------

function AssetManager:Exists(Path)

    return self.ByPath[Path] ~= nil
        or self.ByName[Path] ~= nil

end

------------------------------------------------------------
-- Get Info
------------------------------------------------------------

function AssetManager:GetInfo(Name)

    local Asset = self.ByName[Name]

    if not Asset then
        return nil
    end

    for Path, Id in pairs(self.ByPath) do

        if Id == Asset then

            local Extension = Path:match("%.([^.]+)$")

            return {

                Name = Name,

                Path = Path,

                Extension = Extension,

                AssetId = Id

            }

        end

    end

end

------------------------------------------------------------
-- List Images
------------------------------------------------------------

function AssetManager:ListImages()

    local Result = {}

    for Name, Id in pairs(self.Images) do

        table.insert(Result, {

            Name = Name,

            AssetId = Id

        })

    end

    table.sort(Result,function(a,b)

        return a.Name < b.Name

    end)

    return Result

end

------------------------------------------------------------
-- List Sounds
------------------------------------------------------------

function AssetManager:ListSounds()

    local Result = {}

    for Name, Id in pairs(self.Sounds) do

        table.insert(Result, {

            Name = Name,

            AssetId = Id

        })

    end

    table.sort(Result,function(a,b)

        return a.Name < b.Name

    end)

    return Result

end

------------------------------------------------------------
-- List All
------------------------------------------------------------

function AssetManager:List()

    local Result = {}

    for Path, Id in pairs(self.ByPath) do

        table.insert(Result,{

            Path = Path,

            AssetId = Id

        })

    end

    table.sort(Result,function(a,b)

        return a.Path < b.Path

    end)

    return Result

end

------------------------------------------------------------
-- Search
------------------------------------------------------------

function AssetManager:Search(Query)

    Query = Query:lower()

    local Result = {}

    for Name, Asset in pairs(self.ByName) do

        if Name:lower():find(Query,1,true) then

            table.insert(Result,{

                Name = Name,

                AssetId = Asset

            })

        end

    end

    table.sort(Result,function(a,b)

        return a.Name < b.Name

    end)

    return Result

end

------------------------------------------------------------
-- Reload
------------------------------------------------------------

function AssetManager:Reload()

    print("[AssetManager] Reloading...")

    self:Index()

end

------------------------------------------------------------
-- Print Statistics
------------------------------------------------------------

function AssetManager:PrintStatistics()

    print("----------------------------------------")
    print("[AssetManager] Asset Index")
    print("----------------------------------------")

    print("Verified   :", self.Verified)
    print("Downloaded :", self.Downloaded)

    print("Images     :", self.ImagesIndexed)
    print("Sounds     :", self.SoundsIndexed)
    print("Other      :", self.OtherIndexed)

    local DuplicateCount = 0

    for _ in pairs(self.Duplicates) do
        DuplicateCount += 1
    end

    print("Duplicates :", DuplicateCount)

    print("----------------------------------------")

end

------------------------------------------------------------
-- Init
------------------------------------------------------------

function AssetManager:Init()

    --------------------------------------------------------
    -- Reset Counters
    --------------------------------------------------------

    self.Downloaded = 0
    self.Verified = 0

    self.ImagesIndexed = 0
    self.SoundsIndexed = 0
    self.OtherIndexed = 0

    --------------------------------------------------------
    -- Clear Database
    --------------------------------------------------------

    table.clear(self.Images)
    table.clear(self.Sounds)

    table.clear(self.ByName)
    table.clear(self.ByPath)

    table.clear(self.Duplicates)

    --------------------------------------------------------
    -- Sync
    --------------------------------------------------------

    self:CreateFolder()

    print("[AssetManager] Synchronizing assets...")

    self:ScanFolder(
        ASSETS_GITHUB,
        ASSETS_LOCAL
    )

    --------------------------------------------------------
    -- Index
    --------------------------------------------------------

    print("[AssetManager] Building asset index...")

    self:IndexFolder(ASSETS_LOCAL)

    --------------------------------------------------------
    -- Done
    --------------------------------------------------------

    self:PrintStatistics()

end

------------------------------------------------------------
-- Media: Resolve(Source, Kind, Callback)
--
-- Превращает источник в ассет для Image и VideoPlayer. Kind = "image" | "video".
--   "rbxassetid://123", 123        - ассет Roblox, как есть
--   "folder/file.png"              - локальный файл executor (getcustomasset)
--   "https://.../file.mp4"         - ПРЯМАЯ ссылка на файл: скачивается в кэш
-- Callback(true, asset) или Callback(false, "текст ошибки"). Страницы сайтов
-- (YouTube и т.п.) не поддерживаются, нужна прямая ссылка на файл.
------------------------------------------------------------

local MEDIA_CACHE = ROOT .. "/Cache"

local MEDIA_MAX_BYTES = 150 * 1024 * 1024

-- что понимает Roblox
local MediaSUPPORTED = {
    image = { png = true, jpg = true },
    video = { mp4 = true, webm = true },
}

------------------------------------------------------------
-- helpers
------------------------------------------------------------

local function MediaTrim(Text)
    return (tostring(Text or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function MediaHash(Text)
    local H = 5381
    for Index = 1, #Text do
        H = (H * 33 + Text:byte(Index)) % 4294967296
    end
    return string.format("%08x", H) .. string.format("%x", #Text)
end

-- определяем формат по первым байтам, а не по расширению (у ссылок его часто нет)
local function MediaSniff(Body)

    local Head = Body:sub(1, 64)

    if Head:sub(1, 4) == "\137PNG" then
        return "png"
    elseif Head:sub(1, 3) == "\255\216\255" then
        return "jpg"
    elseif Head:sub(1, 4) == "GIF8" then
        return "gif"
    elseif Head:sub(1, 4) == "RIFF" and Head:sub(9, 12) == "WEBP" then
        return "webp"
    elseif Head:sub(1, 4) == "\26\69\223\163" then
        if Head:find("webm", 1, true) then
            return "webm"
        end
        return "mkv"
    elseif Head:sub(5, 8) == "ftyp" then
        local Brand = Head:sub(9, 12)
        if Brand == "qt  " then
            return "mov"
        end
        return "mp4"
    elseif Head:sub(1, 4) == "RIFF" and Head:sub(9, 12) == "AVI " then
        return "avi"
    elseif Head:sub(1, 5):lower() == "<!doc" or Head:sub(1, 5):lower() == "<html" then
        return "html"
    end

    return nil

end

local function MediaExtension(Path)
    return (tostring(Path):gsub("%?.*$", ""):match("%.(%w+)$") or ""):lower()
end

local function MediaRequest(Url)

    local Fn = (syn and syn.request) or http_request or request or (http and http.request)

    if Fn then
        local Ok, Response = pcall(Fn, { Url = Url, Method = "GET" })
        if Ok and type(Response) == "table" then
            local Code = Response.StatusCode or Response.Status
            if (Response.Success ~= false) and (Code == nil or (Code >= 200 and Code < 300)) then
                return Response.Body
            end
            return nil, "сервер ответил: " .. tostring(Code)
        end
    end

    local Ok, Body = pcall(function()
        return game:HttpGet(Url)
    end)

    if Ok then
        return Body
    end

    return nil, "не удалось скачать"

end

local function MediaEnsureFolders()
    if makefolder and isfolder then
        for _, Path in ipairs({ ROOT, MEDIA_CACHE }) do
            if not isfolder(Path) then
                pcall(makefolder, Path)
            end
        end
    end
end

local function MediaToAsset(Path)

    if not getcustomasset then
        return nil, "executor не поддерживает getcustomasset"
    end

    local Ok, Result = pcall(getcustomasset, Path)

    if Ok and Result and Result ~= "" then
        return Result
    end

    return nil, "не удалось открыть файл"

end

------------------------------------------------------------
-- Resolve
------------------------------------------------------------

local function MediaRun(Source, Kind, Callback)

    Source = MediaTrim(Source)

    if Source == "" then
        return Callback(true, "")
    end

    if Source:find("^rbxasset") or Source:find("^rbxthumb") then
        return Callback(true, Source)
    end

    if tonumber(Source) then
        return Callback(true, "rbxassetid://" .. Source)
    end

    local Allowed = MediaSUPPORTED[Kind] or MediaSUPPORTED.image

    ----------------------------------------------------
    -- ссылка
    ----------------------------------------------------

    if Source:find("^https?://") then

        if not (writefile and isfile and getcustomasset) then
            return Callback(false, "executor не умеет сохранять файлы (writefile/getcustomasset)")
        end

        MediaEnsureFolders()

        -- кэш: ищем уже скачанный файл
        local Base = MEDIA_CACHE .. "/" .. MediaHash(Source)

        for Ext in pairs(Allowed) do
            if isfile(Base .. "." .. Ext) then
                local Asset, Err = MediaToAsset(Base .. "." .. Ext)
                return Callback(Asset ~= nil, Asset or Err)
            end
        end

        local Body, Err = MediaRequest(Source)

        if not Body then
            return Callback(false, Err or "не удалось скачать")
        end

        if #Body > MEDIA_MAX_BYTES then
            return Callback(false, "файл больше 150 МБ")
        end

        local Format = MediaSniff(Body)

        if Format == "html" or not Format then
            return Callback(false, "по ссылке не файл. Нужна прямая ссылка на " .. (Kind == "video" and "mp4/webm" or "png/jpg"))
        end

        if not Allowed[Format] then
            return Callback(false, "формат " .. Format .. " Roblox не поддерживает (нужно " .. (Kind == "video" and "mp4/webm" or "png/jpg") .. ")")
        end

        local Path = Base .. "." .. Format

        local Ok = pcall(writefile, Path, Body)

        if not Ok then
            return Callback(false, "не удалось сохранить файл")
        end

        local Asset, AssetErr = MediaToAsset(Path)

        return Callback(Asset ~= nil, Asset or AssetErr)

    end

    ----------------------------------------------------
    -- локальный файл
    ----------------------------------------------------

    if isfile and isfile(Source) then

        local Ext = MediaExtension(Source)

        if Ext == "jpeg" then
            Ext = "jpg"
        end

        if not Allowed[Ext] then
            return Callback(false, "формат ." .. Ext .. " не поддерживается (нужно " .. (Kind == "video" and "mp4/webm" or "png/jpg") .. ")")
        end

        local Asset, Err = MediaToAsset(Source)

        return Callback(Asset ~= nil, Asset or Err)

    end

    ----------------------------------------------------
    -- уже готовая строка ассета (например от getcustomasset в модуле)
    ----------------------------------------------------

    return Callback(true, Source)

end

-- Асинхронно: скачивание не вешает интерфейс
function AssetManager:Resolve(Source, Kind, Callback)

    task.spawn(function()

        local Ok, Err = pcall(MediaRun, Source, Kind, function(Success, Result)
            pcall(Callback, Success, Result)
        end)

        if not Ok then
            pcall(Callback, false, tostring(Err))
        end

    end)

end

------------------------------------------------------------
-- Global
------------------------------------------------------------

_G.Assets = AssetManager

return AssetManager
