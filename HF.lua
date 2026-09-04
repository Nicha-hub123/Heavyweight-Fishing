local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Variables Setup
local AutoCast = false
local AutoSpecificFish = false
local Noclip = false
local InfiniteJump = false
local AntiAFK = true

-- 🐟 [รายชื่อปลาที่ต้องการตก - Updated List]
local TargetFishList = {
    "Azure Carp",
    "Jiaolong Dragonfish",
    "Chainbound Shark",
    "Adult Jiaolong Dragonfish",
    "Elder Chainbound Shark",
    "Elder Jiaolong Dragonfish",
    "Trueform Jiaolongfish",
    "Trueform Perch",
    "Ascended Perch",
    "Primordial Kunfish",
    "Primordial Kunfish Overlord",
    "Warbringer Shark",
    "Dreadscale Grouper",
    "Crimson Bream Sovereign",
    "Silver Bream Sovereign",
    "Golden Guardian Fish",
    "Colossal Tigerfish",
    "Scarlet Fish",
    "Flying Fish Emperor",
    "Crimson Bonefang",
    "Elder Scarlet Fish",
    "Flying Fish Empress",
    "Draconic Koi",
    "Crimson Electric Eel",
    "Reborn Puffer Beast",
    "Heavenpiercer Turtle",
    "Sanguine Fish",
    "Frost Kingfish",
    "Frost Queenfish",
    "Verdant Alligator Gar",
    "Dreadmare Eel",
    "Tigerfang Whale"
}

local AutoMinigame = false
local AutoSell = false
local SellDelay = 5

local SkillZ = false
local SkillX = false
local SkillC = false
local SkillV = false

local UIPath = LocalPlayer:WaitForChild("PlayerGui")
local Events = ReplicatedStorage:WaitForChild("Events")
local FishingEvent = Events:WaitForChild("Fishing")
local ToggleHotbar = Events:FindFirstChild("ToggleHotbar")
local DialogueEvent = Events:FindFirstChild("ChooseDialogueOption")

local SkillEvent = Events:FindFirstChild("UseSkill") 
                or Events:FindFirstChild("Skill") 
                or Events:FindFirstChild("ActivateSkill")
                or Events:FindFirstChild("Ability")

local SellEvent = Events:FindFirstChild("SellAll") 
               or Events:FindFirstChild("Sell") 
               or Events:FindFirstChild("SellFish")
               or (Events:FindFirstChild("Merchant") and Events.Merchant:FindFirstChild("SellAll"))

-- Window Setup
local Window = OrionLib:MakeWindow({
    Name = "Heavyweight Fishing | Full Features",
    HidePremium = true,
    SaveConfig = false,
    ConfigFolder = "HeavyweightFishingConfig"
})

-- UI Tabs
local TabFishing = Window:MakeTab({ Name = "🎣 Auto Fishing", PremiumOnly = false })
local TabBait = Window:MakeTab({ Name = "🛒 Bait & Craft", PremiumOnly = false })
local TabSkills = Window:MakeTab({ Name = "⚡ Auto Skill", PremiumOnly = false })
local TabSelling = Window:MakeTab({ Name = "💸 Selling", PremiumOnly = false })
local TabTeleport = Window:MakeTab({ Name = "🏝️ Teleport", PremiumOnly = false })
local TabMisc = Window:MakeTab({ Name = "🌀 Misc", PremiumOnly = false })

-- 1. Tab Auto Fishing
TabFishing:AddSection({ Name = "🔥 Main Fishing Settings" })
TabFishing:AddToggle({
    Name = "Auto Cast (ตกปลาอัตโนมัติ)",
    Default = false,
    Callback = function(Value) AutoCast = Value end    
})

TabFishing:AddToggle({
    Name = "Lock Minigame Bar (ล็อคเกจตกปลา)",
    Default = false,
    Callback = function(Value) AutoMinigame = Value end    
})

TabFishing:AddSection({ Name = "🎯 Target Fish Settings" })
TabFishing:AddToggle({
    Name = "Auto Specific Fish (กรองปลาตามรายชื่อ)",
    Default = false,
    Callback = function(Value) AutoSpecificFish = Value end    
})

-- 2. Tab Bait & Craft
TabBait:AddSection({ Name = "🪱 Bait Menu" })
TabBait:AddButton({
    Name = "Open Bait Shop (เปิดร้านซื้อเหยื่อ)",
    Callback = function()
        if DialogueEvent then
            DialogueEvent:FireServer("BuyBait", 1, "BaitShop")
        end
    end
})

TabBait:AddButton({
    Name = "Open Craft Bait (เปิดหน้าต่างคราฟเหยื่อ)",
    Callback = function()
        if DialogueEvent then
            DialogueEvent:FireServer("BuyBait", 2, "CraftBait")
        end
    end
})

