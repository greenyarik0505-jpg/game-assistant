import sys
import time
import os
import psutil
import ctypes
from ctypes import wintypes
import threading
import customtkinter as ctk

# Set initial appearance mode
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class DWM_TIMING_INFO(ctypes.Structure):
    _fields_ = [
        ("cbSize", wintypes.UINT),
        ("rateRefresh", wintypes.UINT64 * 2),
        ("qpcRefreshPeriod", wintypes.UINT64),
        ("rateCompose", wintypes.UINT64 * 2),
        ("qpcVBlank", wintypes.UINT64),
        ("cRefresh", wintypes.UINT64),
        ("cDXActive", wintypes.UINT),
        ("cDXVideoCreated", wintypes.UINT),
        ("cCommandSignaled", wintypes.UINT),
        ("qpcCommandFrameStart", wintypes.UINT64),
        ("cFramesReceived", wintypes.UINT64),
        ("cCursorsSkipped", wintypes.UINT),
        ("cFramesShown", wintypes.UINT),
        ("cPresentRefresh", wintypes.UINT64),
        ("cActiveRefreshes", wintypes.UINT64),
        ("cBuffersEmpty", wintypes.UINT64)
    ]

# Translations dictionary
TRANSLATIONS = {
    "UA": {
        "title": "🎮 Game Assistant",
        "topmost": "Поверх всіх вікон",
        "mini_mode": "🔍 Міні-режим",
        "fps_label": "⚡ FPS Екрана / Дисплея",
        "ram_label": "💾 RAM Використання",
        "clean_ram": "🧹 Очистити RAM",
        "timer_title": "⏱️ Ігровий Таймер",
        "start_pause": "Старт / Пауза",
        "reset": "Скинути",
        "notes_title": "📝 Швидкі Нотатки",
        "theme": "Тема",
        "lang": "Мова",
        "full_mode": "⚙️ Повне",
        "clean": "🧹 Очистити"
    },
    "EN": {
        "title": "🎮 Game Assistant",
        "topmost": "Always on Top",
        "mini_mode": "🔍 Mini Mode",
        "fps_label": "⚡ Display FPS",
        "ram_label": "💾 RAM Usage",
        "clean_ram": "🧹 Clean RAM",
        "timer_title": "⏱️ Game Timer",
        "start_pause": "Start / Pause",
        "reset": "Reset",
        "notes_title": "📝 Quick Notes",
        "theme": "Theme",
        "lang": "Language",
        "full_mode": "⚙️ Full",
        "clean": "🧹 Clean"
    },
    "RU": {
        "title": "🎮 Game Assistant",
        "topmost": "Поверх всех окон",
        "mini_mode": "🔍 Мини-режим",
        "fps_label": "⚡ FPS Экрана / Дисплея",
        "ram_label": "💾 Использование RAM",
        "clean_ram": "🧹 Очистить RAM",
        "timer_title": "⏱️ Игровой Таймер",
        "start_pause": "Старт / Пауза",
        "reset": "Сброс",
        "notes_title": "📝 Быстрые Заметки",
        "theme": "Тема",
        "lang": "Язык",
        "full_mode": "⚙️ Полный",
        "clean": "🧹 Очистить"
    }
}

class GameAssistantApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("🎮 Game Assistant")
        self.normal_geometry = "460x650"
        self.compact_geometry = "250x190"
        
        self.geometry(self.normal_geometry)
        self.resizable(False, False)
        
        # Settings state
        self.current_lang = "UA"
        self.current_theme = "Dark"
        
        self.is_compact = False
        self.timer_running = False
        self.timer_seconds = 0
        
        self.fps_value = 0
        self.fps_lock = threading.Lock()
        self.running = True

        self.setup_ui()
        
        # Always on top setup by default
        self.attributes("-topmost", True)

        # Start DWM System FPS Monitor Thread
        self.monitor_thread = threading.Thread(target=self._measure_dwm_fps, daemon=True)
        self.monitor_thread.start()

        self.update_stats()
        self.update_timer()

    def _measure_dwm_fps(self):
        """ Native Windows DWM VSync & Frame Rate Monitor """
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

    def setup_ui(self):
        # 1. Main / Normal View Container
        self.normal_view = ctk.CTkFrame(self, fg_color="transparent")
        self.normal_view.pack(fill="both", expand=True)

        # Header
        self.header_frame = ctk.CTkFrame(self.normal_view, corner_radius=10)
        self.header_frame.pack(fill="x", padx=15, pady=(10, 5))

        self.title_label = ctk.CTkLabel(
            self.header_frame, 
            text=TRANSLATIONS[self.current_lang]["title"], 
            font=ctk.CTkFont(size=20, weight="bold")
        )
        self.title_label.pack(pady=6)

        # Controls & Settings Row 1 (Topmost & Mini Mode)
        self.ctrl_row1 = ctk.CTkFrame(self.header_frame, fg_color="transparent")
        self.ctrl_row1.pack(pady=2)

        self.topmost_var = ctk.BooleanVar(value=True)
        self.topmost_switch = ctk.CTkSwitch(
            self.ctrl_row1, 
            text=TRANSLATIONS[self.current_lang]["topmost"], 
            variable=self.topmost_var, 
            command=self.toggle_topmost
        )
        self.topmost_switch.pack(side="left", padx=10)

        self.compact_btn = ctk.CTkButton(
            self.ctrl_row1,
            text=TRANSLATIONS[self.current_lang]["mini_mode"],
            width=100,
            fg_color="#3a7ebf",
            command=self.enable_compact_mode
        )
        self.compact_btn.pack(side="left", padx=5)

        # Controls & Settings Row 2 (Language & Theme selectors)
        self.ctrl_row2 = ctk.CTkFrame(self.header_frame, fg_color="transparent")
        self.ctrl_row2.pack(pady=(2, 6))

        self.lang_menu = ctk.CTkOptionMenu(
            self.ctrl_row2,
            values=["UA", "EN", "RU"],
            width=70,
            command=self.change_language
        )
        self.lang_menu.set(self.current_lang)
        self.lang_menu.pack(side="left", padx=5)

        self.theme_menu = ctk.CTkOptionMenu(
            self.ctrl_row2,
            values=["Dark", "Light", "System"],
            width=85,
            command=self.change_theme
        )
        self.theme_menu.set(self.current_theme)
        self.theme_menu.pack(side="left", padx=5)

        # Dashboard / Stats Frame
        self.stats_frame = ctk.CTkFrame(self.normal_view, corner_radius=10)
        self.stats_frame.pack(fill="x", padx=15, pady=5)

        self.fps_label = ctk.CTkLabel(
            self.stats_frame, 
            text=f"{TRANSLATIONS[self.current_lang]['fps_label']}: --", 
            font=ctk.CTkFont(size=16, weight="bold"),
            text_color="#00FFCC"
        )
        self.fps_label.pack(pady=4)

        self.ram_label = ctk.CTkLabel(
            self.stats_frame, 
            text=f"{TRANSLATIONS[self.current_lang]['ram_label']}: --%", 
            font=ctk.CTkFont(size=14)
        )
        self.ram_label.pack(pady=2)

        self.ram_bar = ctk.CTkProgressBar(self.stats_frame, width=380)
        self.ram_bar.pack(pady=5)
        self.ram_bar.set(0)

        self.clean_ram_btn = ctk.CTkButton(
            self.stats_frame, 
            text=TRANSLATIONS[self.current_lang]["clean_ram"], 
            command=self.clean_ram,
            fg_color="#1f538d",
            hover_color="#14375e"
        )
        self.clean_ram_btn.pack(pady=8)

        # Timer Frame
        self.timer_frame = ctk.CTkFrame(self.normal_view, corner_radius=10)
        self.timer_frame.pack(fill="x", padx=15, pady=5)

        self.timer_title = ctk.CTkLabel(
            self.timer_frame, 
            text=TRANSLATIONS[self.current_lang]["timer_title"], 
            font=ctk.CTkFont(size=15, weight="bold")
        )
        self.timer_title.pack(pady=3)

        self.timer_display = ctk.CTkLabel(
            self.timer_frame, 
            text="00:00:00", 
            font=ctk.CTkFont(size=22, weight="bold"),
            text_color="#FFCC00"
        )
        self.timer_display.pack(pady=3)

        self.timer_btn_frame = ctk.CTkFrame(self.timer_frame, fg_color="transparent")
        self.timer_btn_frame.pack(pady=6)

        self.start_timer_btn = ctk.CTkButton(
            self.timer_btn_frame, 
            text=TRANSLATIONS[self.current_lang]["start_pause"], 
            width=110, 
            command=self.toggle_timer
        )
        self.start_timer_btn.pack(side="left", padx=5)

        self.reset_timer_btn = ctk.CTkButton(
            self.timer_btn_frame, 
            text=TRANSLATIONS[self.current_lang]["reset"], 
            width=90, 
            fg_color="#a83232",
            hover_color="#7a2323",
            command=self.reset_timer
        )
        self.reset_timer_btn.pack(side="left", padx=5)

        # Quick Notes Frame
        self.notes_frame = ctk.CTkFrame(self.normal_view, corner_radius=10)
        self.notes_frame.pack(fill="both", expand=True, padx=15, pady=(5, 10))

        self.notes_title = ctk.CTkLabel(
            self.notes_frame, 
            text=TRANSLATIONS[self.current_lang]["notes_title"], 
            font=ctk.CTkFont(size=15, weight="bold")
        )
        self.notes_title.pack(pady=4)

        self.notes_textbox = ctk.CTkTextbox(self.notes_frame, wrap="word")
        self.notes_textbox.pack(fill="both", expand=True, padx=10, pady=(0, 10))

        # 2. Compact / Overlay Mini View Container
        self.compact_view = ctk.CTkFrame(self, fg_color="transparent")

        self.mini_title = ctk.CTkLabel(
            self.compact_view,
            text="🎮 Game Mini Overlay",
            font=ctk.CTkFont(size=13, weight="bold")
        )
        self.mini_title.pack(pady=(5, 2))

        self.mini_fps_label = ctk.CTkLabel(
            self.compact_view,
            text="⚡ FPS: --",
            font=ctk.CTkFont(size=14, weight="bold"),
            text_color="#00FFCC"
        )
        self.mini_fps_label.pack(pady=1)

        self.mini_ram_label = ctk.CTkLabel(
            self.compact_view,
            text="💾 RAM: --%",
            font=ctk.CTkFont(size=12)
        )
        self.mini_ram_label.pack(pady=1)

        self.mini_timer_label = ctk.CTkLabel(
            self.compact_view,
            text="⏱️ 00:00:00",
            font=ctk.CTkFont(size=14, weight="bold"),
            text_color="#FFCC00"
        )
        self.mini_timer_label.pack(pady=2)

        self.mini_btn_frame = ctk.CTkFrame(self.compact_view, fg_color="transparent")
        self.mini_btn_frame.pack(pady=4)

        self.mini_clean_btn = ctk.CTkButton(
            self.mini_btn_frame,
            text=TRANSLATIONS[self.current_lang]["clean"],
            width=80,
            height=24,
            font=ctk.CTkFont(size=11),
            command=self.clean_ram
        )
        self.mini_clean_btn.pack(side="left", padx=3)

        self.expand_btn = ctk.CTkButton(
            self.mini_btn_frame,
            text=TRANSLATIONS[self.current_lang]["full_mode"],
            width=70,
            height=24,
            font=ctk.CTkFont(size=11),
            fg_color="#2b7bba",
            command=self.disable_compact_mode
        )
        self.expand_btn.pack(side="left", padx=3)

        # Load notes content
        self.notes_file = "game_notes.txt"
        if os.path.exists(self.notes_file):
            try:
                with open(self.notes_file, "r", encoding="utf-8") as f:
                    self.notes_textbox.insert("1.0", f.read())
            except Exception:
                pass
        self.notes_textbox.bind("<KeyRelease>", self.save_notes)

    def change_language(self, new_lang):
        self.current_lang = new_lang
        t = TRANSLATIONS[new_lang]
        
        self.title_label.configure(text=t["title"])
        self.topmost_switch.configure(text=t["topmost"])
        self.compact_btn.configure(text=t["mini_mode"])
        
        self.clean_ram_btn.configure(text=t["clean_ram"])
        self.timer_title.configure(text=t["timer_title"])
        self.start_timer_btn.configure(text=t["start_pause"])
        self.reset_timer_btn.configure(text=t["reset"])
        self.notes_title.configure(text=t["notes_title"])
        
        self.mini_clean_btn.configure(text=t["clean"])
        self.expand_btn.configure(text=t["full_mode"])
        
        self.update_stats()

    def change_theme(self, new_theme):
        self.current_theme = new_theme
        ctk.set_appearance_mode(new_theme)

    def enable_compact_mode(self):
        self.is_compact = True
        self.normal_view.pack_forget()
        self.compact_view.pack(fill="both", expand=True)
        self.geometry(self.compact_geometry)
        self.attributes("-topmost", True)
        self.topmost_var.set(True)

    def disable_compact_mode(self):
        self.is_compact = False
        self.compact_view.pack_forget()
        self.normal_view.pack(fill="both", expand=True)
        self.geometry(self.normal_geometry)
        self.attributes("-topmost", self.topmost_var.get())

    def toggle_topmost(self):
        if not self.is_compact:
            self.attributes("-topmost", self.topmost_var.get())

    def update_stats(self):
        with self.fps_lock:
            current_fps = self.fps_value

        t = TRANSLATIONS[self.current_lang]
        fps_text = f"{t['fps_label']}: {current_fps}"
        self.fps_label.configure(text=fps_text)
        self.mini_fps_label.configure(text=f"⚡ FPS: {current_fps}")

        ram_perm = psutil.virtual_memory().percent
        self.ram_label.configure(text=f"{t['ram_label']}: {ram_perm}%")
        self.ram_bar.set(ram_perm / 100.0)
        self.mini_ram_label.configure(text=f"💾 RAM: {ram_perm}%")

        self.after(200, self.update_stats)

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

    def toggle_timer(self):
        self.timer_running = not self.timer_running

    def reset_timer(self):
        self.timer_running = False
        self.timer_seconds = 0
        self.timer_display.configure(text="00:00:00")
        self.mini_timer_label.configure(text="⏱️ 00:00:00")

    def update_timer(self):
        if self.timer_running:
            self.timer_seconds += 1
            hours, remainder = divmod(self.timer_seconds, 3600)
            minutes, seconds = divmod(remainder, 60)
            time_str = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
            self.timer_display.configure(text=time_str)
            self.mini_timer_label.configure(text=f"⏱️ {time_str}")
        self.after(1000, self.update_timer)

    def save_notes(self, event=None):
        try:
            content = self.notes_textbox.get("1.0", "end-1c")
            with open(self.notes_file, "w", encoding="utf-8") as f:
                f.write(content)
        except Exception:
            pass

    def on_closing(self):
        self.running = False
        self.destroy()

if __name__ == "__main__":
    app = GameAssistantApp()
    app.protocol("WM_DELETE_WINDOW", app.on_closing)
    app.mainloop()
