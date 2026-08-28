local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local AutoCast = false
local AutoMinigame = false
local AutoSell = false
local SellDelay = 5

-- ตัวแปรเปิด/ปิด Auto Skill แต่ละสกิลแยกกัน
local SkillZ = false
local SkillX = false
local SkillC = false
local SkillV = false

local UIPath = LocalPlayer:WaitForChild("PlayerGui")
local Events = ReplicatedStorage:WaitForChild("Events")
local FishingEvent = Events:WaitForChild("Fishing")

local SellEvent = Events:FindFirstChild("SellAll") 
               or Events:FindFirstChild("Sell") 
               or Events:FindFirstChild("SellFish")
               or (Events:FindFirstChild("Merchant") and Events.Merchant:FindFirstChild("SellAll"))

local Window = Rayfield:CreateWindow({
    Name = "Heavyweight Fishing | by Nicha",
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "by Nicha",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- แท็บ UI (เรียงลำดับใหม่)
local TabFishing = Window:CreateTab("🎣 Auto Fishing", 0)
local TabSkills = Window:CreateTab("⚡ Auto Skill", 0)
local TabSelling = Window:CreateTab("💸 Selling", 0)
local TabTeleport = Window:CreateTab("🏝️ Teleport", 0)

-- 1. แท็บ Auto Fishing 🎣
TabFishing:CreateToggle({
    Name = "Auto Cast",
    CurrentValue = false,
    Callback = function(Value)
        AutoCast = Value
    end,
})

TabFishing:CreateToggle({
    Name = "Lock Minigame Bar",
    CurrentValue = false,
    Callback = function(Value)
        AutoMinigame = Value
    end,
})

-- 2. แท็บ Auto Skill ⚡ (แยกเปิด/ปิดเป็นรายสกิล)
TabSkills:CreateToggle({
    Name = "Auto Skill Z",
    CurrentValue = false,
    Callback = function(Value)
        SkillZ = Value
    end,
})

TabSkills:CreateToggle({
    Name = "Auto Skill X",
    CurrentValue = false,
    Callback = function(Value)
        SkillX = Value
    end,
})

TabSkills:CreateToggle({
    Name = "Auto Skill C",
    CurrentValue = false,
    Callback = function(Value)
        SkillC = Value
    end,
})

TabSkills:CreateToggle({
    Name = "Auto Skill V",
    CurrentValue = false,
    Callback = function(Value)
        SkillV = Value
    end,
})

-- 3. แท็บ Selling 💸
TabSelling:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Callback = function(Value)
        AutoSell = Value
    end,
})

TabSelling:CreateSlider({
    Name = "Auto Sell Interval",
    Range = {1, 60},
    Increment = 1,
    Suffix = "วินาที",
    CurrentValue = 5,
    Callback = function(Value)
        SellDelay = Value
    end,
})

TabSelling:CreateButton({
    Name = "Sell All Fish",
    Callback = function()
        if SellEvent then
            SellEvent:FireServer()
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "ไม่พบ RemoteEvent สำหรับขายปลา",
                Duration = 3
            })
        end
    end,
})

-- 4. แท็บ Teleport 🏝️
local IslandsList = {
    {"Beginning Isle", Vector3.new(-200.686, 11.0587, 35.9142)},
    {"Bamboo Isle", Vector3.new(-1223, 7.28001, -24.1)},
    {"Fallout Isle", Vector3.new(65.5001, 8.78001, 1181.3)},
    {"Sovereign Isle", Vector3.new(-1276.4, 8.78001, 1239.7)},
    {"Perch Isle", Vector3.new(-61.99, 11.9149, -1321.42)},
    {"Frost Isle", Vector3.new(-1365.99, 11.9149, -1495.42)},
    {"Coconut Isle", Vector3.new(1493.61, 9.11487, -1430.62)},
    {"Amber Isle", Vector3.new(1259.41, 9.11487, 1401.48)},
    {"Battlefield Isle", Vector3.new(1393.49, 11.3362, 169.63)},
    {"Mistpeak Isle", Vector3.new(2660.22, 8.78001, -86.7163)}
}

