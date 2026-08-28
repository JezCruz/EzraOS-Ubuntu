#!/usr/bin/env bash

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILE="$BASE/data/notes.txt"

touch "$FILE"

while true; do
    clear
    echo "NOTES"
    echo
    echo "[1] View notes"
    echo "[2] Add note"
    echo "[3] Clear notes"
    echo "[0] Back"
    echo

    read -r -p "Select > " choice

    case "$choice" in
        1)
            clear
            echo "YOUR NOTES"
            echo

            if [ -s "$FILE" ]; then
                cat "$FILE"
            else
                echo "No notes yet."
            fi

            echo
            read -r -p "Press Enter..."
            ;;
        2)
            echo
            read -r -p "Note: " note

            if [ -n "$note" ]; then
                printf "[%s] %s\n" \
                    "$(date '+%Y-%m-%d %H:%M')" \
                    "$note" >> "$FILE"

                echo "Note saved."
                sleep 1
            fi
            ;;
        3)
            read -r -p "Type CLEAR to confirm: " confirm

            if [ "$confirm" = "CLEAR" ]; then
                : > "$FILE"
                echo "Notes cleared."
                sleep 1
            fi
            ;;
        0)
            exit 0
            ;;
    esac
done
