local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- CÁC CÔNG CỤ (Vui lòng để sẵn trong Backpack)
local function getToolRF(toolName, rfName)
    local tool = player.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
    if tool then return tool:FindFirstChild(rfName) end
    return nil
end

local rfBuild = getToolRF("BuildingTool", "RF")
local rfScale = getToolRF("ScalingTool", "RF")
local rfPaint = getToolRF("PaintingTool", "RF")

if not rfBuild or not rfScale then
    print("❌ LỖI TỐI KHẨN: Bạn cần CÓ SẴN CẢ CÁI BÚA VÀ THƯỚC ĐO (ScalingTool) trong Balo!")
    return
end

-- Tọa độ mốc
local forwardOffset = hrp.CFrame.LookVector * 15
local startPos = hrp.Position + forwardOffset
startPos = Vector3.new(math.round(startPos.X), math.round(startPos.Y) - 2, math.round(startPos.Z))
local startCFrame = CFrame.new(startPos)

-- Bảng Màu
local cBody = Color3.fromRGB(255, 60, 0) -- Màu Cam Lambo
local cGlass = Color3.fromRGB(15, 15, 15) -- Kính đen bóng
local cMetal = Color3.fromRGB(80, 80, 80) -- Màu mâm/gầm
local cLight = Color3.fromRGB(255, 255, 255) -- Đèn pha

print("🏎️ Đang tiến hành sản xuất Siêu Xe Lamborghini (Tích hợp Auto-Scale)...")

-- BẢN VẼ CAO CẤP (Tích hợp Tọa độ + Kích thước Scale)
-- Cấu trúc: { Loại khối, Tọa độ tương đối X-Y-Z, Kích thước X-Y-Z, Góc xoay, Màu sắc }
local blueprint = {
    -- 1. KHUNG GẦM DƯỚI CÙNG (Gầm siêu thấp, siêu mỏng)
    { b="MetalBlock", pos=Vector3.new(0, -0.5, 6), size=Vector3.new(6, 0.2, 16), color=cMetal },

    -- 2. THÂN XE CƠ BẢN (Đã bóp dẹp và kéo dài)
    -- Lườn xe 2 bên
    { b="ToyBlock", pos=Vector3.new(-2.5, 0.5, 6), size=Vector3.new(1, 2, 16), color=cBody },
    { b="ToyBlock", pos=Vector3.new(2.5, 0.5, 6), size=Vector3.new(1, 2, 16), color=cBody },
    -- Khối động cơ sau
    { b="ToyBlock", pos=Vector3.new(0, 1, 11), size=Vector3.new(4, 3, 6), color=cBody },
    
    -- 3. MŨI XE VÁT CHÉO VÀ DÀI (Đặc trưng Lambo)
    -- Mũi nhọn mỏng phía trước
    { b="Wedge", pos=Vector3.new(0, 0.5, -1), size=Vector3.new(4, 1.5, 4), rot=CFrame.Angles(0, 0, 0), color=cBody },
    -- Lưỡi cản gió trước (Splitter mỏng dính)
    { b="MetalBlock", pos=Vector3.new(0, -0.2, -2.5), size=Vector3.new(6, 0.1, 2), color=cGlass },

    -- 4. ĐÈN PHA MẮT HÍ
    { b="NeonBlock", pos=Vector3.new(-2, 1, -1), size=Vector3.new(1.5, 0.2, 0.5), rot=CFrame.Angles(math.rad(15), -math.rad(15), 0), color=cLight },
    { b="NeonBlock", pos=Vector3.new(2, 1, -1), size=Vector3.new(1.5, 0.2, 0.5), rot=CFrame.Angles(math.rad(15), math.rad(15), 0), color=cLight },

    -- 5. KÍNH CHẮN GIÓ (Độ dốc thoải dài mượt mà)
    -- Kính chính
    { b="Wedge", pos=Vector3.new(0, 2.5, 3), size=Vector3.new(4, 2.5, 6), rot=CFrame.Angles(0, 0, 0), color=cGlass },
    -- Mái kính vuốt xuống
    { b="Wedge", pos=Vector3.new(0, 3.5, 7.5), size=Vector3.new(4, 0.5, 3), rot=CFrame.Angles(0, math.pi, 0), color=cGlass },

    -- 6. CÁNH GIÓ SAU (Spoiler)
    -- Chân đế
    { b="MetalBlock", pos=Vector3.new(-2, 3, 13.5), size=Vector3.new(0.2, 1.5, 0.5), color=cGlass },
    { b="MetalBlock", pos=Vector3.new(2, 3, 13.5), size=Vector3.new(0.2, 1.5, 0.5), color=cGlass },
    -- Bản cánh gió siêu mỏng ngang
    { b="MetalBlock", pos=Vector3.new(0, 4, 14), size=Vector3.new(5.5, 0.1, 2), rot=CFrame.Angles(math.rad(5), 0, 0), color=cGlass },

    -- 7. BÁNH XE (Kéo lùi ra ngoài để thân xe nhìn ngầu hơn)
    { b="HugeBackWheel", pos=Vector3.new(-3.5, 0, 1), size=Vector3.new(2,2,2) },
    { b="HugeBackWheel", pos=Vector3.new(3.5, 0, 1), size=Vector3.new(2,2,2) },
    { b="HugeBackWheel", pos=Vector3.new(-3.5, 0, 12), size=Vector3.new(2,2,2) },
    { b="HugeBackWheel", pos=Vector3.new(3.5, 0, 12), size=Vector3.new(2,2,2) },
}

