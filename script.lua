-- Tạo bởi: B - Dungeon Heroes Auto Chest (Multiselect Version)

local player = game.Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Clear old GUI
for _, gui in pairs(coreGui:GetChildren()) do
    if gui:IsA("ScreenGui") and gui.Name == "MySimpleChestGUI" then
        gui:Destroy()
    end
end

-- Biến cấu hình
getgenv().simpleAutoEnabled = false
getgenv().selectedChest = "NightmareBoosterChest" -- Mặc định
local isMinimized = false

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MySimpleChestGUI"
screenGui.Parent = coreGui
screenGui.ResetOnSpawn = false

-- Khung chính (Tăng nhẹ chiều cao để thêm nút chọn)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 220)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Tiêu đề
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Multi-Auto Chest - By B"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- Nút thu nhỏ
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -30, 0, 0)
minimizeButton.Text = "-"
minimizeButton.Parent = mainFrame

-- Nút chọn loại Chest (MỚI)
local selectChestBtn = Instance.new("TextButton")
selectChestBtn.Size = UDim2.new(0.8, 0, 0, 30)
selectChestBtn.Position = UDim2.new(0.1, 0, 0, 40)
selectChestBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 100) -- Màu tím Valentine
selectChestBtn.Text = "Chest: Nightmare"
selectChestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
selectChestBtn.Font = Enum.Font.SourceSansItalic
selectChestBtn.TextSize = 16
selectChestBtn.Parent = mainFrame

-- Trạng thái label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 70)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Trạng thái: TẮT"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Parent = mainFrame

-- Toggle Button (bật/tắt auto)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleButton.Position = UDim2.new(0.1, 0, 0, 100)
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleButton.Text = "BẬT AUTO"
toggleButton.Parent = mainFrame

-- Manual Button
local manualButton = Instance.new("TextButton")
manualButton.Size = UDim2.new(0.8, 0, 0, 40)
manualButton.Position = UDim2.new(0.1, 0, 0, 150)
manualButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
manualButton.Text = "Mở 5x Ngay"
manualButton.Parent = mainFrame

-- Logic chuyển đổi loại Chest
selectChestBtn.MouseButton1Click:Connect(function()
    if getgenv().selectedChest == "NightmareBoosterChest" then
        getgenv().selectedChest = "ValentinesBoosterChest"
        selectChestBtn.Text = "Chest: Valentines"
        selectChestBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 100) -- Đổi màu cho dễ nhận diện
    else
        getgenv().selectedChest = "NightmareBoosterChest"
        selectChestBtn.Text = "Chest: Nightmare"
        selectChestBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 100)
    end
end)

-- Logic thu nhỏ
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Size = isMinimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 220)
    minimizeButton.Text = isMinimized and "+" or "-"
end)

-- Hàm cập nhật trạng thái
local function updateStatus()
    statusLabel.Text = "Trạng thái: " .. (getgenv().simpleAutoEnabled and "BẬT" or "TẮT")
    toggleButton.BackgroundColor3 = getgenv().simpleAutoEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
    toggleButton.Text = getgenv().simpleAutoEnabled and "TẮT AUTO" or "BẬT AUTO"
end

toggleButton.MouseButton1Click:Connect(function()
    getgenv().simpleAutoEnabled = not getgenv().simpleAutoEnabled
    updateStatus()
end)

-- Hàm thực thi Remote
local function fireChestRemote()
    pcall(function()
        replicatedStorage.Systems.ChestShop.OpenChest:InvokeServer(getgenv().selectedChest, 5)
    end)
end

manualButton.MouseButton1Click:Connect(fireChestRemote)

-- Auto loop (nền) sử dụng task.wait để tối ưu hơn wait
task.spawn(function()
    while true do
        task.wait(math.random(90, 110)/100)
        if getgenv().simpleAutoEnabled then
            fireChestRemote()
        end
    end
end)

-- (Giữ nguyên logic Drag của bạn...)
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y - mainFrame.AbsolutePosition.Y <= 30 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

updateStatus()
print("GUI Loaded! Bạn có thể nhấn vào nút 'Chest: ...' để đổi loại rương.")
