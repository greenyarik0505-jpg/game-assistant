-- =========================================================================
-- Smart Auto Farm for SharkBite 2 (Optimized for Xeno)
-- If Human: Teleports to safe sky position & Auto Shoots Shark
-- If Shark: Auto Kills Self (Reset / Oof) to instantly end round & gain stats/win
-- =========================================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local Window = Library:CreateWindow({
	Title = "SharkBite 2 Smart Auto Farm",
	Footer = "Auto Human Teleport & Auto Shark Reset [Xeno]",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local TabMain = Window:AddTab("Smart Auto Farm", "zap")
local MainBox = TabMain:AddLeftGroupbox("Main Logic Control", "zap")

local farmActive = false

MainBox:AddToggle("SmartFarmToggle", {
	Text = "Enable Smart Auto Farm",
	Default = false,
	Tooltip = "Human: Safe Teleport & Shoot. Shark: Auto Reset.",
	Callback = function(Value)
		farmActive = Value
		getgenv().SmartFarmActive = Value
		
		if Value then
			task.spawn(function()
				while getgenv().SmartFarmActive do
					task.wait(0.2)
					pcall(function()
						local player = game.Players.LocalPlayer
						if not player or not player.Character then return end
						local char = player.Character
						local hum = char:FindFirstChildOfClass("Humanoid")
						local hrp = char:FindFirstChild("HumanoidRootPart")
						
						-- Проверяем: Вы за Акулу или за Человека
						local isShark = false
						if char:FindFirstChild("Shark") or char.Name:lower():find("shark") or (player.Team and player.Team.Name:lower():find("shark")) then
							isShark = true
						end
						
						if isShark then
							-- 1. ЕСЛИ ВЫ АКУЛА -> УБИВАЕМСЯ (Auto Self Kill / Reset)
							if hum and hum.Health > 0 then
								hum.Health = 0 -- Мгновенная смерть Акулы для быстрого завершения раунда
							end
						else
							-- 2. ЕСЛИ ВЫ ЧЕЛОВЕК -> ТЕЛЕПОРТ В БЕЗОПАСНОЕ МЕСТО + АВТО-СТРЕЛЬБА
							if hrp then
								-- Безопасный телепорт над картой
								hrp.CFrame = CFrame.new(0, 350, 0)
							end
							
							-- Экипировка оружия из инвентаря
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
							
							-- Находим Акулу на карте
							local sharkTarget = nil
							for _, p in ipairs(game.Players:GetPlayers()) do
								if p ~= player and p.Character and (p.Character:FindFirstChild("Shark") or p.Character.Name:lower():find("shark")) then
									sharkTarget = p.Character
									break
								end
							end
							
							if not sharkTarget and workspace:FindFirstChild("Shark") then
								sharkTarget = workspace.Shark
							end
							
							-- Автоматическая стрельба по Акуле
							if tool and sharkTarget then
								local targetPart = sharkTarget:FindFirstChild("HumanoidRootPart") or sharkTarget:FindFirstChildOfClass("MeshPart") or sharkTarget.PrimaryPart
								if targetPart then
									local remote = tool:FindFirstChild("Shoot") or tool:FindFirstChild("Fire") or tool:FindFirstChildOfClass("RemoteEvent")
									if remote then
										remote:FireServer(targetPart.Position)
									else
										tool:Activate()
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
	Title = "Smart Auto Farm Loaded!",
	Content = "Human -> Safe Teleport. Shark -> Auto Reset.",
	Duration = 5,
})
