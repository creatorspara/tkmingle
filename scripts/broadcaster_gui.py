import sys
import os
import json
import time
import threading
import urllib.request
import urllib.error
import tkinter as tk
from tkinter import messagebox
from tkinter import ttk
import jwt

# Canonical Supabase & Firebase Service Account Configuration
SUPABASE_URL = "https://mwwjuibehscukzueykjc.supabase.co"
SUPABASE_ANON_KEY = "sb_publishable_04veCw-az3gqv23ZD_tUbA_8MKS_lzS"

SERVICE_ACCOUNT = {
  "type": "service_account",
  "project_id": "tkmingle-23f31",
  "private_key_id": "070633f479aaf259e0448f65a986c46a07d65ece",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDFKJl5tlDz/ZNu\njXcXbg83YIS8xBKt1ddDJDS33RAjuiMajbJZLxktVKICt/L7AYtbsxMyZM1Q7cHb\nrM+XC5MajP0QKTpoAMyAaCpyVgdSlGOMmUdYql6HWi+u3k2S7YaM/VTMrUiu5G/L\n/D7b33j2q+CD7u3vRjRFpF2QR4K9cHtGBha4oGPTrLgfEXoYC/oMQzGR4PCzzcO5\nVd8UepHY6S9dZ7yLcape6Ks1U8kT2SDM+nijH3PcmnXRQKzQAb+IaTjg+p08kO3v\nTH76o9+Towp4qgtVNDGVqHlCZScG73P+mDzlgIzHxysyhVbeRW4XLmi9Ww+1fmpA\nqQg7RJdrAgMBAAECggEADrRPogK6zeplzQh9pICKX6ccr0FxDTMA2i/rQ01C+g8q\nCr3Hr/Fxz24w+Rfuu3wVgId+ETObFoPtAe0aZxmvZSW1GA1Nya+e5kgekPwhPAOi\nMGccKZznQ5wH02Meu6xobRUrIRV0HCB1xWvGOmV+jZMrFwaXtfvxQ8Jq/KrrXCUp\nIYT3m/3JE4i6XxE++rpFs8Nq4Fn4a3fa20uvV/+tSdQNbuJa05hF0zNqJE8T8Vba\nwXuZ45Q0SvPfAvOgagCSbx0ZBh/W2dDh4deNnvYOdNoArquLRDzx3FqNN8J05gKq\nCt6fKjBoHdbeZmktV47O9LfYZpmOYZm+WEmSntekLQKBgQDhW/W0p86VN5DFyqCY\nxSPAEuK9dOjhZNGcaUImbUr0m4y66c0idtX529i31/KZAnJ2EKr0/4I8Lws2NvGD\na/0l+y4OyvH4n8djgOa3tH4nruUagfjXEaf4p6Na08AZ+vyaKW/9jYZVXDwxntx1\n3Ejgd+ojs5q2gbOuuKIIiW+ZDwKBgQDf9xC3fczETSfMCXo+fdUqaH4gGTBFJPu8\nKcntKrLKKN+YxuQkiUtZvJ5ZUX8ZH5Q+4L6vztYGW9ZbqKlVCdi0R4S1hdFalMDB\n79q3VXUs6aZd6nErna7EZ/QVpKJYantsrnYDgafHnyIJs84c7gqQEtnj0wfQpxJF\nVkIMMwKD5QKBgBZEzAbJ/jPohbnFyBDQijPUqesmvkxndf8Kt6qsahe5tzJRICAj\ntgk2nDeucx6Di2P3Sa1kAi6IR4dX7o2aAi3aoDZ9/2MeBsniVuoYP88UDTeNWFWI\nPRzpE89J1VW743IoXhSkA34z2w7cL9TFq73im5RjjwoxztuZCwnk6s4pAoGAYN9h\nyKxONJ5W12dGC9+ro0M9Qq8CdPXxOMsufzoXyV9yj4d/yNnl0LPIHkQk4H4LRkM5\n15t0cZ2pk03ZqGGw7RF+MnHmQvLSiVAw31nEbB/ICRlNyBrVLDj2l6H1Yp70Meco\nPo4HP03ykBXI0jSYNwcgXe26lKKfQYR03wf1T40CgYA0SVIi3b7FrZXDZzvucMVY\nNgLXBywlNhTocWYxHm8s/1h3SjPyaEZgQhWTM7SV2m1yjp70X4ugXcRKOBDuXczF\nHp1g4uyzEyU3jyQLI8O00qsZF6OEFj5Cx1dqXUFV46mArMhHy75FmOzvNOO+7LaD\nIR+v9jfUmjFg9zMhk1fhDg==\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@tkmingle-23f31.iam.gserviceaccount.com"
}


