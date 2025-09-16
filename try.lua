
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========== REMOVE ACCESSORIES/CLOTHING ==========
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
if player.Character then task.defer(removeAllAccessoriesFromCharacter) end

-- ========== UI SIZING ==========
local SCALE = 0.7
local PANEL_WIDTH, PANEL_HEIGHT = math.floor(212*SCALE), math.floor(180*SCALE)
local PANEL_RADIUS = math.floor(13*SCALE)
local TITLE_HEIGHT = math.floor(32*SCALE)
local BTN_WIDTH = math.floor(0.89*PANEL_WIDTH)
local BTN_HEIGHT = math.floor(34*SCALE)
local BTN_RADIUS = math.floor(8*SCALE)
local BTN_FONT_SIZE = math.floor(17*SCALE)
local TITLE_FONT_SIZE = math.floor(19*SCALE)
local ICON_SIZE = math.floor(16*SCALE)
local BTN_ICON_PAD = math.floor(8*SCALE)
local BTN_Y0 = math.floor(TITLE_HEIGHT + 110*SCALE)

-- ========== CONFIG ==========
local TOOL_NAMES = {"Bat","Medusa's Head","Boogie Bomb"}      -- default list (will be shown in TextBox)
local SPAM_DELAY = 0.0000                 -- seconds (live-editable)
local MIN_DELAY = 0.0000                  -- minimum allowed delay

-- helper: trim whitespace
local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- parse tool names by comma/semicolon/newline (keeps spaces inside names)
local function parseToolNames(text)
    local names = {}
    if not text or text == "" then return names end
    for part in string.gmatch(text, "([^,;\n]+)") do
        local name = trim(part)
        if name ~= "" then table.insert(names, name) end
    end
    return names
end

-- ========== CORE: equip/unequip all at once (non-blocking) ==========
local FPSDevourer = { running = false, _conn = nil }
do
    local nextActionTime = 0
    local nextShouldEquip = true

    local function backpack() return player:FindFirstChild("Backpack") end

    local function equipAllListed()
        if not TOOL_NAMES or #TOOL_NAMES == 0 then return end
        local character, pack = player.Character, backpack()
        if not character or not pack then return end
        for _, name in ipairs(TOOL_NAMES) do
            if name and name ~= "" then
                if not character:FindFirstChild(name) then
                    local t = pack:FindFirstChild(name)
                    if t and t:IsA("Tool") then
                        pcall(function() t.Parent = character end)
                    end
                end
            end
        end
    end

    local function unequipAllListed()
        if not TOOL_NAMES or #TOOL_NAMES == 0 then return end
        local character, pack = player.Character, backpack()
        if not character or not pack then return end
        for _, name in ipairs(TOOL_NAMES) do
            if name and name ~= "" then
                local t = character:FindFirstChild(name)
                if t and t:IsA("Tool") then
                    pcall(function() t.Parent = pack end)
                end
            end
        end
    end

    local function unequipEverythingFromCharacter()
        local character, pack = player.Character, backpack()
        if not character or not pack then return end
        for _, c in ipairs(character:GetChildren()) do
            if c:IsA("Tool") then
                pcall(function() c.Parent = pack end)
            end
        end
    end

    function FPSDevourer._resetCycle()
        nextShouldEquip = true
        nextActionTime = tick()
    end

    function FPSDevourer.Start()
        if FPSDevourer.running then return end
        FPSDevourer.running = true
        nextShouldEquip = true
        nextActionTime = tick()
        FPSDevourer._conn = RunService.Heartbeat:Connect(function()
            if not FPSDevourer.running then return end
            local now = tick()
            if now < nextActionTime then return end

            if nextShouldEquip then
                equipAllListed()
                nextShouldEquip = false
            else
                unequipAllListed()
                nextShouldEquip = true
            end

            nextActionTime = now + math.max(MIN_DELAY, SPAM_DELAY)
        end)
    end

    function FPSDevourer.Stop()
        if not FPSDevourer.running then
            if FPSDevourer._conn then
                FPSDevourer._conn:Disconnect()
                FPSDevourer._conn = nil
            end
            return
        end
        FPSDevourer.running = false
        if FPSDevourer._conn then
            FPSDevourer._conn:Disconnect()
            FPSDevourer._conn = nil
        end
        -- best-effort unequip the listed tools
        unequipAllListed()
    end

    player.CharacterAdded:Connect(function()
        FPSDevourer.Stop()
    end)

    -- expose helpers for UI use
    FPSDevourer._unequipAll = unequipEverythingFromCharacter
    FPSDevourer._unequipAllListed = unequipAllListed
