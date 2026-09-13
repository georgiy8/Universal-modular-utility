--========================================================--
-- Main Module
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer

local function trySetClipboard(text)
    if typeof(setclipboard) == "function" then
        return pcall(setclipboard, tostring(text))
    end
    if typeof(toclipboard) == "function" then
        return pcall(toclipboard, tostring(text))
    end
    return false
end

return function(Window, meta)

    local Main = Window:CreateTab({
        Name = "Main",
        Icon = "🏠",
        Order = (meta and meta.Order) or 10,
    })

    ------------------------------------------------------------
    -- Session / Place info
    ------------------------------------------------------------

    local Info = Main:CreateSection({
        Name = "Session"
    })

    Info:AddLabel({
        Text = "Player: " .. Player.Name
    })

    Info:AddLabel({
        Text = "Place: " .. tostring(game.Name)
    })

    -- Textbox = можно выделить и скопировать вручную
    Info:AddTextbox({
        Text = "PlaceId",
        Default = tostring(game.PlaceId),
        Placeholder = "PlaceId",
        Callback = function() end
    })

    Info:AddTextbox({
        Text = "JobId",
        Default = tostring(game.JobId),
        Placeholder = "JobId",
        Callback = function() end
    })

    Info:AddButton({
        Text = "Copy PlaceId",
        Callback = function()
            if trySetClipboard(game.PlaceId) then
                print("[Main] PlaceId copied:", game.PlaceId)
            else
                warn("[Main] clipboard unavailable")
            end
        end
    })

    Info:AddButton({
        Text = "Copy JobId",
        Callback = function()
            if trySetClipboard(game.JobId) then
                print("[Main] JobId copied:", game.JobId)
            else
                warn("[Main] clipboard unavailable")
            end
        end
    })

    ------------------------------------------------------------
    -- Performance
    ------------------------------------------------------------

    local Perf = Main:CreateSection({
        Name = "Performance"
    })

    local FPSLabel = Perf:AddLabel({
        Text = "FPS: ..."
    })

    local PingLabel = Perf:AddLabel({
        Text = "Ping: ..."
    })

    local TimeLabel = Perf:AddLabel({
        Text = "Time: " .. os.date("%H:%M:%S")
    })

    local LastTime = tick()
    local Frames = 0

    RunService.Heartbeat:Connect(function()
        Frames += 1
        local now = tick()
        if now - LastTime >= 1 then
            local fps = math.floor(Frames / (now - LastTime))
            FPSLabel:SetText("FPS: " .. fps)
            Frames = 0
            LastTime = now
        end
        TimeLabel:SetText("Time: " .. os.date("%H:%M:%S"))
    end)

    task.spawn(function()
        while task.wait(2) do
            local ok, ping = pcall(function()
                return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
            end)
            if ok and ping then
                PingLabel:SetText("Ping: " .. ping)
            end
        end
    end)

end
