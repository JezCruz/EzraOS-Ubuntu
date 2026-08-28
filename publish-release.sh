#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$SCRIPT_DIR"
RELEASE_BRANCH="v2-server"
MAIN_BRANCH="main"
TAG="v2.1.0-alpha"

cd "$REPO"

echo "==> Fetching remote..."
git fetch origin

echo "==> Checking out release branch..."
git switch "$RELEASE_BRANCH"

echo "==> Staging changes..."
git add .

if ! git diff --cached --quiet; then
    git commit -m "Prepare EzraOS v2.1.0 Alpha release"
else
    echo "No new changes to commit."
fi

echo "==> Pushing $RELEASE_BRANCH..."
git push -u origin "$RELEASE_BRANCH"

echo "==> Switching to $MAIN_BRANCH..."
git switch "$MAIN_BRANCH"

echo "==> Updating local main..."
git pull --ff-only origin "$MAIN_BRANCH" 2>/dev/null || true

echo "==> Merging $RELEASE_BRANCH into $MAIN_BRANCH..."
git merge --no-ff "$RELEASE_BRANCH" -m "Merge $RELEASE_BRANCH for EzraOS v2.1.0 Alpha"

echo "==> Pushing main..."
git push -u origin "$MAIN_BRANCH"

echo "==> Recreating release tag on latest main..."
git tag -d "$TAG" 2>/dev/null || true
git push origin ":refs/tags/$TAG" 2>/dev/null || true
git tag -a "$TAG" -m "EzraOS v2.1.0 Alpha"

echo "==> Pushing tag..."
git push origin "$TAG"

echo
echo "Release branch pushed : $RELEASE_BRANCH"
echo "Main branch updated   : $MAIN_BRANCH"
echo "Release tag pushed    : $TAG"
echo
echo "Done."
