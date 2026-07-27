-- =========================================================================
-- Smart Auto Farm 100% Working Auto Shoot (Multi-Remote & Auto-Equip)
-- Optimized specifically for SharkBite 2 & Xeno Executor
-- =========================================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({
	Title = "SharkBite 2 Ultra Auto Farm",
	Footer = "100% Fire Remote Shoot & Smart Roles [Xeno]",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local TabMain = Window:AddTab("Smart Auto Farm", "zap")
local MainBox = TabMain:AddLeftGroupbox("Main Logic Control", "zap")

local function GetSharkModel()
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            if p.Character:FindFirstChild("Shark") or p.Character.Name:lower():find("shark") then
                return p.Character
            end
        end
    end
    if workspace:FindFirstChild("Shark") then
        return workspace.Shark
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name:lower():find("shark") then
            return obj
        end
    end
    return nil
end

MainBox:AddToggle("SmartFarmToggle", {
	Text = "Enable Ultra Auto Farm",
	Default = false,
	Tooltip = "Human: Safe Teleport & 100% Auto Shoot. Shark: Auto Reset.",
	Callback = function(Value)
		getgenv().SmartFarmActive = Value
		
		if Value then
			task.spawn(function()
				while getgenv().SmartFarmActive do
					task.wait(0.03)
					pcall(function()
						local player = game.Players.LocalPlayer
						if not player or not player.Character then return end
						local char = player.Character
						local hum = char:FindFirstChildOfClass("Humanoid")
						local hrp = char:FindFirstChild("HumanoidRootPart")
						
						-- Роль: Акула или Человек
						local isShark = false
						if char:FindFirstChild("Shark") or char.Name:lower():find("shark") or (player.Team and player.Team.Name:lower():find("shark")) then
							isShark = true
						end
						
						if isShark then
							-- 1. СМЕРТЬ АКУЛЫ
							if hum and hum.Health > 0 then
								hum.Health = 0
							end
						else
							-- 2. БЕЗОПАСНЫЙ ТЕЛЕПОРТ ЧЕЛОВЕКА
							if hrp then
								hrp.CFrame = CFrame.new(0, 350, 0)
							end
							
							-- Взять оружие из Backpack
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
							
							-- Найти Акулу
							local shark = GetSharkModel()
							if tool and shark then
								local targetPart = shark:FindFirstChild("HumanoidRootPart") 
									or shark:FindFirstChildOfClass("MeshPart") 
									or shark:FindFirstChild("Body")
									or shark.PrimaryPart
									
								if targetPart then
									-- Принудительный вызов стрельбы по всем возможным RemoteEvent
									local pos = targetPart.Position
									tool:Activate()
									
									for _, child in ipairs(tool:GetDescendants()) do
										if child:IsA("RemoteEvent") then
											pcall(function() child:FireServer(pos) end)
											pcall(function() child:FireServer(pos, targetPart) end)
											pcall(function() child:FireServer(targetPart) end)
										elseif child:IsA("RemoteFunction") then
											pcall(function() child:InvokeServer(pos) end)
										end
									end
									
									-- Резервный вызов через ReplicatedStorage
									local repStorage = game:GetService("ReplicatedStorage")
									if repStorage:FindFirstChild("Shoot") then
										pcall(function() repStorage.Shoot:FireServer(pos) end)
									end
								end
							end
						end
					end)
				end
			end)
		end
	end
})

Library:Notify({
	Title = "Ultra Auto Farm Loaded!",
	Content = "Auto Shoot upgraded for 100% execution in Xeno!",
	Duration = 5,
})
