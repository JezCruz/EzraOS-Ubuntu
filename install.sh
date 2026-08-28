#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# EzraOS Installer
# Supports:
#   - Ubuntu / Debian-based Linux
#   - Android / Termux
# ============================================================

BLUE='\033[1;34m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
WHITE='\033[1;37m'
RESET='\033[0m'

info() {
    printf "${WHITE}%s${RESET}\n" "$1"
}

success() {
    printf "${GREEN}%s${RESET}\n" "$1"
}

warning() {
    printf "${YELLOW}%s${RESET}\n" "$1"
}

error() {
    printf "${RED}%s${RESET}\n" "$1"
}

section() {
    echo
    printf "${BLUE}============================================================${RESET}\n"
    printf "${CYAN}%s${RESET}\n" "$1"
    printf "${BLUE}============================================================${RESET}\n"
    echo
}

# ============================================================
# EzraOS location
# ============================================================

# Use the directory where install.sh actually exists.
# This allows EzraOS to work from:
#
#   ~/EzraOS
#
# or:
#
#   ~/MyProjects/EzraOS
#
BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================
# Header
# ============================================================

clear 2>/dev/null || true

echo
printf "${BLUE}EzraOS Installer${RESET}\n"
printf "${WHITE}Offline AI Development Environment${RESET}\n"
echo

info "EzraOS directory:"
printf "  ${CYAN}%s${RESET}\n\n" "$BASE"

info "Detecting operating environment..."

# ============================================================
# Detect platform
# ============================================================

PLATFORM=""
PREFIX_PATH=""

if command -v pkg >/dev/null 2>&1 &&
   [ -n "${PREFIX:-}" ] &&
   [ -d "/data/data/com.termux/files" ]; then

    PLATFORM="termux"
    PREFIX_PATH="$PREFIX/bin"

elif [ "$(uname -s)" = "Linux" ] &&
     command -v apt >/dev/null 2>&1; then

    PLATFORM="ubuntu"
    PREFIX_PATH="$HOME/.local/bin"

else
    error "Unsupported operating system."
    echo
    info "Currently supported:"
    info "  - Ubuntu / Debian-based Linux"
    info "  - Android through Termux"
    echo
    exit 1
fi

success "Detected platform: $PLATFORM"

# ============================================================
# Install dependencies
# ============================================================

section "Installing Dependencies"

if [ "$PLATFORM" = "termux" ]; then

    info "Updating Termux packages..."

    pkg update -y

    info "Installing EzraOS dependencies..."

    pkg install -y \
        git \
        python \
        curl \
        llama-cpp

elif [ "$PLATFORM" = "ubuntu" ]; then

    if ! command -v sudo >/dev/null 2>&1; then
        error "sudo is required to install Ubuntu dependencies."
        exit 1
    fi

    info "Updating Ubuntu package database..."

    sudo apt update

    info "Installing EzraOS dependencies..."

    sudo apt install -y \
        git \
        python3 \
        python3-pip \
        python3-venv \
        curl \
        ca-certificates \
        build-essential \
        cmake \
        pkg-config \
        libcurl4-openssl-dev \
        libssl-dev

fi

success "System dependencies installed."

# ============================================================
# User binary directory
# ============================================================

mkdir -p "$PREFIX_PATH"

# ============================================================
# Install llama.cpp on Ubuntu
# ============================================================

