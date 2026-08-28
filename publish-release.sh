#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$SCRIPT_DIR"
MAIN_BRANCH="main"
TAG="v2.1.0-alpha.1"

cd "$REPO"

echo "==> Checking repository state..."

if [ -n "$(git status --porcelain)" ]; then
    echo "Error: working tree has uncommitted changes."
    echo "Commit or discard them before publishing a release."
    exit 1
fi

CURRENT_BRANCH="$(git branch --show-current)"

if [ "$CURRENT_BRANCH" != "$MAIN_BRANCH" ]; then
    echo "Error: release must be published from '$MAIN_BRANCH'."
    echo "Current branch: $CURRENT_BRANCH"
    exit 1
fi

echo "==> Fetching origin..."
git fetch origin

echo "==> Checking that local main is up to date..."
git pull --ff-only origin "$MAIN_BRANCH"

if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Error: tag '$TAG' already exists locally."
    exit 1
fi

if git ls-remote --exit-code --tags origin "refs/tags/$TAG" >/dev/null 2>&1; then
    echo "Error: tag '$TAG' already exists on origin."
    exit 1
fi

echo "==> Pushing main..."
git push origin "$MAIN_BRANCH"

echo "==> Creating release tag..."
git tag -a "$TAG" -m "EzraOS Ubuntu v2.1.0 Alpha"

echo "==> Pushing release tag..."
git push origin "$TAG"

echo
echo "Release published successfully."
echo "Branch : $MAIN_BRANCH"
echo "Tag    : $TAG"
