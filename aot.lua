local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local attackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Mutation"):WaitForChild("Attack")

local weaponID = "Lannister" 

RunService.Stepped:Connect(function()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local mutationsFolder = workspace:FindFirstChild("Mutations")
    if not mutationsFolder then return end
    
    for _, monster in pairs(mutationsFolder:GetChildren()) do
        local humanoid = monster:FindFirstChildWhichIsA("Humanoid")
        if humanoid and humanoid.Health > 0 then
            
            -- TÌM HITBOX ĐẦU (Dựa trên ảnh của bạn)
            local attackHitbox = monster:FindFirstChild("AttackHitbox")
            if attackHitbox then
                local headModel = attackHitbox:FindFirstChild("Head")
                if headModel then
                    -- LỖI CŨ: headModel.CFrame (Sai vì headModel là Model)
                    -- CÁCH SỬA: Tìm cái Mesh/Part thực sự bên trong Model Head
                    local realHeadPart = headModel:FindFirstChild("Head") or headModel:FindFirstChildWhichIsA("BasePart")
                    
                    if realHeadPart then
                        -- Đưa Part thực sự về phía mình
                        realHeadPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                        
                        -- AURA: Đánh vào cái Part đó
                        attackRemote:FireServer(monster, weaponID, realHeadPart.Name)
                    end
                end
            end
        end
    end
end)
