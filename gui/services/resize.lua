--========================================================--
-- Universal-modular-utility GUI Library
-- Resize Service
--========================================================--

local UserInputService = game:GetService("UserInputService")

local Resize = {}

------------------------------------------------------------
-- Enable Resize
------------------------------------------------------------

function Resize.Enable(Target, Handle)

    Handle = Handle or Target

    local Resizing = false
    local ResizeStart
    local StartSize

    Handle.InputBegan:Connect(function(Input)

        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        Resizing = true
        ResizeStart = Input.Position
        StartSize = Target.AbsoluteSize

    end)

    Handle.InputEnded:Connect(function(Input)

        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Resizing = false
        end

    end)

    UserInputService.InputChanged:Connect(function(Input)

        if not Resizing then
            return
        end

        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local Delta = Input.Position - ResizeStart

        local NewWidth = math.max(300, StartSize.X + Delta.X)
        local NewHeight = math.max(200, StartSize.Y + Delta.Y)

        Target.Size = UDim2.fromOffset(NewWidth, NewHeight)

    end)

end

------------------------------------------------------------

return Resize
