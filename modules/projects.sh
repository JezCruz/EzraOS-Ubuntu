#!/usr/bin/env bash

clear
echo "PROJECTS"
echo
echo "Git repositories:"
echo

found=0

while IFS= read -r git_dir; do
    repo="${git_dir%/.git}"
    name="$(basename "$repo")"
    branch="$(git -C "$repo" branch --show-current 2>/dev/null)"

    printf "%-25s %s\n" "$name" "${branch:-no branch}"
    found=1
done < <(find "$HOME" -maxdepth 4 -type d -name .git 2>/dev/null)

if [ "$found" -eq 0 ]; then
    echo "No repositories found."
fi

echo
read -r -p "Press Enter..."
