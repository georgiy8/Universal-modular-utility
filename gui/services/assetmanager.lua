Грок смог починить --========================================================--
-- Pilgrammed GUI Library
-- Asset Manager (Recursive with Counter)
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
    if Dir and not isfolder(Dir) then
        makefolder(Dir)
    end
    
    local WriteSuccess = pcall(function()
        writefile(LocalPath, Data)
    end)
    
    if WriteSuccess then
        self.Downloaded = self.Downloaded + 1
        print("[AssetManager] Saved:", LocalPath)
        return true
    else
        warn("[AssetManager] Failed to save:", LocalPath)
        return false
    end
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
            if isfile(NewLocalPath) then
                self.Verified = self.Verified + 1
                print("[AssetManager] Verified:", NewLocalPath)
            else
                self:Download(item.download_url, NewLocalPath)
            end
        elseif item.type == "dir" then
            print("[AssetManager] Entering folder:", item.name)
            self:ScanFolder(NewGithubPath, NewLocalPath)
        end
    end
end

------------------------------------------------------------
-- Init
------------------------------------------------------------
function AssetManager:Init()
    self.Downloaded = 0
    self.Verified = 0
    self:CreateFolder()
    print("[AssetManager] Starting recursive download from assets/...")
    self:ScanFolder("assets", "assets")
    print(string.format(
        "[AssetManager] Finished. Verified: %d | Downloaded: %d",
        self.Verified,
        self.Downloaded
    ))
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
