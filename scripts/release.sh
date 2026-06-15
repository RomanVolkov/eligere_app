#!/bin/bash
# Release a new version of Eligere
# 1. Reads current version from Xcode project
# 2. Builds the DMG
# 3. Commits, tags, and pushes to trigger CI

set -euo pipefail

cd "$(dirname "$0")/.."

PBXPROJ="EligereApp.xcodeproj/project.pbxproj"

# Read current version from pbxproj (first occurrence)
MARKETING_VERSION=$(grep -m1 "MARKETING_VERSION" "$PBXPROJ" | sed 's/.*= \(.*\);/\1/' | tr -d ' ')
BUILD_NUMBER=$(grep -m1 "CURRENT_PROJECT_VERSION" "$PBXPROJ" | sed 's/.*= \(.*\);/\1/' | tr -d ' ')

if [ -z "$MARKETING_VERSION" ] || [ -z "$BUILD_NUMBER" ]; then
    echo "Error: could not read version from $PBXPROJ"
    exit 1
fi

TAG="v${MARKETING_VERSION}_${BUILD_NUMBER}"

echo "Current version: $MARKETING_VERSION (build $BUILD_NUMBER)"
echo "Tag: $TAG"
echo ""

# Build DMG
echo "Building DMG..."
if ! ./scripts/build_dmg.sh; then
    echo "Error: DMG build failed"
    exit 1
fi

DMG_PATH="$HOME/output/Eligere_${MARKETING_VERSION}_${BUILD_NUMBER}_Installer_compressed.dmg"
if [ ! -f "$DMG_PATH" ]; then
    echo "Error: DMG not found at $DMG_PATH"
    exit 1
fi

SHA256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
echo "DMG: $DMG_PATH"
echo "SHA256: $SHA256"
echo ""

# Commit, tag, push
echo "Committing changes..."
git add "$PBXPROJ"
git commit -m "release: $MARKETING_VERSION (build $BUILD_NUMBER)" || true

echo "Tagging as $TAG..."
git tag -f "$TAG"

echo "Pushing..."
git push origin main
git push origin "$TAG"

echo ""
echo "Release $TAG pushed."
echo "GitHub Actions will build and publish the DMG."
echo ""
echo "To update Homebrew cask:"
echo "  cd ../homebrew-eligere && git pull"
echo "  # update version, sha256, url in Casks/eligere.rb"
echo "  git commit -m \"chore(cask): update eligere to ${MARKETING_VERSION}_${BUILD_NUMBER}\""
echo "  git push"
