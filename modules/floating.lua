-- modules/floating.lua

local Floating = {}

function Floating.Init(Core, Config)

    local player = Config.Player

    Core.CreateTab("Floating", function()

        Core.CreateSection("🎈 Object Explorer")

        local selectedPart = nil
        local selecting = false
        local highlight = nil

        local respawnEnabled = false
        local respawnPosition = nil

        local mouse = player:GetMouse()

        local statusFrame = Core.CreateSection("⛔ No Object Selected")
        local statusLabel = statusFrame:FindFirstChildOfClass("TextLabel")

        local function setStatus(text)
            if statusLabel then
                statusLabel.Text = text
            end
        end

        Core.CreateButton("🔍 Select Object", function()

            selecting = true
            selectedPart = nil

            setStatus("🟡 Waiting for click...")

            if highlight then
                highlight:Destroy()
                highlight = nil
            end
        end)

        mouse.Button1Down:Connect(function()

            if not selecting then
                return
            end

            local target = mouse.Target

            if target and target:IsA("BasePart") then

                selecting = false
                selectedPart = target

                setStatus("🟠 Selected: " .. target.Name)

                if highlight then
                    highlight:Destroy()
                end

                highlight = Instance.new("Highlight")
                highlight.Adornee = target
                highlight.FillColor = Color3.fromRGB(255,255,0)
                highlight.OutlineColor = Color3.fromRGB(255,0,0)
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = target
            end
        end)

        Core.CreateButton("⚓ Anchor Selected Object", function()

            if not selectedPart then
                return
            end

            selectedPart.Anchored = true

            setStatus("🟢 Anchored: " .. selectedPart.Name)
        end)

        Core.CreateButton("📦 Teleport Object To Me", function()

            if not selectedPart then
                return
            end

            local character = player.Character
            if not character then
                return
            end

            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then
                return
            end

            selectedPart.CFrame =
                root.CFrame * CFrame.new(0, -3, 0)

            setStatus("📦 Object moved under player")
        end)

        Core.CreateButton("🚶 Teleport To Object", function()

            if not selectedPart then
                return
            end

            local character = player.Character
            if not character then
                return
            end

            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then
                return
            end

            root.CFrame =
                selectedPart.CFrame + Vector3.new(0,5,0)

            setStatus("🚶 Teleported to object")
        end)

        Core.CreateToggle(
            "Respawn On Selected Object",
            false,
            function(state)

                respawnEnabled = state

                if state and selectedPart then

                    respawnPosition =
                        selectedPart.CFrame + Vector3.new(0,5,0)

                    setStatus("🟢 Respawn Enabled")
                else
                    setStatus("🔴 Respawn Disabled")
                end
            end
        )

        player.CharacterAdded:Connect(function(character)

            if not respawnEnabled then
                return
            end

            if not respawnPosition then
                return
            end

            local root =
                character:WaitForChild("HumanoidRootPart")

            task.wait(0.5)

            root.CFrame = respawnPosition
        end)

    end)
end

return Floating
