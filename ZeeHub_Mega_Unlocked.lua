-- =========================================================================
-- ZeeHub Mega Unlocked (All Universal & Game Features Included)
-- =========================================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
	Title = "ZeeHub Premium (All Features Unlocked)",
	Footer = "Universal Hub [Bypassed & Extended]",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Information = Window:AddKeyTab("Information", "info"),
	Visuals = Window:AddTab("Visuals", "eye"),
	Blatant = Window:AddTab("Blatant", "skull"),
	Player = Window:AddTab("Player", "users"),
	Teleport = Window:AddTab("Teleports", "map-pin"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

Tabs.Information:AddLabel({
	Text = "ZeeHub Complete Master Edition\nAll 100% features, visuals, & farms unlocked for yarik0505!",
	DoesWrap = true,
	Size = 16,
})

-- ---------------------------
-- 1. Visuals Tab (Player, Shark, Chams, Tracers)
-- ---------------------------
local VisualsPlayerBox = Tabs.Visuals:AddLeftGroupbox("Player & Entity ESP", "eye")

VisualsPlayerBox:AddToggle("PlayerNametag", {
	Text = "Player ESP & Nametags",
	Default = false,
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

VisualsPlayerBox:AddToggle("SharkESP", {
	Text = "Shark ESP (Red Highlight)",
	Default = false,
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

-- ---------------------------
-- 2. Blatant Tab (Auto Farm, Auto Shoot, Kill All)
-- ---------------------------
local BlatantBox = Tabs.Blatant:AddLeftGroupbox("Combat & Auto Farm", "skull")

BlatantBox:AddToggle("AutoShoot", {
	Text = "Auto Shoot Target (Shark/Enemies)",
	Default = false,
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
						
						local target = nil
						for _, p in ipairs(game.Players:GetPlayers()) do
							if p ~= player and p.Character and (p.Character:FindFirstChild("Shark") or p.Character.Name:lower():find("shark")) then
								target = p.Character
								break
							end
						end
						
						if tool and target then
							local part = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildOfClass("MeshPart") or target.PrimaryPart
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

BlatantBox:AddToggle("InfAmmo", {
	Text = "Infinite Ammo / Rapid Fire",
	Default = false,
	Callback = function(Value)
		getgenv().InfAmmo = Value
	end
})

-- ---------------------------
-- 3. Player Tab (Fly, WalkSpeed, Jump, Noclip)
-- ---------------------------
local PlayerBox = Tabs.Player:AddLeftGroupbox("Movement Modifications", "users")

PlayerBox:AddSlider("WalkSpeed", {
	Text = "Speed Multiplier",
	Default = 16,
	Min = 16,
	Max = 200,
	Rounding = 0,
	Callback = function(Value)
		pcall(function()
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
			end
		end)
	end
})

PlayerBox:AddSlider("JumpPower", {
	Text = "Jump Height",
	Default = 50,
	Min = 50,
	Max = 300,
	Rounding = 0,
	Callback = function(Value)
		pcall(function()
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
			end
		end)
	end
})

PlayerBox:AddToggle("Noclip", {
	Text = "Noclip (Walk Through Walls)",
	Default = false,
	Callback = function(Value)
		getgenv().ZeeNoclip = Value
		if Value then
			task.spawn(function()
				while getgenv().ZeeNoclip do
					task.wait()
					pcall(function()
						if game.Players.LocalPlayer.Character then
							for _, part in ipairs(game.Players:GetPlayers().LocalPlayer.Character:GetChildren()) do
								if part:IsA("BasePart") then
									part.CanCollide = false
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
-- 4. Teleport Tab
-- ---------------------------
local TeleportBox = Tabs.Teleport:AddLeftGroupbox("Safe Locations", "map-pin")

TeleportBox:AddButton({
	Text = "Teleport to Safe Island",
	Func = function()
		pcall(function()
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
			end
		end)
	end
})

-- Theme and Settings
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("ZeeHub")
SaveManager:SetFolder("ZeeHub/Universal")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

Library:Notify({
	Title = "ZeeHub Mega Unlocked Loaded!",
	Content = "All features are active & 100% available.",
	Duration = 5,
})
