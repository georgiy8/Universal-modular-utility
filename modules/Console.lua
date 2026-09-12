-- modules/Console.lua
-- Developer console: history, live logs, execute in/out

return function(Window, meta)

    local LogService = game:GetService("LogService")
    local UserInputService = game:GetService("UserInputService")

    local Tab = Window:CreateTab({
        Name = "Console",
        Icon = "📋",
        Order = (meta and meta.Order) or 90,
    })

    ------------------------------------------------------------
    -- Config
    ------------------------------------------------------------

    local MAX_MESSAGES = 250

    local C = {
        Bg       = Color3.fromRGB(18, 18, 22),
        Row      = Color3.fromRGB(22, 22, 28),
        RowAlt   = Color3.fromRGB(26, 26, 32),
        Border   = Color3.fromRGB(40, 40, 50),
        Text     = Color3.fromRGB(210, 210, 220),
        Muted    = Color3.fromRGB(100, 100, 115),
        Info     = Color3.fromRGB(120, 170, 255),
        Warn     = Color3.fromRGB(255, 190, 70),
        Error    = Color3.fromRGB(255, 95, 95),
        Output   = Color3.fromRGB(180, 220, 160),
        Input    = Color3.fromRGB(200, 160, 255),
        Prompt   = Color3.fromRGB(90, 200, 130),
        Accent   = Color3.fromRGB(55, 55, 70),
    }

    local messageCache = {}
    local filterQuery = ""
    local autoScroll = true

    ------------------------------------------------------------
    -- Host: one block under tab (not chunky sections)
    ------------------------------------------------------------

    local host = Instance.new("Frame")
    host.Name = "ConsoleHost"
    host.Parent = Tab.Container
        local function layoutHost()
        local h = Tab.Container.AbsoluteSize.Y
        -- отступы padding вкладки
        h = math.max(h - 20, 180)
        host.Size = UDim2.new(1, -4, 0, h)
    end

    layoutHost()

    Tab.Container:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutHost)

    if Window.MainFrame then
        Window.MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            task.defer(layoutHost)
        end)
    end
    host.BackgroundColor3 = C.Bg
    host.BorderSizePixel = 0
    Instance.new("UICorner", host).CornerRadius = UDim.new(0, 8)

    local hostStroke = Instance.new("UIStroke")
    hostStroke.Color = C.Border
    hostStroke.Thickness = 1
    hostStroke.Parent = host

    ------------------------------------------------------------
    -- Top bar
    ------------------------------------------------------------

    local top = Instance.new("Frame")
    top.Parent = host
    top.Size = UDim2.new(1, 0, 0, 34)
    top.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    top.BorderSizePixel = 0

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 8)
    topCorner.Parent = top

    -- hide bottom corners of top bar
    local topFix = Instance.new("Frame")
    topFix.Parent = top
    topFix.BackgroundColor3 = top.BackgroundColor3
    topFix.BorderSizePixel = 0
    topFix.Position = UDim2.new(0, 0, 1, -8)
    topFix.Size = UDim2.new(1, 0, 0, 8)

    local title = Instance.new("TextLabel")
    title.Parent = top
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(12, 0)
    title.Size = UDim2.new(0, 120, 1, 0)
    title.Font = Enum.Font.Code
    title.TextSize = 13
    title.TextColor3 = C.Muted
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "CONSOLE"

    local filterBox = Instance.new("TextBox")
    filterBox.Parent = top
    filterBox.Position = UDim2.new(0, 100, 0.5, -11)
    filterBox.Size = UDim2.new(1, -280, 0, 22)
    filterBox.BackgroundColor3 = C.Accent
    filterBox.BorderSizePixel = 0
    filterBox.Font = Enum.Font.Code
    filterBox.TextSize = 12
    filterBox.TextColor3 = C.Text
    filterBox.PlaceholderText = "filter..."
    filterBox.PlaceholderColor3 = C.Muted
    filterBox.Text = ""
    filterBox.ClearTextOnFocus = false
    Instance.new("UICorner", filterBox).CornerRadius = UDim.new(0, 4)

    local function makeTopBtn(text, x)
        local b = Instance.new("TextButton")
        b.Parent = top
        b.AnchorPoint = Vector2.new(1, 0.5)
        b.Position = UDim2.new(1, x, 0.5, 0)
        b.Size = UDim2.fromOffset(56, 22)
        b.BackgroundColor3 = C.Accent
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Code
        b.TextSize = 12
        b.TextColor3 = C.Text
        b.Text = text
        b.AutoButtonColor = true
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        return b
    end

    local clearBtn = makeTopBtn("clear", -12)
    local copyBtn = makeTopBtn("copy", -74)

    ------------------------------------------------------------
    -- Log scroll
    ------------------------------------------------------------

    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = host
    scroll.Position = UDim2.fromOffset(0, 34)
    scroll.Size = UDim2.new(1, 0, 1, -74)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = C.Muted
    scroll.CanvasSize = UDim2.new()
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local list = Instance.new("UIListLayout")
    list.Parent = scroll
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 1)

    local pad = Instance.new("UIPadding")
    pad.Parent = scroll
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)

    ------------------------------------------------------------
    -- Input bar
    ------------------------------------------------------------

    local inputBar = Instance.new("Frame")
    inputBar.Parent = host
    inputBar.AnchorPoint = Vector2.new(0, 1)
    inputBar.Position = UDim2.new(0, 0, 1, 0)
    inputBar.Size = UDim2.new(1, 0, 0, 40)
    inputBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    inputBar.BorderSizePixel = 0

    local inputFix = Instance.new("Frame")
    inputFix.Parent = inputBar
    inputFix.BackgroundColor3 = inputBar.BackgroundColor3
    inputFix.BorderSizePixel = 0
    inputFix.Size = UDim2.new(1, 0, 0, 8)

    local prompt = Instance.new("TextLabel")
    prompt.Parent = inputBar
    prompt.BackgroundTransparency = 1
    prompt.Position = UDim2.fromOffset(10, 0)
    prompt.Size = UDim2.new(0, 16, 1, 0)
    prompt.Font = Enum.Font.Code
    prompt.TextSize = 14
    prompt.TextColor3 = C.Prompt
    prompt.Text = ">"

    local codeBox = Instance.new("TextBox")
    codeBox.Parent = inputBar
    codeBox.Position = UDim2.fromOffset(28, 6)
    codeBox.Size = UDim2.new(1, -100, 0, 28)
    codeBox.BackgroundColor3 = C.Accent
    codeBox.BorderSizePixel = 0
    codeBox.Font = Enum.Font.Code
    codeBox.TextSize = 13
    codeBox.TextColor3 = C.Text
    codeBox.PlaceholderText = "lua expression..."
    codeBox.PlaceholderColor3 = C.Muted
    codeBox.Text = ""
    codeBox.ClearTextOnFocus = false
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0, 4)

    local codePad = Instance.new("UIPadding")
    codePad.Parent = codeBox
    codePad.PaddingLeft = UDim.new(0, 8)

    local runBtn = Instance.new("TextButton")
    runBtn.Parent = inputBar
    runBtn.AnchorPoint = Vector2.new(1, 0.5)
    runBtn.Position = UDim2.new(1, -10, 0.5, 0)
    runBtn.Size = UDim2.fromOffset(56, 28)
    runBtn.BackgroundColor3 = Color3.fromRGB(45, 90, 55)
    runBtn.BorderSizePixel = 0
    runBtn.Font = Enum.Font.Code
    runBtn.TextSize = 13
    runBtn.TextColor3 = Color3.fromRGB(220, 255, 220)
    runBtn.Text = "run"
    runBtn.AutoButtonColor = true
    Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0, 4)

    ------------------------------------------------------------
    -- Helpers
    ------------------------------------------------------------

    local function trySetClipboard(text)
        if typeof(setclipboard) == "function" then
            return pcall(setclipboard, text)
        end
        if typeof(toclipboard) == "function" then
            return pcall(toclipboard, text)
        end
        return false
    end

    local function typeStyle(kind)
        -- kind: MessageType or string "INPUT" / "RETURN"
        if kind == "INPUT" then
            return "IN", C.Input
        elseif kind == "RETURN" then
            return "RET", C.Output
        elseif kind == Enum.MessageType.MessageError or kind == "ERROR" then
            return "ERR", C.Error
        elseif kind == Enum.MessageType.MessageWarning or kind == "WARN" then
            return "WRN", C.Warn
        elseif kind == Enum.MessageType.MessageOutput or kind == "OUT" then
            return "OUT", C.Output
        end
        return "INF", C.Info
    end

    local function applyFilter(entry)
        if filterQuery == "" then
            entry.frame.Visible = true
        else
            entry.frame.Visible =
                string.find(string.lower(entry.text), filterQuery, 1, true) ~= nil
        end
    end

    local function appendMessage(msg, kind)
        msg = tostring(msg or "")

        if #messageCache >= MAX_MESSAGES then
            local old = table.remove(messageCache, 1)
            if old and old.frame then
                old.frame:Destroy()
            end
        end

        local tag, color = typeStyle(kind)
        local ts = os.date("%H:%M:%S")
        local copyString = string.format("[%s] [%s] %s", ts, tag, msg)

        local row = Instance.new("Frame")
        row.BackgroundColor3 = (#messageCache % 2 == 0) and C.Row or C.RowAlt
        row.BorderSizePixel = 0
        row.Size = UDim2.new(1, 0, 0, 0)
        row.AutomaticSize = Enum.AutomaticSize.Y
        row.Parent = scroll

        local rowPad = Instance.new("UIPadding")
        rowPad.Parent = row
        rowPad.PaddingTop = UDim.new(0, 3)
        rowPad.PaddingBottom = UDim.new(0, 3)
        rowPad.PaddingLeft = UDim.new(0, 6)
        rowPad.PaddingRight = UDim.new(0, 6)

        local line = Instance.new("TextLabel")
        line.Parent = row
        line.BackgroundTransparency = 1
        line.Size = UDim2.new(1, -36, 0, 0)
        line.AutomaticSize = Enum.AutomaticSize.Y
        line.Font = Enum.Font.Code
        line.TextSize = 12
        line.TextXAlignment = Enum.TextXAlignment.Left
        line.TextYAlignment = Enum.TextYAlignment.Top
        line.TextWrapped = true
        line.RichText = true
        line.Text = string.format(
            "<font color=\"#888899\">%s</font>  <font color=\"#%s\">%s</font>  %s",
            ts,
            color:ToHex(),
            tag,
            msg:gsub("<", "&lt;"):gsub(">", "&gt;")
        )
        line.TextColor3 = C.Text

        local cbtn = Instance.new("TextButton")
        cbtn.Parent = row
        cbtn.AnchorPoint = Vector2.new(1, 0)
        cbtn.Position = UDim2.new(1, 0, 0, 0)
        cbtn.Size = UDim2.fromOffset(28, 16)
        cbtn.BackgroundColor3 = C.Accent
        cbtn.BorderSizePixel = 0
        cbtn.Font = Enum.Font.Code
        cbtn.TextSize = 10
        cbtn.TextColor3 = C.Muted
        cbtn.Text = "cp"
        cbtn.AutoButtonColor = true
        Instance.new("UICorner", cbtn).CornerRadius = UDim.new(0, 3)

        cbtn.MouseButton1Click:Connect(function()
            trySetClipboard(copyString)
        end)

        local entry = {
            frame = row,
            text = msg,
            copyString = copyString,
        }
        applyFilter(entry)
        table.insert(messageCache, entry)

        if autoScroll then
            task.defer(function()
                scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
            end)
        end
    end

    local function clearMessages()
        for _, e in ipairs(messageCache) do
            if e.frame then
                e.frame:Destroy()
            end
        end
        table.clear(messageCache)
    end

    ------------------------------------------------------------
    -- History (before script) + live
    ------------------------------------------------------------

    local function pullHistory()
        local ok, history = pcall(function()
            return LogService:GetLogHistory()
        end)
        if not ok or type(history) ~= "table" then
            return
        end
        -- history entries: { message, messageType, timestamp }
        local startIndex = 1
        if #history > MAX_MESSAGES then
            startIndex = #history - MAX_MESSAGES + 1
        end
        for i = startIndex, #history do
            local item = history[i]
            if type(item) == "table" then
                appendMessage(item.message or item.Message, item.messageType or item.MessageType)
            end
        end
    end

    pullHistory()

    local conn = LogService.MessageOut:Connect(function(msg, messageType)
        appendMessage(msg, messageType)
    end)

    if Window.Gui then
        Window.Gui.Destroying:Connect(function()
            if conn then
                conn:Disconnect()
            end
        end)
    end

    ------------------------------------------------------------
    -- Execute
    ------------------------------------------------------------

    local function executeCode(code)
        code = code and code:match("^%s*(.-)%s*$") or ""
        if code == "" then
            appendMessage("empty input", "WARN")
            return
        end

        appendMessage(code, "INPUT")

        local fn, err = loadstring(code)
        if not fn then
            appendMessage("compile: " .. tostring(err), "ERROR")
            return
        end

        local results = table.pack(pcall(fn))
        local ok = results[1]
        if not ok then
            appendMessage("runtime: " .. tostring(results[2]), "ERROR")
            return
        end

        -- show returned values (print already goes via LogService)
        if results.n > 1 then
            local parts = {}
            for i = 2, results.n do
                local v = results[i]
                local t = typeof(v)
                if t == "string" then
                    table.insert(parts, string.format("%q", v))
                elseif t == "Instance" then
                    table.insert(parts, v:GetFullName())
                else
                    table.insert(parts, tostring(v))
                end
            end
            appendMessage(table.concat(parts, "  |  "), "RETURN")
        end
    end

    runBtn.MouseButton1Click:Connect(function()
        executeCode(codeBox.Text)
    end)

    codeBox.FocusLost:Connect(function(enter)
        if enter then
            executeCode(codeBox.Text)
        end
    end)

    ------------------------------------------------------------
    -- Toolbar actions
    ------------------------------------------------------------

    filterBox:GetPropertyChangedSignal("Text"):Connect(function()
        filterQuery = string.lower(filterBox.Text or "")
        for _, e in ipairs(messageCache) do
            applyFilter(e)
        end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        clearMessages()
        appendMessage("cleared", Enum.MessageType.MessageInfo)
    end)

    copyBtn.MouseButton1Click:Connect(function()
        local lines = {}
        for _, e in ipairs(messageCache) do
            if e.frame.Visible then
                table.insert(lines, e.copyString)
            end
        end
        if #lines == 0 then
            appendMessage("nothing to copy", "WARN")
            return
        end
        if trySetClipboard(table.concat(lines, "\n")) then
            appendMessage("copied " .. #lines .. " lines", Enum.MessageType.MessageInfo)
        else
            appendMessage("clipboard unavailable", "ERROR")
        end
    end)

    appendMessage("console ready · history loaded", Enum.MessageType.MessageInfo)

end
