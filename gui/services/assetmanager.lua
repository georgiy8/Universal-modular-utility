--========================================================--
-- Pilgrammed GUI Library
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
local REPO = "Pilgrammed-modular-utility"
local BRANCH = "main"

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

    if not isfolder("assets") then

        makefolder("assets")

        print("[AssetManager] Created assets folder.")

    end

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
        :gsub("^assets/","")

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
        "assets",
        "assets"
    )

    --------------------------------------------------------
    -- Index
    --------------------------------------------------------

    print("[AssetManager] Building asset index...")

    self:IndexFolder("assets")

    --------------------------------------------------------
    -- Done
    --------------------------------------------------------

    self:PrintStatistics()

end

------------------------------------------------------------
-- Global
------------------------------------------------------------

_G.Assets = AssetManager

return AssetManager
