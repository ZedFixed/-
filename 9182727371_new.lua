local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========== REMOVE TODOS ACESSÓRIOS/ROUPAS AO EXECUTAR O SCRIPT ==========
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

-- ====== DIMENSIONAMENTO (70%) =======
local SCALE = 0.7
local PANEL_WIDTH, PANEL_HEIGHT = math.floor(212*SCALE), math.floor(170*SCALE) -- taller for slider
local PANEL_RADIUS = math.floor(13*SCALE)
local TITLE_HEIGHT = math.floor(32*SCALE)
local BTN_WIDTH = math.floor(0.89*PANEL_WIDTH)
local BTN_HEIGHT = math.floor(34*SCALE)
local BTN_RADIUS = math.floor(8*SCALE)
local BTN_FONT_SIZE = math.floor(17*SCALE)
local TITLE_FONT_SIZE = math.floor(19*SCALE)
local ICON_SIZE = math.floor(16*SCALE)
local BTN_ICON_PAD = math.floor(8*SCALE)
local BTN_Y0 = math.floor(70*SCALE)

-- ========== FPS DEVOURER ==========
local FPSDevourer = {}
do
    FPSDevourer.running = false
    FPSDevourer.Speed = 0.07 -- default delay
    local TOOL_NAMES = {}

    local function equipTools()
        local character = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if not character or not backpack then return end
        for _, toolName in ipairs(TOOL_NAMES) do
            local tool = backpack:FindFirstChild(toolName)
            if tool then
                tool.Parent = character
            end
        end
    end

    local function unequipTools()
        local character = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if not character or not backpack then return end
        for _, toolName in ipairs(TOOL_NAMES) do
            local tool = character:FindFirstChild(toolName)
            if tool then
                tool.Parent = backpack
            end
        end
    end

    function FPSDevourer:Start()
        if FPSDevourer.running then return end
        FPSDevourer.running = true
        FPSDevourer._stop = false

        task.spawn(function()
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            while FPSDevourer.running and not FPSDevourer._stop do
                local delay = math.max(0.02, FPSDevourer.Speed) -- min clamp
                if hrp then
                    local pos = hrp.CFrame
                    equipTools()
                    task.wait(delay)
                    unequipTools()
                    task.wait(delay)
                    if hrp.Parent then
                        hrp.CFrame = pos
                    end
                else
                    equipTools()
                    task.wait(delay)
                    unequipTools()
                    task.wait(delay)
                end
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

-- Remove antigo painel, se houver
local old = playerGui:FindFirstChild("NOTHING")
if old then old:Destroy() end

-- ========== PAINEL UI + DRAG ==========
local gui = Instance.new("ScreenGui")
gui.Name = "NOTHING"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame", gui)
main.Name = "MainPanel"
main.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
main.Position = UDim2.new(1, -PANEL_WIDTH-10, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(138,43,226)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, PANEL_RADIUS)

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

local title = Instance.new("TextLabel", main)
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
title.Position = UDim2.new(0,0,0,0)
title.Text = "Tubol"
title.Font = Enum.Font.GothamBlack
title.TextSize = TITLE_FONT_SIZE
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextStrokeTransparency = 0.08
title.TextStrokeColor3 = Color3.fromRGB(186,85,211)

-- TextBox for tool names
local toolBox = Instance.new("TextBox", main)
toolBox.Size = UDim2.new(0, BTN_WIDTH, 0, BTN_HEIGHT)
toolBox.Position = UDim2.new(0, math.floor((PANEL_WIDTH-BTN_WIDTH)/2), 0, 34)
toolBox.PlaceholderText = "Type tool names here (comma separated)"
toolBox.Font = Enum.Font.Gotham
toolBox.TextSize = 14
toolBox.Text = "Medusa's Head, Bat, Boogie Bomb"
toolBox.TextColor3 = Color3.fromRGB(255,255,255)
toolBox.BackgroundColor3 = Color3.fromRGB(100,30,180)
toolBox.ClearTextOnFocus = false
Instance.new("UICorner", toolBox).CornerRadius = UDim.new(0, BTN_RADIUS)
toolBox.FocusLost:Connect(function()
    FPSDevourer._setTools(toolBox.Text)
end)

local function createCircleIcon(parent, y, on)
    local icon = Instance.new("Frame", parent)
    icon.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
    icon.Position = UDim2.new(0, BTN_ICON_PAD, 0, y + math.floor((BTN_HEIGHT-ICON_SIZE)/2))
    icon.BackgroundTransparency = 1
    local circle = Instance.new("ImageLabel", icon)
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.Position = UDim2.new(0,0,0,0)
    circle.BackgroundTransparency = 1
    circle.Image = "rbxassetid://10137946418"
    circle.ImageColor3 = (on and Color3.fromRGB(50,255,60)) or Color3.fromRGB(255,40,40)
    return icon, circle
end

-- Toggle Button
local function makeToggleBtn(parent, label, y, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, BTN_WIDTH, 0, BTN_HEIGHT)
    btn.Position = UDim2.new(0, math.floor((PANEL_WIDTH-BTN_WIDTH)/2), 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(138,43,226)
    btn.Text = label
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = BTN_FONT_SIZE
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, BTN_RADIUS)
    btn.TextXAlignment = Enum.TextXAlignment.Center
    local icon, circle = createCircleIcon(parent, y, false)
    icon.ZIndex = btn.ZIndex+1
    btn.ZIndex = btn.ZIndex+2
    btn.LayoutOrder = y
    btn.AutoButtonColor = false
    local state = false
    local function updateVisual()
        circle.ImageColor3 = (state and Color3.fromRGB(50,255,60)) or Color3.fromRGB(255,40,40)
        btn.BackgroundColor3 = state and Color3.fromRGB(186,85,211) or Color3.fromRGB(138,43,226)
    end
    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state, btn)
        updateVisual()
    end)
    icon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            callback(state, btn)
            updateVisual()
        end
    end)
    updateVisual()
    return btn, function(v)
        state = v
        callback(state, btn)
        updateVisual()
    end
