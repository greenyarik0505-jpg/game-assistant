-- =========================================================================
-- Smart Auto Farm Panel for SharkBite 2 (Xeno Optimized)
-- Features: Clean UI Toggle Panel, Accurate Shark Status Detection, Auto Shoot & Auto Reset
-- =========================================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({
	Title = "SharkBite 2 Auto Farm Control",
	Footer = "Smart Detection & Auto Shoot [Xeno]",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local TabMain = Window:AddTab("Control Panel", "zap")
local MainBox = TabMain:AddLeftGroupbox("Auto Farm Switch", "power")
local StatusBox = TabMain:AddRightGroupbox("Shark Status & Info", "info")

-- Отображение точного статуса Акулы в Панели
local SharkStatusLabel = StatusBox:AddLabel({
	Text = "Shark Status: Checking...",
	DoesWrap = true,
})

local RoleLabel = StatusBox:AddLabel({
	Text = "Your Role: Human",
	DoesWrap = true,
})

-- Функция точного поиска Акулы на карте
local function FindActiveShark()
    -- 1. Поиск среди игроков
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            local char = p.Character
            if char:FindFirstChild("Shark") or char.Name:lower():find("shark") or (p.Team and p.Team.Name:lower():find("shark")) then
                return char, p.Name
            end
        end
    end
    -- 2. Поиск среди объектов Workspace
    if workspace:FindFirstChild("Shark") then
        return workspace.Shark, "Workspace Shark"
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name:lower():find("shark") and obj:IsA("Model") then
            return obj, obj.Name
        end
    end
    return nil, nil
end

-- Переключатель в Панели (ВКЛ / ВЫКЛ)
MainBox:AddToggle("AutoFarmMasterToggle", {
	Text = "AUTO FARM (ON / OFF)",
	Default = false,
	Tooltip = "Turn ON to Auto Shoot + Auto Reset Shark. Turn OFF to Stop.",
	Callback = function(Value)
		getgenv().SmartFarmActive = Value
		
		if Value then
			Library:Notify({ Title = "Auto Farm", Content = "Auto Farm ENABLED!", Duration = 3 })
			
			task.spawn(function()
				while getgenv().SmartFarmActive do
					task.wait(0.03)
					pcall(function()
						local player = game.Players.LocalPlayer
						if not player or not player.Character then return end
						local char = player.Character
						local hum = char:FindFirstChildOfClass("Humanoid")
						local hrp = char:FindFirstChild("HumanoidRootPart")
						
						-- Проверка точного статуса Акулы
						local sharkModel, sharkName = FindActiveShark()
						if sharkModel then
							SharkStatusLabel:SetText("Shark Status: ALIVE (" .. tostring(sharkName) .. ")")
						else
							SharkStatusLabel:SetText("Shark Status: NOT FOUND / WAITING ROUND")
						end
						
						-- Проверка роли игрока
						local isShark = false
						if char:FindFirstChild("Shark") or char.Name:lower():find("shark") or (player.Team and player.Team.Name:lower():find("shark")) then
							isShark = true
						end
						
						if isShark then
							RoleLabel:SetText("Your Role: SHARK (Auto Resetting...)")
							-- Акула убивает себя для мгновенной победы/раунда
							if hum and hum.Health > 0 then
								hum.Health = 0
							end
						else
							RoleLabel:SetText("Your Role: HUMAN (Farming...)")
							
							-- Безопасный Телепорт над картой
							if hrp then
								hrp.CFrame = CFrame.new(0, 350, 0)
							end
							
							-- Экипировка оружия из рюкзака
							local tool = char:FindFirstChildOfClass("Tool")
							if not tool and player:FindFirstChild("Backpack") then
								for _, item in ipairs(player.Backpack:GetChildren()) do
									if item:IsA("Tool") then
										item.Parent = char
										tool = item
										break
									end
								end
							end
							
							-- Стрельба ТОЛЬКО если Акула ТОЧНО есть на карте
							if tool and sharkModel then
								local targetPart = sharkModel:FindFirstChild("HumanoidRootPart") 
									or sharkModel:FindFirstChildOfClass("MeshPart") 
									or sharkModel:FindFirstChild("Body")
									or sharkModel.PrimaryPart
									
								if targetPart then
									local pos = targetPart.Position
									tool:Activate()
									
									for _, child in ipairs(tool:GetDescendants()) do
										if child:IsA("RemoteEvent") then
											pcall(function() child:FireServer(pos) end)
											pcall(function() child:FireServer(pos, targetPart) end)
										end
									end
								end
							end
						end
					end)
				end
			end)
		else
			SharkStatusLabel:SetText("Shark Status: OFF")
			RoleLabel:SetText("Your Role: IDLE")
			Library:Notify({ Title = "Auto Farm", Content = "Auto Farm DISABLED!", Duration = 3 })
		end
	end
})

Library:Notify({
	Title = "Control Panel Ready",
	Content = "Use the Panel to Toggle Auto Farm ON / OFF!",
	Duration = 4,
})
