local Mining = {}

function Mining.Init(Core, Config)

    local player = Config.Player

    local oreESPEnabled = false
    local oreHighlights = {}

    local selectedOres = {}

    local oreColors = {
        Copper  = Color3.fromRGB(184,115,51),
        Tin     = Color3.fromRGB(180,180,180),
        Iron    = Color3.fromRGB(200,200,200),
        Zinc    = Color3.fromRGB(220,220,230),
        Silver  = Color3.fromRGB(192,192,192),
        Brass   = Color3.fromRGB(181,166,66),
        Bronze  = Color3.fromRGB(205,127,50),
        Demetal = Color3.fromRGB(150,50,50),
        Mithril = Color3.fromRGB(100,200,255),
        Emerald = Color3.fromRGB(0,255,0),
        Diamond = Color3.fromRGB(0,200,255),
        Sapphire= Color3.fromRGB(0,100,255),
        Ruby    = Color3.fromRGB(255,0,0),
        Sulfur  = Color3.fromRGB(255,255,0),
    }

    for oreName in pairs(oreColors) do
        selectedOres[oreName] = true
    end

    local function getOreName(obj)

        local base = obj:FindFirstChild("Base")

        if base then
            local part = base:FindFirstChild("Part")

            if part and part.Name then
                return part.Name
            end
        end

        for _, child in ipairs(obj:GetDescendants()) do

            if child:IsA("BasePart")
            and child.Name ~= "Base"
            and child.Name ~= "Part"
            then

                for oreName in pairs(oreColors) do

                    if string.find(child.Name, oreName) then
                        return oreName
                    end
                end
            end
        end

        return nil
    end

    local function createOreESP(ore)

        local oreName = getOreName(ore)

        if not oreName then
            return
        end

        if not selectedOres[oreName] then
            return
        end

        local color =
            oreColors[oreName]
            or Color3.fromRGB(255,255,255)

        local mainPart =
            ore:FindFirstChildWhichIsA("BasePart", true)

        if not mainPart then
            return
        end

        local highlight = Instance.new("Highlight")
        highlight.Parent = ore
        highlight.Adornee = ore
        highlight.FillColor = color
        highlight.OutlineColor = color
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode =
            Enum.HighlightDepthMode.AlwaysOnTop

        local billboard = Instance.new("BillboardGui")
        billboard.Parent = mainPart
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0,100,0,40)
        billboard.StudsOffset = Vector3.new(0,2,0)
        billboard.AlwaysOnTop = true

        local text = Instance.new("TextLabel")
        text.Parent = billboard
        text.Size = UDim2.fromScale(1,1)
        text.BackgroundTransparency = 1
        text.Text = oreName
        text.TextColor3 = color
        text.TextStrokeTransparency = 0.5
        text.Font = Enum.Font.GothamBold
        text.TextSize = 14

        table.insert(oreHighlights,{
            Highlight = highlight,
            Billboard = billboard
        })
    end

    local function clearOreESP()

        for _, data in ipairs(oreHighlights) do

            if data.Highlight then
                data.Highlight:Destroy()
            end

            if data.Billboard then
                data.Billboard:Destroy()
            end
        end

        table.clear(oreHighlights)
    end

    local function updateOreESP()

        clearOreESP()

        if not oreESPEnabled then
            return
        end

        local oresFolder =
            workspace:FindFirstChild("Ores")
            or workspace:FindFirstChild("ores")

        if not oresFolder then
            return
        end

        for _, ore in ipairs(oresFolder:GetChildren()) do

            if ore:IsA("Model")
            or ore:IsA("Folder")
            then
                createOreESP(ore)
            end
        end
    end

    Core.CreateTab("Mining", function()

        Core.CreateSection("⛏ Mining & Visuals")

        Core.CreateToggle(
            "Ore ESP",
            false,
            function(state)

                oreESPEnabled = state
                updateOreESP()

                if not state then
                    clearOreESP()
                end
            end
        )

        Core.CreateSection("Selected Ores")

        for oreName in pairs(oreColors) do

            Core.CreateToggle(
                oreName,
                true,
                function(state)

                    selectedOres[oreName] = state

                    if oreESPEnabled then
                        updateOreESP()
                    end
                end
            )
        end

        task.spawn(function()

            while task.wait(5) do

                if oreESPEnabled then
                    updateOreESP()
                end
            end
        end)
    end)

    Mining.Shared = {
        SelectedOres = selectedOres,
        OreColors = oreColors,
        GetOreName = getOreName
    }
