-- [[ Safe Load Fluent UI ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

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

-- 🪱 Auto Buy Bait Variables
local AutoBuyBait = false
local SelectedBait = "Basic Bait"
local BaitAmount = 1
local BaitDelay = 5

-- 🐟 Target Fish List
local TargetFishList = {
    "Azure Carp", "Jiaolong Dragonfish", "Chainbound Shark", "Adult Jiaolong Dragonfish",
    "Elder Chainbound Shark", "Elder Jiaolong Dragonfish", "Trueform Jiaolongfish",
    "Trueform Perch", "Ascended Perch", "Primordial Kunfish", "Primordial Kunfish Overlord",
    "Warbringer Shark", "Dreadscale Grouper", "Crimson Bream Sovereign", "Silver Bream Sovereign",
    "Golden Guardian Fish", "Colossal Tigerfish", "Scarlet Fish", "Flying Fish Emperor",
    "Crimson Bonefang", "Elder Scarlet Fish", "Flying Fish Empress", "Draconic Koi",
    "Crimson Electric Eel", "Reborn Puffer Beast", "Heavenpiercer Turtle", "Sanguine Fish",
    "Frost Kingfish", "Frost Queenfish", "Verdant Alligator Gar", "Dreadmare Eel",
    "Mirage Lanternfish", "Tigerfang Whale"
}

local AutoMinigame = false
local AutoSell = false
local SellDelay = 5

local SkillZ = false
local SkillX = false
local SkillC = false
local SkillV = false

local UIPath = LocalPlayer:WaitForChild("PlayerGui")

-- Helper Function ดึง Events แบบปลอดภัย
local function getEvent(name)
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    if eventsFolder then
        return eventsFolder:FindFirstChild(name)
    end
    return nil
end

-- Window Setup
local Window = Fluent:CreateWindow({
    Title = "Heavyweight Fishing | by Nicha",
    SubTitle = "by Nicha",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 420),
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- UI Tabs
local Tabs = {
    Fishing = Window:AddTab({ Title = "🎣 Auto Fishing", Icon = "" }),
    Bait = Window:AddTab({ Title = "🛒 Bait & Craft", Icon = "" }),
    Skills = Window:AddTab({ Title = "⚡ Auto Skill", Icon = "" }),
    Selling = Window:AddTab({ Title = "💸 Selling", Icon = "" }),
    Teleport = Window:AddTab({ Title = "🏝️ Teleport", Icon = "" }),
    Misc = Window:AddTab({ Title = "🌀 Misc", Icon = "" })
}

-- 1. Tab Auto Fishing
Tabs.Fishing:AddSection("🔥 Main Fishing Settings")
Tabs.Fishing:AddToggle("AutoCast", { Title = "Auto Cast (ตกปลาอัตโนมัติ)", Default = false, Callback = function(v) AutoCast = v end })
Tabs.Fishing:AddToggle("AutoMinigame", { Title = "Lock Minigame Bar (ล็อคเกจตกปลา)", Default = false, Callback = function(v) AutoMinigame = v end })
Tabs.Fishing:AddSection("🎯 Target Fish Settings")
Tabs.Fishing:AddToggle("AutoSpecificFish", { Title = "Auto Specific Fish (กรองปลาตามรายชื่อ)", Default = false, Callback = function(v) AutoSpecificFish = v end })

-- 2. Tab Bait & Craft
Tabs.Bait:AddSection("🤖 Auto Buy Bait (ซื้อเหยื่ออัตโนมัติ)")
Tabs.Bait:AddDropdown("BaitSelect", {
    Title = "Select Bait (เลือกชนิดเหยื่อ)",
    Values = {"Basic Bait", "Crude Mash Bait", "Corrupted Essence Bait", "Elite Bait", "Ancestral Bait"},
    Default = "Basic Bait",
    Callback = function(v) SelectedBait = v end
})

Tabs.Bait:AddInput("BaitAmountInput", {
    Title = "Amount (จำนวนที่ซื้อต่อรอบ)",
    Default = "1",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then BaitAmount = math.floor(num) end
    end
})

Tabs.Bait:AddInput("BaitDelayInput", {
    Title = "Buy Interval (ระยะเวลาซื้อ/วินาที)",
    Default = "5",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then BaitDelay = num end
    end
})

Tabs.Bait:AddToggle("AutoBuyBaitToggle", { Title = "Auto Buy Bait (เปิดซื้อเหยื่ออัตโนมัติ)", Default = false, Callback = function(v) AutoBuyBait = v end })

Tabs.Bait:AddButton({
    Title = "Buy Bait Once (ซื้อทันที 1 ครั้ง)",
    Callback = function()
        local buyBaitEvent = getEvent("BuyBait")
        if buyBaitEvent then
            buyBaitEvent:FireServer(SelectedBait, BaitAmount)
        end
    end
})

Tabs.Bait:AddSection("🪱 Bait Shop UI")
Tabs.Bait:AddButton({
    Title = "Open Bait Shop (เปิดร้านซื้อเหยื่อ)",
    Callback = function()
        local dialogueEvent = getEvent("ChooseDialogueOption")
        if dialogueEvent then dialogueEvent:FireServer("BuyBait", 1, "BaitShop") end
    end
})

Tabs.Bait:AddButton({
    Title = "Open Craft Bait (เปิดหน้าต่างคราฟเหยื่อ)",
    Callback = function()
        local dialogueEvent = getEvent("ChooseDialogueOption")
        if dialogueEvent then dialogueEvent:FireServer("BuyBait", 2, "CraftBait") end
    end
})

-- 3. Tab Auto Skill
Tabs.Skills:AddToggle("SkillZ", { Title = "Auto Skill Z", Default = false, Callback = function(v) SkillZ = v end })
Tabs.Skills:AddToggle("SkillX", { Title = "Auto Skill X", Default = false, Callback = function(v) SkillX = v end })
Tabs.Skills:AddToggle("SkillC", { Title = "Auto Skill C", Default = false, Callback = function(v) SkillC = v end })
Tabs.Skills:AddToggle("SkillV", { Title = "Auto Skill V", Default = false, Callback = function(v) SkillV = v end })

-- 4. Tab Selling
Tabs.Selling:AddToggle("AutoSell", { Title = "Auto Sell Fish", Default = false, Callback = function(v) AutoSell = v end })
Tabs.Selling:AddInput("SellInterval", {
    Title = "Auto Sell Interval (วินาที)",
    Default = "5",
    Numeric = true,
    Finished = true,
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then SellDelay = num end
    end
})

Tabs.Selling:AddButton({
    Title = "Sell All Fish",
    Callback = function()
        local sellEvent = getEvent("SellAll") or getEvent("Sell") or getEvent("SellFish")
        if sellEvent then sellEvent:FireServer() end
    end
})

-- 5. Tab Teleport
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

Tabs.Teleport:AddSection("🧙 Secret NPCs (NPC ลับ)")
Tabs.Teleport:AddButton({
    Title = "TP to Mysterious Merchant (Maoshan)",
    Callback = function()
        local m = Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("Function") and Workspace.NPC.Function:FindFirstChild("Maoshan")
        teleportToTarget(m)
    end
})
Tabs.Teleport:AddButton({
    Title = "TP to Taoist",
    Callback = function()
        local t = Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("Function") and Workspace.NPC.Function:FindFirstChild("Taoist")
        teleportToTarget(t)
    end
})

Tabs.Teleport:AddSection("📍 Functional NPCs")
local FunctionNPCs = {
    {"Bac Minh", "Bac Minh"}, {"Giang Lao (Battlefield Isle)", "Battlefield Isle's Giang Lao"},
    {"Blind Grand Angler", "Blind Grand Angler"}, {"Duan Gan", "Duan Gan"},
    {"Dumb guy", "Dumb guy"}, {"Giang Lao", "Giang Lao"}, {"Ha Dieu De", "Ha Dieu De"},
    {"Lao Ngo", "Lao Ngo"}, {"Nanjiang", "Nanjiang"}, {"Sage Yijiu", "Sage Yijiu"},
    {"The Shadow", "The Shadow"}, {"Ticket Quest Giver", "Ticket Quest Giver"}, {"Zeng Tianguo", "Zeng Tianguo"}
}

for _, npcData in ipairs(FunctionNPCs) do
    Tabs.Teleport:AddButton({
        Title = "TP to " .. npcData[1],
        Callback = function()
            local targetNPC = Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("Function") and Workspace.NPC.Function:FindFirstChild(npcData[2])
            teleportToTarget(targetNPC)
        end
    })
end

Tabs.Teleport:AddSection("🗿 God Statues")
Tabs.Teleport:AddButton({ Title = "TP to God Yellow", Callback = function() teleportToTarget(Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("God") and Workspace.NPC.God:FindFirstChild("Yellow")) end })
Tabs.Teleport:AddButton({ Title = "TP to God Green", Callback = function() teleportToTarget(Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("God") and Workspace.NPC.God:FindFirstChild("Green")) end })
Tabs.Teleport:AddButton({ Title = "TP to God Blue", Callback = function() teleportToTarget(Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("God") and Workspace.NPC.God:FindFirstChild("Blue")) end })

Tabs.Teleport:AddSection("📍 Islands")
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
    Tabs.Teleport:AddButton({
        Title = "TP to " .. islandData[1],
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(islandData[2] + Vector3.new(0, 3, 0))
            end
        end
    })
end

-- 6. Tab Misc
Tabs.Misc:AddSection("⚙️ Player Utilities")
Tabs.Misc:AddToggle("AntiAFK", { Title = "Anti AFK", Default = true, Callback = function(v) AntiAFK = v end })
Tabs.Misc:AddToggle("Noclip", { Title = "Noclip", Default = false, Callback = function(v) Noclip = v end })
Tabs.Misc:AddToggle("InfiniteJump", { Title = "Infinite Jump", Default = false, Callback = function(v) InfiniteJump = v end })

-- Mobile Toggle Button
task.spawn(function()
    task.wait(0.5)
    local targetParent = (typeof(gethui) == "function" and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    if targetParent:FindFirstChild("FluentMobileToggle") then targetParent.FluentMobileToggle:Destroy() end

    local ScreenGui = Instance.new("ScreenGui", targetParent)
    ScreenGui.Name = "FluentMobileToggle"
    
    local ToggleButton = Instance.new("TextButton", ScreenGui)
    ToggleButton.Size = UDim2.new(0, 55, 0, 55)
    ToggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
    ToggleButton.Text = "NC"
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.FredokaOne
    ToggleButton.TextSize = 22
    ToggleButton.Draggable = true

    local UICorner = Instance.new("UICorner", ToggleButton)
    UICorner.CornerRadius = UDim.new(0, 14)

    ToggleButton.MouseButton1Click:Connect(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end)
end)

-- Background Logic Loop
LocalPlayer.Idled:Connect(function()
    if AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

RunService.Stepped:Connect(function()
    if Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- 🪱 Auto Buy Bait Loop
task.spawn(function()
    while true do
        task.wait(BaitDelay)
        if AutoBuyBait then
            local buyBaitEvent = getEvent("BuyBait")
            if buyBaitEvent then
                pcall(function()
                    buyBaitEvent:FireServer(SelectedBait, BaitAmount)
                end)
            end
        end
    end
end)

-- Auto Sell Loop
task.spawn(function()
    while true do
        task.wait(SellDelay)
        if AutoSell then
            local sellEvent = getEvent("SellAll") or getEvent("Sell") or getEvent("SellFish")
            if sellEvent then sellEvent:FireServer() end
        end
    end
end)

-- Main Fishing Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoCast then
            local fishingEvent = getEvent("Fishing")
            local char = LocalPlayer.Character
            if fishingEvent and char and char:FindFirstChild("HumanoidRootPart") then
                local castCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -15)
                fishingEvent:FireServer(castCFrame)
                task.wait(1.5)
            end
        end
    end
end)

