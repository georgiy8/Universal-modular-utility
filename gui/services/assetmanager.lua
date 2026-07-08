--========================================================--
-- Pilgrammed GUI Library
-- Asset Manager (Recursive from assets/)
--========================================================--

local AssetManager = {}

AssetManager.Downloaded = 0
AssetManager.Verified = 0

------------------------------------------------------------
-- Repository
------------------------------------------------------------
local USER = "georgiy8"
local REPO_NAME = "Pilgrammed-modular-utility"
local BRANCH = "main"

------------------------------------------------------------
-- Create Folder
------------------------------------------------------------
function AssetManager:CreateFolder()
    if not isfolder("assets") then
        makefolder("assets")
        print("[AssetManager] Created assets folder.")
    end
end

------------------------------------------------------------
-- Download
------------------------------------------------------------
function AssetManager:Download(Url, LocalPath)
    print("[AssetManager] Downloading:", LocalPath)
    local Success, Data = pcall(function()
        return game:HttpGet(Url)
    end)
    if not Success then
        warn("[AssetManager] Download failed:", LocalPath)
        return false
    end
    local Dir = LocalPath:match("(.*/)")
    if Dir then makefolder(Dir) end
    local WriteSuccess = pcall(function()
        writefile(LocalPath, Data)
            if isfile(LocalPath) then
    print("[AssetManager] Saved:", LocalPath)
else
    warn("[AssetManager] Failed:", LocalPath)
end
    end)
    if WriteSuccess then
          self.Downloaded += 1
        print("[AssetManager] Saved:", LocalPath)
        return true
    end
    return false
end

------------------------------------------------------------
-- Recursive Scan
------------------------------------------------------------
function AssetManager:ScanFolder(GithubPath, LocalPath)
    local Url = "https://api.github.com/repos/" .. USER .. "/" .. REPO_NAME .. "/contents/" .. GithubPath .. "?ref=" .. BRANCH
    
    local Success, Response = pcall(function()
        return game:HttpGet(Url)
    end)
    
    if not Success then
        warn("[AssetManager] Failed to scan:", GithubPath)
        return
    end
    
    local Items = game:GetService("HttpService"):JSONDecode(Response)
    
    for _, item in ipairs(Items) do
        local NewGithubPath = GithubPath .. "/" .. item.name
        local NewLocalPath = LocalPath .. "/" .. item.name
        
  if item.type == "file" then
    if not isfile(NewLocalPath) then
        self:Download(item.download_url, NewLocalPath)

    else
                self.Verified += 1

        print("[AssetManager] Verified:", NewLocalPath)

    end

elseif item.type == "dir" then
    print("[AssetManager] Entering folder:", item.name)
    self:ScanFolder(NewGithubPath, NewLocalPath)

end

------------------------------------------------------------
-- Init
------------------------------------------------------------
function AssetManager:Init()
    self:CreateFolder()
    print("[AssetManager] Starting recursive download from assets/...")
    self:ScanFolder("assets", "assets")
    print("[AssetManager] All assets verified and downloaded.")
end

------------------------------------------------------------
-- Get Asset
------------------------------------------------------------
function AssetManager:Get(RelativePath)
    local LocalPath = "assets/" .. RelativePath
    if isfile(LocalPath) then
        return getcustomasset(LocalPath)
    end
    return nil
end

------------------------------------------------------------
return AssetManager
