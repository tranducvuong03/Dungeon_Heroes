-- Dynamic Chest Shop UI - Tự động detect shop & chests (No Hardcode!)
-- Delta Executor Friendly | By Grok for B
-- Detects all chests từ Items.ItemData, group by Type (shop), lấy title từ modules

local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

-- Clear old GUI
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui.Name == "DynamicChestGUI" then gui:Destroy() end
end

-- Load data động
local ItemData, ShopTypesData
local chestsByShop = {}
local shopList = {}
local success, err = pcall(function()
    local ItemsMod = require(RS.Systems.Items)
    ItemData = debug.getupvalue(ItemsMod.GetItemData, 1)
    
    local ChestMod = require(RS.Systems.ChestShop)
    ShopTypesData = debug.getupvalue(ChestMod.GetChestTypeData, 1)
end)

if success and ItemData then
    for name, data in pairs(ItemData) do
        if data.Category == "Chest" then
            local typ = data.Type
            if not chestsByShop[typ] then
                chestsByShop[typ] = {}
                table.insert(shopList, typ)
            end
            table.insert(chestsByShop[typ], name)
        end
    end
    -- Sort
    table.sort(shopList)
    for typ, lst in pairs(chestsByShop) do
        table.sort(lst)
    end
    print("Detected " .. #shopList .. " shops with " .. (function() local t=0 for _ in pairs(chestsByShop) do t=t+1 end return t end)() .. " total chests!")
else
    warn("Failed to load ItemData (debug.getupvalue not supported?): " .. tostring(err) .. " | Use manual chest name in game GUI.")
end

-- Helper functions
local function getShopTitle(typ)
    if ShopTypesData and ShopTypesData[typ] then
        return ShopTypesData[typ].Title or typ
    end
    return typ:gsub("^%l", string.upper)
end

local function getChestTitle(name)
    local data = ItemData and ItemData[name]
    return data and data.MenuTitle or name
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DynamicChestGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 460, 0, 380)
mainFrame.Position = UDim2.new(0.5, -230, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 40)
title.Position = UDim2.new(0, 15, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Dynamic Chest Shop Auto"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = mainFrame
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Shops Scroller (Left)
local shopsScroll = Instance.new("ScrollingFrame")
shopsScroll.Name = "ShopsScroll"
shopsScroll.Size = UDim2.new(0, 215, 0, 220)
shopsScroll.Position = UDim2.new(0, 15, 0, 55)
shopsScroll.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
shopsScroll.BorderSizePixel = 0
shopsScroll.ScrollBarThickness = 6
shopsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
shopsScroll.Parent = mainFrame
local shopsCorner = Instance.new("UICorner")
shopsCorner.CornerRadius = UDim.new(0, 8)
shopsCorner.Parent = shopsScroll

local shopsLayout = Instance.new("UIListLayout")
shopsLayout.SortOrder = Enum.SortOrder.LayoutOrder
shopsLayout.Padding = UDim.new(0, 4)
shopsLayout.Parent = shopsScroll

-- Chests Scroller (Right)
local chestsScroll = Instance.new("ScrollingFrame")
chestsScroll.Name = "ChestsScroll"
chestsScroll.Size = UDim2.new(0, 215, 0, 220)
chestsScroll.Position = UDim2.new(0, 235, 0, 55)
chestsScroll.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
chestsScroll.BorderSizePixel = 0
chestsScroll.ScrollBarThickness = 6
chestsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
chestsScroll.Parent = mainFrame
local chestsCorner = Instance.new("UICorner")
chestsCorner.CornerRadius = UDim.new(0, 8)
chestsCorner.Parent = chestsScroll

local chestsLayout = Instance.new("UIListLayout")
chestsLayout.SortOrder = Enum.SortOrder.LayoutOrder
chestsLayout.Padding = UDim.new(0, 4)
chestsLayout.Parent = chestsScroll

-- Controls Bottom
local amountBox = Instance.new("TextBox")
amountBox.Name = "AmountBox"
amountBox.Size = UDim2.new(0, 70, 0, 40)
amountBox.Position = UDim2.new(0, 15, 0, 285)
amountBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
amountBox.Text = "5"
amountBox.TextColor3 = Color3.fromRGB(255, 255, 255)
amountBox.PlaceholderText = "1-5"
amountBox.Font = Enum.Font.Gotham
amountBox.TextSize = 24
amountBox.TextScaled = true
amountBox.Parent = mainFrame
local amountCorner = Instance.new("UICorner")
amountCorner.CornerRadius = UDim.new(0, 8)
amountCorner.Parent = amountBox

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 110, 0, 40)
toggleBtn.Position = UDim2.new(0, 95, 0, 285)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
toggleBtn.Text = "Auto: OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.TextSize = 16
toggleBtn.Parent = mainFrame
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