for _, islandData in ipairs(IslandsList) do
    local name = islandData[1]
    local pos = islandData[2]
    
    TabTeleport:CreateButton({
        Name = "TP to " .. name,
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end,
    })
end

-- ระบบล็อกแถบมินิเกมตรงกลาง
RunService.RenderStepped:Connect(function()
    if AutoMinigame then
        local mainGui = UIPath:FindFirstChild("MainGui")
        if mainGui then
            local fishing = mainGui:FindFirstChild("Fishing")
            if fishing and fishing.Visible then
                local barFrame = fishing:FindFirstChild("BarFrame")
                if barFrame then
                    local bar = barFrame:FindFirstChild("Bar")
                    if bar then
                        bar.AnchorPoint = Vector2.new(0.5, 0.5)
                        bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                    end
                end
            end
        end
    end
end)

-- ฟังก์ชันเช็กว่า ProgressionBar กำลังทำงานอยู่หรือไม่
local function isProgressionBarActive()
    local mainGui = UIPath:FindFirstChild("MainGui")
    if mainGui then
        local fishing = mainGui:FindFirstChild("Fishing")
        if fishing and fishing.Visible then
            local progBar = fishing:FindFirstChild("ProgressionBar")
            if progBar and progBar.Visible then
                return true
            end
        end
    end
    return false
end

-- ฟังก์ชันสำหรับส่งคำสั่งจำลองการกดปุ่ม
local function pressKey(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

-- ระบบ Auto Skill เช็กปุ่มตาม Toggle ที่เปิดไว้
task.spawn(function()
    while true do
        task.wait(0.3)
        if SkillZ then pressKey(Enum.KeyCode.Z) task.wait(0.1) end
        if SkillX then pressKey(Enum.KeyCode.X) task.wait(0.1) end
        if SkillC then pressKey(Enum.KeyCode.C) task.wait(0.1) end
        if SkillV then pressKey(Enum.KeyCode.V) task.wait(0.1) end
    end
end)

-- ระบบเหวี่ยงเบ็ดอัตโนมัติ
task.spawn(function()
    while true do
        task.wait(0.3)
        if AutoCast then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local castCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -15)
                FishingEvent:FireServer(castCFrame)
                
                task.wait(1.5)

                repeat
                    task.wait(0.1)
                until isProgressionBarActive() or not AutoCast

                if AutoCast then
                    repeat
                        task.wait(0.1)
                    until not isProgressionBarActive() or not AutoCast
                end

                task.wait(1)
            end
        end
    end
end)

-- ระบบ Auto Sell ทำงานตามเวลาที่ตั้งไว้
task.spawn(function()
    while true do
        task.wait(SellDelay)
        if AutoSell and SellEvent then
            SellEvent:FireServer()
        end
    end
end)
-- แท็บ UI (เรียงลำดับใหม่)
local TabFishing = Window:CreateTab("🎣 Auto Fishing", 0)
local TabSkills = Window:CreateTab("⚡ Auto Skill", 0)
local TabSelling = Window:CreateTab("💸 Selling", 0)
local TabTeleport = Window:CreateTab("🏝️ Teleport", 0)

-- 1. แท็บ Auto Fishing 🎣
TabFishing:CreateToggle({
    Name = "Auto Cast (เช็ก ProgressionBar)",
    CurrentValue = false,
    Callback = function(Value)
        AutoCast = Value
    end,
})

TabFishing:CreateToggle({
    Name = "Lock Minigame Bar (ล็อกแถบตรงกลาง)",
    CurrentValue = false,
    Callback = function(Value)
        AutoMinigame = Value
    end,
})