local expectedColors = {}
local blocksPlaced = 0

for i, data in ipairs(blueprint) do
    local invData = player.Data:FindFirstChild(data.b)
    if not invData or invData.Value <= 0 then 
        print("⚠️ Cảnh báo: Bạn hết khối " .. data.b)
        continue 
    end

    -- Tính tọa độ tuyệt đối
    local targetCFrame = startCFrame * CFrame.new(data.pos)
    if data.rot then targetCFrame = targetCFrame * data.rot end

    -- 1. ĐẶT KHỐI
    rfBuild:InvokeServer(data.b, invData.Value, nil, nil, true, targetCFrame, nil)
    blocksPlaced = blocksPlaced + 1
    task.wait(0.03) -- Chờ đặt xong

    -- 2. TÌM VÀ THU PHÓNG (SCALE) KHỐI VỪA ĐẶT
    -- Để Scale, Server yêu cầu Model thực sự. Ta quét vùng nhỏ quanh tọa độ vừa đặt để bắt nó.
    local Region = Region3.new(targetCFrame.Position - Vector3.new(1,1,1), targetCFrame.Position + Vector3.new(1,1,1))
    local partsInRegion = workspace:FindPartsInRegion3(Region, nil, 50)
    
    local placedModel = nil
    for _, part in ipairs(partsInRegion) do
        if part.Parent and part.Parent.Name == data.b and part.Parent.Parent.Name == player.Name then
            placedModel = part.Parent
            break
        end
    end

    -- Nếu tìm thấy khối vừa đặt, gửi lệnh ÉP KÍCH THƯỚC lên Server
    if placedModel and data.size then
        -- Gửi lệnh Scale: (Model, Kích thước mới, Tọa độ mới - vì khi scale tâm có thể bị lệch)
        rfScale:InvokeServer(placedModel, data.size, targetCFrame)
    end

    -- Lưu màu sắc để sơn sau
    if data.color then
        local key = string.format("%.1f,%.1f,%.1f", targetCFrame.Position.X, targetCFrame.Position.Y, targetCFrame.Position.Z)
        expectedColors[key] = data.color
    end

    task.wait(0.05)
end

print("✅ Đã xây & ép tỉ lệ xong " .. blocksPlaced .. " khối! Đang đợi 2 giây để nạp vật lý...")

-- GIAI ĐOẠN 2: TÔ MÀU
if rfPaint then
    task.wait(2) 
    print("🎨 Bắt đầu sơn xe...")
    
    local myBoatFolder = workspace:FindFirstChild("PlayerBoats") and workspace.PlayerBoats:FindFirstChild(player.Name)
    local paintBatch = {}
    
    if myBoatFolder then
        for _, obj in ipairs(myBoatFolder:GetDescendants()) do
            if obj:IsA("BasePart") then
                local key = string.format("%.1f,%.1f,%.1f", obj.Position.X, obj.Position.Y, obj.Position.Z)
                if expectedColors[key] then
                    table.insert(paintBatch, { obj, expectedColors[key] })
                end
            end
        end
        
        if #paintBatch > 0 then
            rfPaint:InvokeServer(paintBatch)
            print("✅ Đã sơn mượt mà!")
        end
    end
end
