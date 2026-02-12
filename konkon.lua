local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UtilityHelper_V2"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 60) 
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.Parent = frame
layout.Padding = UDim.new(0, 5)
layout.VerticalAlignment = Enum.VerticalAlignment.Center -- 中央配置
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center


local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSans
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

print("Menu Loaded!")

