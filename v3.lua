local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UtilityHelper_V3_InfiniteWatch"
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
local FALL_THRESHOLD = -25 -- この高さ以下で自動引き戻し
local isWatching = false -- 監視状態のフラグ

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
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
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

-- 2. 基地テレポート ＆ 永続監視開始
createButton("基地テレポート(自動復帰ON)", function(btn)
    local player = game.Players.LocalPlayer
    
    -- 最初の一回テレポート
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(BASE_COORDS)
    end

    -- すでに監視中なら二重起動しない
    if isWatching then 
        btn.Text = "再テレポート完了"
        task.wait(1)
        btn.Text = "自動復帰: 稼働中"
        return 
    end

    isWatching = true
    btn.Text = "自動復帰: 稼働中"
    btn.TextColor3 = Color3.fromRGB(0, 255, 0)

    -- 永続ループ開始
    task.spawn(function()
        while true do
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if rootPart then
                -- 高さが閾値より低くなったら座標を戻す
                if rootPart.Position.Y < FALL_THRESHOLD then
                    rootPart.CFrame = CFrame.new(BASE_COORDS)
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- 落下加速を消す
                    print(" shiun4545: 落下を検知したため基地へ戻しました。")
                end
            end
            task.wait(0.5) -- サーバー負荷を考えて0.5秒おきにチェック
        end
    end)
end)

print("UtilityHelper_V3 (Infinite Loop Mode) Loaded!")
