#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get GPU backend from parameter (default: cpu)
BACKEND="${1:-cpu}"

# Validate backend
case "$BACKEND" in
cuda | vulkan | cpu) ;;
*)
  echo -e "${RED}Error: Invalid backend '$BACKEND'${NC}"
  echo "Usage: $0 [cuda|vulkan|cpu]"
  echo "  cuda   - For NVIDIA GPUs"
  echo "  vulkan - For AMD/Intel GPUs"
  echo "  cpu    - For CPU only (default)"
  exit 1
  ;;
esac

echo -e "${GREEN}=== Hyprflow Installer ===${NC}"
echo -e "GPU Backend: ${YELLOW}$BACKEND${NC}\n"

# Check dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"
MISSING_DEPS=()

if ! command -v git &>/dev/null; then
  MISSING_DEPS+=("git")
fi

if ! command -v cmake &>/dev/null; then
  MISSING_DEPS+=("cmake")
fi

if ! command -v pw-record &>/dev/null; then
  MISSING_DEPS+=("pipewire (pw-record)")
fi

if ! command -v wl-copy &>/dev/null; then
  MISSING_DEPS+=("wl-clipboard (wl-copy)")
fi

if ! command -v notify-send &>/dev/null; then
  MISSING_DEPS+=("notification daemon (notify-send)")
fi

if ! command -v makoctl &>/dev/null; then
  MISSING_DEPS+=("mako (makoctl)")
fi

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
  echo -e "${RED}Missing dependencies:${NC}"
  for dep in "${MISSING_DEPS[@]}"; do
    all.sh add make-o as installation dependency echo "  - $dep"
  done
  echo ""
  echo "Please install missing dependencies and try again."
  exit 1
fi

echo -e "${GREEN}All dependencies found!${NC}\n"

# Set installation directory
FLOW_DIR="$HOME/.hyprflow"
WHISPER_DIR="$FLOW_DIR/whisper.cpp"

# Create hyprflow directory if it doesn't exist
mkdir -p "$FLOW_DIR"

# Clone whisper.cpp if not exists
if [ -d "$WHISPER_DIR" ]; then
  echo -e "${YELLOW}whisper.cpp already exists at $WHISPER_DIR${NC}"
  read -p "Do you want to rebuild it? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Skipping whisper.cpp build${NC}\n"
  else
    echo -e "${YELLOW}Rebuilding whisper.cpp...${NC}"
    cd "$WHISPER_DIR"
    git pull
    rm -rf build
  fi
else
  echo -e "${YELLOW}Cloning whisper.cpp...${NC}"
  git clone https://github.com/ggerganov/whisper.cpp "$WHISPER_DIR"
  cd "$WHISPER_DIR"
fi

# Build whisper.cpp with appropriate backend
if [ ! -f "$WHISPER_DIR/build/bin/whisper-cli" ]; then
  cd "$WHISPER_DIR"
  echo -e "${YELLOW}Building whisper.cpp with $BACKEND backend...${NC}"

  case "$BACKEND" in
  cuda)
    cmake -B build -DGGML_CUDA=ON
    ;;
  vulkan)
    cmake -B build -DGGML_VULKAN=ON
    ;;
  cpu)
    cmake -B build
    ;;
  esac

  cmake --build build --config Release
  echo -e "${GREEN}whisper.cpp built successfully!${NC}\n"
fi

# Download model if not exists
MODEL_FILE="$WHISPER_DIR/models/ggml-base.en.bin"
if [ ! -f "$MODEL_FILE" ]; then
  echo -e "${YELLOW}Downloading base.en model...${NC}"
  cd "$WHISPER_DIR"
  bash models/download-ggml-model.sh base.en
  echo -e "${GREEN}Model downloaded!${NC}\n"
else
  echo -e "${GREEN}Model already exists: $MODEL_FILE${NC}\n"
fi

# Configure hyprflow
FLOW_DIR_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$FLOW_DIR_SCRIPT/config"

if [ -f "$CONFIG_FILE" ]; then
  echo -e "${YELLOW}Config file already exists${NC}"
  read -p "Do you want to overwrite it? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Keeping existing config${NC}\n"
  else
    echo -e "${YELLOW}Creating new config file...${NC}"
    cat >"$CONFIG_FILE" <<EOF
# Hyprflow Configuration
WHISPER_DIR="$WHISPER_DIR"
EOF
    echo -e "${GREEN}Config created!${NC}\n"
  fi
else
  echo -e "${YELLOW}Creating config file...${NC}"
  cat >"$CONFIG_FILE" <<EOF
# Hyprflow Configuration
WHISPER_DIR="$WHISPER_DIR"
EOF
  echo -e "${GREEN}Config created!${NC}\n"
fi

# Make hyprflow executable
chmod +x "$FLOW_DIR_SCRIPT/hyprflow"

echo -e "${GREEN}=== Installation Complete! ===${NC}\n"
echo -e "Next steps:"
echo -e "1. Configure notifications (optional):"
echo -e "   Add to ${YELLOW}~/.config/mako/config${NC}:"
echo -e "   ${YELLOW}[app-name=Flow]${NC}"
echo -e "   ${YELLOW}anchor=bottom-center${NC}"
echo -e "   ${YELLOW}width=200${NC}"
echo -e "   ${YELLOW}text-alignment=center${NC}"
echo -e "   ${YELLOW}font=monospace 15${NC}\n"
echo -e "2. Add keybind to your compositor config:"
echo -e "   Hyprland: ${YELLOW}\$hyprflow = $FLOW_DIR_SCRIPT/hyprflow${NC}"
echo -e "             ${YELLOW}bindd = SUPER, SPACE, Hyprflow, exec, \$hyprflow${NC}\n"
echo -e "3. Reload your compositor config and you're ready to go!"
echo -e "\nPress ${YELLOW}SUPER+SPACE${NC} to start recording!"