-- 2. แท็บ Auto Skill ⚡ (แยกเปิด/ปิดเป็นรายสกิล)
TabSkills:CreateToggle({
    Name = "Auto Skill Z",
    CurrentValue = false,
    Callback = function(Value)
        SkillZ = Value
    end,
})

TabSkills:CreateToggle({
    Name = "Auto Skill X",
    CurrentValue = false,
    Callback = function(Value)
        SkillX = Value
    end,
})

TabSkills:CreateToggle({
    Name = "Auto Skill C",
    CurrentValue = false,
    Callback = function(Value)
        SkillC = Value
    end,
})

TabSkills:CreateToggle({
    Name = "Auto Skill V",
    CurrentValue = false,
    Callback = function(Value)
        SkillV = Value
    end,
})

-- 3. แท็บ Selling 💸
TabSelling:CreateToggle({
    Name = "Auto Sell Fish (ขายปลาอัตโนมัติ)",
    CurrentValue = false,
    Callback = function(Value)
        AutoSell = Value
    end,
})

TabSelling:CreateSlider({
    Name = "Auto Sell Interval (วินาที)",
    Range = {1, 60},
    Increment = 1,
    Suffix = "วินาที",
    CurrentValue = 5,
    Callback = function(Value)
        SellDelay = Value
    end,
})

TabSelling:CreateButton({
    Name = "Sell All Fish (ขายปลาทั้งหมดที่ไม่ได้ Favorite)",
    Callback = function()
        if SellEvent then
            SellEvent:FireServer()
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "ไม่พบ RemoteEvent สำหรับขายปลา",
                Duration = 3
            })
        end
    end,
})

-- 4. แท็บ Teleport 🏝️
local IslandsList = {
    {"Beginning Isle", Vector3.new(-200.686, 11.0587, 35.9142)},
    {"Bamboo Isle", Vector3.new(-1223, 7.28001, -24.1)},
    {"Fallout Isle", Vector3.new(65.5001, 8.78001, 1181.3)},
    {"Sovereign Isle", Vector3.new(-1276.4, 8.78001, 1239.7)},
    {"Perch Isle", Vector3.new(-61.99, 11.9149, -1321.42)},
    {"Frost Isle", Vector3.new(-1365.99, 11.9149, -1495.42)},
    {"Coconut Isle", Vector3.new(1493.61, 9.11487, -1430.62)},
    {"Amber Isle", Vector3.new(1259.41, 9.11487, 1401.48)},
    {"Battlefield Isle", Vector3.new(1393.49, 11.3362, 169.63)},
    {"Mistpeak Isle", Vector3.new(2660.22, 8.78001, -86.7163)}
}

for _, islandData in ipairs(IslandsList) do
    local name = islandData[1]
    local pos = islandData[2]
    
    TabTeleport:CreateButton({
        Name = "TP to " .. name,
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end,
    })
end

-- ระบบล็อกแถบมินิเกมตรงกลาง
RunService.RenderStepped:Connect(function()
    if AutoMinigame then
        local mainGui = UIPath:FindFirstChild("MainGui")
        if mainGui then
            local fishing = mainGui:FindFirstChild("Fishing")
            if fishing and fishing.Visible then
                local barFrame = fishing:FindFirstChild("BarFrame")
                if barFrame then
                    local bar = barFrame:FindFirstChild("Bar")
                    if bar then
                        bar.AnchorPoint = Vector2.new(0.5, 0.5)
                        bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                    end
                end
            end
        end
    end
end)

-- ฟังก์ชันเช็กว่า ProgressionBar กำลังทำงานอยู่หรือไม่
local function isProgressionBarActive()
    local mainGui = UIPath:FindFirstChild("MainGui")
    if mainGui then
        local fishing = mainGui:FindFirstChild("Fishing")
        if fishing and fishing.Visible then
            local progBar = fishing:FindFirstChild("ProgressionBar")
            if progBar and progBar.Visible then
                return true
            end
        end
    end
    return false