end

local btnFPSDevourer, setFPSDevourerState = makeToggleBtn(main, "ON", BTN_Y0, function(on)
    if on then FPSDevourer:Start() else FPSDevourer:Stop() end
end)

-- Slider for speed adjustment
local sliderFrame = Instance.new("Frame", main)
sliderFrame.Size = UDim2.new(0, BTN_WIDTH, 0, 20)
sliderFrame.Position = UDim2.new(0, math.floor((PANEL_WIDTH-BTN_WIDTH)/2), 0, BTN_Y0 + 45)
sliderFrame.BackgroundColor3 = Color3.fromRGB(100,30,180)
sliderFrame.BorderSizePixel = 0
Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 6)

local bar = Instance.new("Frame", sliderFrame)
bar.Size = UDim2.new(0.5, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(186,85,211)
bar.BorderSizePixel = 0
Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)

local speedLabel = Instance.new("TextLabel", main)
speedLabel.Size = UDim2.new(0, BTN_WIDTH, 0, 16)
speedLabel.Position = UDim2.new(0, math.floor((PANEL_WIDTH-BTN_WIDTH)/2), 0, BTN_Y0 + 70)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: 0.07s"
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.TextColor3 = Color3.fromRGB(255,255,255)

local draggingSlider = false
sliderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
        local move = function(posX)
            local rel = math.clamp((posX - sliderFrame.AbsolutePosition.X)/sliderFrame.AbsoluteSize.X,0,1)
            bar.Size = UDim2.new(rel,0,1,0)
            local newSpeed = 0.02 + (0.15-0.02)*(1-rel) -- invert: left fast, right slow
            FPSDevourer.Speed = newSpeed
            speedLabel.Text = string.format("Speed: %.3fs", newSpeed)
        end
        move(input.Position.X)
        local conn
        conn = UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement and draggingSlider then
                move(i.Position.X)
            end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingSlider = false
                conn:Disconnect()
            end
        end)
    end
end)

player.CharacterAdded:Connect(function()
    setFPSDevourerState(false)
    task.wait(0.2)
    removeAllAccessoriesFromCharacter()
end)