if [ "$PLATFORM" = "ubuntu" ]; then

    section "Checking llama.cpp"

    if command -v llama-server >/dev/null 2>&1; then

        success "llama-server is already installed."

        LLAMA_PATH="$(command -v llama-server)"

        printf "${WHITE}Location: ${CYAN}%s${RESET}\n" "$LLAMA_PATH"

    else

        info "llama-server was not found."
        info "Installing llama.cpp..."

        LLAMA_ROOT="$HOME/.local/share/ezraos"
        LLAMA_SOURCE="$LLAMA_ROOT/llama.cpp"

        mkdir -p "$LLAMA_ROOT"

        if [ -d "$LLAMA_SOURCE/.git" ]; then

            info "Existing llama.cpp source found."
            info "Updating source..."

            git -C "$LLAMA_SOURCE" pull --ff-only

        else

            rm -rf "$LLAMA_SOURCE"

            info "Downloading llama.cpp..."

            git clone \
                --depth 1 \
                https://github.com/ggml-org/llama.cpp.git \
                "$LLAMA_SOURCE"

        fi

        info "Configuring llama.cpp..."

        cmake \
            -S "$LLAMA_SOURCE" \
            -B "$LLAMA_SOURCE/build" \
            -DCMAKE_BUILD_TYPE=Release \
            -DLLAMA_BUILD_SERVER=ON \
            -DLLAMA_BUILD_TESTS=OFF \
            -DLLAMA_BUILD_EXAMPLES=OFF

        info "Building llama-server..."

        cmake \
            --build "$LLAMA_SOURCE/build" \
            --config Release \
            --target llama-server \
            -j"$(nproc)"

        LLAMA_BINARY="$LLAMA_SOURCE/build/bin/llama-server"

        if [ ! -x "$LLAMA_BINARY" ]; then
            error "llama-server build failed."
            error "Expected binary:"
            echo "$LLAMA_BINARY"
            exit 1
        fi

        ln -sf \
            "$LLAMA_BINARY" \
            "$PREFIX_PATH/llama-server"

        success "llama-server installed successfully."

    fi

fi

# ============================================================
# Verify llama-server
# ============================================================

section "Verifying AI Runtime"

if [ "$PLATFORM" = "termux" ]; then

    # Termux package normally exposes llama-server directly.
    if command -v llama-server >/dev/null 2>&1; then
        success "llama-server detected."
    else
        error "llama-server could not be found after installing llama-cpp."
        exit 1
    fi

else

    if [ -x "$PREFIX_PATH/llama-server" ]; then

        success "llama-server detected."

    elif command -v llama-server >/dev/null 2>&1; then

        success "llama-server detected."

    else

        error "llama-server is unavailable."
        exit 1

    fi

fi

# ============================================================
# EzraOS directories
# ============================================================

section "Preparing EzraOS"

mkdir -p \
    "$BASE/data" \
    "$BASE/data/history" \
    "$BASE/logs" \
    "$BASE/runtime" \
    "$BASE/models"

# ============================================================
# Notes
# ============================================================

touch "$BASE/data/notes.txt"

# ============================================================
# Conversation histories
# ============================================================

create_history() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo '[]' > "$file"
    fi
}

create_history "$BASE/data/history/general.json"
create_history "$BASE/data/history/java.json"
create_history "$BASE/data/history/python.json"
create_history "$BASE/data/history/sql.json"
create_history "$BASE/data/history/git.json"
create_history "$BASE/data/history/linux.json"
create_history "$BASE/data/history/bible.json"

success "EzraOS data directories prepared."

# ============================================================
# Clean stale runtime files
# ============================================================

section "Cleaning Runtime"

rm -f "$BASE/runtime/server.pid"
rm -f "$BASE/logs/server.log"

success "Stale runtime files removed."

# ============================================================
# Permissions
# ============================================================

section "Setting Permissions"

if [ -f "$BASE/ezra" ]; then
    chmod +x "$BASE/ezra"
else
    error "EzraOS launcher not found:"
    echo "$BASE/ezra"
    exit 1
fi

if [ -f "$BASE/core/server.sh" ]; then
    chmod +x "$BASE/core/server.sh"
fi

if [ -d "$BASE/modules" ]; then
    find "$BASE/modules" \
        -maxdepth 1 \
        -type f \
        -name '*.sh' \
        -exec chmod +x {} \;
fi

success "Permissions configured."

# ============================================================
# Global Ezra command
# ============================================================

section "Installing Ezra Command"

ln -sf "$BASE/ezra" "$PREFIX_PATH/ezra"

success "Created command:"
printf "  ${CYAN}%s/ezra${RESET}\n" "$PREFIX_PATH"

# ============================================================
# PATH configuration
# ============================================================

