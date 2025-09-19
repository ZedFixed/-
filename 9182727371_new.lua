
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- ========== REMOVE ACESSÓRIOS ==========
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

-- ====== DIMENSIONAMENTO (60%) =======
local SCALE = 0.6
local PANEL_WIDTH, PANEL_HEIGHT = math.floor(200*SCALE), math.floor(100*SCALE)
local PANEL_RADIUS = math.floor(14*SCALE)
local TITLE_HEIGHT = math.floor(28*SCALE)
local BTN_WIDTH = math.floor(0.9*PANEL_WIDTH)
local BTN_HEIGHT = math.floor(30*SCALE)
local BTN_RADIUS = math.floor(10*SCALE)
local BTN_FONT_SIZE = math.floor(16*SCALE)
local TITLE_FONT_SIZE = math.floor(18*SCALE)
local ICON_SIZE = math.floor(14*SCALE)
local BTN_ICON_PAD = math.floor(6*SCALE)
local BTN_Y0 = math.floor(35*SCALE)
local BTN_SPACING = math.floor(32*SCALE)

-- ========== FPS DEVOURER ==========
local FPSDevourer = {}
do
    FPSDevourer.running = false
    local TOOL_NAME = "Bat"

    local function equipTungBat()
        local character = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if not character or not backpack then return false end
        local tool = backpack:FindFirstChild(TOOL_NAME)
        if tool then tool.Parent = character return true end
        return false
    end

local FPSDevourer = {}
do
    FPSDevourer.running = false
    local TOOL_NAME = "Medusa's Head"

    local function equipMedusa'sHead()
        local character = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if not character or not backpack then return false end
        local tool = backpack:FindFirstChild(TOOL_NAME)
        if tool then tool.Parent = character return true end
        return false
    end
    local function unequipMedusa'sHead()
        local character = player.Character
        local backpack = player:FindFirstChild("Backpack")
        if not character or not backpack then return false end
        local tool = character:FindFirstChild(TOOL_NAME)
        if tool then tool.Parent = backpack return true end
        return false
    end


    function FPSDevourer:Start()
        if FPSDevourer.running then return end
        FPSDevourer.running = true
        FPSDevourer._stop = false
        task.spawn(function()
            while FPSDevourer.running and not FPSDevourer._stop do
                equipTungBat()
                task.wait(0.035)
                equipMedusa'sHead()
                task.wait(0.035)
                unequipMedusa'sHead()
                task.wait(0.50)
                
            end
        end)
    end
    function FPSDevourer:Stop()
        FPSDevourer.running = false
        FPSDevourer._stop = true
        unequipTungBat()
    end
    player.CharacterAdded:Connect(function()
        FPSDevourer.running = false
        FPSDevourer._stop = true
    end)
end

-- ========== SPEED BOOST ==========
local SpeedBoost = {}
do
    local DEFAULT_SPEED = 25
    local BOOST_SPEED = 25
    SpeedBoost.on = false

    function SpeedBoost:Start()
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then humanoid.WalkSpeed = BOOST_SPEED end
        SpeedBoost.on = true
    end
    function SpeedBoost:Stop()
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then humanoid.WalkSpeed = DEFAULT_SPEED end
        SpeedBoost.on = false
    end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.2)
        local humanoid = char:WaitForChild("Humanoid")
        if SpeedBoost.on then
            humanoid.WalkSpeed = BOOST_SPEED
        else
            humanoid.WalkSpeed = DEFAULT_SPEED
        end
    end)
end

-- Remove antigo painel
local old = playerGui:FindFirstChild("Nothing")
if old then old:Destroy() end

-- ========== PAINEL UI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "Nothing"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame", gui)
main.Name = "MainPanel"
main.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
main.Position = UDim2.new(1, -PANEL_WIDTH-12, 0, 12)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, PANEL_RADIUS)

-- sombra fake
local shadow = Instance.new("ImageLabel", main)
shadow.ZIndex = -1
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0,0,0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10,10,118,118)

-- drag
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

-- título
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
title.Text = "Tubol"
title.Font = Enum.Font.GothamBold
title.TextSize = TITLE_FONT_SIZE
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)

-- botão helper
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

local function makeToggleBtn(parent, label, y, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, BTN_WIDTH, 0, BTN_HEIGHT)
    btn.Position = UDim2.new(0, math.floor((PANEL_WIDTH-BTN_WIDTH)/2), 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
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
        circle.ImageColor3 = (state and Color3.fromRGB(50,255,60)) or Color3.fromRGB(255,40,40)
        btn.BackgroundColor3 = state and Color3.fromRGB(40,40,40) or Color3.fromRGB(30,30,30)
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

-- botão 1: FPS Devourer
local btnFPSDevourer, setFPSDevourerState = makeToggleBtn(main, "FPS Devourer", BTN_Y0, function(on)
    if on then FPSDevourer:Start() else FPSDevourer:Stop() end
end)

-- botão 2: Speed Boost
local btnSpeed, setSpeedState = makeToggleBtn(main, "Speed Boost", BTN_Y0+BTN_SPACING, function(on)
    if on then SpeedBoost:Start() else SpeedBoost:Stop() end
end)

-- reset ao respawn
player.CharacterAdded:Connect(function()
    setFPSDevourerState(false)
    setSpeedState(false)
    task.wait(0.2)
    removeAllAccessoriesFromCharacter()
end)
