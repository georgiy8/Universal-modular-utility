--========================================================--
-- Pilgrammed Asset Manager
--========================================================--

local AssetManager = {}

------------------------------------------------------------
-- Repository
------------------------------------------------------------

local REPO = "https://raw.githubusercontent.com/georgiy8/Pilgrammed-modular-utility/main/assets/"

------------------------------------------------------------
-- Assets
------------------------------------------------------------

AssetManager.Files = {

    "phantom.png",

    "click.wav",

}

------------------------------------------------------------
-- Create Folder
------------------------------------------------------------

function AssetManager:CreateFolder()

    if not isfolder("assets") then

        makefolder("assets")

    end

end

------------------------------------------------------------
-- Download Asset
------------------------------------------------------------

function AssetManager:Download(File)

    local Url = REPO .. File

    local Path = "assets/" .. File

    print("[Assets] Downloading:", File)

    local Success, Data = pcall(function()

        return game:HttpGet(Url)

    end)

    if not Success then

        warn("[Assets] Failed to download:", File)

        return false

    end

    writefile(Path, Data)

    return true

end

------------------------------------------------------------
-- Check Assets
------------------------------------------------------------

function AssetManager:Check()

    self:CreateFolder()

    for _, File in ipairs(self.Files) do

        local Path = "assets/" .. File

        if not isfile(Path) then

            self:Download(File)

        else

            print("[Assets] Found:", File)

        end

    end

end

------------------------------------------------------------
-- Get Asset
------------------------------------------------------------

function AssetManager:Get(File)

    local Path = "assets/" .. File

    if not isfile(Path) then

        self:Download(File)

    end

    return getcustomasset(Path)

end

------------------------------------------------------------
-- Init
------------------------------------------------------------

function AssetManager:Init()

    self:Check()

    print("[Assets] Ready.")

end

------------------------------------------------------------

return AssetManager
