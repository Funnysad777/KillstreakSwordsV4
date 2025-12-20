local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ==================== WINDOW SETUP ====================
local Window = Fluent:CreateWindow({
    Title = "Null Hub | KillstreakSwordsV4 | [Version 1.0.31 - beta]",
    SubTitle = "by Funnysad",
    TabWidth = 160,
    Size = UDim2.fromOffset(480, 360),
    Acrylic = false,
    Theme = "Rose",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- ==================== TOGGLE BUTTON SETUP ====================
local isVisible = true

local function ToggleWindow()
    isVisible = not isVisible
    if isVisible then
        Window:SelectTab(1)
    else
        Window:Minimize()
    end
end

local guiParent = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FluentToggleGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local Button = Instance.new("ImageButton")
Button.Name = "ToggleFluent"
Button.Size = UDim2.new(0, 60, 0, 60)
Button.Position = UDim2.new(0, 20, 0.5, -30)
Button.BackgroundTransparency = 1
Button.Image = "rbxassetid://140249661815764"
Button.Parent = ScreenGui

Button.MouseButton1Click:Connect(ToggleWindow)

-- ==================== TABS ====================
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "arrow-left-right"}),
    Misc = Window:AddTab({ Title = "Misc", Icon = "airplay"}),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ==================== MAIN FUNCTIONALITY ====================
