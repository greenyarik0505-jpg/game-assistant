# 🎮 Game Assistant (Ігровий Помічник)

![Version](https://img.shields.io/github/v/release/greenyarik0505-jpg/game-assistant?color=06b6d4&label=Latest%20Release)
![License](https://img.shields.io/github/license/greenyarik0505-jpg/game-assistant?color=green)
![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-blue)
![UI](https://img.shields.io/badge/design-Glassmorphic%20Vector-a855f7)

Сучасний преміальний оверлей-додаток для геймерів з багатим функціоналом, скляним Glassmorphic дизайном та векторними іконками.

---

## 🚀 Основні можливості (Features)

* ⚡ **System FPS Counter** — точне вимірювання частоти кадрів дисплея/системи за допомогою **Windows DWM API**.
* 💾 **RAM Cleaner** — моніторинг та швидке очищення оперативної пам'яті в один клік (`Очистити RAM`) з візуальним сповіщенням (Toast).
* ⏱️ **Game Timer** — зручний ігровий таймер сесії з можливістю запуску, паузи та скидання.
* 📝 **Quick Notes** — блокнот прямо у додатку з автоматичним збереженням нотаток.
* 📌 **Always-on-Top & Mini Overlay** — перемикач для утримання вікна поверх усіх ігор та кнопка швидкого згортання у компактне плаваюче міні-віконце.
* 🌐 **Багатомовність** — повна підтримка **UA** (Українська), **EN** (English) та **RU** (Русский).
* 🎨 **Темна/Світла Тема** — підлаштування під ваші вподобання.

---

## 🛡️ Як запустити при блокуванні SmartApp Control / Windows Defender

Оскільки файл не має купленого платного цифрового підпису Code Signing Certificate (який коштує $300+/рік), **SmartApp Control (Интеллектуальное управление приложениями)** Windows 11 блокує завантажені незареєстровані exe-файли з інтернету.

### 💡 Варіанти розблокування:

#### Спосіб 1. Розблокувати файл у властивостях (Рекомендовано):
1. Клацніть правою кнопкою миші на завантажений файл `game_assistant.exe` -> **Свойства (Properties)**.
2. Внизу на вкладці **Общие (General)** поставте прапорець **Разблокировать (Unblock)**.
3. Натисніть **Применить (Apply)** та **ОК**.

#### Спосіб 2. Розблокування через PowerShell:
Відкрийте PowerShell та виконайте команду:
```powershell
Unblock-File -Path "$env:USERPROFILE\Downloads\game_assistant.exe"
```

#### Спосіб 3. Запуск через Python (100% без попереджень):
```bash
git clone https://github.com/greenyarik0505-jpg/game-assistant.git
cd game-assistant
pip install pywebview psutil
python game_assistant.py
```

---

## 📥 Завантаження (Releases)

👉 **[Завантажити Game Assistant v1.0.0 (Release)](https://github.com/greenyarik0505-jpg/game-assistant/releases/tag/v1.0.0)**
