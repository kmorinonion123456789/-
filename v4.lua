local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UtilityHelper_V4_HeightLock"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140) 
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.Parent = frame
layout.Padding = UDim.new(0, 8)
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 設定値
local BASE_COORDS = Vector3.new(-4.2, -12.0, -15.4)
local isHeightLocked = false -- 高さを固定中かどうかのフラグ
local RunService = game:GetService("RunService")

-- ボタン作成用の共通関数
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
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

-- 1. 遠距離キャッチ
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
    
    -- 初回テレポート
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(BASE_COORDS)
    end

    -- すでにロック中なら解除、そうでなければ開始（トグル式）
    if isHeightLocked then
        isHeightLocked = false
        btn.Text = "基地テレポート ＆ 高さ固定"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        return
    end

    isHeightLocked = true
    btn.Text = "高さ固定中: ON"
    btn.TextColor3 = Color3.fromRGB(0, 255, 0)

    -- 高さを毎フレーム固定するループ
    -- Heartbeatを使うことで、重力で落ちる前に座標を書き換えます
    task.spawn(function()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not isHeightLocked then 
                connection:Disconnect() -- フラグが折れたらループ終了
                return 
            end

            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                -- 現在のXとZは維持しつつ、Y座標（高さ）だけをBASE_COORDSのものに強制固定
                local currentPos = rootPart.Position
                rootPart.CFrame = CFrame.new(currentPos.X, BASE_COORDS.Y, currentPos.Z)
                -- 落下速度をリセットして、物理演算による引っ掛かりを防止
                rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, 0, rootPart.AssemblyLinearVelocity.Z)
            end
        end)
    end)
end)

print("UtilityHelper_V4 (Height Lock Mode) Loaded for shiun4545!")
