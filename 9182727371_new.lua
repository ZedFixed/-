local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- ========= REMOVE ACCESSORIES ON SPAWN ==========
local function removeAllAccessoriesFromCharacter()
    local character = player.Character
    if not character then return end
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Accessory")
        or item:IsA("LayeredClothing")
        or item:IsA("Shirt")
        or item:IsA("ShirtGraphic")
        or item:IsA("Pants")
        or item:IsA("BodyColors")
        or item:IsA("CharacterMesh") then
            pcall(function() item:Destroy() end)
        end
    end
end
player.CharacterAdded:Connect(function()
    task.wait(0.2)
    removeAllAccessoriesFromCharacter()
end)
if player.Character then
    task.defer(removeAllAccessoriesFromCharacter)
end

-- ========= FPS DEVOURER ==========
local FPSDevourer = {}
do
    FPSDevourer.running = false
    local TOOL_NAMES = {}

    local function equipTools()
        local character = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if not character or not backpack then return end
        for _, toolName in ipairs(TOOL_NAMES) do
            local tool = backpack:FindFirstChild(toolName)
            if tool then tool.Parent = character end
        end
    end

    local function unequipTools()
        local character = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if not character or not backpack then return end
        for _, toolName in ipairs(TOOL_NAMES) do
            local tool = character:FindFirstChild(toolName)
            if tool then tool.Parent = backpack end
        end
    end

    function FPSDevourer:Start()
        if FPSDevourer.running then return end
        FPSDevourer.running = true
        FPSDevourer._stop = false
        task.spawn(function()
            while FPSDevourer.running and not FPSDevourer._stop do
                equipTools()
                task.wait(0.085)
                unequipTools()
                task.wait(0.085)
            end
        end)
    end

    function FPSDevourer:Stop()
        FPSDevourer.running = false
        FPSDevourer._stop = true
        unequipTools()
    end

    function FPSDevourer:SetToolNames(text)
        TOOL_NAMES = {}
        for name in string.gmatch(text, "[^,]+") do
            table.insert(TOOL_NAMES, name:match("^%s*(.-)%s*$"))
        end
    end

    player.CharacterAdded:Connect(function()
        FPSDevourer.running = false
        FPSDevourer._stop = true
    end)

    FPSDevourer._setTools = function(text) FPSDevourer:SetToolNames(text) end
end

-- ========= DESTROY OLD GUI ==========
local old = playerGui:FindFirstChild("SmoothPanel")
if old then old:Destroy() end

-- ========= PANEL UI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "SmoothPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame", gui)
main.Name = "MainPanel"
main.Size = UDim2.new(0, 240, 0, 150)
main.Position = UDim2.new(1, -260, 0, 40)
main.BackgroundColor3 = Color3.fromRGB(40, 0, 70)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

-- Drop shadow
local shadow = Instance.new("ImageLabel", main)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0,0,0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10,10,118,118)
shadow.ZIndex = -1

-- Dragging
do
    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.Text = "⚡ FPS Devourer"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,255,255)

-- TextBox
local toolBox = Instance.new("TextBox", main)
toolBox.Size = UDim2.new(0.9, 0, 0, 32)
toolBox.Position = UDim2.new(0.05, 0, 0, 44)
toolBox.PlaceholderText = "Tool names (comma separated)"
toolBox.Font = Enum.Font.Gotham
toolBox.TextSize = 14
toolBox.Text = "Bat, Medusa's Head"
toolBox.TextColor3 = Color3.fromRGB(255,255,255)
toolBox.BackgroundColor3 = Color3.fromRGB(60, 0, 120)
toolBox.ClearTextOnFocus = false
Instance.new("UICorner", toolBox).CornerRadius = UDim.new(0, 8)
toolBox.FocusLost:Connect(function()
    FPSDevourer._setTools(toolBox.Text)
end)

-- Toggle Button
local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(0.5, 0, 0, 36)
toggle.Position = UDim2.new(0.25, 0, 0, 90)
toggle.BackgroundColor3 = Color3.fromRGB(120, 40, 200)
toggle.Text = "OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 16
toggle.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 12)

local on = false
toggle.MouseButton1Click:Connect(function()
    on = not on
    if on then
        FPSDevourer:Start()
        toggle.Text = "ON"
        toggle.BackgroundColor3 = Color3.fromRGB(180, 60, 255)
    else
        FPSDevourer:Stop()
        toggle.Text = "OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(120, 40, 200)
    end
end)

-- Reset on spawn
player.CharacterAdded:Connect(function()
    on = false
    toggle.Text = "OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(120, 40, 200)
    task.wait(0.2)
    removeAllAccessoriesFromCharacter()
end)
