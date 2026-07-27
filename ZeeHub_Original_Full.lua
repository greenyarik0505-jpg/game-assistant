local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
local Window = Library:CreateWindow({
	Title = "ZeeHub",
	Footer = "Violence District [PREMIUM]",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})
---------------------------
-- List Semua Tabs
----------------------------
local Tabs = {
	Information = Window:AddKeyTab("Information", "info"),
	Visuals = Window:AddTab("Visuals", "eye"),
	Blatant = Window:AddTab("Blatant", "skull"),
	Player = Window:AddTab("Player", "users"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}
---------------------------
-- Tabs Information
----------------------------
Tabs.Information:AddLabel({
	Text = "ZeeHub [Official] #5k 🎉\n© ᴢᴇᴇʜᴜʙ ɪɴᴅᴏɴᴇꜱɪᴀ\ndiscord.gg/fH7mPkJMWE",
	DoesWrap = true,
	Size = 16,
})
---------------------------
-- Tab Kiri Visuals [Player]
----------------------------
local VisualsLeftGroupBox = Tabs.Visuals:AddLeftGroupbox("Player", "users-round")
-- 🔥 ESP / Chams Player logic
local espPlayersActive = false
local espNoNameActive = false
local espPlayersObjects = {}
local espConnections = {}
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
-- 🧹 Disconnect all ESP connections
local function disconnectESPConnections()
    for _, conn in ipairs(espConnections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(espConnections)
end
-- 🧹 Clear all ESP visuals
local function clearESP()
    for _, objs in pairs(espPlayersObjects) do
        if objs.highlight then pcall(function() objs.highlight:Destroy() end) end
        if objs.nametag then pcall(function() objs.nametag:Destroy() end) end
    end
    espPlayersObjects = {}
end
-- 📌 Safe parent for ESP objects
local function safeParent(obj)
    local ok = pcall(function()
        obj.Parent = CoreGui
    end)
    if not ok then
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            obj.Parent = pg
        else
            obj.Parent = workspace
        end
    end
end
-- 🧩 Create highlight + nametag
local function createESP(player, withName)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local color
    local killerTeam = Teams:FindFirstChild("Killer")
    local survivorTeam = Teams:FindFirstChild("Survivors")
    if killerTeam and player.Team == killerTeam then
        color = Color3.fromRGB(255, 0, 0)
    elseif survivorTeam and player.Team == survivorTeam then
        color = Color3.fromRGB(0, 150, 255)
    else
        color = Color3.fromRGB(255, 255, 255)
    end
    if espPlayersObjects[player] then
        if espPlayersObjects[player].highlight then pcall(function() espPlayersObjects[player].highlight:Destroy() end) end
        if espPlayersObjects[player].nametag then pcall(function() espPlayersObjects[player].nametag:Destroy() end) end
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESPHighlight"
    highlight.Adornee = character
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    safeParent(highlight)
    local billboard = nil
    if withName then
        local head = character:FindFirstChild("Head")
        if head then
            billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPNametag"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 130, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            safeParent(billboard)
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = color
            textLabel.TextStrokeTransparency = 0
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextScaled = true
            textLabel.Text = string.format("%s (%s)", player.Name, player.Team and player.Team.Name or "Unknown")
            textLabel.Parent = billboard
        end
    end
    espPlayersObjects[player] = {highlight = highlight, nametag = billboard}
end
-- 🔁 Track one player (respawn & team change)
local function setupPlayerTracking(player)
    if player == LocalPlayer then return end
    if player.Character then
        task.delay(0.1, function()
            if espPlayersActive or espNoNameActive then
                createESP(player, espPlayersActive)
            end
        end)
    end
    table.insert(espConnections,
        player.CharacterAdded:Connect(function()
            task.delay(0.2, function()
                if espPlayersActive or espNoNameActive then
                    createESP(player, espPlayersActive)
                end
            end)
        end)
    )
    table.insert(espConnections,
        player:GetPropertyChangedSignal("Team"):Connect(function()
            if espPlayersActive or espNoNameActive then
                createESP(player, espPlayersActive)
            end
        end)
    )
end
-- 🚀 Enable ESP (withName or noName)
local function enableESP(withName)
    clearESP()
    disconnectESPConnections()
    for _, player in ipairs(Players:GetPlayers()) do
        setupPlayerTracking(player)
    end
    table.insert(espConnections,
        Players.PlayerAdded:Connect(function(player)
            setupPlayerTracking(player)
        end)
    )
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESP(player, withName)
        end
    end
end
-- 🔹 UI Toggle integration
VisualsLeftGroupBox:AddToggle("PlayerNametag", {
    Text = "Player Nametag",
    Default = false,
    Callback = function(state)
        espPlayersActive = state
        espNoNameActive = false
        if state then
            enableESP(true)
        else
            clearESP()
            disconnectESPConnections()
        end
    end,
})
VisualsLeftGroupBox:AddToggle("ChamsPlayer", {
    Text = "Chams",
    Default = false,
    Callback = function(state)
        espNoNameActive = state
        espPlayersActive = false
        if state then
            enableESP(false)
        else
            clearESP()
            disconnectESPConnections()
        end
    end,
})
---------------------------
-- Tab Kiri Visuals [Generator]
----------------------------
local VisualsLeftGroupBox2 = Tabs.Visuals:AddLeftGroupbox("Generator", "zap")
---------------------------
-- Fiture ESP Generator Name
----------------------------
local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()
ESP.Players = false
ESP.Boxes = false
ESP.Names = true
ESP:Toggle(true)
VisualsLeftGroupBox2:AddToggle("Nametag", {
	Text = "Nametag",
	Default = false,
	Callback = function(state)
        if state then
            -- Listener object Generator
            ESP:AddObjectListener(workspace.Map, {
                Name = "Generator",
                CustomName = "Generator",
                Color = Color3.fromRGB(255, 0, 0),
                IsEnabled = "GeneratorESP"
            })
            -- Rooftop
            local map = workspace:FindFirstChild("Map")
            if map then
                local rooftop = map:FindFirstChild("Rooftop")
                if rooftop then
                    local function AddGenESP(obj)
                        if obj:IsA("BasePart") and obj.Name == "HitBox" then
                            ESP:Add(obj, {
                                Name = "Generator",
                                Color = Color3.fromRGB(255, 0, 0)
                            })
                        end
                    end
                    for _, v in ipairs(rooftop:GetDescendants()) do
                        AddGenESP(v)
                    end
                    rooftop.DescendantAdded:Connect(AddGenESP)
                end
            end
            -- Gens
            local map2 = workspace:FindFirstChild("Map")
            if map2 then
                local gens = map2:FindFirstChild("Gens")
                if gens then
                    local function AddGenESP2(obj)
                        if obj:IsA("BasePart") and obj.Name == "HitBox" then
                            ESP:Add(obj, {
                                Name = "Generator",
                                Color = Color3.fromRGB(255, 0, 0)
                            })
                        end
                    end
                    for _, v in ipairs(gens:GetDescendants()) do
                        AddGenESP2(v)
                    end
                    gens.DescendantAdded:Connect(AddGenESP2)
                end
            end
            ESP.GeneratorESP = true
        else
            ESP.GeneratorESP = false
        end
	end,
})
---------------------------
-- Fiture Generator Chams + Percent
----------------------------
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GeneratorESP = {}
local enabled = false
local conns = {}
local reg = {}          -- [Model] = { part = BasePart, lastPct = number }
local billboards = {}   -- [Model] = BillboardGui
local highlights = {}   -- [Model] = Highlight
local TEXT_RED   = Color3.fromRGB(255, 0, 0)
local HL_YELLOW  = Color3.fromRGB(255, 255, 0)
local HL_GREEN   = Color3.fromRGB(0, 255, 0)
local updateInterval = 0.5
local lastUpdateTime = 0
local function alive(i) return i and i.Parent ~= nil end
local function validPart(p) return p and alive(p) and p:IsA("BasePart") end
local function firstBasePart(inst)
	if not alive(inst) then return nil end
	if inst:IsA("BasePart") then return inst end
	if inst:IsA("Model") then
		if inst.PrimaryPart and validPart(inst.PrimaryPart) then return inst.PrimaryPart end
		local p = inst:FindFirstChildWhichIsA("BasePart", true)
		if validPart(p) then return p end
	end
	return nil
end
local function makeBillboard()
	local g = Instance.new("BillboardGui")
	g.Name = "GEN_ESP"
	g.AlwaysOnTop = true
	g.Size = UDim2.new(0, 220, 0, 36)
	g.StudsOffset = Vector3.new(0, 3, 0)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 1, 0)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 14
	l.TextColor3 = TEXT_RED
	l.TextStrokeTransparency = 0
	l.TextStrokeColor3 = Color3.new(0, 0, 0)
	l.Parent = g
	return g
end
local function makeHighlight(adornee)
	local hl = Instance.new("Highlight")
	hl.Name = "GeneratorHighlight"
	hl.Adornee = adornee
	hl.FillColor = HL_YELLOW
	hl.OutlineColor = HL_YELLOW
	hl.FillTransparency = 0.4
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	return hl
end
local function getGenerators()
	local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("Map1")
	if not map then return {} end
	local results = {}
	local function recurse(folder)
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("Model") and child.Name:lower():find("generator") then
				table.insert(results, child)
			elseif child:IsA("Folder") or child:IsA("Model") then
				recurse(child)
			end
		end
	end
	recurse(map)
	return results
end
local function genLabelText(model)
	local pct = 0
	if model.GetAttribute then
		pct = tonumber(model:GetAttribute("RepairProgress")) or 0
	end
	if pct >= 0 and pct <= 1.001 then pct = pct * 100 end
	pct = math.clamp(pct, 0, 100)
	local repairers = 0
	if model.GetAttribute then
		repairers = tonumber(model:GetAttribute("PlayersRepairingCount")) or 0
	end
	local paused = false
	if model.GetAttribute then
		paused = (model:GetAttribute("ProgressPaused") == true)
	end
	local parts = {("Gen %d%%"):format(math.floor(pct + 0.5))}
	if repairers > 0 then table.insert(parts, ("(%dp)"):format(repairers)) end
	if paused then table.insert(parts, "⏸") end
	return table.concat(parts, " ")
end
local function ensure(model)
	if reg[model] then return end
	local rep = firstBasePart(model)
	if not validPart(rep) then return end
	reg[model] = { part = rep, lastPct = -1 }
	local bb = makeBillboard()
	bb.Adornee = rep
	bb.Parent = rep
	billboards[model] = bb
	local hl = makeHighlight(model)
	hl.Parent = model
	highlights[model] = hl
end
local function remove(model)
	pcall(function()
		local bb = billboards[model]
		if bb and bb.Parent then bb:Destroy() end
	end)
	billboards[model] = nil
	pcall(function()
		local hl = highlights[model]
		if hl and hl.Parent then hl:Destroy() end
	end)
	highlights[model] = nil
	reg[model] = nil
end
local function refresh()
	for m,_ in pairs(reg) do remove(m) end
	for _, gen in ipairs(getGenerators()) do ensure(gen) end
end
local function startLoops()
	if conns.heartbeat then return end
	conns.heartbeat = RunService.Heartbeat:Connect(function(dt)
		if not enabled then return end
		pcall(function()
			lastUpdateTime = lastUpdateTime + dt
			if lastUpdateTime < updateInterval then return end
			lastUpdateTime = 0
			for model, entry in pairs(reg) do
				if alive(model) and entry and validPart(entry.part) then
					if not (billboards[model] and billboards[model].Parent) then
						local bb = makeBillboard()
						bb.Adornee = entry.part
						bb.Parent = entry.part
						billboards[model] = bb
					end
					if not (highlights[model] and highlights[model].Parent) then
						local hl = makeHighlight(model)
						hl.Parent = model
						highlights[model] = hl
					end
					local currentPct = model:GetAttribute("RepairProgress") or 0
					if currentPct ~= entry.lastPct then
						entry.lastPct = currentPct
						local bb = billboards[model]
						local lbl = bb and bb:FindFirstChildWhichIsA("TextLabel")
						if lbl then
							lbl.Text = genLabelText(model)
							lbl.TextColor3 = TEXT_RED
						end
						local hl = highlights[model]
						if hl then
							local color = (currentPct >= 1) and HL_GREEN or HL_YELLOW
							hl.FillColor = color
							hl.OutlineColor = color
						end
					end
				else
					remove(model)
				end
			end
		end)
	end)
	conns.descAdded = Workspace.DescendantAdded:Connect(function(obj)
		if not enabled then return end
		pcall(function()
			if obj:IsA("Model") and obj.Name:lower():find("generator") then
				ensure(obj)
			end
		end)
	end)
	conns.descRemoving = Workspace.DescendantRemoving:Connect(function(obj)
		pcall(function()
			if obj:IsA("Model") then
				remove(obj)
			end
		end)
	end)
end
local function stopLoops()
	for _, c in pairs(conns) do
		if c then c:Disconnect() end
	end
	conns = {}
	for m,_ in pairs(reg) do remove(m) end
	lastUpdateTime = 0
end
function GeneratorESP:SetEnabled(state: boolean)
	enabled = state and true or false
	if enabled then
		refresh()
		startLoops()
	else
		stopLoops()
	end
end
-