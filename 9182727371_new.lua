
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ========== REMOVE ALL ACCESSORIES ==========
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
local PANEL_WIDTH, PANEL_HEIGHT = math.floor(212*SCALE), math.floor(90*SCALE)
local PANEL_RADIUS = math.floor(13*SCALE)
local TITLE_HEIGHT = math.floor(32*SCALE)
local BTN_WIDTH = math.floor(0.89*PANEL_WIDTH)
local BTN_HEIGHT = math.floor(34*SCALE)
local BTN_RADIUS = math.floor(8*SCALE)
local BTN_FONT_SIZE = math.floor(17*SCALE)
local TITLE_FONT_SIZE = math.floor(19*SCALE)
local ICON_SIZE = math.floor(16*SCALE)
local BTN_ICON_PAD = math.floor(8*SCALE)
local BTN_Y0 = math.floor(38*SCALE)

-- ========== FPS DEVOURER ==========
local FPSDevourer = {}
do
    FPSDevourer.running = false
    local TOOL_NAME = "Bat"
    local function equipBat()
        local c = player.Character
        local b = player:FindFirstChild("Backpack")
        if not c or not b then return false end
        local t = b:FindFirstChild(TOOL_NAME)
        if t then t.Parent = c return true end
        return false
    end
    FPSDevourer.running = false
    local TOOL_NAME = "Medusa's Head"
    local function equipItem()
        local c = player.Character
        local b = player:FindFirstChild("Backpack")
        if not c or not b then return false end
        local t = b:FindFirstChild(TOOL_NAME)
        if t then t.Parent = c return true end
        return false
    end
    local function unequipItem()
        local c = player.Character
        local b = player:FindFirstChild("Backpack")
        if not c or not b then return false end
        local t = c:FindFirstChild(TOOL_NAME)
        if t then t.Parent = b return true end
        return false
    end
    function FPSDevourer:Start()
        if FPSDevourer.running then return end
        FPSDevourer.running = true
        FPSDevourer._stop = false
        task.spawn(function()
            while FPSDevourer.running and not FPSDevourer._stop do
                equipBat()
                task.wait(0.035)
                equipItem()
                task.wait(0.15)
                unequipItem()
                task.wait(0.90)
            end
        end)
    end
    function FPSDevourer:Stop()
        FPSDevourer.running = false
        FPSDevourer._stop = true
        unequip()
    end
    player.CharacterAdded:Connect(function()
        FPSDevourer.running = false
        FPSDevourer._stop = true
    end)
end

-- Remove antigo painel
local old = playerGui:FindFirstChild("AkunBitchDevourerPanel")
if old then old:Destroy() end

-- ========== GUI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "AkunBitchDevourerPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame", gui)
main.Name = "MainPanel"
main.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
main.Position = UDim2.new(1, -PANEL_WIDTH-10, 0, 10)
main.BackgroundColor3 = Color3.fromRGB(13,13,13)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, PANEL_RADIUS)

-- Drag com Tween
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
            local goal = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(main, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goal}):Play()
        end
    end)
end

-- Title
local title = Instance.new("TextLabel", main)
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
title.Position = UDim2.new(0,0,0,0)
title.Text = ""
title.Font = Enum.Font.GothamBlack
title.TextSize = TITLE_FONT_SIZE
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextStrokeTransparency = 0.08
title.TextStrokeColor3 = Color3.fromRGB(220,220,220)

-- Ping Monitor (left of title)
local pingLabel = Instance.new("TextLabel", main)
pingLabel.Size = UDim2.new(0, 60, 0, TITLE_HEIGHT)
pingLabel.Position = UDim2.new(0, 6, 0, 0)
pingLabel.BackgroundTransparency = 1
pingLabel.Font = Enum.Font.GothamBold
pingLabel.TextSize = math.floor(15*SCALE)
pingLabel.TextColor3 = Color3.fromRGB(180,255,180)
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Text = "Ping: --"

task.spawn(function()
    while task.wait(0.5) do
        local stats = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
        if stats then
            pingLabel.Text = "Ping: "..math.floor(stats:GetValue()).."ms"
        end
    end
end)

-- Circle Icon
local function createCircleIcon(parent, y, on)
    local icon = Instance.new("Frame", parent)
    icon.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
    icon.Position = UDim2.new(0, BTN_ICON_PAD, 0, y + math.floor((BTN_HEIGHT-ICON_SIZE)/2))
    icon.BackgroundTransparency = 1
    local circle = Instance.new("ImageLabel", icon)
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.BackgroundTransparency = 1
    circle.Image = "rbxassetid://10137946418"
    circle.ImageColor3 = (on and Color3.fromRGB(50,255,60)) or Color3.fromRGB(255,40,40)
    return icon, circle
end

-- Toggle Btn
local function makeToggleBtn(parent, label, y, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, BTN_WIDTH, 0, BTN_HEIGHT)
    btn.Position = UDim2.new(0, math.floor((PANEL_WIDTH-BTN_WIDTH)/2), 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(28,28,28)
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
    btn.AutoButtonColor = false
    local state = false
    local function updateVisual()
        TweenService:Create(circle, TweenInfo.new(0.15), {
            ImageColor3 = (state and Color3.fromRGB(50,255,60)) or Color3.fromRGB(255,40,40)
        }):Play()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(38,38,38) or Color3.fromRGB(28,28,28)
        }):Play()
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

local btnFPSDevourer, setFPSDevourerState = makeToggleBtn(main, "Start", BTN_Y0, function(on)
    if on then FPSDevourer:Start() else FPSDevourer:Stop() end
end)

-- Reset toggle on respawn
player.CharacterAdded:Connect(function()
    setFPSDevourerState(false)
    task.wait(0.2)
    removeAllAccessoriesFromCharacter()
end)
