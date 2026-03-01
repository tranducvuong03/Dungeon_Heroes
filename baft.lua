local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Tìm BuildingTool và RemoteFunction
local buildTool = player.Backpack:FindFirstChild("BuildingTool") or char:FindFirstChild("BuildingTool")
if not buildTool then
    print("❌ LỖI: Không tìm thấy BuildingTool. Hãy chắc chắn bạn đang có cái búa trong kho đồ!")
    return
end

local rf = buildTool:FindFirstChild("RF")
if not rf then
    print("❌ LỖI: Không tìm thấy RemoteFunction (RF) trong búa. Game có thể đã update cấu trúc!")
    return
end

local blockName = "ToyBlock"
local inventoryData = player:WaitForChild("Data"):FindFirstChild(blockName)

-- Kiểm tra xem có đủ block không
if not inventoryData or inventoryData.Value <= 0 then
    print("❌ LỖI: Bạn không có khối " .. blockName .. " nào trong kho đồ để xây!")
    return
end

-- Cấu hình kích thước nhà
local width = 6       -- Chiều rộng (số block)
local length = 6      -- Chiều dài (số block)
local height = 4      -- Chiều cao (số block)
local blockSize = 2   -- Kích thước mặc định của 1 block trong BABFT thường là 2x2x2 studs

-- Tính toán điểm bắt đầu (Xây cách mặt người chơi 10 studs về phía trước)
local forwardOffset = hrp.CFrame.LookVector * 10
local startPos = hrp.Position + forwardOffset
-- Làm tròn tọa độ để block khớp với lưới (Grid) của game
startPos = Vector3.new(math.round(startPos.X), math.round(startPos.Y) - 2, math.round(startPos.Z))

print("🟢 Bắt đầu xây nhà vuông bằng " .. blockName .. "...")

-- Hàm gửi gói tin (packet) lên server để đặt 1 block
local function placeBlock(cframe)
    if inventoryData.Value <= 0 then return false end
    
    -- Các tham số dựa trên script gốc của game:
    -- InvokeServer(Name, InventoryValue, TargetPart, OffsetCFrame, isAnchored, AbsoluteCFrame, SecondaryData)
    rf:InvokeServer(
        blockName, 
        inventoryData.Value, 
        nil,      -- Không bám vào block nào cả (đặt tự do)
        nil,      -- Không có offset tương đối
        true,     -- Anchored (Neo lại cho nhà không đổ)
        cframe,   -- Tọa độ tuyệt đối
        nil       -- Dữ liệu phụ (chỉ dùng cho lò xo, dây thừng...)
    )
    return true
end

-- Vòng lặp tính toán tọa độ (Thuật toán xây tường rỗng)
local blocksPlaced = 0
for y = 0, height - 1 do
    for x = 0, width - 1 do
        for z = 0, length - 1 do
            -- Chỉ xây nếu tọa độ nằm ở cạnh ngoài (tạo thành 4 bức tường)
            if x == 0 or x == width - 1 or z == 0 or z == length - 1 then
                local px = startPos.X + (x * blockSize)
                local py = startPos.Y + (y * blockSize)
                local pz = startPos.Z + (z * blockSize)
                
                local targetCFrame = CFrame.new(px, py, pz)
                
                local success = placeBlock(targetCFrame)
                if not success then
                    print("⚠️ Hết " .. blockName .. " giữa chừng! Đã đặt được " .. blocksPlaced .. " khối.")
                    return
                end
                
                blocksPlaced = blocksPlaced + 1
                -- Delay cực kỳ quan trọng: Tránh bị kick vì spam Remote quá nhanh (Rate Limit)
                task.wait(0.05) 
            end
        end
    end
end

print("✅ Đã hoàn thành ngôi nhà với " .. blocksPlaced .. " khối " .. blockName .. "!")