end

-- ========== UI ==========
-- clean old panels if present
local old = playerGui:FindFirstChild("Script kong malupit")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "Script kong malupit"
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

-- title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
title.Position = UDim2.new(0,0,0,0)
title.Text = "Malupitang Script"
title.Font = Enum.Font.GothamBlack
title.TextSize = TITLE_FONT_SIZE
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextStrokeTransparency = 0.08
title.TextStrokeColor3 = Color3.fromRGB(186,85,211)

-- tool names textbox
local toolBox = Instance.new("TextBox", main)
toolBox.Size = UDim2.new(0.9, 0, 0, 26)
toolBox.Position = UDim2.new(0.05, 0, 0, TITLE_HEIGHT + 5)
toolBox.BackgroundColor3 = Color3.fromRGB(186,85,211)
toolBox.PlaceholderText = "Tool names (comma-separated; names may include spaces)"
toolBox.Text = table.concat(TOOL_NAMES, ", ")
toolBox.Font = Enum.Font.Gotham
toolBox.TextSize = 16
toolBox.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", toolBox).CornerRadius = UDim.new(0, 6)

-- status label (shows recognized tool count)
local statusLabel = Instance.new("TextLabel", main)
statusLabel.Size = UDim2.new(0.9, 0, 0, 16)
statusLabel.Position = UDim2.new(0.05, 0, 0, TITLE_HEIGHT + 36)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255,255,255)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Text = "Recognized: " .. tostring(#TOOL_NAMES) .. " tool(s)"

toolBox:GetPropertyChangedSignal("Text"):Connect(function()
    local newList = parseToolNames(toolBox.Text)
    TOOL_NAMES = newList
    statusLabel.Text = "Recognized: " .. tostring(#TOOL_NAMES) .. " tool(s)"
    if FPSDevourer.running then
        -- unequip currently held tools (to avoid sticking to old names) and reset cycle
        pcall(function() FPSDevourer._unequipAll() end)
        FPSDevourer._resetCycle()
    end
end)

-- delay textbox (placed under status)
local delayBox = Instance.new("TextBox", main)
delayBox.Size = UDim2.new(0.9, 0, 0, 26)
delayBox.Position = UDim2.new(0.05, 0, 0, TITLE_HEIGHT + 58)
delayBox.BackgroundColor3 = Color3.fromRGB(186,85,211)
delayBox.PlaceholderText = "Delay (sec) - minimum "..tostring(MIN_DELAY)
delayBox.Text = tostring(SPAM_DELAY)
delayBox.Font = Enum.Font.Gotham
delayBox.TextSize = 16
delayBox.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 6)

delayBox:GetPropertyChangedSignal("Text"):Connect(function()
    local n = tonumber(delayBox.Text)
    if n and n >= MIN_DELAY then
        SPAM_DELAY = n
        if FPSDevourer.running then FPSDevourer._resetCycle() end
    end
end)

-- Toggle button (Start/Stop)
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
    local state = false
    local function updateVisual()
        btn.BackgroundColor3 = state and Color3.fromRGB(186,85,211) or Color3.fromRGB(138,43,226)
        btn.Text = state and "Stop" or "Start"
    end
    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        updateVisual()
    end)
    updateVisual()
    return function(v)
        state = v
        callback(state)
        updateVisual()
    end
end

local setState = makeToggleBtn(main, "Start", BTN_Y0, function(on)
    if on then FPSDevourer.Start() else FPSDevourer.Stop() end
end)

-- on respawn, stop and remove accessories
player.CharacterAdded:Connect(function()
    setState(false)
    task.wait(0.2)
    removeAllAccessoriesFromCharacter()
end)
