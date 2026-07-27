-- Обход ошибки кика/выхода Junkie Key System (Bypass JD_SOF8)

pcall(function()
    -- 1. Подмена функций кика пользователя
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if LocalPlayer then
        local rawmeta = getrawmetatable(game)
        if rawmeta and setreadonly then
            setreadonly(rawmeta, false)
            local oldNamecall = rawmeta.__namecall
            rawmeta.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "Kick" or method == "kick" then
                    return nil
                end
                return oldNamecall(self, ...)
            end)
        end
        LocalPlayer.Kick = function() return nil end
    end

    -- 2. Удаление GUI бана/кика Junkie
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name:find("Junkie") or gui.Name:find("JD_SOF8") or gui.Name:find("ScreenGui") then
            gui:Destroy()
        end
    end
end)

-- 3. Запуск основного скрипта ZeeHub
loadstring(game:HttpGet("https://raw.githubusercontent.com/greenyarik0505-jpg/sharkbite2-hub/main/ZeeHub_Original_Full.lua"))()
