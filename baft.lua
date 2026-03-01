local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Tìm Tool và RemoteFunction cho đặt khối
local buildTool = player.Backpack:FindFirstChild("BuildingTool") or char:FindFirstChild("BuildingTool")
if not buildTool then
    print("❌ LỖI: Không tìm thấy BuildingTool. Hãy chắc chắn bạn đang có cái búa trong kho đồ!")
    return
end

local rfBuild = buildTool:FindFirstChild("RF")
if not rfBuild then
    print("❌ LỖI: Không tìm thấy RemoteFunction (RF) trong búa. Game có thể đã update cấu trúc!")
    return
end

-- Tìm Tool và RemoteFunction cho sơn màu
local paintingTool = player.Backpack:FindFirstChild("PaintingTool") or char:FindFirstChild("PaintingTool")
if not paintingTool then
    print("❌ LỖI: Không tìm thấy PaintingTool. Xe sẽ được xây nhưng không được sơn màu!")
end

local rfPaint = paintingTool and paintingTool:FindFirstChild("RF")

-- Cấu hình block
local blockToy = "ToyBlock"
local blockWedge = "Wedge" -- Sử dụng chêm để tạo độ dốc
local blockWheelHuge = "HugeBackWheel" -- Sử dụng bánh xe lớn cho đúng tỷ lệ
local inventoryToy = player:WaitForChild("Data"):FindFirstChild(blockToy)

-- Kiểm tra xem có đủ block không
if not inventoryToy or inventoryToy.Value <= 0 then
    print("❌ LỖI: Bạn không có khối " .. blockToy .. " nào trong kho đồ để xây!")
    return
end

-- Tính toán điểm bắt đầu (Xây cách mặt người chơi 15 studs về phía trước)
local forwardOffset = hrp.CFrame.LookVector * 15
local startPos = hrp.Position + forwardOffset
-- Làm tròn tọa độ để block khớp với lưới (Grid) của game
startPos = Vector3.new(math.round(startPos.X), math.round(startPos.Y) - 2, math.round(startPos.Z))

local startCFrame = CFrame.new(startPos)

-- Định nghĩa dải màu
local colorSilver = BrickColor.new("Silver")
local colorOrange = BrickColor.new("Bright orange")

print("🟢 Bắt đầu xây dựng chiếc xe khái niệm 3D...")

-- Hàm gửi gói tin để đặt 1 block
local function placeBlock(blockName, inventoryValue, cframe)
    if inventoryValue <= 0 then return false end
    rfBuild:InvokeServer(
        blockName, 
        inventoryValue, 
        nil,      -- Không bám vào block nào cả (đặt tự do)
        nil,      -- Không có offset tương đối
        true,     -- Anchored
        cframe,   -- Tọa độ tuyệt đối
        nil       -- Dữ liệu phụ
    )
    return true
end

-- Hàm gửi gói tin để sơn màu cho block tại tọa độ
local function paintBlock(cframe, color)
    if not rfPaint then return end
    -- BABFT PaintingTool RF yêu cầu Part, nhưng chúng ta không có. 
    -- Chúng ta gửi yêu cầu của PaintingTool lên và Server sẽ phải tìm Part tại CFrame.
    rfPaint:InvokeServer(cframe, color)
end

-- Định nghĩa dữ liệu khối voxel 3D (Tọa độ tương đối XY Z so với startCFrame)
-- Thân xe: Bạc chính (x=±2, x=0), Sọc cam (x=±2 ở y=2), Mái cao (y=6)
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
    -- Sọc màu cam đặc trưng dọc theo cạnh dưới
    { pos = Vector3.new(-2, 2, 0), block = blockToy, color = colorOrange },
    { pos = Vector3.new(2, 2, 0), block = blockToy, color = colorOrange },
    -- Thân bạc phía trên sọc
    { pos = Vector3.new(-2, 4, 0), block = blockToy, color = colorSilver },
    { pos = Vector3.new(0, 4, 0), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 4, 0), block = blockToy, color = colorSilver },
    -- Mũi xe dốc (Sử dụng chêm)
    { pos = Vector3.new(-2, 0, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorSilver },
    { pos = Vector3.new(0, 0, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorSilver },
    { pos = Vector3.new(2, 0, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorSilver },
    { pos = Vector3.new(-2, 2, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorSilver },
    { pos = Vector3.new(2, 2, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = colorSilver },
    -- Kính chắn gió dốc lớn (Màu đen/trong suốt)
    { pos = Vector3.new(0, 2, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = BrickColor.new("Black") },
    { pos = Vector3.new(-2, 4, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = BrickColor.new("Black") },
    { pos = Vector3.new(0, 4, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = BrickColor.new("Black") },
    { pos = Vector3.new(2, 4, -2), block = blockWedge, rot = CFrame.Angles(0, 0, 0), color = BrickColor.new("Black") },
    -- Mái xe cao (y=6)
    { pos = Vector3.new(-2, 6, 0), block = blockToy, color = colorSilver },
    { pos = Vector3.new(0, 6, 0), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 6, 0), block = blockToy, color = colorSilver },
    -- Phần đuôi xe cao, cụt
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
    -- Cánh gió sau tích hợp sau mui xe
    { pos = Vector3.new(-2, 8, 12), block = blockWedge, rot = CFrame.Angles(0, math.pi/2, 0), color = colorSilver },
    { pos = Vector3.new(0, 8, 12), block = blockToy, color = colorSilver },
    { pos = Vector3.new(2, 8, 12), block = blockWedge, rot = CFrame.Angles(0, -math.pi/2, 0), color = colorSilver },
    -- Bánh xe (Đặt ở các góc)
    { pos = Vector3.new(-4, -1, 1), block = blockWheelHuge },
    { pos = Vector3.new(4, -1, 1), block = blockWheelHuge },
    { pos = Vector3.new(-4, -1, 13), block = blockWheelHuge },
    { pos = Vector3.new(4, -1, 13), block = blockWheelHuge },
}

-- Vòng lặp xây dựng
local blocksPlaced = 0
for i, data in ipairs(voxelData) do
    local inventoryData = player.Data:FindFirstChild(data.block)
    if not inventoryData then
        print("⚠️ Cảnh báo: Bạn không sở hữu block loại: " .. data.block)
        continue
    end

    local targetCFrame = startCFrame * CFrame.new(data.pos)
    if data.rot then
        targetCFrame = targetCFrame * data.rot
    end

    local success = placeBlock(data.block, inventoryData.Value, targetCFrame)
    if not success then
        print("⚠️ Hết " .. data.block .. " giữa chừng! Đã đặt được " .. blocksPlaced .. " khối.")
        break
    end

    blocksPlaced = blocksPlaced + 1
    
    -- Sơn màu ngay sau khi đặt
    if data.color then
        paintBlock(targetCFrame, data.color)
    end

    -- Delay để tránh bị kick vì spam Remote quá nhanh
    task.wait(0.05) 
end

print("✅ Đã hoàn thành chiếc xe khái niệm 3D với " .. blocksPlaced .. " khối!")
