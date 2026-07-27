-- =========================================================================
-- ZeeHub Fully Bypassed & Expanded Script for SharkBite 2 (Xeno Compatible)
-- =========================================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
	Title = "ZeeHub (Universal Full Unlocked)",
	Footer = "SharkBite 2 & All Games [NoKey Bypassed]",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Information = Window:AddKeyTab("Information", "info"),
	Visuals = Window:AddTab("Visuals", "eye"),
	Blatant = Window:AddTab("Blatant", "skull"),
	Player = Window:AddTab("Player", "users"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

Tabs.Information:AddLabel({
	Text = "ZeeHub Official Unlocked Script\nAll key checks bypassed for yarik0505!",
	DoesWrap = true,
	Size = 16,
})

-- ---------------------------
-- Visuals Tab
-- ---------------------------
local VisualsLeftGroupBox = Tabs.Visuals:AddLeftGroupbox("Player & Shark ESP", "eye")

VisualsLeftGroupBox:AddToggle("SharkESP", {
	Text = "Shark ESP (Red Highlight)",
	Default = false,
	Tooltip = "Highlights the Shark in Red",
	Callback = function(Value)
		getgenv().ZeeHubSharkESP = Value
		if Value then
			task.spawn(function()
				while getgenv().ZeeHubSharkESP do
					task.wait(0.5)
					pcall(function()
						for _, p in ipairs(game.Players:GetPlayers()) do
							if p ~= game.Players.LocalPlayer and p.Character and (p.Character:FindFirstChild("Shark") or p.Character.Name:lower():find("shark")) then
								if not p.Character:FindFirstChild("ZeeHighlight") then
									local hl = Instance.new("Highlight")
									hl.Name = "ZeeHighlight"
									hl.FillColor = Color3.fromRGB(255, 0, 0)
									hl.Parent = p.Character
								end
							end
						end
					end)
				end
			end)
		else
			pcall(function()
				for _, p in ipairs(game.Players:GetPlayers()) do
					if p.Character and p.Character:FindFirstChild("ZeeHighlight") then
						p.Character.ZeeHighlight:Destroy()
					end
				end
			end)
		end
	end
})

VisualsLeftGroupBox:AddToggle("PlayerESP", {
	Text = "Player ESP",
	Default = false,
	Tooltip = "Highlights Players",
	Callback = function(Value)
		getgenv().ZeeHubPlayerESP = Value
		if Value then
			task.spawn(function()
				while getgenv().ZeeHubPlayerESP do
					task.wait(0.5)
					pcall(function()
						for _, p in ipairs(game.Players:GetPlayers()) do
							if p ~= game.Players.LocalPlayer and p.Character then
								if not p.Character:FindFirstChild("ZeePlayerHighlight") then
									local hl = Instance.new("Highlight")
									hl.Name = "ZeePlayerHighlight"
									hl.FillColor = Color3.fromRGB(0, 170, 255)
									hl.Parent = p.Character
								end
							end
						end
					end)
				end
			end)
		else
			pcall(function()
				for _, p in ipairs(game.Players:GetPlayers()) do
					if p.Character and p.Character:FindFirstChild("ZeePlayerHighlight") then
						p.Character.ZeePlayerHighlight:Destroy()
					end
				end
			end)
		end
	end
})

-- ---------------------------
-- Blatant Tab (Auto Farm & Aimbot)
-- ---------------------------
local BlatantGroupBox = Tabs.Blatant:AddLeftGroupbox("Auto Farm & Combat", "skull")

BlatantGroupBox:AddToggle("AutoShoot", {
	Text = "Auto Shoot Shark (Auto Weapon)",
	Default = false,
	Tooltip = "Equips weapon & automatically shoots shark",
	Callback = function(Value)
		getgenv().ZeeHubAutoShoot = Value
		if Value then
			task.spawn(function()
				while getgenv().ZeeHubAutoShoot do
					task.wait(0.05)
					pcall(function()
						local player = game.Players.LocalPlayer
						if not player or not player.Character then return end
						local character = player.Character
						
						local tool = character:FindFirstChildOfClass("Tool")
						if not tool and player:FindFirstChild("Backpack") then
							for _, item in ipairs(player.Backpack:GetChildren()) do
								if item:IsA("Tool") then
									item.Parent = character
									tool = item
									break
								end
							end
						end
						
						local shark = nil
						for _, p in ipairs(game.Players:GetPlayers()) do
							if p ~= player and p.Character and (p.Character:FindFirstChild("Shark") or p.Character.Name:lower():find("shark")) then
								shark = p.Character
								break
							end
						end
						
						if tool and shark then
							local part = shark:FindFirstChild("HumanoidRootPart") or shark:FindFirstChildOfClass("MeshPart") or shark.PrimaryPart
							if part then
								local remote = tool:FindFirstChild("Shoot") or tool:FindFirstChild("Fire") or tool:FindFirstChildOfClass("RemoteEvent")
								if remote then
									remote:FireServer(part.Position)
								else
									tool:Activate()
								end
							end
						end
					end)
				end
			end)
		end
	end
})

-- ---------------------------
-- Player Tab (Speed & Jump Mods)
-- ---------------------------
local PlayerGroupBox = Tabs.Player:AddLeftGroupbox("Player Modifications", "users")

PlayerGroupBox:AddSlider("WalkSpeed", {
	Text = "WalkSpeed",
	Default = 16,
	Min = 16,
	Max = 120,
	Rounding = 0,
	Callback = function(Value)
		pcall(function()
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
			end
		end)
	end
})

PlayerGroupBox:AddSlider("JumpPower", {
	Text = "JumpPower",
	Default = 50,
	Min = 50,
	Max = 200,
	Rounding = 0,
	Callback = function(Value)
		pcall(function()
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
			end
		end)
	end
})

-- Theme and Save Setup
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("ZeeHub")
SaveManager:SetFolder("ZeeHub/SharkBite2")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

Library:Notify({
	Title = "ZeeHub Full Unlocked!",
	Content = "All features loaded without key restrictions.",
	Duration = 5,
})