local manualBtn = Instance.new("TextButton")
manualBtn.Name = "ManualBtn"
manualBtn.Size = UDim2.new(0, 110, 0, 40)
manualBtn.Position = UDim2.new(0, 215, 0, 285)
manualBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
manualBtn.Text = "Open 5"
manualBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
manualBtn.Font = Enum.Font.GothamSemibold
manualBtn.TextSize = 16
manualBtn.Parent = mainFrame
local manualCorner = Instance.new("UICorner")
manualCorner.CornerRadius = UDim.new(0, 8)
manualCorner.Parent = manualBtn

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -30, 0, 30)
statusLabel.Position = UDim2.new(0, 15, 0, 335)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Chọn Shop → Chọn Chest → Set Amount → Bật Auto!"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Variables
local selectedShop = nil
local selectedChest = nil
local selectedAmount = 5
getgenv().dynAutoEnabled = false

-- Functions
local function updateStatus()
    local shopTxt = selectedShop and getShopTitle(selectedShop) or "None"
    local chestTxt = selectedChest and getChestTitle(selectedChest) or "None"
    statusLabel.Text = string.format("Shop: %s | Chest: %s | Amount: %d | Auto: %s", shopTxt, chestTxt, selectedAmount, getgenv().dynAutoEnabled and "ON" or "OFF")
    manualBtn.Text = selectedChest and ("Open " .. selectedAmount) or "Select Chest"
    toggleBtn.BackgroundColor3 = getgenv().dynAutoEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 90)
    toggleBtn.Text = "Auto: " .. (getgenv().dynAutoEnabled and "ON" or "OFF")
end

local function populateChests()
    for _, child in pairs(chestsScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    if selectedShop and chestsByShop[selectedShop] then
        local shopChests = chestsByShop[selectedShop]
        for _, cname in ipairs(shopChests) do
            local cbtn = Instance.new("TextButton")
            cbtn.Size = UDim2.new(1, -10, 0, 32)
            cbtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            cbtn.Text = getChestTitle(cname)
            cbtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            cbtn.Font = Enum.Font.Gotham
            cbtn.TextSize = 13
            cbtn.TextClips = true
            cbtn.Parent = chestsScroll
            local cCorner = Instance.new("UICorner")
            cCorner.CornerRadius = UDim.new(0, 6)
            cCorner.Parent = cbtn
            cbtn.MouseButton1Click:Connect(function()
                selectedChest = cname
                updateStatus()
            end)
        end
        chestsScroll.CanvasSize = UDim2.new(0, 0, 0, chestsLayout.AbsoluteContentSize.Y + 10)
    else
        chestsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    end
end

-- Populate Shops
for i, typ in ipairs(shopList) do
    local sbtn = Instance.new("TextButton")
    sbtn.Size = UDim2.new(1, -10, 0, 36)
    sbtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    sbtn.Text = getShopTitle(typ)
    sbtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sbtn.Font = Enum.Font.GothamSemibold
    sbtn.TextSize = 14
    sbtn.Parent = shopsScroll
    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(0, 6)
    sCorner.Parent = sbtn
    sbtn.MouseButton1Click:Connect(function()
        selectedShop = typ
        populateChests()
        updateStatus()
    end)
end
shopsScroll.CanvasSize = UDim2.new(0, 0, 0, shopsLayout.AbsoluteContentSize.Y + 10)

-- Events
amountBox.FocusLost:Connect(function(enterPressed)
    local num = tonumber(amountBox.Text)
    if num then
        selectedAmount = math.clamp(math.floor(num), 1, 5)
        amountBox.Text = tostring(selectedAmount)
    else
        amountBox.Text = tostring(selectedAmount)
    end
    updateStatus()
end)

toggleBtn.MouseButton1Click:Connect(function()
    getgenv().dynAutoEnabled = not getgenv().dynAutoEnabled
    updateStatus()
end)

manualBtn.MouseButton1Click:Connect(function()
    if selectedChest then
        pcall(function()
            RS.Systems.ChestShop.OpenChest:InvokeServer(selectedChest, selectedAmount)
        end)
    end
end)

-- Auto Loop
spawn(function()
    while wait(math.random(95, 105)/100) do
        if getgenv().dynAutoEnabled and selectedChest then
            pcall(function()
                RS.Systems.ChestShop.OpenChest:InvokeServer(selectedChest, selectedAmount)
            end)
        end
    end
end)

-- Stop All (toggle off)
-- Drag Frame
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil
local dragObj = title  -- Drag on title

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

dragObj.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

dragObj.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Init
updateStatus()
print("✅ Dynamic Chest Shop UI Loaded! | Detected shops: " .. #shopList .. " | Kéo title để di chuyển.")
