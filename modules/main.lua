--========================================================--
-- Main Module
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer

return function(Window, meta)

    --------------------------------------------------------
    -- Tab
    --------------------------------------------------------

    local Main = Window:CreateTab({
        Name = "Main",
        Icon = "🏠",
        Order = (meta and meta.Order) or 10,
    })

    --------------------------------------------------------
    -- Information
    --------------------------------------------------------

    local Info = Main:CreateSection({

        Name = "Information"

    })

    local PlayerLabel = Info:AddLabel({

        Text = "👤 Player: " .. Player.Name

    })

    local FPSLabel = Info:AddLabel({

        Text = "📊 FPS: Calculating..."

    })

    local PingLabel = Info:AddLabel({

        Text = "📡 Ping: Calculating..."

    })

    local TimeLabel = Info:AddLabel({

        Text = "⏰ Time: " .. os.date("%H:%M:%S")

    })

    --------------------------------------------------------
    -- Walk Speed
    --------------------------------------------------------

    local Movement = Main:CreateSection({

        Name = "Movement"

    })

    Movement:AddSlider({

        Text = "Walk Speed",

        Min = 16,

        Max = 100,

        Default = 16,

        Increment = 4,

        Callback = function(Value)

            local Character = Player.Character

            if Character then

                local Humanoid = Character:FindFirstChild("Humanoid")

                if Humanoid then

                    Humanoid.WalkSpeed = Value
                end

            end

        end

    })

    --------------------------------------------------------
    -- FPS Counter
    --------------------------------------------------------

    local LastTime = tick()

    local Frames = 0

    RunService.Heartbeat:Connect(function()

        Frames += 1

        local Current = tick()

        if Current - LastTime >= 1 then

            local FPS = math.floor(

                Frames /

                (Current - LastTime)

            )

            FPSLabel:SetText(

                "📊 FPS: " .. FPS

            )

            Frames = 0

            LastTime = Current

        end

        TimeLabel:SetText(

            "⏰ Time: " ..

            os.date("%H:%M:%S")

        )

    end)

    --------------------------------------------------------
    -- Ping
    --------------------------------------------------------

    task.spawn(function()

        while task.wait(2) do

            local Ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()

            PingLabel:SetText(

                "📡 Ping: " .. Ping

            )

        end

    end)

end