do
    -- Services
    local workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    local VIM = game:GetService("VirtualInputManager")
    
    -- Variables
    local sword_stand = workspace.SwordStands
    local LocalPlayer = Players.LocalPlayer
    local Npc = workspace.NPC
    
    -- ==================== HELPER FUNCTIONS ====================
    
    -- ฟังก์ชันสำหรับดึง Character ปัจจุบัน
    local function getCharacter()
        return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    end
    
    -- ฟังก์ชันสำหรับดึง HumanoidRootPart และ Humanoid
    local function getCharacterParts()
        local character = getCharacter()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")
        return hrp, humanoid
    end
    
    -- ==================== SWORD COLLECTION ====================
    local SwordStandT = {}
    
    for i, v in pairs(sword_stand:GetChildren()) do
        if v:IsA("Model") and string.find(v.Name, "Sword") then
            table.insert(SwordStandT, v.Name)
        end
    end
    
    -- ==================== mob table loop ====================
    local mob_Folder = {}
    local mob_Model = {}

    function mobReset()
        -- ล้างตารางก่อนเพิ่มข้อมูลใหม่
        table.clear(mob_Folder)
        table.clear(mob_Model)
        
        local uniqueNames = {}
        
        for _, mob_folder in pairs(Npc:GetChildren()) do
            if mob_folder:IsA("Folder") then
                table.insert(mob_Folder, mob_folder.Name)
                
                for _, mob_model in pairs(mob_folder:GetDescendants()) do
                    if mob_model:IsA("Model") then
                        -- เช็คว่าชื่อซ้ำหรือไม่
                        if not uniqueNames[mob_model.Name] then
                            uniqueNames[mob_model.Name] = true
                            table.insert(mob_Model, mob_model.Name)
                        end
                    end
                end
            end
        end
    end
    
    -- เรียกครั้งแรกเพื่อโหลดข้อมูล
    mobReset()
    
    function AbilityCooldown()
        for _,tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                for _,cooldown in pairs(tool:GetDescendants()) do
                    if cooldown.Name == "Cooldown" or cooldown:IsA("NumberValue") then
                        cooldown.Value = 0
                        print("reset cooldown for", tool.Name)
                        
                    end
                end
            else
                print("tool not found")
            end
        end
    end
    
    function SwordCooldown()
        for _,Sword in pairs(LocalPlayer.Backpack:GetChildren()) do
            if Sword:IsA("Tool") then
                for _,speed in pairs(Sword:GetDescendants()) do
                    if speed.Name == "speed" or speed:IsA("NumberValue") then
                       speed.Value = 0
                       print("set speed 0 for", Sword)
                    end
                end
            else
                print("tool not found got:", Sword)
            end
        end
    end
    -- ==================== UI ELEMENTS ====================
    
    -- Dropdown สำหรับเลือกดาบ
    local Dropdown_SSword = Tabs.Main:AddDropdown("Dropdown", {
        Title = "Choose sword",
        Values = SwordStandT,
        Multi = false,
        Default = 1,
    })

    local Dropdown_mob = Tabs.Main:AddDropdown("DropdownMob", {
        Title = "Choose mob",
        Values = mob_Model,
        Multi = false,
        Default = 1,
    })

    local Dropdown_Tp = Tabs.Teleport:AddDropdown("DropdownTp", {
        Title = "Teleport",
        Values = {"null"},
        Multi = false,
        Default = 1,
    })

    local changeY = Tabs.Main:AddSlider("SliderY", {
        Title = "height",
        Description = Value,
        Default = 20,
        Min = 10,
        Max = 30,
        Rounding = 1,
        Callback = function(Value)
            print(Value)
        end
    })

    
    local InputHeight = Tabs.Main:AddInput("InputH", {
        Title = "Height(input)",
        Default = 20,
        Placeholder = "Placeholder",
        Numeric = true, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            
        end
    })

    InputHeight:OnChanged(function()
        if InputHeight.Value then
            changeY.Value = InputHeight.Value
        end
    end)
        
    Tabs.Main:AddButton({
        Title = "Reset mob dropdown",
        Description = "",
        Callback = function()
            mobReset()
            task.wait(0.2)
            Dropdown_mob:SetValue(mob_Model)
        end
    })
    
    --========================= Toggle =========================
    
    local TpS = Tabs.Main:AddToggle("TpCSword", {
        Title = "TP Choose Sword",
        Default = false
    })

    local mobFarm = Tabs.Main:AddToggle("FarmMob", {
        Title = "Auto Farm",
        Default = false
    })

    local Tp = Tabs.Teleport:AddToggle("TP", {
        Title = "Teleport",
        Default = false
    })

    local SkillCooldown = Tabs.Misc:AddToggle("Scooldown", {
        Title = "No Ability cooldown",
        Default = false
    })
    
    local Swordcooldown = Tabs.Misc:AddToggle("SwordCooldown", {
        Title = "No Sword cooldown",
        Default = false
    })
    
    
    -- ==================== TOGGLE LOGIC ====================
    TpS:OnChanged(function()
        if TpS.Value then
            task.spawn(function()
                while TpS.Value do
                    task.wait(0.1) -- ป้องกันไม่ให้ loop เร็วเกินไป
                    
                    local success, err = pcall(function()
                        local hrp, humanoid = getCharacterParts()
                        
                        -- ตรวจสอบว่า Health มากพอ
                        if humanoid.Health >= 999e999 then
                            local selectedSwordName = Dropdown_SSword.Value
                            
                            if hrp and selectedSwordName then
                                local targetModel = sword_stand:FindFirstChild(selectedSwordName)
                                
                                if targetModel and targetModel:IsA("Model") then
                                    -- เทเลพอร์ตไปยังตำแหน่งดาบ
                                    hrp:PivotTo(targetModel:GetPivot())
                                    
                                    -- จัดการกับ ProximityPrompt
                                    local giver = targetModel:FindFirstChild("Giver")
                                    if giver then
                                        local prompt = giver:FindFirstChild("ProximityPrompt")
                                        if prompt then
                                            prompt.HoldDuration = 0
                                            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                            task.wait(0.1)
                                            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                        end
                                    end
                                else
                                    warn("ไม่พบ Model:", selectedSwordName)
                                end
                            end
                        end
                    end)
                    
                    if not success then
                        warn("Error:", err)
                    end
                end
            end)
        end
    end)
    
    mobFarm:OnChanged(function()
    if mobFarm.Value then
        task.spawn(function()
            while mobFarm.Value do task.wait()
                local success, err = pcall(function()
                        local hrp, humanoid = getCharacterParts()
                    
                    local selectedMob = Dropdown_mob.Value
                    
                    local Y = changeY.Value
                    
                    for _,mob_foldeR in pairs(Npc:GetChildren()) do
                        if mob_foldeR:IsA("Folder") then
                              for _,mob_modeL in pairs(mob_foldeR:GetDescendants()) do
                                if mob_modeL:IsA("Model") and mob_modeL.Name == selectedMob then
                                    for _, MobHrp in pairs(mob_modeL:GetChildren()) do
                if MobHrp:IsA("BasePart") and MobHrp.Name == "HumanoidRootPart" then
                    -- หา Humanoid ใน mob_modeL
                    local MobHumanoid = mob_modeL:FindFirstChild("Humanoid")
                    
                    if MobHumanoid and MobHumanoid:IsA("Humanoid") and MobHumanoid.health > 0 and humanoid.health < 999e999 then
                                                    
                                            hrp.CFrame = MobHrp.CFrame * CFrame.new(0,Y,0)
                    
                    MobHrp.CanCollide = false
                    
                        MobHrp.Size = Vector3.new(20,20,20)
                        MobHrp.Transparency = 0.5
                        
                        LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
                        end
                                 end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
end)

    Tp:OnChanged(function()
        if Tp.Value then
            local success, err = pcall(function()
                        local hrp, humanoid = getCharacterParts()
                        
                    if Dropdown_Tp.Value == "null" then
                    hrp.CFrame = CFrame.new(5910.52, 4233.31, -2945.27)
                end
            end)
        end
    end)
    
    SkillCooldown:OnChanged(function()
        if SkillCooldown.Value then
            while SkillCooldown.Value do task.wait()
                AbilityCooldown()
            end
        end
    end)
    
    Swordcooldown:OnChanged(function()
        if Swordcooldown.Value then
            while Swordcooldown.Value do task.wait()
                SwordCooldown()
            end
        end
    end)

    
    -- ตั้งค่าเริ่มต้น
    Options.TpCSword:SetValue(false)
    Options.FarmMob:SetValue(false)
    Options.TP:SetValue(false)
    Options.Scooldown:SetValue(false)
    Options.SwordCooldown:SetValue(false)
end
