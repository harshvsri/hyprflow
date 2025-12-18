# Hyprflow

A simple, open-source voice-to-text tool for Linux. Press a keybind to record, press again to stop, transcribed text appears in your active window.

## Prerequisites

Install these tools (distro-agnostic, use your package manager):

- **pw-record** (PipeWire) — audio recording
- **wl-copy** (wl-clipboard) — clipboard operations
- **wtype** — simulating paste keystrokes
- **notify-send** — notifications (mako, dunst, swaync, etc.)
- **whisper.cpp** — transcription engine (build from source)

For X11 systems, substitute Wayland-specific tools with X11 equivalents (xclip, xdotool, etc.).

## Setup

1. **Build whisper.cpp from source:**

   ```bash
   git clone https://github.com/ggerganov/whisper.cpp.git
   cd whisper.cpp
   # Follow their build instructions for GPU support
   ```

2. **Configure the flow script:**
   
   Edit the `flow` script and update these paths:
   ```bash
   WHISPER_DIR="${FLOW_DIR}/whisper.cpp"
   WHISPER_BIN="${WHISPER_DIR}/whisper"
   WHISPER_MODEL="${WHISPER_DIR}/models/ggml-base.en.bin"
   ```

3. **Add keybind and Configure notifications(Optional)**
   
   For Hyprland (`~/.config/hypr/hyprland.conf`):
   ```bash
   bindd = SUPER, SPACE, Universal stt, exec, /path/to/hyprflow/flow
   ```
   
   For other compositors, bind a key to execute the `flow` script.

   For mako (`~/.config/mako/config`):
   ```ini
   [app-name=Flow]
   anchor=bottom-center
   width=200
   text-alignment=center
   font=monospace 16
   ```
   
   For other notification daemons, configure the app-name `Flow` according to your daemon's format.

That's it. You're done.
