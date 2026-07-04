-- modules/main.lua

local Main = {}

function Main.Init(Core, Config)
    Core.CreateTab("Main", function()

        Core.CreateSection("📊 Local Player")

        local player = Config.Player

        Core.CreateSection("Name: " .. player.Name)

        local fpsLabel = Core.CreateSection("FPS: Calculating...")
        local pingLabel = Core.CreateSection("Ping: Calculating...")
        local timeLabel = Core.CreateSection("Time: Updating...")
        local speedLabel = Core.CreateSection(
            "WalkSpeed: " ..
            tostring(player.Character
                and player.Character:FindFirstChildOfClass("Humanoid")
                and player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed
                or 16)
        )

        task.spawn(function()
            while task.wait(1) do
                if not fpsLabel or not fpsLabel.Parent then
                    break
                end

                local fps = math.floor(1 / task.wait())

                local label = fpsLabel:FindFirstChildOfClass("TextLabel")
                if label then
                    label.Text = "FPS: " .. tostring(fps)
                end
            end
        end)

        task.spawn(function()
            while task.wait(1) do
                if not pingLabel or not pingLabel.Parent then
                    break
                end

                local ping = 0

                pcall(function()
                    ping = math.floor(
                        game:GetService("Stats")
                            .Network.ServerStatsItem["Data Ping"]
                            :GetValue()
                    )
                end)

                local label = pingLabel:FindFirstChildOfClass("TextLabel")
                if label then
                    label.Text = "Ping: " .. tostring(ping) .. " ms"
                end
            end
        end)

        task.spawn(function()
            while task.wait(1) do
                if not timeLabel or not timeLabel.Parent then
                    break
                end

                local currentTime = os.date("%H:%M:%S")

                local label = timeLabel:FindFirstChildOfClass("TextLabel")
                if label then
                    label.Text = "Time: " .. currentTime
                end
            end
        end)

        task.spawn(function()
            while task.wait(0.5) do
                if not speedLabel or not speedLabel.Parent then
                    break
                end

                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")

                local speed = humanoid and humanoid.WalkSpeed or 0

                local label = speedLabel:FindFirstChildOfClass("TextLabel")
                if label then
                    label.Text = "WalkSpeed: " .. tostring(speed)
                end
            end
        end)

        Core.CreateSection("⚙ Utility")

        Core.CreateButton("Rejoin Server", function()
            game:GetService("TeleportService"):Teleport(
                game.PlaceId,
                player
            )
        end)

        Core.CreateButton("Reset Character", function()
            if player.Character then
                player.Character:BreakJoints()
            end
        end)

        Core.CreateButton("Copy JobId", function()
            if setclipboard then
                setclipboard(game.JobId)
            end
        end)

    end)
end

return Main
