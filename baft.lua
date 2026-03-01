local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Tìm folder Data
local boatsFolder = workspace:WaitForChild("PlayerBoats")
local myFolder = boatsFolder:WaitForChild(player.Name)
local dataFolder = myFolder:WaitForChild("Data")  -- Nếu là Boat.Data thì đổi thành: myFolder:WaitForChild("Boat"):WaitForChild("Data")

print("Đang đọc folder Data...")

local objectNames = {}
for _, obj in pairs(dataFolder:GetChildren()) do
    table.insert(objectNames, obj.Name .. " (" .. typeof(obj) .. ")")
end

if #objectNames == 0 then
    print("❌ Không tìm thấy object nào trong Data! Chờ boat load đầy hoặc kiểm tra path.")
    return
end

-- Tạo nội dung file
local username = os.getenv("USERNAME") or "User"  -- Tự detect tên user Windows
local downloadsPath = "C:\\Users\\" .. username .. "\\Downloads\\"
local fileName = "BABFT_Data_" .. player.Name .. ".txt"
local fullPath = downloadsPath .. fileName

local content = "DANH SÁCH OBJECTS TRONG FOLDER DATA CỦA " .. player.Name .. "\n"
content = content .. "=====================================\n"
for i, name in ipairs(objectNames) do
    content = content .. i .. ". " .. name .. "\n"
end
content = content .. "=====================================\n"
content = content .. "Tổng cộng: " .. #objectNames .. " objects\n"
content = content .. "Ngày: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"

-- Thử lưu vào Downloads
local success, err = pcall(function()
    writefile(fullPath, content)
end)

if success then
    print("🟢 LƯU THÀNH CÔNG VÀO DOWNLOADS!")
    print("Đường dẫn: " .. fullPath)
    print("Mở File Explorer → Downloads → tìm file " .. fileName)
    print("Nội dung đã lưu:")
    print(content)
    
    -- GUI thông báo
    local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 320, 0, 140)
    frame.Position = UDim2.new(0.5, -160, 0.5, -70)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextScaled = true
    label.Text = "Đã lưu file vào:\nDownloads\\" .. fileName .. "\n\nKiểm tra thư mục Downloads nhé!"
    label.Font = Enum.Font.GothamBold
else
    print("❌ KHÔNG THỂ LƯU VÀO DOWNLOADS (lỗi phổ biến): " .. tostring(err))
    print("Executor thường KHÔNG CHO PHÉP write ra ngoài folder của nó.")
    print("File sẽ lưu mặc định vào folder executor (thường là 'workspace/" .. fileName .. "')")
    
    -- Thử lưu fallback vào workspace/
    pcall(function()
        writefile(fileName, content)
    end)
    print("Đã thử lưu fallback: " .. fileName)
    print("Copy nội dung dưới đây thủ công nếu cần:")
    print(content)
    print("Cách fix: Dùng executor premium như Synapse X cũ (nếu có), hoặc copy console paste vào Notepad → Save as .txt vào Downloads.")
end
