local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Tìm Tool và RemoteFunction
local buildTool = player.Backpack:FindFirstChild("BuildingTool") or char:FindFirstChild("BuildingTool")
if not buildTool then
    print("❌ LỖI: Không tìm thấy BuildingTool.")
    return
end
local rfBuild = buildTool:FindFirstChild("RF")

local paintingTool = player.Backpack:FindFirstChild("PaintingTool") or char:FindFirstChild("PaintingTool")
local rfPaint = paintingTool and paintingTool:FindFirstChild("RF")

-- Cấu hình block
local blockToy = "ToyBlock"
local blockWedge = "Wedge" 
local blockWheelHuge = "HugeBackWheel"
local inventoryToy = player:WaitForChild("Data"):FindFirstChild(blockToy)

if not inventoryToy or inventoryToy.Value <= 0 then
    print("❌ LỖI: Bạn không có khối " .. blockToy .. " nào trong kho đồ để xây!")
    return
end

-- Tính toán điểm bắt đầu
local forwardOffset = hrp.CFrame.LookVector * 15
local startPos = hrp.Position + forwardOffset
startPos = Vector3.new(math.round(startPos.X), math.round(startPos.Y) - 2, math.round(startPos.Z))
local startCFrame = CFrame.new(startPos)

-- ĐỊNH NGHĨA MÀU SẮC (Sử dụng Color3 vì PaintingTool yêu cầu Color3, không dùng BrickColor)
local colorSilver = Color3.fromRGB(192, 192, 192)
local colorOrange = Color3.fromRGB(255, 85, 0)
local colorBlack = Color3.fromRGB(20, 20, 20)

print("🟢 Bắt đầu xây dựng xe (Giai đoạn 1: Đặt Block)...")

