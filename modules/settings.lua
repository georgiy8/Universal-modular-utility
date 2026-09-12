return function(Window, meta)
    local Tab = Window:CreateTab({
        Name = "Settings",
        Icon = "⚙️",
        Order = (meta and meta.Order) or 100,
    })

    local s = Tab:CreateSection({ Name = "Config" })

    s:AddLabel({
        Text = "Profile: Gk_config / Autoload.json"
    })

    s:AddButton({
        Text = "Save Config",
        Callback = function()
            local CM = _G.ConfigManager
            if CM and CM.Save then
                if CM.Save() then
                    print("[Settings] Saved:", CM.GetPath and CM.GetPath())
                end
            else
                warn("[Settings] ConfigManager missing")
            end
        end
    })

    s:AddButton({
        Text = "Load Config",
        Callback = function()
            local CM = _G.ConfigManager
            if CM and CM.Load then
                if CM.Load() then
                    print("[Settings] Loaded")
                else
                    warn("[Settings] No config file")
                end
            end
        end
    })

    s:AddButton({
        Text = "Reset Config",
        Callback = function()
            local CM = _G.ConfigManager
            if CM and CM.Reset then
                CM.Reset()
                print("[Settings] Reset")
            end
        end
    })
end