end

-- ฟังก์ชันสำหรับส่งคำสั่งจำลองการกดปุ่ม
local function pressKey(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

-- ระบบ Auto Skill เช็กปุ่มตาม Toggle ที่เปิดไว้
task.spawn(function()
    while true do
        task.wait(0.3)
        if SkillZ then pressKey(Enum.KeyCode.Z) task.wait(0.1) end
        if SkillX then pressKey(Enum.KeyCode.X) task.wait(0.1) end
        if SkillC then pressKey(Enum.KeyCode.C) task.wait(0.1) end
        if SkillV then pressKey(Enum.KeyCode.V) task.wait(0.1) end
    end
end)

-- ระบบเหวี่ยงเบ็ดอัตโนมัติ
task.spawn(function()
    while true do
        task.wait(0.3)
        if AutoCast then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local castCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -15)
                FishingEvent:FireServer(castCFrame)
                
                task.wait(1.5)

                repeat
                    task.wait(0.1)
                until isProgressionBarActive() or not AutoCast

                if AutoCast then
                    repeat
                        task.wait(0.1)
                    until not isProgressionBarActive() or not AutoCast
                end

                task.wait(1)
            end
        end
    end
end)

-- ระบบ Auto Sell ทำงานตามเวลาที่ตั้งไว้
task.spawn(function()
    while true do
        task.wait(SellDelay)
        if AutoSell and SellEvent then
            SellEvent:FireServer()
        end
    end
end)
-- แท็บ UI (เรียงลำดับใหม่)
local TabFishing = Window:CreateTab("🎣 Auto Fishing", 0)
local TabSkills = Window:CreateTab("⚡ Auto Skill", 0)
local TabSelling = Window:CreateTab("💸 Selling", 0)
local TabTeleport = Window:CreateTab("🏝️ Teleport", 0)

-- 1. แท็บ Auto Fishing 🎣
TabFishing:CreateToggle({
    Name = "Auto Cast",
    CurrentValue = false,
    Callback = function(Value)
        AutoCast = Value
    end,
})

TabFishing:CreateToggle({
    Name = "Lock Minigame Bar",
    CurrentValue = false,
    Callback = function(Value)
        AutoMinigame = Value
    end,
})

-- 2. แท็บ Auto Skill ⚡ (แยกเปิด/ปิดเป็นรายสกิล)
TabSkills:CreateToggle({
    Name = "Auto Skill Z",
    CurrentValue = false,
    Callback = function(Value)
        SkillZ = Value
    end,
})

TabSkills:CreateToggle({
    Name = "Auto Skill X",
    CurrentValue = false,
    Callback = function(Value)
        SkillX = Value
    end,
})

TabSkills:CreateToggle({
    Name = "Auto Skill C",
    CurrentValue = false,
    Callback = function(Value)
        SkillC = Value
    end,
})

TabSkills:CreateToggle({
    Name = "Auto Skill V",
    CurrentValue = false,
    Callback = function(Value)
        SkillV = Value
    end,
})

-- 3. แท็บ Selling 💸
TabSelling:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Callback = function(Value)
        AutoSell = Value
    end,
})

TabSelling:CreateSlider({
    Name = "Auto Sell Interval",
    Range = {1, 60},
    Increment = 1,
    Suffix = "วินาที",
    CurrentValue = 5,
    Callback = function(Value)
        SellDelay = Value
    end,
})

TabSelling:CreateButton({
    Name = "Sell All Fish",
    Callback = function()
        if SellEvent then
            SellEvent:FireServer()
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "ไม่พบ RemoteEvent สำหรับขายปลา",
                Duration = 3
            })
        end
    end,
})

