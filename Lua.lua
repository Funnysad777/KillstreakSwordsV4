local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ==================== WINDOW SETUP ====================
local Window = Fluent:CreateWindow({
    Title = "Null Hub | STLD | [Version 1.0.0]",
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
    local mob_model = {}
    
    task.spawn(function()
        while true do task.wait(0.5)
            table.clear(mob_model)
            for i,v in pairs(Npc:GetDescendants()) do
                if v:IsA("Model") then
                   table.insert(mob_model, v.Name)
                end
            end
        end
    end)
    
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
        Values = mob_model,
        Multi = true,
        Default = 1,
    })

    Tabs.Main:AddButton({
        Title = "Reset mob dropdown",
        Description = "",
        Callback = function()
            Dropdown_mob:SetValue(mob_model)
        end
    })
    
    -- Toggle สำหรับเทเลพอร์ตไปหาดาบ
    local TpS = Tabs.Main:AddToggle("TpCSword", {
        Title = "TP Choose Sword",
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
    
    local mobFarm = Tabs.Main:AddToggle("FarmMob", {
        Title = "Auto Farm",
        Default = false
    })

    local mobHixboxExpand = Tabs.Main:AddToggle("Hitbox", {
        Title = "Hitbox Expanded",
        Default = false
    })

    mobFarm:OnChanged(function()
        if mobFarm.Value then
            task.spawn(function()
                while mobFarm.Value do task.wait()
                    local success, err = pcall(function()
                        local hrp, humanoid = getCharacterParts()
                        
                        local selectedMob = Dropdown_mob.Value
                            
                        if hrp and selectedMob then
                            for _,mob in pairs(Npc:GetDescendants()) do
                                if mob.Name == selectedMob and mob:IsA("Model") then
                                    local mobHrp = mob:FindFirstChild("HumanoidRootPart")
                                    local mobHumanoid = mob:FindFirstChild("Humanoid")
                                    
                                    if mobHrp and mobHumanoid.health >= 0 then
                                        hrp.CFrame = mobHrp.CFrame * CFrame.new(0,10,0)
                                        break
                                    else
                                        print(mobHrp,mobHumanoid.health)
                                    end
                                else
                                    print(mob.Name)
                                end
                            end
                        else
                            print(hrp)
                        end
                    end)
                end
            end)
        end
    end)

    
    
    -- ตั้งค่าเริ่มต้น
    Options.TpCSword:SetValue(false)
    Options.FarmMob:SetValue(false)
    Options.mobHixboxExpand:SetValue(false)
end
