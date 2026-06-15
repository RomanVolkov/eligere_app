#!/bin/bash
# Sync test source files from EligereApp/ to EligereTests/Sources/Eligere/
# Run this before `swift test` if you've modified the original sources.

set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_SOURCES="$DIR/EligereTests/Sources/Eligere"
APP_SOURCES="$DIR/EligereApp"

FILES=(
    "Configs/Browser.swift"
    "Configs/BrowserName.swift"
    "Configs/Config.swift"
    "Configs/TOMLDecoder.swift"
    "Models/BrowserDetector.swift"
    "Models/RoutingResult.swift"
    "Utils/URLCleaner.swift"
)

echo "Syncing test sources from EligereApp/..."
for f in "${FILES[@]}"; do
    src="$APP_SOURCES/$f"
    dst="$TEST_SOURCES/$(basename "$f")"
    cp "$src" "$dst"
    echo "  $f"
done

echo "Done. Run 'cd EligereTests && swift test' to test."
