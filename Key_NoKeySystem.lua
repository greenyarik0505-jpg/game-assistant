local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🦈 SharkBite 2 Hub",
   LoadingTitle = "SharkBite 2 Hub",
   LoadingSubtitle = "by n0namevnnek",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "SharkBite2Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "nolink",
      RememberJoins = true
   },
   KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)
local Section = Tab:CreateSection("Auto Farm")

-- Безопасные функции фарма с полной проверкой nil / pcall
local function SafeAutoFarmEquipWeapon()
    task.spawn(function()
        while getgenv().AutoFarmEquipWeapon do
            task.wait(0.1)
            pcall(function()
                local player = game.Players.LocalPlayer
                if not player then return end
                local character = player.Character
                if not character then return end
                
                local currentWeapon = character:FindFirstChildOfClass("Tool")
                if not currentWeapon and player:FindFirstChild("Backpack") then
                    for _, item in ipairs(player.Backpack:GetChildren()) do
                        if item:IsA("Tool") then
                            local itemName = item.Name:lower()
                            if itemName:find("gun") or itemName:find("rifle") or itemName:find("rocket") or itemName:find("launcher") or itemName:find("shotgun") or itemName:find("ray") or itemName:find("blaster") or itemName:find("sniper") or itemName:find("bow") or itemName:find("harpoon") then
                                item.Parent = character
                                currentWeapon = item
                                break
                            end
                        end
                    end
                end

                local shark = nil
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Shark") then
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

                if currentWeapon and shark then
                    local sharkHRP = shark:FindFirstChild("HumanoidRootPart") or shark:FindFirstChildOfClass("MeshPart") or shark:FindFirstChild("Body") or shark.PrimaryPart
                    if sharkHRP then
                        local remote = currentWeapon:FindFirstChild("Shoot") or currentWeapon:FindFirstChild("Fire") or currentWeapon:FindFirstChild("RemoteEvent")
                        if remote and remote:IsA("RemoteEvent") then
                            remote:FireServer(sharkHRP.Position)
                        else
                            currentWeapon:Activate()
                        end
                    end
                end
            end)
        end
    end)
end

local AutoFarmEquipWeaponToggle = Tab:CreateToggle({
   Name = "Auto Farm Equip Weapon",
   CurrentValue = false,
   Flag = "AutoFarmEquipWeapon",
   Callback = function(Value)
       getgenv().AutoFarmEquipWeapon = Value
       if Value then
           SafeAutoFarmEquipWeapon()
       end
   end,
})

local function SafeAutoFarmEquipWeaponBoat()
    task.spawn(function()
        while getgenv().AutoFarmEquipWeaponBoat do
            task.wait(0.1)
            pcall(function()
                local player = game.Players.LocalPlayer
                if not player then return end
                local character = player.Character
                if not character then return end
                
                local currentWeapon = character:FindFirstChildOfClass("Tool")
                if not currentWeapon and player:FindFirstChild("Backpack") then
                    for _, item in ipairs(player.Backpack:GetChildren()) do
                        if item:IsA("Tool") then
                            local itemName = item.Name:lower()
                            if itemName:find("gun") or itemName:find("rifle") or itemName:find("rocket") or itemName:find("launcher") or itemName:find("shotgun") or itemName:find("ray") or itemName:find("blaster") or itemName:find("sniper") or itemName:find("bow") or itemName:find("harpoon") then
                                item.Parent = character
                                currentWeapon = item
                                break
                            end
                        end
                    end
                end

                local shark = nil
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Shark") then
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

                if currentWeapon and shark then
                    local sharkHRP = shark:FindFirstChild("HumanoidRootPart") or shark:FindFirstChildOfClass("MeshPart") or shark:FindFirstChild("Body") or shark.PrimaryPart
                    if sharkHRP then
                        local remote = currentWeapon:FindFirstChild("Shoot") or currentWeapon:FindFirstChild("Fire") or currentWeapon:FindFirstChild("RemoteEvent")
                        if remote and remote:IsA("RemoteEvent") then
                            remote:FireServer(sharkHRP.Position)
                        else
                            currentWeapon:Activate()
                        end
                    end
                end
            end)
        end
    end)
