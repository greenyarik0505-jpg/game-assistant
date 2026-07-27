-- Скрипт для полного закрытия и удаления ZeeHub GUI из игры
pcall(function()
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    -- Отключаем глобальные переменные циклов
    getgenv().ZeeHubSharkESP = false
    getgenv().ZeeHubAutoShoot = false
    getgenv().TrinityAutoWeaponFarm = false
    getgenv().TrinitySharkESP = false

    -- Удаляем интерфейс из CoreGui
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui.Name:find("Obsidian") or gui.Name:find("ZeeHub") or gui.Name:find("Rayfield") or gui.Name:find("ScreenGui") then
            pcall(function() gui:Destroy() end)
        end
    end

    -- Удаляем интерфейс из PlayerGui
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui.Name:find("Obsidian") or gui.Name:find("ZeeHub") or gui.Name:find("Rayfield") then
                pcall(function() gui:Destroy() end)
            end
        end
    end

    -- Удаляем подсветки ESP из игры
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:find("Highlight") or obj.Name:find("ESP") then
            pcall(function() obj:Destroy() end)
        end
    end
end)
