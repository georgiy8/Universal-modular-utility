--========================================================--
-- Pilgrammed GUI Library
-- Drag Service
--========================================================--

local UserInputService = game:GetService("UserInputService")

local Drag = {}

------------------------------------------------------------
-- Enable Drag
------------------------------------------------------------

function Drag.Enable(DragObject, Target)

    local Dragging = false
    local DragStart
    local StartPosition

    local function Update(Input)

        local Delta = Input.Position - DragStart

        Target.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,

            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )

    end

    DragObject.InputBegan:Connect(function(Input)

        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        Dragging = true
        DragStart = Input.Position
        StartPosition = Target.Position

        Input.Changed:Connect(function()

            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end

        end)

    end)

    UserInputService.InputChanged:Connect(function(Input)

        if not Dragging then
            return
        end

        if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        Update(Input)

    end)

end

------------------------------------------------------------

return Drag