end

local AutoFarmEquipWeaponBoatToggle = Tab:CreateToggle({
   Name = "Auto Farm Equip Weapon Boat (Alpha)",
   CurrentValue = false,
   Flag = "AutoFarmEquipWeaponBoat",
   Callback = function(Value)
       getgenv().AutoFarmEquipWeaponBoat = Value
       if Value then
           SafeAutoFarmEquipWeaponBoat()
       end
   end,
})

local function SafeAutoFarmChest()
    task.spawn(function()
        while getgenv().AutoFarmChest do
            task.wait(0.1)
            pcall(function()
                local player = game.Players.LocalPlayer
                if not player then return end
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end

                if game.Workspace then
                    for _, obj in ipairs(game.Workspace:GetChildren()) do
                        if obj.Name:lower():find("chest") or obj.Name:lower():find("gift") or obj.Name:lower():find("treasure") then
                            local part = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildOfClass("MeshPart") or obj:FindFirstChildOfClass("Part")
                            if part then
                                character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                                if firetouchinterest then
                                    firetouchinterest(character.HumanoidRootPart, part, 0)
                                    firetouchinterest(character.HumanoidRootPart, part, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end

local AutoFarmChestToggle = Tab:CreateToggle({
   Name = "Auto Farm Chest",
   CurrentValue = false,
   Flag = "AutoFarmChest",
   Callback = function(Value)
       getgenv().AutoFarmChest = Value
       if Value then
           SafeAutoFarmChest()
       end
   end,
})

local Section = Tab:CreateSection("ESP")

local function ApplyHighlight(model, color, name)
    if model and not model:FindFirstChild(name) then
        pcall(function()
            local hl = Instance.new("Highlight")
            hl.Name = name
            hl.FillColor = color
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Parent = model
        end)
    end
end

local function ClearESP(name)
    pcall(function()
        if game.Workspace then
            for _, obj in ipairs(game.Workspace:GetDescendants()) do
                if obj.Name == name then
                    obj:Destroy()
                end
            end
        end
    end)
end

local function SafeESPShark()
    task.spawn(function()
        while getgenv().ESPShark do
            task.wait(1)
            pcall(function()
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Shark") then
                        ApplyHighlight(p.Character, Color3.fromRGB(255, 0, 0), "SharkESP")
                    end
                end
                if game.Workspace then
                    for _, obj in ipairs(game.Workspace:GetChildren()) do
                        if obj.Name:lower():find("shark") then
                            ApplyHighlight(obj, Color3.fromRGB(255, 0, 0), "SharkESP")
                        end
                    end
                end
            end)
        end
    end)
end

local ESPSharkToggle = Tab:CreateToggle({
   Name = "ESP Shark",
   CurrentValue = false,
   Flag = "ESPShark",
   Callback = function(Value)
       getgenv().ESPShark = Value
       if Value then
           SafeESPShark()
       else
           ClearESP("SharkESP")
       end
   end,
})

local function SafeESPPlayers()
    task.spawn(function()
        while getgenv().ESPPlayers do
            task.wait(1)
            pcall(function()
                local lp = game.Players.LocalPlayer
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= lp and p.Character then
                        ApplyHighlight(p.Character, Color3.fromRGB(0, 255, 0), "PlayerESP")
                    end
                end
            end)
        end
    end)
end

local ESPPlayersToggle = Tab:CreateToggle({
   Name = "ESP Players",
   CurrentValue = false,
   Flag = "ESPPlayers",
   Callback = function(Value)
       getgenv().ESPPlayers = Value
       if Value then
           SafeESPPlayers()
       else
           ClearESP("PlayerESP")
       end
   end,
})

Rayfield:Notify({
   Title = "SharkBite 2 Hub Loaded!",
   Content = "Script loaded successfully.",
   Duration = 5.0,
   Image = 4483362458
})
