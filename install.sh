#!/usr/bin/env bash

set -e

BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

echo
printf "${BLUE}EzraOS Installer${RESET}\n"
printf "${WHITE}Detecting operating environment...${RESET}\n\n"

# ============================================================
# Detect platform
# ============================================================

if command -v pkg >/dev/null 2>&1 && [ -n "${PREFIX:-}" ]; then

    PLATFORM="termux"

    printf "${CYAN}Termux detected.${RESET}\n"
    printf "${WHITE}Installing required packages...${RESET}\n\n"

    pkg update -y
    pkg install -y git python curl llama-cpp

    PREFIX_PATH="$PREFIX/bin"

elif command -v apt >/dev/null 2>&1; then

    PLATFORM="ubuntu"

    printf "${CYAN}Ubuntu/Debian Linux detected.${RESET}\n"
    printf "${WHITE}Installing required packages...${RESET}\n\n"

    sudo apt update
    sudo apt install -y \
        git \
        python3 \
        python3-pip \
        curl \
        build-essential

    PREFIX_PATH="$HOME/.local/bin"

    mkdir -p "$PREFIX_PATH"

else

    printf "${WHITE}Unsupported operating system.${RESET}\n"
    exit 1

fi

# ============================================================
# EzraOS directories
# ============================================================

BASE="$HOME/EzraOS"

mkdir -p \
    "$BASE/data/history" \
    "$BASE/logs" \
    "$BASE/runtime" \
    "$BASE/models"

touch "$BASE/data/notes.txt"

[ -f "$BASE/data/history/general.json" ] || \
    echo '[]' > "$BASE/data/history/general.json"

[ -f "$BASE/data/history/java.json" ] || \
    echo '[]' > "$BASE/data/history/java.json"

[ -f "$BASE/data/history/bible.json" ] || \
    echo '[]' > "$BASE/data/history/bible.json"

# ============================================================
# Clean stale runtime files
# ============================================================

rm -f "$BASE/runtime/server.pid"
rm -f "$BASE/logs/server.log"

# ============================================================
# Permissions
# ============================================================

chmod +x "$BASE/ezra"
chmod +x "$BASE/core/server.sh"
chmod +x "$BASE/modules/"*.sh 2>/dev/null || true

# ============================================================
# Global Ezra command
# ============================================================

ln -sf "$BASE/ezra" "$PREFIX_PATH/ezra"

# Add ~/.local/bin to PATH on Linux
if [ "$PLATFORM" = "ubuntu" ]; then

    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    fi

fi

echo
printf "${CYAN}EzraOS installation completed.${RESET}\n"
printf "${WHITE}Platform: ${CYAN}${PLATFORM}${RESET}\n"
printf "${WHITE}Start EzraOS with:${RESET}\n\n"
printf "    ${CYAN}ezra${RESET}\n\n"
printf "${WHITE}The AI model may be downloaded automatically on first use.${RESET}\n"
echo
