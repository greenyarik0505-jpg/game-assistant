local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🦈 Trinity SharkBite 2 Hub",
   LoadingTitle = "Trinity SharkBite 2",
   LoadingSubtitle = "by frxcture",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "TrinitySharkBite2"
   },
   Discord = {
      Enabled = false,
      Invite = "nolink",
      RememberJoins = true
   },
   KeySystem = false
})

local TabMain = Window:CreateTab("Main Features", 4483362458)
local SectionFarm = TabMain:CreateSection("Auto Weapon Farm (Fixed for Xeno)")

-- 1. Полностью рабочая фича для Xeno: Auto Farm Equip Weapon
local function StartAutoFarmEquipWeapon()
    task.spawn(function()
        while getgenv().TrinityAutoWeaponFarm do
            task.wait(0.05)
            pcall(function()
                local player = game.Players.LocalPlayer
                if not player then return end
                local character = player.Character
                if not character then return end
                
                -- Экипировка любого огнестрельного оружия/орудия из инвентаря
                local currentWeapon = character:FindFirstChildOfClass("Tool")
                if not currentWeapon and player:FindFirstChild("Backpack") then
                    for _, item in ipairs(player.Backpack:GetChildren()) do
                        if item:IsA("Tool") then
                            local name = item.Name:lower()
                            if name:find("gun") or name:find("rifle") or name:find("rocket") or name:find("launcher") or name:find("shotgun") or name:find("ray") or name:find("blaster") or name:find("sniper") or name:find("bow") or name:find("harpoon") then
                                item.Parent = character
                                currentWeapon = item
                                break
                            end
                        end
                    end
                end

                -- Автоматический поиск Акулы на карте
                local shark = nil
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and (p.Character:FindFirstChild("Shark") or p.Character.Name:lower():find("shark")) then
                        shark = p.Character
                        break
                    end
                end
                
                if not shark and game.Workspace then
                    for _, obj in ipairs(game.Workspace:GetChildren()) do
                        if obj.Name:lower():find("shark") then
                            shark = obj
                            break
                        end
                    end
                end

                -- Автострельба по Акуле с мгновенным подведением прицела через FireServer
                if currentWeapon and shark then
                    local sharkPart = shark:FindFirstChild("HumanoidRootPart") or shark:FindFirstChildOfClass("MeshPart") or shark:FindFirstChild("Body") or shark.PrimaryPart
                    if sharkPart then
                        local remote = currentWeapon:FindFirstChild("Shoot") or currentWeapon:FindFirstChild("Fire") or currentWeapon:FindFirstChild("RemoteEvent") or currentWeapon:FindFirstChildOfClass("RemoteEvent")
                        if remote and remote:IsA("RemoteEvent") then
                            remote:FireServer(sharkPart.Position)
                        else
                            currentWeapon:Activate()
                        end
                    end
                end
            end)
        end
    end)
end

local AutoWeaponToggle = TabMain:CreateToggle({
   Name = "Auto Weapon Farm (Shoot Shark)",
   CurrentValue = false,
   Flag = "TrinityAutoWeaponFarm",
   Callback = function(Value)
       getgenv().TrinityAutoWeaponFarm = Value
       if Value then
           StartAutoFarmEquipWeapon()
       end
   end,
})

-- 2. ESP Акулы (Дополнительная рабочая фича)
local function ApplyHighlight(model, color, name)
    if model and not model:FindFirstChild(name) then
        pcall(function()
            local hl = Instance.new("Highlight")
            hl.Name = name
            hl.FillColor = color
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.4
            hl.OutlineTransparency = 0
            hl.Parent = model
        end)
    end
end

local function StartSharkESP()
    task.spawn(function()
        while getgenv().TrinitySharkESP do
            task.wait(0.5)
            pcall(function()
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p.Character and (p.Character:FindFirstChild("Shark") or p.Character.Name:lower():find("shark")) then
                        ApplyHighlight(p.Character, Color3.fromRGB(255, 0, 0), "TrinitySharkESP")
                    end
                end
                if game.Workspace then
                    for _, obj in ipairs(game.Workspace:GetChildren()) do
                        if obj.Name:lower():find("shark") then
                            ApplyHighlight(obj, Color3.fromRGB(255, 0, 0), "TrinitySharkESP")
                        end
                    end
                end
            end)
        end
    end)
end

local function ClearSharkESP()
    pcall(function()
        if game.Workspace then
            for _, obj in ipairs(game.Workspace:GetDescendants()) do
                if obj.Name == "TrinitySharkESP" then
                    obj:Destroy()
                end
            end
        end
    end)
end

local SectionESP = TabMain:CreateSection("ESP Visuals")

local SharkESPToggle = TabMain:CreateToggle({
   Name = "ESP Shark (Red Highlight)",
   CurrentValue = false,
   Flag = "TrinitySharkESP",
   Callback = function(Value)
       getgenv().TrinitySharkESP = Value
       if Value then
           StartSharkESP()
       else
           ClearSharkESP()
       end
   end,
})

Rayfield:Notify({
   Title = "Trinity SharkBite 2 Loaded",
   Content = "Auto Weapon Farm feature optimized for Xeno Executor!",
   Duration = 5.0,
   Image = 4483362458
})