end

    local autoMining = false
    local autoTool = false

    local miningMode = "Teleport"

    local selectedTool = nil
    local availableTools = {}

    local function findMiningTools()

        table.clear(availableTools)

        local function scan(container)

            if not container then
                return
            end

            for _, obj in ipairs(container:GetChildren()) do

                if obj:IsA("Tool") then

                    local lower = obj.Name:lower()

                    if lower:find("pick")
                    or lower:find("hammer")
                    or lower:find("drill")
                    or lower:find("axe")
                    then
                        table.insert(availableTools, obj)
                    end
                end
            end
        end

        scan(player.Backpack)

        if player.Character then
            scan(player.Character)
        end
    end

    local function equipTool(tool)

        if not tool then
            return false
        end

        local character = player.Character
        if not character then
            return false
        end

        local humanoid =
            character:FindFirstChildOfClass("Humanoid")

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

    local function activateTool()

        local character = player.Character
        if not character then
            return
        end

        for _, tool in ipairs(character:GetChildren()) do

            if tool:IsA("Tool") then

                pcall(function()
                    tool:Activate()
                end)

                return
            end
        end
    end

    local function getOrePosition(ore)

        local part =
            ore:FindFirstChildWhichIsA(
                "BasePart",
                true
            )

        if part then
            return part.Position
        end

        return nil
    end

    local function findNearestOre()

        local character = player.Character

        if not character then
            return nil
        end

        local root =
            character:FindFirstChild("HumanoidRootPart")

        if not root then
            return nil
        end

        local oresFolder =
            workspace:FindFirstChild("Ores")
            or workspace:FindFirstChild("ores")

        if not oresFolder then
            return nil
        end

        local nearestOre = nil
        local shortestDistance = math.huge

        for _, ore in ipairs(oresFolder:GetChildren()) do

            local oreName =
                Mining.Shared.GetOreName(ore)

            if oreName
            and Mining.Shared.SelectedOres[oreName]
            then

                local pos = getOrePosition(ore)

                if pos then

                    local distance =
                        (root.Position - pos).Magnitude

                    if distance < shortestDistance then

                        shortestDistance = distance
                        nearestOre = ore
                    end
                end
            end
        end

        return nearestOre
    end

    local function teleportToOre(ore)

        local character = player.Character
        if not character then
            return
        end

        local root =
            character:FindFirstChild("HumanoidRootPart")

        local pos =
            getOrePosition(ore)

        if root and pos then

            root.CFrame =
                CFrame.new(
                    pos + Vector3.new(0,4,0)
                )
        end
    end

    local function walkToOre(ore)

        local character = player.Character
        if not character then
            return
        end

        local humanoid =
            character:FindFirstChildOfClass("Humanoid")

        local pos =
            getOrePosition(ore)

        if humanoid and pos then
            humanoid:MoveTo(pos)
        end
    end

------------------------------------------------------------------
-- UI
------------------------------------------------------------------

    Core.CreateSection("⛏ Auto Mining")

    Core.CreateToggle(
        "Auto Tool",
        false,
        function(state)

            autoTool = state

            if state and selectedTool then
                equipTool(selectedTool)
            end
        end
    )

    Core.CreateToggle(
        "Auto Mining",
        false,
        function(state)

            autoMining = state
        end
    )

    Core.CreateButton("Refresh Tools", function()

        findMiningTools()

        if #availableTools > 0 then
            selectedTool = availableTools[1]
        end
    end)

    Core.CreateButton("Mode: Teleport / Walk", function()

        if miningMode == "Teleport" then
            miningMode = "Walk"
        else
            miningMode = "Teleport"
        end
    end)

------------------------------------------------------------------
-- MAIN LOOP
------------------------------------------------------------------

    task.spawn(function()

        while task.wait(0.2) do

            if not autoMining then
                continue
            end

            local targetOre =
                findNearestOre()

            if not targetOre then
                continue
            end

            if autoTool
            and selectedTool then

                equipTool(selectedTool)
            end

            if miningMode == "Teleport" then
                teleportToOre(targetOre)
            else
                walkToOre(targetOre)
            end

            task.wait(0.15)

            activateTool()
        end
    end)

------------------------------------------------------------------
-- INIT
------------------------------------------------------------------

    task.wait(0.5)

    findMiningTools()

    if #availableTools > 0 then
        selectedTool = availableTools[1]
    end

    player.CharacterAdded:Connect(function()

        task.wait(1)

        if autoTool and selectedTool then
            equipTool(selectedTool)
        end
    end)

return Mining