local voxelData = {
    -- Nền chính (Màu bạc)
    { pos = Vector3.new(-2, 0, 0), block = blockToy, color = colorSilver },
    { pos = Vector3.new(0, 0, 0), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 0, 0), block = blockToy, color = colorSilver },
    -- Tường bên (Bạc)
    { pos = Vector3.new(-2, 0, 2), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 0, 2), block = blockToy, color = colorSilver },
    { pos = Vector3.new(-2, 0, 4), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 0, 4), block = blockToy, color = colorSilver },
    -- Sọc màu cam
    { pos = Vector3.new(-2, 2, 0), block = blockToy, color = colorOrange },
    { pos = Vector3.new(2, 2, 0), block = blockToy, color = colorOrange },
    -- Thân bạc
    { pos = Vector3.new(-2, 4, 0), block = blockToy, color = colorSilver },
    { pos = Vector3.new(0, 4, 0), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 4, 0), block = blockToy, color = colorSilver },
    -- Mũi xe dốc (Wedge)
    { pos = Vector3.new(-2, 0, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorSilver },
    { pos = Vector3.new(0, 0, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorSilver },
    { pos = Vector3.new(2, 0, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorSilver },
    { pos = Vector3.new(-2, 2, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorSilver },
    { pos = Vector3.new(2, 2, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorSilver },
    -- Kính chắn gió (Đen)
    { pos = Vector3.new(0, 2, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorBlack },
    { pos = Vector3.new(-2, 4, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorBlack },
    { pos = Vector3.new(0, 4, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorBlack },
    { pos = Vector3.new(2, 4, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorBlack },
    -- Mái xe
    { pos = Vector3.new(-2, 6, 0), block = blockToy, color = colorSilver },
    { pos = Vector3.new(0, 6, 0), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 6, 0), block = blockToy, color = colorSilver },
    -- Đuôi xe
    { pos = Vector3.new(-2, 0, 14), block = blockToy, color = colorSilver },
    { pos = Vector3.new(0, 0, 14), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 0, 14), block = blockToy, color = colorSilver },
    { pos = Vector3.new(-2, 2, 14), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 2, 14), block = blockToy, color = colorSilver },
    { pos = Vector3.new(-2, 4, 14), block = blockToy, color = colorSilver },
    { pos = Vector3.new(0, 4, 14), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 4, 14), block = blockToy, color = colorSilver },
    { pos = Vector3.new(-2, 6, 14), block = blockToy, color = colorSilver },
    { pos = Vector3.new(0, 6, 14), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 6, 14), block = blockToy, color = colorSilver },
    -- Cánh gió
    { pos = Vector3.new(-2, 8, 12), block = blockWedge, rot = CFrame.Angles(0, math.pi/2, 0), color = colorSilver },
    { pos = Vector3.new(0, 8, 12), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 8, 12), block = blockWedge, rot = CFrame.Angles(0, -math.pi/2, 0), color = colorSilver },
    -- Bánh xe (Không cần sơn)
    { pos = Vector3.new(-4, -1, 1), block = blockWheelHuge },
    { pos = Vector3.new(4, -1, 1), block = blockWheelHuge },
    { pos = Vector3.new(-4, -1, 13), block = blockWheelHuge },
    { pos = Vector3.new(4, -1, 13), block = blockWheelHuge },
}

-- 1. TẠO BẢN ĐỒ MÀU (Dictionary) DỰA TRÊN TỌA ĐỘ
local expectedColors = {}
local blocksPlaced = 0

for i, data in ipairs(voxelData) do
    local inventoryData = player.Data:FindFirstChild(data.block)
    if not inventoryData then continue end

    local targetCFrame = startCFrame * CFrame.new(data.pos)
    if data.rot then targetCFrame = targetCFrame * data.rot end

    -- Gửi lệnh đặt block
    rfBuild:InvokeServer(data.block, inventoryData.Value, nil, nil, true, targetCFrame, nil)
    blocksPlaced = blocksPlaced + 1
    
    -- Ghi nhớ màu sắc vào Dictionary với Key là chuỗi tọa độ (làm tròn để tránh sai số dấu phẩy động)
    if data.color then
        local pos = targetCFrame.Position
        local key = string.format("%.0f,%.0f,%.0f", pos.X, pos.Y, pos.Z)
        expectedColors[key] = data.color
    end

    task.wait(0.05) 
end

print("✅ Đã xây xong " .. blocksPlaced .. " khối! Đang chờ Server nạp vật lý...")

-- 2. ĐỢI VÀ QUÉT ĐỂ SƠN MÀU (Giai đoạn 2)
if rfPaint then
    task.wait(1.5) -- Đợi 1.5s cho khối hiện hình hoàn toàn trên Workspace
    print("🎨 Bắt đầu sơn màu (Batching)...")
    
    local myBoatFolder = workspace:FindFirstChild("PlayerBoats") and workspace.PlayerBoats:FindFirstChild(player.Name)
    local paintBatch = {}
    
    if myBoatFolder then
        -- Quét các khối trong khu vực của người chơi
        for _, obj in ipairs(myBoatFolder:GetDescendants()) do
            if obj:IsA("BasePart") then
                -- Lấy tọa độ của khối trên sân
                local pos = obj.Position
                local key = string.format("%.0f,%.0f,%.0f", pos.X, pos.Y, pos.Z)
                
                -- Nếu tọa độ này có nằm trong "bản đồ màu" đã lưu -> Nhét vào mảng
                if expectedColors[key] then
                    table.insert(paintBatch, { obj, expectedColors[key] })
                end
            end
        end
        
        -- Gửi mẻ sơn lên Server
        if #paintBatch > 0 then
            rfPaint:InvokeServer(paintBatch)
            print("✅ Đã sơn thành công " .. #paintBatch .. " khối trong 1 nhịp!")
        else
            print("⚠️ Không tìm thấy khối nào khớp tọa độ để sơn.")
        end
    end
else
    print("⚠️ Bỏ qua bước sơn vì không có PaintingTool.")
end
