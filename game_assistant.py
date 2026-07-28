import sys
import time
import os
import psutil
import ctypes
import customtkinter as ctk
from datetime import timedelta

# Set appearance mode and theme
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class GameAssistantApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("🎮 Game Assistant")
        self.normal_geometry = "450x620"
        self.compact_geometry = "240x180"
        
        self.geometry(self.normal_geometry)
        self.resizable(False, False)
        
        # State variables
        self.is_compact = False
        self.timer_running = False
        self.timer_seconds = 0
        self.last_frame_time = time.time()
        self.frame_count = 0
        self.fps_value = 0

        self.setup_ui()
        
        # Always on top setup by default
        self.attributes("-topmost", True)
        
        self.update_stats()
        self.update_timer()

    def setup_ui(self):
        # 1. Main / Normal View Container
        self.normal_view = ctk.CTkFrame(self, fg_color="transparent")
        self.normal_view.pack(fill="both", expand=True)

        # Header
        self.header_frame = ctk.CTkFrame(self.normal_view, corner_radius=10)
        self.header_frame.pack(fill="x", padx=15, pady=(10, 5))

        self.title_label = ctk.CTkLabel(
            self.header_frame, 
            text="🎮 Game Assistant", 
            font=ctk.CTkFont(size=20, weight="bold")
        )
        self.title_label.pack(pady=8)

        # Switches Frame
        self.switches_frame = ctk.CTkFrame(self.header_frame, fg_color="transparent")
        self.switches_frame.pack(pady=(0, 8))

        self.topmost_var = ctk.BooleanVar(value=True)
        self.topmost_switch = ctk.CTkSwitch(
            self.switches_frame, 
            text="Поверх всіх вікон", 
            variable=self.topmost_var, 
            command=self.toggle_topmost
        )
        self.topmost_switch.pack(side="left", padx=10)

        self.compact_btn = ctk.CTkButton(
            self.switches_frame,
            text="🔍 Міні-режим",
            width=100,
            fg_color="#3a7ebf",
            command=self.enable_compact_mode
        )
        self.compact_btn.pack(side="left", padx=5)

        # Dashboard / Stats Frame
        self.stats_frame = ctk.CTkFrame(self.normal_view, corner_radius=10)
        self.stats_frame.pack(fill="x", padx=15, pady=5)

        self.fps_label = ctk.CTkLabel(
            self.stats_frame, 
            text="⚡ FPS: --", 
            font=ctk.CTkFont(size=16, weight="bold"),
            text_color="#00FFCC"
        )
        self.fps_label.pack(pady=4)

        self.ram_label = ctk.CTkLabel(
            self.stats_frame, 
            text="💾 RAM Використання: --%", 
            font=ctk.CTkFont(size=14)
        )
        self.ram_label.pack(pady=2)

        self.ram_bar = ctk.CTkProgressBar(self.stats_frame, width=380)
        self.ram_bar.pack(pady=5)
        self.ram_bar.set(0)

        self.clean_ram_btn = ctk.CTkButton(
            self.stats_frame, 
            text="🧹 Очистити RAM", 
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
            text="⏱️ Ігровий Таймер", 
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
            text="Старт / Пауза", 
            width=110, 
            command=self.toggle_timer
        )
        self.start_timer_btn.pack(side="left", padx=5)

        self.reset_timer_btn = ctk.CTkButton(
            self.timer_btn_frame, 
            text="Скинути", 
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
            text="📝 Швидкі Нотатки", 
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
            text="🧹 Очистити",
            width=80,
            height=24,
            font=ctk.CTkFont(size=11),
            command=self.clean_ram
        )
        self.mini_clean_btn.pack(side="left", padx=3)

        self.expand_btn = ctk.CTkButton(
            self.mini_btn_frame,
            text="⚙️ Повне",
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
        now = time.time()
        self.frame_count += 1
        elapsed = now - self.last_frame_time
        if elapsed >= 1.0:
            self.fps_value = int(self.frame_count / elapsed)
            self.frame_count = 0
            self.last_frame_time = now
            fps_text = f"⚡ FPS: {self.fps_value}"
            self.fps_label.configure(text=f"⚡ GUI / Screen FPS: {self.fps_value}")
            self.mini_fps_label.configure(text=fps_text)

        ram_perm = psutil.virtual_memory().percent
        self.ram_label.configure(text=f"💾 RAM Використання: {ram_perm}%")
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

if __name__ == "__main__":
    app = GameAssistantApp()
    app.mainloop()
