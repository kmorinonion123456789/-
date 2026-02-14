local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UtilityHelper_V2_BaseTP"
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

-- 1. 遠距離キャッチ機能
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

-- 2. 指定座標（基地）へテレポートするボタン
-- 画像の座標: -4.2, -12.0, -15.4
local BASE_COORDS = Vector3.new(-4.2, -12.0, -15.4)

createButton("基地にテレポート", function(btn)
    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        hrp.CFrame = CFrame.new(BASE_COORDS)
        btn.Text = "基地に到着！"
        btn.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        task.delay(1.5, function()
            btn.Text = "基地にテレポート"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    else
        btn.Text = "キャラが見つかりません"
        btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

print("UtilityHelper_V2 (Base TP Mode) Loaded!")