if [ "$PLATFORM" = "ubuntu" ]; then

    PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

    if ! grep -Fqx "$PATH_LINE" "$HOME/.bashrc" 2>/dev/null; then

        echo >> "$HOME/.bashrc"
        echo '# EzraOS' >> "$HOME/.bashrc"
        echo "$PATH_LINE" >> "$HOME/.bashrc"

        info "Added ~/.local/bin to ~/.bashrc"

    fi

    export PATH="$HOME/.local/bin:$PATH"

fi

# ============================================================
# Python verification
# ============================================================

section "Checking Python"

if [ "$PLATFORM" = "termux" ]; then

    PYTHON_BIN="python"

else

    PYTHON_BIN="python3"

fi

if command -v "$PYTHON_BIN" >/dev/null 2>&1; then

    PYTHON_VERSION="$("$PYTHON_BIN" --version 2>&1)"

    success "$PYTHON_VERSION detected."

else

    error "Python could not be found."
    exit 1

fi

# ============================================================
# Git verification
# ============================================================

section "Checking Git"

if command -v git >/dev/null 2>&1; then

    GIT_VERSION="$(git --version)"

    success "$GIT_VERSION detected."

else

    error "Git could not be found."
    exit 1

fi

# ============================================================
# curl verification
# ============================================================

section "Checking Network Tools"

if command -v curl >/dev/null 2>&1; then

    success "curl detected."

else

    error "curl could not be found."
    exit 1

fi

# ============================================================
# Final verification
# ============================================================

section "Final Verification"

FAILED=0

check_file() {

    local file="$1"
    local description="$2"

    if [ -e "$file" ]; then
        success "$description"
    else
        error "$description missing"
        FAILED=1
    fi

}

check_file "$BASE/ezra" "Ezra launcher"
check_file "$BASE/core" "EzraOS core"
check_file "$BASE/modules" "EzraOS modules"
check_file "$BASE/data" "EzraOS data directory"
check_file "$BASE/models" "Model directory"
check_file "$BASE/runtime" "Runtime directory"
check_file "$BASE/logs" "Log directory"

if [ "$FAILED" -ne 0 ]; then

    echo
    error "EzraOS installation verification failed."
    exit 1

fi

if command -v llama-server >/dev/null 2>&1; then

    success "AI runtime"

elif [ -x "$PREFIX_PATH/llama-server" ]; then

    success "AI runtime"

else

    error "AI runtime missing"
    exit 1

fi

# ============================================================
# Installation complete
# ============================================================

echo
printf "${BLUE}============================================================${RESET}\n"
printf "${GREEN}EzraOS installation completed successfully.${RESET}\n"
printf "${BLUE}============================================================${RESET}\n"
echo

printf "${WHITE}Platform:${RESET}      ${CYAN}%s${RESET}\n" "$PLATFORM"
printf "${WHITE}EzraOS:${RESET}        ${CYAN}%s${RESET}\n" "$BASE"
printf "${WHITE}Command:${RESET}       ${CYAN}ezra${RESET}\n"

if command -v llama-server >/dev/null 2>&1; then

    printf "${WHITE}AI Runtime:${RESET}    ${CYAN}%s${RESET}\n" \
        "$(command -v llama-server)"

elif [ -x "$PREFIX_PATH/llama-server" ]; then

    printf "${WHITE}AI Runtime:${RESET}    ${CYAN}%s${RESET}\n" \
        "$PREFIX_PATH/llama-server"

fi

echo
printf "${WHITE}Start EzraOS with:${RESET}\n\n"
printf "    ${CYAN}ezra${RESET}\n\n"

if [ "$PLATFORM" = "ubuntu" ]; then

    printf "${WHITE}If the ezra command is not immediately available, run:${RESET}\n\n"
    printf "    ${CYAN}source ~/.bashrc${RESET}\n\n"

fi

printf "${WHITE}The AI model may be downloaded automatically on first use.${RESET}\n"
printf "${WHITE}After the model is available, EzraOS can operate locally.${RESET}\n"
echo
