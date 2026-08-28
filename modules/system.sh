#!/usr/bin/env bash

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

clear
echo "SYSTEM INFORMATION"
echo
printf "Device       : %s %s\n" \
    "$(getprop ro.product.manufacturer)" \
    "$(getprop ro.product.model)"
printf "Android      : %s\n" \
    "$(getprop ro.build.version.release)"
printf "Architecture : %s\n" "$(uname -m)"
printf "Kernel       : %s\n" "$(uname -r)"
printf "Memory       : %s\n" \
    "$(free -h | awk '/Mem:/ {print $3 " / " $2}')"
printf "Storage      : %s free\n" \
    "$(df -h "$HOME" | awk 'NR==2 {print $4}')"
printf "AI server    : %s\n" \
    "$("$BASE/core/server.sh" status)"
printf "Model        : Qwen2.5-Coder 1.5B\n"

echo
read -r -p "Press Enter..."