def get_google_access_token():
    """Generates Google OAuth2 Access Token for Firebase Messaging via JWT."""
    now = int(time.time())
    payload = {
        "iss": SERVICE_ACCOUNT["client_email"],
        "scope": "https://www.googleapis.com/auth/firebase.messaging",
        "aud": "https://oauth2.googleapis.com/token",
        "exp": now + 3600,
        "iat": now,
    }
    encoded_jwt = jwt.encode(payload, SERVICE_ACCOUNT["private_key"], algorithm="RS256")
    post_data = urllib.parse.urlencode({
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": encoded_jwt
    }).encode("utf-8")

    req = urllib.request.Request(
        "https://oauth2.googleapis.com/token",
        data=post_data,
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        data = json.loads(resp.read().decode("utf-8"))
        return data["access_token"]


def fetch_device_tokens():
    """Queries active device tokens registered in Supabase."""
    url = f"{SUPABASE_URL}/rest/v1/rpc/get_active_device_tokens"
    req = urllib.request.Request(
        url,
        data=b"{}",
        headers={
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
            "Content-Type": "application/json"
        }
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode("utf-8"))


def insert_inapp_broadcast(title, body, payload_ref="v2.5.0"):
    """Inserts in-app notifications for all registered students."""
    url = f"{SUPABASE_URL}/rest/v1/rpc/broadcast_campus_notification"
    post_data = json.dumps({
        "p_title": title,
        "p_body": body,
        "p_type": "admin_notice",
        "p_reference_id": payload_ref
    }).encode("utf-8")

    req = urllib.request.Request(
        url,
        data=post_data,
        headers={
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
            "Content-Type": "application/json"
        }
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode("utf-8"))


def send_fcm_message(access_token, token, title, body, payload_ref):
    """Sends single high-priority push notification via FCM v1 HTTP API."""
    url = f"https://fcm.googleapis.com/v1/projects/{SERVICE_ACCOUNT['project_id']}/messages:send"
    message_payload = {
        "message": {
            "token": token,
            "notification": {
                "title": title,
                "body": body
            },
            "data": {
                "type": "admin_notice",
                "reference_id": str(payload_ref)
            },
            "android": {
                "priority": "high",
                "notification": {
                    "channel_id": "tkmingle_alerts",
                    "icon": "ic_launcher",
                    "color": "#8875FF",
                    "default_sound": True,
                    "default_vibrate_timings": True
                }
            }
        }
    }
    data = json.dumps(message_payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        }
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.status == 200
    except Exception:
        return False


class TKMingleBroadcasterApp:
    def __init__(self, root):
        self.root = root
        self.root.title("TKMingle Campus Broadcaster")
        self.root.geometry("640x700")
        self.root.minsize(580, 620)
        self.root.configure(bg="#0A1026")

        # Styling
        self.bg_color = "#0A1026"
        self.card_color = "#141A32"
        self.accent_purple = "#8875FF"
        self.accent_teal = "#50D6C2"
        self.text_white = "#F6F5FF"
        self.text_muted = "#A5A9BC"

        self._build_ui()

    def _build_ui(self):
        # Header Frame
        header = tk.Frame(self.root, bg=self.card_color, padx=20, pady=16)
        header.pack(fill="x")

        title_lbl = tk.Label(
            header,
            text="📢 TKMingle Campus Broadcaster",
            font=("Segoe UI", 16, "bold"),
            fg=self.text_white,
            bg=self.card_color
        )
        title_lbl.pack(anchor="w")

        sub_lbl = tk.Label(
            header,
            text="Send push notifications and text alerts to all registered TKMCE campus devices.",
            font=("Segoe UI", 10),
            fg=self.text_muted,
            bg=self.card_color
        )
        sub_lbl.pack(anchor="w", pady=(4, 0))

        # Main Body
        body = tk.Frame(self.root, bg=self.bg_color, padx=20, pady=16)
        body.pack(fill="both", expand=True)

        # Title Input
        tk.Label(
            body,
            text="NOTIFICATION TITLE *",
            font=("Segoe UI", 9, "bold"),
            fg=self.accent_purple,
            bg=self.bg_color
        ).pack(anchor="w", pady=(0, 4))

        self.title_entry = tk.Entry(
            body,
            font=("Segoe UI", 11),
            bg=self.card_color,
            fg=self.text_white,
            insertbackground=self.text_white,
            relief="flat",
            highlightthickness=1,
            highlightbackground="#303451",
            highlightcolor=self.accent_purple
        )
        self.title_entry.pack(fill="x", ipady=8, pady=(0, 14))
        self.title_entry.insert(0, "🚀 TKMingle v2.5.0 Stable is Live!")

        # Message Body Input
        tk.Label(
            body,
            text="NOTIFICATION MESSAGE / TEXT *",
            font=("Segoe UI", 9, "bold"),
            fg=self.accent_purple,
            bg=self.bg_color
        ).pack(anchor="w", pady=(0, 4))

        self.body_text = tk.Text(
            body,
            font=("Segoe UI", 11),
            bg=self.card_color,
            fg=self.text_white,
            insertbackground=self.text_white,
            height=4,
            relief="flat",
            highlightthickness=1,
            highlightbackground="#303451",
            highlightcolor=self.accent_purple
        )
        self.body_text.pack(fill="x", pady=(0, 14))
        self.body_text.insert(
            "1.0",
            "A new major update is ready! Tap to update and experience the clean campus layout & latest fixes."
        )

        # Reference Link / ID (Optional)
        tk.Label(
            body,
            text="REFERENCE ID / TARGET (Optional)",
            font=("Segoe UI", 9, "bold"),
            fg=self.text_muted,
            bg=self.bg_color
        ).pack(anchor="w", pady=(0, 4))

        self.ref_entry = tk.Entry(
            body,
            font=("Segoe UI", 10),
            bg=self.card_color,
            fg=self.text_white,
            insertbackground=self.text_white,
            relief="flat",
            highlightthickness=1,
            highlightbackground="#303451",
            highlightcolor=self.accent_teal
        )
        self.ref_entry.pack(fill="x", ipady=6, pady=(0, 16))
        self.ref_entry.insert(0, "v2.5.0")

        # Quick Preset Buttons
        preset_frame = tk.Frame(body, bg=self.bg_color)
        preset_frame.pack(fill="x", pady=(0, 16))

        tk.Label(
            preset_frame,
            text="Quick Presets:",
            font=("Segoe UI", 9, "bold"),
            fg=self.text_muted,
            bg=self.bg_color
        ).pack(side="left", padx=(0, 8))

        btn_style = {
            "font": ("Segoe UI", 9),
            "bg": "#1E2648",
            "fg": self.text_white,
            "relief": "flat",
            "activebackground": self.accent_purple,
            "padx": 8,
            "pady": 2,
            "cursor": "hand2"
        }

        tk.Button(
            preset_frame,
            text="🚀 App Update",
            command=self._preset_update,
            **btn_style
        ).pack(side="left", padx=4)

        tk.Button(
            preset_frame,
            text="☕ Campus Tea Notice",
            command=self._preset_tea,
            **btn_style
        ).pack(side="left", padx=4)

        tk.Button(
            preset_frame,
            text="📢 General Alert",
            command=self._preset_alert,
            **btn_style
        ).pack(side="left", padx=4)

        # Dispatch Action Button
        self.send_btn = tk.Button(
            body,
            text="🚀 DISPATCH PUSH NOTIFICATION TO EVERYONE",
            font=("Segoe UI", 11, "bold"),
            bg=self.accent_purple,
            fg="white",
            activebackground="#725FEB",
            relief="flat",
            pady=10,
            cursor="hand2",
            command=self._start_broadcast
        )
        self.send_btn.pack(fill="x", pady=(0, 16))

        # Status & Activity Log
        tk.Label(
            body,
            text="BROADCAST ACTIVITY LOG",
            font=("Segoe UI", 9, "bold"),
            fg=self.accent_teal,
            bg=self.bg_color
        ).pack(anchor="w", pady=(0, 4))

        self.log_box = tk.Text(
            body,
            font=("Consolas", 9),
            bg="#0D132A",
            fg="#50D6C2",
            height=10,
            relief="flat",
            highlightthickness=1,
            highlightbackground="#232946"
        )
        self.log_box.pack(fill="both", expand=True)
        self._log("Ready. Enter title and message above, then click Dispatch.")

    def _preset_update(self):
        self.title_entry.delete(0, tk.END)
        self.title_entry.insert(0, "🚀 TKMingle v2.5.0 Stable is Live!")
        self.body_text.delete("1.0", tk.END)
        self.body_text.insert(
            "1.0",
            "A new major update is ready! Tap to update and experience the clean campus layout & latest fixes."
        )
        self.ref_entry.delete(0, tk.END)
        self.ref_entry.insert(0, "v2.5.0")

    def _preset_tea(self):
        self.title_entry.delete(0, tk.END)
        self.title_entry.insert(0, "☕ New Campus Whispers on TKMingle!")
        self.body_text.delete("1.0", tk.END)
        self.body_text.insert(
            "1.0",
            "Fresh campus tea and lecture quotes just dropped. Check it out now!"
        )
        self.ref_entry.delete(0, tk.END)
        self.ref_entry.insert(0, "tea_feed")

    def _preset_alert(self):
        self.title_entry.delete(0, tk.END)
        self.title_entry.insert(0, "📢 TKMCE Campus Announcement")
        self.body_text.delete("1.0", tk.END)
        self.body_text.insert(
            "1.0",
            "Important campus update from TKMingle administration."
        )
        self.ref_entry.delete(0, tk.END)
        self.ref_entry.insert(0, "announcement")

    def _log(self, text):
        timestamp = time.strftime("%H:%M:%S")
        self.log_box.insert(tk.END, f"[{timestamp}] {text}\n")
        self.log_box.see(tk.END)

    def _start_broadcast(self):
        title = self.title_entry.get().strip()
        body = self.body_text.get("1.0", tk.END).strip()
        ref = self.ref_entry.get().strip() or "general"

        if not title or not body:
            messagebox.showwarning("Validation Error", "Please enter both Title and Message.")
            return

        confirm = messagebox.askyesno(
            "Confirm Broadcast",
            f"Are you sure you want to send this push notification to ALL registered TKMCE campus devices?\n\nTitle: {title}\nMessage: {body}"
        )
        if not confirm:
            return

        self.send_btn.config(state="disabled", text="⏳ Dispatching Broadcast...", bg="#555")
        threading.Thread(target=self._execute_broadcast, args=(title, body, ref), daemon=True).start()

    def _execute_broadcast(self, title, body, ref):
        try:
            self._log("Authenticating with Google Cloud / Firebase...")
            token = get_google_access_token()
            self._log("Google OAuth2 Access Token successfully minted.")

            self._log("Inserting in-app notifications for all campus students...")
            inapp_count = insert_inapp_broadcast(title, body, ref)
            self._log(f"In-app notifications inserted for {inapp_count} student profiles.")

            self._log("Fetching active device tokens from Supabase...")
            devices = fetch_device_tokens()
            total_devices = len(devices)
            self._log(f"Found {total_devices} active mobile device tokens.")

            success_count = 0
            fail_count = 0

            for i, dev in enumerate(devices, 1):
                device_token = dev.get("device_token")
                if not device_token:
                    continue
                ok = send_fcm_message(token, device_token, title, body, ref)
                if ok:
                    success_count += 1
                else:
                    fail_count += 1

                if i % 10 == 0 or i == total_devices:
                    self._log(f"Progress: Sent {i}/{total_devices} (Success: {success_count}, Failed: {fail_count})")

            self._log("=" * 45)
            self._log(f"🎉 BROADCAST COMPLETE!")
            self._log(f"• In-app notifications: {inapp_count} students")
            self._log(f"• Push notifications: {success_count} devices successfully reached")
            if fail_count > 0:
                self._log(f"• Inactive/uninstalled tokens: {fail_count}")

            messagebox.showinfo(
                "Broadcast Sent Successfully",
                f"Push Notification Delivered!\n\n• {success_count} mobile devices received push notification.\n• {inapp_count} student profiles received in-app alert."
            )

        except Exception as e:
            self._log(f"ERROR: {str(e)}")
            messagebox.showerror("Broadcast Error", f"An error occurred while dispatching:\n{str(e)}")

        finally:
            self.send_btn.config(
                state="normal",
                text="🚀 DISPATCH PUSH NOTIFICATION TO EVERYONE",
                bg=self.accent_purple
            )


if __name__ == "__main__":
    root = tk.Tk()
    app = TKMingleBroadcasterApp(root)
    root.mainloop()
