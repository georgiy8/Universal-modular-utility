-- modules/console.lua
-- Developer console: LogService output, filter, copy, clear, run Lua

return function(Window)

    local LogService = game:GetService("LogService")
    local RunService = game:GetService("RunService")
    local TextService = game:GetService("TextService")

    local Tab = Window:CreateTab({
        Name = "Console",
        Icon = "📋"
    })

    ------------------------------------------------------------
    -- Config
    ------------------------------------------------------------

    local MAX_MESSAGES = 150

    local COLORS = {
        Info    = Color3.fromRGB(140, 180, 255),
        Warning = Color3.fromRGB(255, 190, 60),
        Error   = Color3.fromRGB(255, 90, 90),
        Output  = Color3.fromRGB(200, 200, 210),
        Muted   = Color3.fromRGB(120, 120, 130),
        Row     = Color3.fromRGB(42, 42, 42),
        RowAlt  = Color3.fromRGB(38, 38, 38),
    }

    ------------------------------------------------------------
    -- Toolbar section
    ------------------------------------------------------------

    local Toolbar = Tab:CreateSection({
        Name = "Controls"
    })

    local filterQuery = ""
    local messageCache = {} -- { frame, text, typeName, copyString }

    local SearchBox = Toolbar:AddTextbox({
        Text = "Filter",
        Placeholder = "Search logs...",
        Callback = function(Text)
            filterQuery = string.lower(Text or "")
            for _, entry in ipairs(messageCache) do
                if filterQuery == "" then
                    entry.frame.Visible = true
                else
                    entry.frame.Visible =
                        string.find(string.lower(entry.text), filterQuery, 1, true) ~= nil
                end
            end
        end
    })

    local function trySetClipboard(text)
        if typeof(setclipboard) == "function" then
            local ok = pcall(setclipboard, text)
            return ok
        end
        if typeof(toclipboard) == "function" then
            local ok = pcall(toclipboard, text)
            return ok
        end
        return false
    end

    local function clearMessages()
        for _, entry in ipairs(messageCache) do
            if entry.frame then
                entry.frame:Destroy()
            end
        end
        table.clear(messageCache)
    end

    Toolbar:AddButton({
        Text = "Clear",
        Callback = function()
            clearMessages()
        end
    })

    Toolbar:AddButton({
        Text = "Copy All",
        Callback = function()
            local lines = {}
            for _, entry in ipairs(messageCache) do
                if entry.frame.Visible then
                    table.insert(lines, entry.copyString)
                end
            end
            if #lines == 0 then
                warn("[Console] Nothing to copy")
                return
            end
            if trySetClipboard(table.concat(lines, "\n")) then
                print("[Console] Copied " .. #lines .. " lines")
            else
                warn("[Console] setclipboard not available")
            end
        end
    })

    ------------------------------------------------------------
    -- Log view (custom UI inside section)
    ------------------------------------------------------------

    local Logs = Tab:CreateSection({
        Name = "Output"
    })

    local host = Logs.Container

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "LogScroll"
    scroll.Parent = host
    scroll.Size = UDim2.new(1, 0, 0, 220)
    scroll.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new()
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

    local list = Instance.new("UIListLayout")
    list.Parent = scroll
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 4)

    local pad = Instance.new("UIPadding")
    pad.Parent = scroll
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)

    local function typeStyle(messageType)
        if messageType == Enum.MessageType.MessageError then
            return "ERROR", COLORS.Error
        elseif messageType == Enum.MessageType.MessageWarning then
            return "WARN", COLORS.Warning
        elseif messageType == Enum.MessageType.MessageOutput then
            return "OUT", COLORS.Output
        end
        return "INFO", COLORS.Info
    end

    local function appendMessage(msg, messageType)
        msg = tostring(msg or "")

        if #messageCache >= MAX_MESSAGES then
            local old = table.remove(messageCache, 1)
            if old and old.frame then
                old.frame:Destroy()
            end
        end

        local typeName, typeColor = typeStyle(messageType)
        local timestamp = os.date("%H:%M:%S")
        local copyString = string.format("[%s] [%s] %s", timestamp, typeName, msg)

        local row = Instance.new("Frame")
        row.BackgroundColor3 = (#messageCache % 2 == 0) and COLORS.Row or COLORS.RowAlt
        row.BorderSizePixel = 0
        row.Size = UDim2.new(1, -4, 0, 0)
        row.AutomaticSize = Enum.AutomaticSize.Y
        row.Parent = scroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

        local rowPad = Instance.new("UIPadding")
        rowPad.Parent = row
        rowPad.PaddingTop = UDim.new(0, 4)
        rowPad.PaddingBottom = UDim.new(0, 4)
        rowPad.PaddingLeft = UDim.new(0, 6)
        rowPad.PaddingRight = UDim.new(0, 6)

        local header = Instance.new("Frame")
        header.BackgroundTransparency = 1
        header.Size = UDim2.new(1, 0, 0, 16)
        header.Parent = row

        local timeLabel = Instance.new("TextLabel")
        timeLabel.BackgroundTransparency = 1
        timeLabel.Size = UDim2.new(0, 54, 1, 0)
        timeLabel.Font = Enum.Font.Code
        timeLabel.TextSize = 11
        timeLabel.TextColor3 = COLORS.Muted
        timeLabel.TextXAlignment = Enum.TextXAlignment.Left
        timeLabel.Text = timestamp
        timeLabel.Parent = header

        local badge = Instance.new("TextLabel")
        badge.BackgroundTransparency = 1
        badge.Position = UDim2.fromOffset(58, 0)
        badge.Size = UDim2.new(0, 44, 1, 0)
        badge.Font = Enum.Font.GothamBold
        badge.TextSize = 11
        badge.TextColor3 = typeColor
        badge.TextXAlignment = Enum.TextXAlignment.Left
        badge.Text = typeName
        badge.Parent = header

        local copyBtn = Instance.new("TextButton")
        copyBtn.AnchorPoint = Vector2.new(1, 0)
        copyBtn.Position = UDim2.new(1, 0, 0, 0)
        copyBtn.Size = UDim2.fromOffset(40, 16)
        copyBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        copyBtn.BorderSizePixel = 0
        copyBtn.Font = Enum.Font.Gotham
        copyBtn.TextSize = 11
        copyBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        copyBtn.Text = "Copy"
        copyBtn.AutoButtonColor = true
        copyBtn.Parent = header
        Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 3)

        copyBtn.MouseButton1Click:Connect(function()
            if trySetClipboard(copyString) then
                print("[Console] Line copied")
            else
                warn("[Console] setclipboard not available")
            end
        end)

        local body = Instance.new("TextLabel")
        body.BackgroundTransparency = 1
        body.Position = UDim2.fromOffset(0, 18)
        body.Size = UDim2.new(1, 0, 0, 0)
        body.AutomaticSize = Enum.AutomaticSize.Y
        body.Font = Enum.Font.Code
        body.TextSize = 12
        body.TextColor3 = Color3.fromRGB(230, 230, 235)
        body.TextXAlignment = Enum.TextXAlignment.Left
        body.TextYAlignment = Enum.TextYAlignment.Top
        body.TextWrapped = true
        body.Text = msg
        body.Parent = row

        if filterQuery ~= "" then
            row.Visible = string.find(string.lower(msg), filterQuery, 1, true) ~= nil
        end

        table.insert(messageCache, {
            frame = row,
            text = msg,
            typeName = typeName,
            copyString = copyString,
        })

        task.defer(function()
            scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
        end)
    end

    ------------------------------------------------------------
    -- Run Lua
    ------------------------------------------------------------

    local Run = Tab:CreateSection({
        Name = "Run"
    })

    local pendingCode = ""

    Run:AddTextbox({
        Text = "Lua",
        Placeholder = "print('hello')",
        Callback = function(Text)
            pendingCode = Text or ""
        end
    })

    Run:AddButton({
        Text = "Execute",
        Callback = function()
            if pendingCode == "" then
                warn("[Console] Empty code")
                return
            end
            local fn, err = loadstring(pendingCode)
            if not fn then
                warn("[Console] Compile error: " .. tostring(err))
                return
            end
            local ok, runtimeErr = pcall(fn)
            if not ok then
                warn("[Console] Runtime error: " .. tostring(runtimeErr))
            end
        end
    })

    ------------------------------------------------------------
    -- Hook LogService
    ------------------------------------------------------------

    local conn = LogService.MessageOut:Connect(function(msg, messageType)
        appendMessage(msg, messageType)
    end)

    -- clean up if window closes (best-effort)
    if Window.Gui then
        Window.Gui.Destroying:Connect(function()
            if conn then
                conn:Disconnect()
            end
        end)
    end

    appendMessage("Console module loaded.", Enum.MessageType.MessageInfo)

end
