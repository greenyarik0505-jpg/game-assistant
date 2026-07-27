-- Полный скрипт экстренной очистки (Full Uninject / Destroyer)
pcall(function()
    local Players = game:GetService("Players")
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = Players.LocalPlayer

    -- 1. Сброс всех глобальных генераций и флагов
    if getgenv then
        for k, v in pairs(getgenv()) do
            if type(k) == "string" and (k:find("Zee") or k:find("Trinity") or k:find("Auto") or k:find("ESP") or k:find("Obsidian")) then
                getgenv()[k] = false
            end
        end
    end

    -- 2. Принудительное удаление всех объектов интерфейса из CoreGui
    for _, item in ipairs(CoreGui:GetChildren()) do
        if item:IsA("ScreenGui") then
            item:Destroy()
        end
    end

    -- 3. Принудительное удаление из PlayerGui
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        for _, item in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
            if item:IsA("ScreenGui") and (item.Name:find("Obsidian") or item.Name:find("ZeeHub") or item.Name:find("Rayfield") or item.Name:find("Screen") or item.Name:find("Library")) then
                item:Destroy()
            end
        end
    end

    -- 4. Удаление подсветки (Highlights / Billboards)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") or obj:IsA("BillboardGui") then
            obj:Destroy()
        end
    end
end)
