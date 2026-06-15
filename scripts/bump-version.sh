#!/bin/bash
# Bump Eligere version
# Usage: ./scripts/bump-version.sh <marketing-version> <build-number>
# Example: ./scripts/bump-version.sh 2.2.0 34

set -euo pipefail

if [ $# -ne 2 ]; then
    echo "Usage: $0 <marketing-version> <build-number>"
    echo "Example: $0 2.2.0 34"
    exit 1
fi

MARKETING_VERSION="$1"
BUILD_NUMBER="$2"

PBXPROJ="EligereApp.xcodeproj/project.pbxproj"

# Validate
if ! echo "$MARKETING_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Error: marketing version must be in X.Y.Z format"
    exit 1
fi
if ! echo "$BUILD_NUMBER" | grep -qE '^[0-9]+$'; then
    echo "Error: build number must be numeric"
    exit 1
fi

echo "Bumping to $MARKETING_VERSION (build $BUILD_NUMBER)..."

# Replace MARKETING_VERSION in pbxproj (4 occurrences)
sed -i '' 's/MARKETING_VERSION = "[0-9]*\.[0-9]*\.[0-9]*";/MARKETING_VERSION = "'"$MARKETING_VERSION"'";/g' "$PBXPROJ"

# Replace CURRENT_PROJECT_VERSION in pbxproj (4 occurrences)
sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = '"$BUILD_NUMBER"';/g' "$PBXPROJ"

echo "Done. Committing..."

git add "$PBXPROJ"
git commit -m "release: bump to $MARKETING_VERSION (build $BUILD_NUMBER)"

echo ""
echo "Version bumped to $MARKETING_VERSION (build $BUILD_NUMBER)"
echo "Run ./build_dmg.sh to build the DMG"
echo "Then: git tag v${MARKETING_VERSION}_${BUILD_NUMBER} && git push origin v${MARKETING_VERSION}_${BUILD_NUMBER}"
