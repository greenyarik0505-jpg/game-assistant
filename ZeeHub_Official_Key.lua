-- =========================================================================
-- ZeeHub Script with Official Key Support (Auto-Key: yarik0505)
-- =========================================================================

getgenv().SCRIPT_KEY = "ZeeHub-ef4cdc22-a239-4b69-a09e-f568f6fa5e6e"

-- Загрузка официального модуля ZeeHub
local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/greenyarik0505-jpg/sharkbite2-hub/main/ZeeHub_Original_Full.lua"))()
end)

if not success then
    warn("Failed to load ZeeHub:", err)
end
