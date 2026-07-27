-- =========================================================================
-- Minimalistic Auto Farm Toggle GUI for SharkBite 2
-- Checks: Spectator Mode & Active Round Participation
-- UI: Clean Minimalist Floating Widget (ON / OFF)
-- =========================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Удалить старую плашку если есть
for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name == "SharkBiteSimpleToggleUI" then
        gui:Destroy()
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SharkBiteSimpleToggleUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end

-- Главная мини-плашка
local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 220, 0, 90)
Frame.Position = UDim2.new(0.02, 0, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 2
UIStroke.Parent = Frame

-- Заголовок плашки
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "🦈 Auto Farm Control"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

-- Статус раунда/наблюдателя
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0.3, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Checking..."
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = Frame

-- Кнопка ВКЛ / ВЫКЛ
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.075, 0, 0.58, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
ToggleButton.Text = "AUTO FARM: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 13
ToggleButton.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleButton

local isFarmActive = false

-- Проверка участия в игре (Не в Spectator)
local function IsPlayerInMatch()
    if not LocalPlayer then return false end
    
    -- 1. Проверяем команду Spectator
    if LocalPlayer.Team and LocalPlayer.Team.Name:lower():find("spectator") then
        return false
    end
    
    -- 2. Проверяем список наблюдателей на экране
    pcall(function()
        if LocalPlayer.PlayerGui then
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if gui:IsA("TextLabel") and gui.Text:lower():find("spectator") then
                    if gui.Parent and gui.Parent:FindFirstChild(LocalPlayer.Name) then
                        return false
                    end
                end
            end
        end
    end)
    
    -- 3. Проверяем наличие персонажа в игре
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    return true
end

-- Логика переключения
ToggleButton.MouseButton1Click:Connect(function()
    isFarmActive = not isFarmActive
    getgenv().MinimalFarmActive = isFarmActive
    
    if isFarmActive then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 200, 90)
        ToggleButton.Text = "AUTO FARM: ON"
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
        ToggleButton.Text = "AUTO FARM: OFF"
        StatusLabel.Text = "Status: Disabled"
    end
end)

-- Основной цикл автофарма
task.spawn(function()
    while true do
        task.wait(0.05)
        if getgenv().MinimalFarmActive then
            pcall(function()
                local inMatch = IsPlayerInMatch()
                
                if not inMatch then
                    StatusLabel.Text = "Status: Spectator (Waiting match)"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
                    return -- Пропускаем телепорт и стрельбу если вы наблюдете (Spectator)!
                end
                
                local char = LocalPlayer.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                
                -- Вы за Акулу?
                local isShark = false
                if char:FindFirstChild("Shark") or char.Name:lower():find("shark") or (LocalPlayer.Team and LocalPlayer.Team.Name:lower():find("shark")) then
                    isShark = true
                end
                
                if isShark then
                    StatusLabel.Text = "Status: Shark (Auto Reset)"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                    if hum and hum.Health > 0 then
                        hum.Health = 0 -- Авто-сброс за Акулу
                    end
                else
                    StatusLabel.Text = "Status: Human (Farming...)"
                    StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
                    
                    -- Телепорт Человека над картой
                    if hrp then
                        hrp.CFrame = CFrame.new(0, 350, 0)
                    end
                    
                    -- Взять оружие из рюкзака
                    local tool = char:FindFirstChildOfClass("Tool")
                    if not tool and LocalPlayer:FindFirstChild("Backpack") then
                        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                item.Parent = char
                                tool = item
                                break
                            end
                        end
                    end
                    
                    -- Находим Акулу на карте
                    local shark = nil
                    for _, p in ipairs(game.Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            if p.Character:FindFirstChild("Shark") or p.Character.Name:lower():find("shark") then
                                shark = p.Character
                                break
                            end
                        end
                    end
                    if not shark and workspace:FindFirstChild("Shark") then shark = workspace.Shark end
                    
                    -- Стрельба по Акуле
                    if tool and shark then
                        local part = shark:FindFirstChild("HumanoidRootPart") or shark:FindFirstChildOfClass("MeshPart") or shark.PrimaryPart
                        if part then
                            tool:Activate()
                            for _, child in ipairs(tool:GetDescendants()) do
                                if child:IsA("RemoteEvent") then
                                    pcall(function() child:FireServer(part.Position) end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
