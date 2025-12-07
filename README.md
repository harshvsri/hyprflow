# Hyprflow

A free, open-source voice-to-text tool for Linux — the WhisperFlow alternative.

Hyprflow enables seamless speech-to-text input anywhere on your system. Press a keybind to start recording, press again to stop, and your transcribed text is automatically typed into the active window.

## Prerequisites

- **Wayland compositor** (Hyprland, Sway, etc.)
- [PipeWire](https://pipewire.org/) (for `pw-record`)
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) (for `wl-copy`)
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) (compiled with GPU support)
- [mako](https://github.com/emersion/mako) (or other notification daemon that supports `notify-send`)

## Installation

### Option A: Automatic Installation (Recommended)

Run the install script with your preferred GPU backend:

```bash
# For NVIDIA (CUDA)
./install.sh cuda

# For AMD/Intel (Vulkan)
./install.sh vulkan

# For CPU only (default)
./install.sh
```

### Option B: Manual Installation

For manual installation instructions, see the [whisper.cpp documentation](https://github.com/ggerganov/whisper.cpp).

After building whisper.cpp, update the `config` file in the hyprflow directory:

```bash
# Hyprflow Configuration
WHISPER_DIR="/path/to/whisper.cpp"
# Make the script executable:
chmod +x hyprflow
```
```bash
```

## Configuration

### 1. Configure notification appearance (optional)

For mako notification daemon, add this to your `~/.config/mako/config`:

```ini
[app-name=Flow]
anchor=bottom-center
width=200
text-alignment=center
font=monospace 15
```

For other notification daemons (dunst, swaync, etc.), configure the app-name `Flow` according to your daemon's format.

### 2. Add keybind

**For Hyprland** (`~/.config/hypr/hyprland.conf`):

```bash
bindd = SUPER, SPACE, Hyprflow, exec, /path/to/hyprflow/hyprflow
```

**For Sway** (`~/.config/sway/config`):

```bash
bindsym $mod+Space exec /path/to/hyprflow/hyprflow
```

**For other Wayland compositors:** Add a keybind that executes the `hyprflow` script.

All recordings and transcripts are stored in subdirectories within the hyprflow folder by default.

## Troubleshooting

**No audio captured:**
- Ensure PipeWire is running: `systemctl --user status pipewire`
- Check your default audio input device

**Slow transcription:**
- Verify GPU acceleration is working (check whisper.cpp build flags)
- Try a smaller model (`tiny.en` or `base.en`)

**Text not pasting:**
- Ensure `wl-clipboard` is installed
- For Hyprland: Uses `CTRL+SHIFT+V` shortcut
- For other compositors: Text is in clipboard, paste manually if auto-paste fails

**Configuration not loading:**
- Ensure config file exists in the hyprflow directory
- Check file permissions are readable
- Verify WHISPER_MODEL path is correct
