#!/bin/bash

# Hyprflow Configuration Script
# Automatically configures Hyprland and Mako for hyprflow

set -e

# Get the absolute path to hyprflow directory
HYPRFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPRFLOW_SCRIPT="${HYPRFLOW_DIR}/hyprflow"

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=== Hyprflow Configuration Script ==="
echo ""

# Function to check if a line exists in a file
line_exists() {
  local file="$1"
  local pattern="$2"
  grep -qF "$pattern" "$file" 2>/dev/null
}

# 1. Configure Hyprland
echo -e "${YELLOW}[1/2] Configuring Hyprland...${NC}"

HYPRLAND_CONF="${HOME}/.config/hypr/hyprland.conf"

if [ ! -f "$HYPRLAND_CONF" ]; then
  echo -e "${RED}Error: Hyprland config not found at $HYPRLAND_CONF${NC}"
  echo "Please ensure Hyprland is installed and configured."
  exit 1
fi

# Check if hyprflow keybind already exists
if line_exists "$HYPRLAND_CONF" "Hyprflow"; then
  echo -e "${GREEN}✓ Hyprflow keybind already exists in Hyprland config${NC}"
else
  # Append the keybind to hyprland.conf
  echo "" >>"$HYPRLAND_CONF"
  echo "# Hyprflow - Voice-to-text keybind" >>"$HYPRLAND_CONF"
  echo "bindd = SUPER, SPACE, Hyprflow, exec, ${HYPRFLOW_SCRIPT}" >>"$HYPRLAND_CONF"
  echo -e "${GREEN}✓ Added Hyprflow keybind to Hyprland config${NC}"
  echo "  Keybind: SUPER + SPACE"
fi

# 2. Configure Mako
echo -e "${YELLOW}[2/2] Configuring Mako...${NC}"

MAKO_CONFIG_DIR="${HOME}/.config/mako"
MAKO_CONFIG="${MAKO_CONFIG_DIR}/config"

# Create mako config directory if it doesn't exist
if [ ! -d "$MAKO_CONFIG_DIR" ]; then
  mkdir -p "$MAKO_CONFIG_DIR"
  echo -e "${GREEN}✓ Created Mako config directory${NC}"
fi

# Check if mako config exists, create if not
if [ ! -f "$MAKO_CONFIG" ]; then
  touch "$MAKO_CONFIG"
  echo -e "${GREEN}✓ Created Mako config file${NC}"
fi

# Check if Flow app configuration already exists
if line_exists "$MAKO_CONFIG" "[app-name=Flow]"; then
  echo -e "${GREEN}✓ Mako Flow configuration already exists${NC}"
else
  # Append Flow configuration to mako config
  echo "" >>"$MAKO_CONFIG"
  echo "# Hyprflow notification styling" >>"$MAKO_CONFIG"
  echo "[app-name=Flow]" >>"$MAKO_CONFIG"
  echo "anchor=bottom-center" >>"$MAKO_CONFIG"
  echo "width=200" >>"$MAKO_CONFIG"
  echo "text-alignment=center" >>"$MAKO_CONFIG"
  echo "font=monospace 15" >>"$MAKO_CONFIG"
  echo -e "${GREEN}✓ Added Flow notification styling to Mako config${NC}"
fi

# 3. Restart services (optional)
echo ""
echo -e "${YELLOW}Configuration complete!${NC}"
echo ""
echo "To apply changes:"
echo "  1. Reload Hyprland config: hyprctl reload"
echo "  2. Restart Mako: pkill mako && mako &"
echo ""
echo "Or simply log out and log back in."
echo ""
echo -e "${GREEN}Usage: Press SUPER + SPACE to start/stop recording${NC}"
echo ""

# Ask if user wants to reload services now
read -p "Would you like to reload services now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Reloading services...${NC}"

  # Reload Hyprland config
  if command -v hyprctl &>/dev/null; then
    hyprctl reload && echo -e "${GREEN}✓ Hyprland config reloaded${NC}"
  fi

  # Restart Mako
  if command -v mako &>/dev/null; then
    pkill mako 2>/dev/null
    mako &
    disown
    echo -e "${GREEN}✓ Mako restarted${NC}"
  fi

  echo ""
  echo -e "${GREEN}All done! You can now use Hyprflow with SUPER + SPACE${NC}"
fi