-- 3. Tab Auto Skill
TabSkills:AddToggle({ Name = "Auto Skill Z", Default = false, Callback = function(Value) SkillZ = Value end })
TabSkills:AddToggle({ Name = "Auto Skill X", Default = false, Callback = function(Value) SkillX = Value end })
TabSkills:AddToggle({ Name = "Auto Skill C", Default = false, Callback = function(Value) SkillC = Value end })
TabSkills:AddToggle({ Name = "Auto Skill V", Default = false, Callback = function(Value) SkillV = Value end })

-- 4. Tab Selling
TabSelling:AddToggle({
    Name = "Auto Sell Fish",
    Default = false,
    Callback = function(Value) AutoSell = Value end    
})

TabSelling:AddTextbox({
    Name = "Auto Sell Interval (วินาที)",
    Default = "5",
    TextDisappear = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then SellDelay = num end
    end
})

TabSelling:AddButton({
    Name = "Sell All Fish",
    Callback = function()
        if SellEvent then SellEvent:FireServer() end
    end
})

-- 5. Tab Teleport
TabTeleport:AddSection({ Name = "🧙 Special NPC" })

-- Helper Function สำหรับการ TP ไปยัง Instance
local function teleportToTarget(targetObj)
    if not targetObj then return end
    local targetCFrame = nil

    if targetObj:IsA("Model") then
        targetCFrame = targetObj:GetPrimaryPartCFrame() or (targetObj:FindFirstChild("HumanoidRootPart") and targetObj.HumanoidRootPart.CFrame) or (targetObj:FindFirstChildWhichIsA("BasePart") and targetObj:FindFirstChildWhichIsA("BasePart").CFrame)
    elseif targetObj:IsA("BasePart") then
        targetCFrame = targetObj.CFrame
    end

    if targetCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 0, -3)
    end
end

TabTeleport:AddButton({
    Name = "TP to Mysterious Merchant (Maoshan)",
    Callback = function()
        local maoshan = Workspace:FindFirstChild("NPC") 
                     and Workspace.NPC:FindFirstChild("Function") 
                     and Workspace.NPC.Function:FindFirstChild("Maoshan")
        teleportToTarget(maoshan)
    end
})

TabTeleport:AddButton({
    Name = "TP to Taoist (NPC ลับ)",
    Callback = function()
        local taoist = Workspace:FindFirstChild("NPC") 
                    and Workspace.NPC:FindFirstChild("Function") 
                    and Workspace.NPC.Function:FindFirstChild("Taoist")
        teleportToTarget(taoist)
    end
})

TabTeleport:AddSection({ Name = "🗿 God Statues" })

TabTeleport:AddButton({
    Name = "TP to God Yellow",
    Callback = function()
        local godYellow = Workspace:FindFirstChild("NPC") 
                       and Workspace.NPC:FindFirstChild("God") 
                       and Workspace.NPC.God:FindFirstChild("Yellow")
        teleportToTarget(godYellow)
    end
})

TabTeleport:AddButton({
    Name = "TP to God Green",
    Callback = function()
        local godGreen = Workspace:FindFirstChild("NPC") 
                      and Workspace.NPC:FindFirstChild("God") 
                      and Workspace.NPC.God:FindFirstChild("Green")
        teleportToTarget(godGreen)
    end
})

TabTeleport:AddButton({
    Name = "TP to God Blue",
    Callback = function()
        local godBlue = Workspace:FindFirstChild("NPC") 
                     and Workspace.NPC:FindFirstChild("God") 
                     and Workspace.NPC.God:FindFirstChild("Blue")
        teleportToTarget(godBlue)
    end
})

TabTeleport:AddSection({ Name = "📍 Islands (เกาะต่างๆ)" })
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
    TabTeleport:AddButton({
        Name = "TP to " .. islandData[1],
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(islandData[2] + Vector3.new(0, 3, 0))
            end
        end
    })
end

-- 6. Tab Misc
TabMisc:AddSection({ Name = "⚙️ Player Utilities" })
TabMisc:AddToggle({
    Name = "Anti AFK (กันหลุดออกจากเกม - Advanced)",
    Default = true,
    Callback = function(Value) AntiAFK = Value end
})

TabMisc:AddToggle({
    Name = "Noclip (เดินทะลุกำแพง)",
    Default = false,
    Callback = function(Value) Noclip = Value end
})

TabMisc:AddToggle({
    Name = "Infinite Jump (กระโดดไม่จำกัด)",
    Default = false,
    Callback = function(Value) InfiniteJump = Value end
})

OrionLib:Init()

-- Mobile Toggle UI
task.spawn(function()
    task.wait(0.5)
    local targetParent = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    if targetParent:FindFirstChild("OrionMobileToggle") then
        targetParent.OrionMobileToggle:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    local ToggleButton = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")

    ScreenGui.Name = "OrionMobileToggle"
    ScreenGui.Parent = targetParent
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999999

    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ScreenGui
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
    ToggleButton.Size = UDim2.new(0, 55, 0, 55)
    ToggleButton.Text = "NC"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 22
    ToggleButton.Font = Enum.Font.FredokaOne
    ToggleButton.Active = true
    ToggleButton.Draggable = true

    UICorner.CornerRadius = UDim.new(0, 14)
    UICorner.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        local containers = {}
        if typeof(gethui) == "function" then table.insert(containers, gethui()) end
        table.insert(containers, game:GetService("CoreGui"))
        table.insert(containers, LocalPlayer.PlayerGui)

        for _, parent in ipairs(containers) do
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("ScreenGui") and child.Name ~= "OrionMobileToggle" and (child.Name == "Orion" or child.Name:sub(1,5) == "Orion") then
                    child.Enabled = not child.Enabled
                end
            end
        end
    end)
