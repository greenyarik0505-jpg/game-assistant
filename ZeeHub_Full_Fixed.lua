-- 1. Скрипт для полных исправлений и запуска оригинального скрипта
local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/honukagaming/zeehub/main/ea")
end)

if success and result and #result > 100 then
    -- Выполняем полный оригинальный код ZeeHub без обрезки и с сохранением всех функций
    loadstring(result)()
else
    -- Резервный запуск полного модуля ZeeHub
    loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
end
