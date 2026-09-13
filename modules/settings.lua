return function(Window, meta)

    local CM = _G.ConfigManager
    if not CM then
        warn("[Settings] ConfigManager missing")
    end

    local Tab = Window:CreateTab({
        Name = "Settings",
        Icon = "⚙️",
        Order = (meta and meta.Order) or 100,
    })

    ------------------------------------------------------------
    -- Profiles
    ------------------------------------------------------------

    local Profiles = Tab:CreateSection({ Name = "Profiles" })

    local selectedName = (CM and CM.GetCurrentName and CM.GetCurrentName()) or ""

    Profiles:AddLabel({
        Text = "PlaceId: " .. tostring(game.PlaceId)
    })

    local statusLabel = Profiles:AddLabel({
        Text = "Current: " .. (selectedName ~= "" and selectedName or "(none)")
    })

    Profiles:AddTextbox({
        Text = "Name",
        Placeholder = "my_config",
        Default = selectedName,
        Callback = function(text)
            selectedName = text or ""
        end
    })

    local function refreshStatus()
        local cur = CM and CM.GetCurrentName and CM.GetCurrentName()
        if cur and cur ~= "" then
            statusLabel:SetText("Current: " .. cur)
        elseif selectedName ~= "" then
            statusLabel:SetText("Current: " .. selectedName)
        else
            statusLabel:SetText("Current: (none)")
        end
    end

    local profileDropdown

    local function refreshDropdown()
        if not CM or not profileDropdown then
            return
        end
        local list = CM.ListProfiles()
        if #list == 0 then
            list = { "(empty)" }
        end
        if profileDropdown.SetValues then
            profileDropdown:SetValues(list)
        end
    end

    profileDropdown = Profiles:AddDropdown({
        Text = "Saved",
        Options = (CM and CM.ListProfiles and CM.ListProfiles()) or { "(empty)" },
        Callback = function(value)
            if value and value ~= "(empty)" then
                selectedName = value
            end
        end
    })

    Profiles:AddButton({
        Text = "Refresh List",
        Callback = function()
            refreshDropdown()
            print("[Settings] Profile list refreshed")
        end
    })

    Profiles:AddButton({
        Text = "Save / Overwrite",
        Callback = function()
            if not CM then
                return
            end
            if CM.Save(selectedName) then
                refreshStatus()
                refreshDropdown()
                print("[Settings] Saved:", selectedName)
            end
        end
    })

    Profiles:AddButton({
        Text = "Load",
        Callback = function()
            if not CM then
                return
            end
            if CM.Load(selectedName) then
                refreshStatus()
                print("[Settings] Loaded:", selectedName)
            end
        end
    })

    Profiles:AddButton({
        Text = "Delete",
        Callback = function()
            if not CM then
                return
            end
            if CM.Delete(selectedName) then
                selectedName = ""
                refreshStatus()
                refreshDropdown()
            end
        end
    })

    ------------------------------------------------------------
    -- Autoload (this place)
    ------------------------------------------------------------

    local Auto = Tab:CreateSection({ Name = "Autoload" })

    local autoEnabled = false
    local autoName = selectedName

    if CM and CM.GetAutoload then
        local en, name = CM.GetAutoload(game.PlaceId)
        autoEnabled = en
        autoName = name or selectedName
    end

    Auto:AddLabel({
        Text = "Path: Universal-assets-by-gk/Configs/Autoload.json"
    })

    Auto:AddToggle({
        Text = "Autoload on this place",
        Default = autoEnabled,
        Callback = function(value)
            autoEnabled = value
        end
    })

    Auto:AddTextbox({
        Text = "Autoload config name",
        Placeholder = "profile name",
        Default = autoName or "",
        Callback = function(text)
            autoName = text or ""
        end
    })

    Auto:AddButton({
        Text = "Apply Autoload Setting",
        Callback = function()
            if not CM then
                return
            end
            local name = autoName
            if name == "" then
                name = selectedName
            end
            if CM.SetAutoload(autoEnabled, name) then
                print("[Settings] Autoload:", autoEnabled, name, game.PlaceId)
            end
        end
    })

    Auto:AddButton({
        Text = "Run Autoload Now",
        Callback = function()
            if not CM then
                return
            end
            if CM.TryAutoload() then
                selectedName = CM.GetCurrentName() or selectedName
                refreshStatus()
                print("[Settings] Autoload OK")
            else
                warn("[Settings] Autoload skipped or failed")
            end
        end
    })

    if CM and CM.TryAutoload then
        task.defer(function()
            if CM.TryAutoload() then
                selectedName = CM.GetCurrentName() or selectedName
                refreshStatus()
            end
        end)
    end

end