end)

-- Anti-AFK Logic
LocalPlayer.Idled:Connect(function()
    if AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        if AntiAFK then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 0.05)
                    task.wait(0.1)
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -0.05)
                end
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end
end)

-- Player Utilities Logic
RunService.Stepped:Connect(function()
    if Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local function resetMinigameWithHotbar()
    if ToggleHotbar then
        pcall(function()
            ToggleHotbar:InvokeServer("1")
            task.wait(0.12)
            ToggleHotbar:InvokeServer("1")
            task.wait(0.15)
        end)
    end
end

local function isFishingUIActive()
    local mainGui = UIPath:FindFirstChild("MainGui")
    if not mainGui then return false end
    local fishing = mainGui:FindFirstChild("Fishing")
    return fishing and fishing.Visible
end

local function getFishNameText()
    local mainGui = UIPath:FindFirstChild("MainGui")
    if not mainGui then return nil, "" end
    local fishing = mainGui:FindFirstChild("Fishing")
    if not fishing or not fishing.Visible then return nil, "" end
    local progBar = fishing:FindFirstChild("ProgressionBar")
    if not progBar or not progBar.Visible then return nil, "" end
    
    local fishLabel = progBar:FindFirstChild("FishName")
    if fishLabel and fishLabel:IsA("TextLabel") then
        local cleanText = fishLabel.Text:gsub("<[^>]-Calculated>", ""):gsub("<[^>]-", "")
        return fishLabel, cleanText
    end
    return nil, ""
end

local function checkTargetMatch(fishName)
    if not fishName or fishName == "" then return false end
    local lowerName = fishName:lower()
    for _, target in ipairs(TargetFishList) do
        if string.find(lowerName, target:lower(), 1, true) then
            return true
        end
    end
    return false
end

-- Lock Minigame Bar Logic
local allowMinigameLock = false

RunService.RenderStepped:Connect(function()
    if AutoMinigame and allowMinigameLock then
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

-- Auto Skill Loop
local function useSkillSafe(skillKey, skillName)
    if SkillEvent then
        SkillEvent:FireServer(skillName or skillKey)
    else
        VirtualInputManager:SendKeyEvent(true, skillKey, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, skillKey, false, game)
    end
end

task.spawn(function()
    while true do
        task.wait(0.6)
        if isFishingUIActive() then
            pcall(function()
                if SkillZ then useSkillSafe(Enum.KeyCode.Z, "Z") task.wait(0.15) end
                if SkillX then useSkillSafe(Enum.KeyCode.X, "X") task.wait(0.15) end
                if SkillC then useSkillSafe(Enum.KeyCode.C, "C") task.wait(0.15) end
                if SkillV then useSkillSafe(Enum.KeyCode.V, "V") task.wait(0.15) end
            end)
        end
    end
end)

-- Main Fishing Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoCast then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                allowMinigameLock = false
                
                -- 1. เหวี่ยงเบ็ด
                local castCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -15)
                FishingEvent:FireServer(castCFrame)
                
                -- 2. วนรอจนชื่อปลาขึ้นบน UI
                local fishLabel, currentText = nil, ""
                local timeWaited = 0
                
                while timeWaited < 8.0 and AutoCast do
                    fishLabel, currentText = getFishNameText()
                    if currentText ~= "" and currentText ~= "Fishing..." and currentText ~= "..." then
                        break
                    end
                    task.wait(0.05)
                    timeWaited = timeWaited + 0.05
                end

                -- 3. ตรวจสอบปลาที่ตกได้
                if AutoCast and currentText ~= "" and currentText ~= "Fishing..." and currentText ~= "..." then
                    local isMatched = not AutoSpecificFish or checkTargetMatch(currentText)

                    if isMatched then
                        allowMinigameLock = true
                        local minGameTime = tick()
                        
                        repeat
                            task.wait(0.15)
                            _, currentText = getFishNameText()
                            
                            local timePassed = tick() - minGameTime
                            local uiActive = isFishingUIActive()
                            
                            if not uiActive and timePassed > 3.0 then
                                task.wait(0.3)
                                if not isFishingUIActive() then
                                    break
                                end
                            end
                        until not AutoCast
                        
                        allowMinigameLock = false
                        task.wait(0.8)
                    else
                        resetMinigameWithHotbar()
                        task.wait(0.3)
                    end
                else
                    resetMinigameWithHotbar()
                    task.wait(0.3)
                end
            end
        end
    end
end)

-- Auto Sell Loop
task.spawn(function()
    while true do
        task.wait(SellDelay)
        if AutoSell and SellEvent then
            SellEvent:FireServer()
        end
    end
end)
