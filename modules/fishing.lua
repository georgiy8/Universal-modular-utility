-- modules/fishing.lua

local Fishing = {}

function Fishing.Init(Core, Config)

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer

    local autoFishing = false
    local autoRodEnabled = false

    local selectedRod = nil
    local fishCount = 0
    local currentDelay = 0.03

    local rodList = {}

    local function click()
        if mouse1press and mouse1release then
            mouse1press()
            task.wait(currentDelay)
            mouse1release()
        end
    end

    local function findFishingRods()

        table.clear(rodList)

        local function scan(container)

            if not container then
                return
            end

            for _, obj in ipairs(container:GetChildren()) do

                if obj:IsA("Tool") then

                    local name = obj.Name:lower()

                    if name:find("rod")
                    or name:find("fishing")
                    or name:find("pole")
                    then
                        table.insert(rodList, obj)
                    end
                end
            end
        end

        scan(player.Backpack)

        if player.Character then
            scan(player.Character)
        end
    end

    local function equipRod(tool)

        if not tool then
            return false
        end

        local character = player.Character
        if not character then
            return false
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return false
        end

        if tool.Parent == player.Backpack then
            humanoid:EquipTool(tool)
            return true
        end

        if tool.Parent == character then
            return true
        end

        return false
    end

    local function isRodEquipped()

        local character = player.Character
        if not character then
            return false
        end

        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then

                local name = tool.Name:lower()

                if name:find("rod")
                or name:find("fishing")
                or name:find("pole")
                then
                    return true
                end
            end
        end

        return false
    end

    Core.CreateTab("Fishing", function()

        Core.CreateSection("🎣 Auto Fishing")

        local statusFrame =
            Core.CreateSection("Status: 🔴 Disabled")

        local biteFrame =
            Core.CreateSection("Bite: ⚪ None")

        local fishFrame =
            Core.CreateSection("Fish Caught: 0")

        local rodFrame =
            Core.CreateSection("Rod: Not Selected")

        local function setText(section, text)
            local lbl = section:FindFirstChildOfClass("TextLabel")
            if lbl then
                lbl.Text = text
            end
        end

        Core.CreateToggle(
            "Auto Fishing",
            false,
            function(state)

                autoFishing = state

                setText(
                    statusFrame,
                    state and
                    "Status: 🟢 Running" or
                    "Status: 🔴 Disabled"
                )
            end
        )

        Core.CreateToggle(
            "Auto Rod",
            false,
            function(state)

                autoRodEnabled = state

                if state and selectedRod then
                    equipRod(selectedRod)
                end
            end
        )

        Core.CreateButton("Refresh Rod List", function()

            findFishingRods()

            if #rodList > 0 then

                selectedRod = rodList[1]

                setText(
                    rodFrame,
                    "Rod: " .. selectedRod.Name
                )

            else

                setText(
                    rodFrame,
                    "Rod: Not Found"
                )
            end
        end)

        Core.CreateButton("Increase Delay", function()

            currentDelay += 0.02

            if currentDelay > 0.10 then
                currentDelay = 0.03
            end
        end)

        task.spawn(function()

            while task.wait(0.5) do

                if not autoFishing then
                    continue
                end

                if not isRodEquipped() then

                    setText(
                        statusFrame,
                        "⚠ Rod Not Equipped"
                    )

                    if autoRodEnabled and selectedRod then
                        equipRod(selectedRod)
                    end

                    task.wait(2)
                    continue
                end

                setText(
                    statusFrame,
                    "Status: 🟢 Running"
                )

                click()

                local bobber = nil

                local timeout = 5
                local elapsed = 0

                repeat

                    bobber = workspace:FindFirstChild("Bobber")

                    task.wait(0.1)

                    elapsed += 0.1

                until bobber or elapsed >= timeout

                if not bobber then

                    setText(
                        statusFrame,
                        "⚠ Bobber Not Found"
                    )

                    click()

                    continue
                end

                local lastCenter =
                    bobber.AssemblyCenterOfMass

                local noMoveTime = 0

                local connection

                connection =
                    RunService.Heartbeat:Connect(function(dt)

                    if not bobber
                    or not bobber.Parent then
                        return
                    end

                    local center =
                        bobber.AssemblyCenterOfMass

                    local delta =
                        (center - lastCenter).Magnitude

                    if delta > 0.01 then

                        setText(
                            biteFrame,
                            "Bite: ⚡ Detected"
                        )

                        click()

                        fishCount += 1

                        setText(
                            fishFrame,
                            "Fish Caught: " .. fishCount
                        )

                        noMoveTime = 0

                    else

                        setText(
                            biteFrame,
                            "Bite: ⚪ None"
                        )

                        noMoveTime += dt
                    end

                    if noMoveTime >= 10 then
                        click()
                        noMoveTime = 0
                    end

                    lastCenter = center
                end)

                repeat
                    task.wait(0.2)
                until not bobber.Parent

                if connection then
                    connection:Disconnect()
                end
            end
        end)

        task.wait(0.5)
        findFishingRods()

        if #rodList > 0 then
            selectedRod = rodList[1]

            setText(
                rodFrame,
                "Rod: " .. selectedRod.Name
            )
        end

        player.CharacterAdded:Connect(function()

            task.wait(0.5)

            if autoRodEnabled and selectedRod then
                equipRod(selectedRod)
            end
        end)
    end)
end

return Fishing
