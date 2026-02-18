local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UtilityHelper_V4_Full"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 240)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.Parent = frame
layout.Padding = UDim.new(0, 5)
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local BASE_COORDS = Vector3.new(-4.2, -12.0, -15.4)
local TARGET_COORDS = Vector3.new(-84.6, 19.1, -7.1)
local isHeightLocked = false
local noclipEnabled = false
local RunService = game:GetService("RunService")

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

createButton("遠距離キャッチを有効化", function(btn)
    local count = 0
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            obj.MaxActivationDistance = 99999
            obj.RequiresLineOfSight = false
            obj.HoldDuration = 0
            count = count + 1
        elseif obj:IsA("ClickDetector") then
            obj.MaxDistance = 99999
            count = count + 1
        end
    end
    btn.Text = "有効化済み (" .. count .. ")"
    btn.TextColor3 = Color3.fromRGB(0, 255, 255)
end)

-- 2. 基地テレポート ＆ 高さロック
createButton("基地テレポート ＆ 高さ固定", function(btn)
    local player = game.Players.LocalPlayer
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(BASE_COORDS) end

    if isHeightLocked then
        isHeightLocked = false
        btn.Text = "基地テレポート ＆ 高さ固定"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        return
    end

    isHeightLocked = true
    btn.Text = "高さ固定中: ON"
    btn.TextColor3 = Color3.fromRGB(0, 255, 0)

    task.spawn(function()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not isHeightLocked then connection:Disconnect() return end
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local currentPos = rootPart.Position
                rootPart.CFrame = CFrame.new(currentPos.X, BASE_COORDS.Y, currentPos.Z)
                rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, 0, rootPart.AssemblyLinearVelocity.Z)
            end
        end)
    end)
end)

createButton("ogのところー", function(btn)
    local player = game.Players.LocalPlayer
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        isHeightLocked = false -- 高さ固定を解除
        hrp.CFrame = CFrame.new(TARGET_COORDS)
        btn.Text = "tp完了！"
        btn.TextColor3 = Color3.fromRGB(255, 200, 0)
        
        task.wait(1)
        btn.Text = "ogのところー"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

createButton("Noclip: OFF", function(btn)
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        btn.Text = "Noclip: ON"
        btn.TextColor3 = Color3.fromRGB(255, 85, 85) -- 赤っぽく強調
    else
        btn.Text = "Noclip: OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end
end)