-- 4. แท็บ Teleport 🏝️
local IslandsList = {
    {"Beginning Isle", Vector3.new(-200.686, 11.0587, 35.9142)},
    {"Bamboo Isle", Vector3.new(-1223, 7.28001, -24.1)},
    {"Fallout Isle", Vector3.new(65.5001, 8.78001, 1181.3)},
    {"Sovereign Isle", Vector3.new(-1276.4, 8.78001, 1239.7)},
    {"Perch Isle", Vector3.new(-61.99, 11.9149, -1321.42)},
    {"Frost Isle", Vector3.new(-1365.99, 11.9149, -1495.42)},
    {"Coconut Isle", Vector3.new(1493.61, 9.11487, -1430.62)},
    {"Amber Isle", Vector3.new(1259.41, 9.11487, 1401.48)},
    {"Battlefield Isle", Vector3.new(1393.49, 11.3362, 169.63)},
    {"Mistpeak Isle", Vector3.new(2660.22, 8.78001, -86.7163)}
}

for _, islandData in ipairs(IslandsList) do
    local name = islandData[1]
    local pos = islandData[2]
    
    TabTeleport:CreateButton({
        Name = "TP to " .. name,
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end,
    })
end

-- ระบบล็อกแถบมินิเกมตรงกลาง
RunService.RenderStepped:Connect(function()
    if AutoMinigame then
        local mainGui = UIPath:FindFirstChild("MainGui")
        if mainGui then
            local fishing = mainGui:FindFirstChild("Fishing")
            if fishing and fishing.Visible then
                local barFrame = fishing:FindFirstChild("BarFrame")
                if barFrame then
                    local bar = barFrame:FindFirstChild("Bar")
                    if bar then
                        bar.AnchorPoint = Vector2.new(0.5, 0.5)
                        bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                    end
                end
            end
        end
    end
end)

-- ฟังก์ชันเช็กว่า ProgressionBar กำลังทำงานอยู่หรือไม่
local function isProgressionBarActive()
    local mainGui = UIPath:FindFirstChild("MainGui")
    if mainGui then
        local fishing = mainGui:FindFirstChild("Fishing")
        if fishing and fishing.Visible then
            local progBar = fishing:FindFirstChild("ProgressionBar")
            if progBar and progBar.Visible then
                return true
            end
        end
    end
    return false
end

-- ฟังก์ชันสำหรับส่งคำสั่งจำลองการกดปุ่ม
local function pressKey(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

-- ระบบ Auto Skill เช็กปุ่มตาม Toggle ที่เปิดไว้
task.spawn(function()
    while true do
        task.wait(0.3)
        if SkillZ then pressKey(Enum.KeyCode.Z) task.wait(0.1) end
        if SkillX then pressKey(Enum.KeyCode.X) task.wait(0.1) end
        if SkillC then pressKey(Enum.KeyCode.C) task.wait(0.1) end
        if SkillV then pressKey(Enum.KeyCode.V) task.wait(0.1) end
    end
end)

-- ระบบเหวี่ยงเบ็ดอัตโนมัติ
task.spawn(function()
    while true do
        task.wait(0.3)
        if AutoCast then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local castCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -15)
                FishingEvent:FireServer(castCFrame)
                
                task.wait(1.5)

                repeat
                    task.wait(0.1)
                until isProgressionBarActive() or not AutoCast

                if AutoCast then
                    repeat
                        task.wait(0.1)
                    until not isProgressionBarActive() or not AutoCast
                end

                task.wait(1)
            end
        end
    end
end)

-- ระบบ Auto Sell ทำงานตามเวลาที่ตั้งไว้
task.spawn(function()
    while true do
        task.wait(SellDelay)
        if AutoSell and SellEvent then
            SellEvent:FireServer()
        end
    end
end)
    Name = "Auto Cast",
    CurrentValue = false,
    Callback = function(Value)
        AutoCast = Value
    end,
})

TabFishing:CreateToggle({
    Name = "Lock Minigame Bar",
    CurrentValue = false,
    Callback = function(Value)
        AutoMinigame = Value
    end,
})

