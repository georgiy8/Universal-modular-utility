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
