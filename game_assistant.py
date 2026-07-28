import os
import sys
import time
import psutil
import ctypes
import threading
import webview

# Definitions for Windows DWM API
c_ulonglong = ctypes.c_ulonglong
c_uint32 = ctypes.c_uint32

class DWM_TIMING_INFO(ctypes.Structure):
    _fields_ = [
        ("cbSize", c_uint32),
        ("rateRefresh", c_ulonglong * 2),
        ("qpcRefreshPeriod", c_ulonglong),
        ("rateCompose", c_ulonglong * 2),
        ("qpcVBlank", c_ulonglong),
        ("cRefresh", c_ulonglong),
        ("cDXActive", c_uint32),
        ("cDXVideoCreated", c_uint32),
        ("cCommandSignaled", c_uint32),
        ("qpcCommandFrameStart", c_ulonglong),
        ("cFramesReceived", c_ulonglong),
        ("cCursorsSkipped", c_uint32),
        ("cFramesShown", c_uint32),
        ("cPresentRefresh", c_ulonglong),
        ("cActiveRefreshes", c_ulonglong),
        ("cBuffersEmpty", c_ulonglong)
    ]

HTML_UI = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Game Assistant</title>
    <!-- Lucide Icons & Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        :root {
            --bg-gradient: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%);
            --card-bg: rgba(30, 41, 59, 0.7);
            --card-border: rgba(255, 255, 255, 0.08);
            --text-main: #f8fafc;
            --text-muted: #94a3b8;
            --accent-cyan: #06b6d4;
            --accent-purple: #a855f7;
            --accent-pink: #ec4899;
            --accent-amber: #f59e0b;
            --accent-emerald: #10b981;
            --button-bg: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
            --button-hover: linear-gradient(135deg, #4f46e5 0%, #4338ca 100%);
            --danger-bg: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        }

        body.light-theme {
            --bg-gradient: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
            --card-bg: rgba(255, 255, 255, 0.85);
            --card-border: rgba(0, 0, 0, 0.08);
            --text-main: #0f172a;
            --text-muted: #64748b;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Outfit', sans-serif;
            user-select: none;
        }

        body {
            background: var(--bg-gradient);
            color: var(--text-main);
            height: 100vh;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        /* Custom Title Bar Dragging Area */
        .title-bar {
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 16px;
            background: rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid var(--card-border);
            -webkit-app-region: drag;
        }

        .title-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 700;
            font-size: 15px;
            letter-spacing: 0.5px;
            background: linear-gradient(90deg, #38bdf8, #a855f7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .title-actions {
            display: flex;
            align-items: center;
            gap: 6px;
            -webkit-app-region: no-drag;
        }

        .icon-btn {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--card-border);
            color: var(--text-muted);
            width: 28px;
            height: 28px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .icon-btn:hover {
            background: rgba(255, 255, 255, 0.15);
            color: var(--text-main);
            transform: translateY(-1px);
        }

        /* App Main Content */
        .content {
            flex: 1;
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 14px;
            overflow-y: auto;
        }

        /* Glassmorphic Cards */
        .card {
            background: var(--card-bg);
            backdrop-filter: blur(16px);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            padding: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
            transition: all 0.3s ease;
        }

        .card:hover {
            border-color: rgba(255, 255, 255, 0.18);
        }

        /* Stats Section */
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .stat-card {
            display: flex;
            flex-direction: column;
            gap: 6px;
            position: relative;
            overflow: hidden;
        }

        .stat-header {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--text-muted);
            font-size: 13px;
            font-weight: 600;
        }

        .stat-value {
            font-size: 26px;
            font-weight: 800;
            letter-spacing: -0.5px;
        }

        .fps-value {
            color: var(--accent-cyan);
            text-shadow: 0 0 15px rgba(6, 182, 212, 0.4);
        }

        .ram-value {
            color: var(--accent-purple);
        }

        .progress-bar-bg {
            height: 6px;
            background: rgba(255, 255, 255, 0.08);
            border-radius: 10px;
            overflow: hidden;
            margin-top: 4px;
        }

        .progress-bar-fill {
            height: 100%;
            width: 0%;
            background: linear-gradient(90deg, #a855f7, #ec4899);
            border-radius: 10px;
            transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .action-btn {
            background: var(--button-bg);
            color: white;
            border: none;
            border-radius: 12px;
            padding: 10px 16px;
            font-weight: 600;
            font-size: 13px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }

        .action-btn:hover {
            background: var(--button-hover);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
        }

        .action-btn:active {
            transform: translateY(0);
        }

        .action-btn.danger {
            background: var(--danger-bg);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        }

        .action-btn.danger:hover {
            box-shadow: 0 6px 20px rgba(239, 68, 68, 0.4);
        }

        /* Timer Section */
        .timer-card {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .timer-info {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .timer-display {
            font-size: 28px;
            font-weight: 800;
            color: var(--accent-amber);
            font-mono: monospace;
            letter-spacing: 1px;
            text-shadow: 0 0 15px rgba(245, 158, 11, 0.3);
        }

        .timer-controls {
            display: flex;
            gap: 8px;
        }

        /* Notes Section */
        .notes-card {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 10px;
            min-height: 140px;
        }

        .card-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            font-weight: 700;
            color: var(--text-muted);

        }

        textarea {
            width: 100%;
            flex: 1;
            background: rgba(0, 0, 0, 0.15);
            border: 1px solid var(--card-border);
            border-radius: 12px;
            padding: 12px;
            color: var(--text-main);
            font-size: 13px;
            resize: none;
            outline: none;
            transition: all 0.2s ease;
        }

        textarea:focus {
            border-color: rgba(99, 102, 241, 0.5);
            background: rgba(0, 0, 0, 0.25);
        }

        /* Mini Overlay View */
        .mini-view {
            display: none;
            padding: 12px;
            height: 100%;
            flex-direction: column;
            justify-content: space-between;
        }

        body.compact-mode .normal-view {
            display: none;
        }

        body.compact-mode .mini-view {
            display: flex;
        }

        .mini-stats {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .mini-badge {
            display: flex;
            align-items: center;
            gap: 4px;
            font-size: 14px;
            font-weight: 800;
        }

        /* Select controls */
        select {
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid var(--card-border);
            color: var(--text-main);
            padding: 6px 10px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            outline: none;
            cursor: pointer;
        }
    </style>
</head>
<body>

    <!-- Title Drag Bar -->
    <div class="title-bar">
        <div class="title-title">
            <i data-lucide="gamepad-2"></i> GAME ASSISTANT
        </div>
        <div class="title-actions">
            <select id="langSelect" onchange="changeLang(this.value)">
                <option value="UA">UA</option>
                <option value="EN">EN</option>
                <option value="RU">RU</option>
            </select>
            <button class="icon-btn" onclick="toggleTheme()" title="Toggle Theme">
                <i data-lucide="sun-moon" id="themeIcon"></i>
            </button>
            <button class="icon-btn" onclick="toggleCompactMode()" title="Mini Overlay Mode">
                <i data-lucide="shrink" id="modeIcon"></i>
            </button>
            <button class="icon-btn" onclick="pywebview.api.close_app()" title="Close App">
                <i data-lucide="x"></i>
            </button>
        </div>
    </div>

    <!-- Main Full View -->
    <div class="content normal-view">
        
        <!-- Stats Grid -->
        <div class="stats-grid">
            <div class="card stat-card">
                <div class="stat-header">
                    <i data-lucide="zap" style="color: var(--accent-cyan);"></i> <span data-i18n="fps_label">System FPS</span>
                </div>
                <div class="stat-value fps-value" id="fpsVal">--</div>
            </div>

            <div class="card stat-card">
                <div class="stat-header">
                    <i data-lucide="cpu" style="color: var(--accent-purple);"></i> <span data-i18n="ram_label">RAM Usage</span>
                </div>
                <div class="stat-value ram-value" id="ramVal">--%</div>
                <div class="progress-bar-bg">
                    <div class="progress-bar-fill" id="ramBar"></div>
                </div>
            </div>
        </div>

        <!-- Clean RAM Button Card -->
        <button class="action-btn" onclick="cleanRam()">
            <i data-lucide="sparkles"></i> <span data-i18n="clean_ram">Clean RAM Memory</span>
        </button>

        <!-- Timer Card -->
        <div class="card timer-card">
            <div class="timer-info">
                <div class="card-title">
                    <i data-lucide="timer" style="color: var(--accent-amber);"></i> <span data-i18n="timer_title">Game Timer</span>
                </div>
                <div class="timer-display" id="timerVal">00:00:00</div>
            </div>
            <div class="timer-controls">
                <button class="action-btn" onclick="toggleTimer()">
                    <i data-lucide="play" id="playIcon"></i>
                </button>
                <button class="action-btn danger" onclick="resetTimer()">
                    <i data-lucide="rotate-ccw"></i>
                </button>
            </div>
        </div>

        <!-- Notes Card -->
        <div class="card notes-card">
            <div class="card-title">
                <i data-lucide="file-text" style="color: var(--accent-pink);"></i> <span data-i18n="notes_title">Quick Notes</span>
            </div>
            <textarea id="notesArea" placeholder="Type quick game notes, coords, strategies..." oninput="saveNotes()"></textarea>
        </div>

    </div>

    <!-- Mini Overlay View -->
    <div class="mini-view">
        <div class="mini-stats">
            <div class="mini-badge" style="color: var(--accent-cyan);">
                <i data-lucide="zap" size="16"></i> <span id="miniFpsVal">--</span>
            </div>
            <div class="mini-badge" style="color: var(--accent-purple);">
                <i data-lucide="cpu" size="16"></i> <span id="miniRamVal">--%</span>
            </div>
            <div class="mini-badge" style="color: var(--accent-amber);">
                <i data-lucide="timer" size="16"></i> <span id="miniTimerVal">00:00:00</span>
            </div>
        </div>

        <div style="display: flex; gap: 8px;">
            <button class="action-btn" style="flex: 1; padding: 6px; font-size: 11px;" onclick="cleanRam()">
                <i data-lucide="sparkles" size="14"></i> Clean
            </button>
            <button class="action-btn" style="flex: 1; padding: 6px; font-size: 11px; background: rgba(255,255,255,0.1);" onclick="toggleCompactMode()">
                <i data-lucide="expand" size="14"></i> Expand
            </button>
        </div>
    </div>

    <script>
        lucide.createIcons();

        const dict = {
            UA: {
                fps_label: "⚡ FPS Дисплея",
                ram_label: "💾 Використання RAM",
                clean_ram: "🧹 Очистити RAM Пам'ять",
                timer_title: "⏱️ Ігровий Таймер",
                notes_title: "📝 Швидкі Нотатки"
            },
            EN: {
                fps_label: "⚡ Display FPS",
                ram_label: "💾 RAM Usage",
                clean_ram: "🧹 Clean RAM Memory",
                timer_title: "⏱️ Game Timer",
                notes_title: "📝 Quick Notes"
            },
            RU: {
                fps_label: "⚡ FPS Дисплея",
                ram_label: "💾 Использование RAM",
                clean_ram: "🧹 Очистить Память RAM",
                timer_title: "⏱️ Игровой Таймер",
                notes_title: "📝 Быстрые Заметки"
            }
        };

        let currentLang = "UA";
        let isTimerRunning = false;
        let timerSeconds = 0;
        let isCompact = false;

        function changeLang(lang) {
            currentLang = lang;
            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.getAttribute('data-i18n');
                if (dict[lang][key]) {
                    el.innerText = dict[lang][key];
                }
            });
        }

        function toggleTheme() {
            document.body.classList.toggle('light-theme');
        }

        function toggleCompactMode() {
            isCompact = !isCompact;
            document.body.classList.toggle('compact-mode', isCompact);
            pywebview.api.resize_window(isCompact);
        }

        function cleanRam() {
            pywebview.api.clean_ram();
        }

        function toggleTimer() {
            isTimerRunning = !isTimerRunning;
            const playIcon = document.getElementById('playIcon');
            playIcon.setAttribute('data-lucide', isTimerRunning ? 'pause' : 'play');
            lucide.createIcons();
        }

        function resetTimer() {
            isTimerRunning = false;
            timerSeconds = 0;
            updateTimerDisplay();
            const playIcon = document.getElementById('playIcon');
            playIcon.setAttribute('data-lucide', 'play');
            lucide.createIcons();
        }

        function updateTimerDisplay() {
            const h = String(Math.floor(timerSeconds / 3600)).padStart(2, '0');
            const m = String(Math.floor((timerSeconds % 3600) / 60)).padStart(2, '0');
            const s = String(timerSeconds % 60).padStart(2, '0');
            const str = `${h}:${m}:${s}`;
            document.getElementById('timerVal').innerText = str;
            document.getElementById('miniTimerVal').innerText = str;
        }

        setInterval(() => {
            if (isTimerRunning) {
                timerSeconds++;
                updateTimerDisplay();
            }
        }, 1000);

        function updateStats(fps, ram) {
            document.getElementById('fpsVal').innerText = fps;
            document.getElementById('miniFpsVal').innerText = fps;

            document.getElementById('ramVal').innerText = ram + '%';
            document.getElementById('miniRamVal').innerText = ram + '%';
            document.getElementById('ramBar').style.width = ram + '%';
        }

        function saveNotes() {
            const txt = document.getElementById('notesArea').value;
            pywebview.api.save_notes(txt);
        }

        // Init notes from python
        window.addEventListener('pywebviewready', () => {
            pywebview.api.load_notes().then(notes => {
                if (notes) document.getElementById('notesArea').value = notes;
            });
        });
    </script>
</body>
</html>
"""

class Api:
    def __init__(self, app_instance):
        self.app = app_instance

    def clean_ram(self):
        self.app.clean_ram()

    def resize_window(self, compact):
        if compact:
            self.app.window.resize(260, 110)
        else:
            self.app.window.resize(440, 620)

    def save_notes(self, text):
        try:
            with open("game_notes.txt", "w", encoding="utf-8") as f:
                f.write(text)
        except Exception:
            pass

    def load_notes(self):
        if os.path.exists("game_notes.txt"):
            try:
                with open("game_notes.txt", "r", encoding="utf-8") as f:
                    return f.read()
            except Exception:
                pass
        return ""

    def close_app(self):
        self.app.running = False
        self.app.window.destroy()

class GameAssistantApp:
    def __init__(self):
        self.fps_value = 0
        self.fps_lock = threading.Lock()
        self.running = True

        self.api = Api(self)
        self.window = webview.create_window(
            title="Game Assistant",
            html=HTML_UI,
            js_api=self.api,
            width=440,
            height=620,
            resizable=False,
            frameless=True,
            on_top=True
        )

        threading.Thread(target=self._measure_dwm_fps, daemon=True).start()
        threading.Thread(target=self._push_stats_loop, daemon=True).start()

    def _measure_dwm_fps(self):
        dwmapi = ctypes.windll.dwmapi
        timing = DWM_TIMING_INFO()
        timing.cbSize = ctypes.sizeof(DWM_TIMING_INFO)

        last_c_refresh = 0
        last_time = time.time()

        while self.running:
            try:
                res = dwmapi.DwmGetCompositionTimingInfo(0, ctypes.byref(timing))
                if res == 0:
                    current_refresh = timing.cRefresh
                    now = time.time()
                    elapsed = now - last_time

                    if elapsed >= 0.5:
                        if last_c_refresh > 0:
                            diff = current_refresh - last_c_refresh
                            calc_fps = int(diff / elapsed)
                            with self.fps_lock:
                                self.fps_value = calc_fps
                        last_c_refresh = current_refresh
                        last_time = now
                else:
                    user32 = ctypes.windll.user32
                    hdc = user32.GetDC(0)
                    gdi32 = ctypes.windll.gdi32
                    refresh_rate = gdi32.GetDeviceCaps(hdc, 116)
                    user32.ReleaseDC(0, hdc)
                    with self.fps_lock:
                        self.fps_value = refresh_rate if refresh_rate > 0 else 60
            except Exception:
                pass
            time.sleep(0.1)

    def _push_stats_loop(self):
        time.sleep(1.0)
        while self.running:
            try:
                with self.fps_lock:
                    fps = self.fps_value
                ram = psutil.virtual_memory().percent
                self.window.evaluate_js(f"updateStats({fps}, {ram});")
            except Exception:
                pass
            time.sleep(0.25)

    def clean_ram(self):
        try:
            ctypes.windll.psapi.EmptyWorkingSet(ctypes.windll.kernel32.GetCurrentProcess())
            current_pid = os.getpid()
            for proc in psutil.process_iter(['pid']):
                try:
                    if proc.info['pid'] != current_pid:
                        handle = ctypes.windll.kernel32.OpenProcess(0x1F0FFF, False, proc.info['pid'])
                        if handle:
                            ctypes.windll.psapi.EmptyWorkingSet(handle)
                            ctypes.windll.kernel32.CloseHandle(handle)
                except Exception:
                    continue
        except Exception as e:
            print("RAM Clean Error:", e)

    def run(self):
        webview.start()

if __name__ == "__main__":
    app = GameAssistantApp()
    app.run()