-- 2. แท็บ Selling 💸
TabSelling:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Callback = function(Value)
        AutoSell = Value
    end,
})

TabSelling:CreateSlider({
    Name = "Auto Sell Interval",
    Range = {1, 60},
    Increment = 1,
    Suffix = "วินาที",
    CurrentValue = 5,
    Callback = function(Value)
        SellDelay = Value
    end,
})

TabSelling:CreateButton({
    Name = "Sell All Fish",
    Callback = function()
        if SellEvent then
            SellEvent:FireServer()
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "ไม่พบ RemoteEvent สำหรับขายปลา",
                Duration = 3
            })
        end
    end,
})

-- 3. แท็บ Teleport 🏝️ (เรียงตามลำดับใหม่ที่กำหนด)
local IslandsList = {
    {"Beginning Isle", Vector3.new(-200.686, 11.0587, 35.9142)},
    {"Bamboo Isle", Vector3.new(-1223, 7.28001, -24.1)},
    {"Fallout Isle", Vector3.new(65.5001, 8.78001, 1181.3)},
    {"Sovereign Isle", Vector3.new(-1276.4, 8.78001, 1239.7)},
    {"Perch Isle", Vector3.new(-61.99, 11.9149, -1321.42)},
    {"Frost Isle", Vector3.new(-1365.99, 11.9149, -1495.42)},
    {"Coconut Isle", Vector3.new(1493.61, 9.11487, -1430.62)},
    {"Amber Isle", Vector3.new(1259.41, 9.11487, 1401.48)},
    {"Battlefield Isle", Vector3.new(1393.49, 11.3362, 169.63)},
    {"Mistpeak Isle", Vector3.new(2660.22, 8.78001, -86.7163)}
}

for _, islandData in ipairs(IslandsList) do
    local name = islandData[1]
    local pos = islandData[2]
    
    TabTeleport:CreateButton({
        Name = "TP to " .. name,
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end,
    })
end

-- ระบบล็อกแถบมินิเกมตรงกลาง
RunService.RenderStepped:Connect(function()
    if AutoMinigame then
        local mainGui = UIPath:FindFirstChild("MainGui")
        if mainGui then
            local fishing = mainGui:FindFirstChild("Fishing")
            if fishing and fishing.Visible then
                local barFrame = fishing:FindFirstChild("BarFrame")
                if barFrame then
                    local bar = barFrame:FindFirstChild("Bar")
                    if bar then
                        bar.AnchorPoint = Vector2.new(0.5, 0.5)
                        bar.Position = UDim2.new(0.5, 0, 0.5, 0)
                    end
                end
            end
        end
    end
end)

-- ฟังก์ชันเช็กว่า ProgressionBar กำลังทำงานอยู่หรือไม่
local function isProgressionBarActive()
    local mainGui = UIPath:FindFirstChild("MainGui")
    if mainGui then
        local fishing = mainGui:FindFirstChild("Fishing")
        if fishing and fishing.Visible then
            local progBar = fishing:FindFirstChild("ProgressionBar")
            if progBar and progBar.Visible then
                return true
            end
        end
    end
    return false
end

-- ระบบเหวี่ยงเบ็ดอัตโนมัติ
task.spawn(function()
    while true do
        task.wait(0.3)
        if AutoCast then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local castCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -15)
                FishingEvent:FireServer(castCFrame)
                
                task.wait(1.5)

                repeat
                    task.wait(0.1)
                until isProgressionBarActive() or not AutoCast

                if AutoCast then
                    repeat
                        task.wait(0.1)
                    until not isProgressionBarActive() or not AutoCast
                end

                task.wait(1)
            end
        end
    end
end)

-- ระบบ Auto Sell ทำงานตามเวลาที่ตั้งไว้
task.spawn(function()
    while true do
        task.wait(SellDelay)
        if AutoSell and SellEvent then
            SellEvent:FireServer()
        end
    end
end)
