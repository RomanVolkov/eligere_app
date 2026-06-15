#!/bin/bash
APP_NAME="Eligere"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME="EligereApp"
SCHEME_NAME="Eligere"
BACKGROUND_SCHEME_NAME="Eligere Agent"
CONFIGURATION="Release"
BUILD_DIR="${PROJECT_DIR}/build"
OUTPUT_DIR="$HOME/output"

rm -rf "${BUILD_DIR}"
mkdir -p ${BUILD_DIR}
mkdir -p ${OUTPUT_DIR}

# Clean both targets
echo "Cleaning main app..."
xcodebuild clean \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}"

echo "Cleaning background service..."
xcodebuild clean \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${BACKGROUND_SCHEME_NAME}" \
    -configuration "${CONFIGURATION}"

# Build and archive main app
echo "Building main app..."
xcodebuild archive \
    -project "${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${BUILD_DIR}/${APP_NAME}.xcarchive"

echo "${BUILD_DIR}/${APP_NAME}.xcarchive/"

# Export main app
xcodebuild -exportArchive \
    -archivePath "${BUILD_DIR}/${APP_NAME}.xcarchive" \
    -exportOptionsPlist "${PROJECT_DIR}/ExportOptions.plist" \
    -exportPath "${BUILD_DIR}"

# exit 0
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
LOGINITEMS_DIR="${APP_PATH}/Contents/Library/LoginItems"
mkdir -p "${LOGINITEMS_DIR}"

echo "Signing background service and main app components..."

# Sign background service first (ad-hoc)
codesign --sign - \
    --force --options runtime "${LOGINITEMS_DIR}/${BACKGROUND_SCHEME_NAME}.app"

# Extract marketing version and build number from Info.plist
MARKETING_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${APP_PATH}/Contents/Info.plist")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${APP_PATH}/Contents/Info.plist")
echo "Marketing Version: ${MARKETING_VERSION}"
echo "Build Number: ${BUILD_NUMBER}"

codesign --sign - \
    --force --options runtime "${APP_PATH}"

echo "Verifying code signatures..."
codesign --verify --verbose "${LOGINITEMS_DIR}/${BACKGROUND_SCHEME_NAME}.app"
codesign --verify --verbose "${APP_PATH}"

# Use version information in DMG names
DMG_NAME="${APP_NAME}_${MARKETING_VERSION}_${BUILD_NUMBER}_Installer.dmg"
COMPRESSED_DMG_NAME="${APP_NAME}_${MARKETING_VERSION}_${BUILD_NUMBER}_Installer_compressed.dmg"

MOUNT_POINT=$(mktemp -d)
hdiutil create -verbose -fs HFS+ -size 200m -volname "${APP_NAME}" "${OUTPUT_DIR}/${DMG_NAME}"
hdiutil attach -verbose "${OUTPUT_DIR}/${DMG_NAME}" -mountpoint "${MOUNT_POINT}"
cp -R "${BUILD_DIR}/${APP_NAME}.app" "${MOUNT_POINT}/"
ln -s /Applications "${MOUNT_POINT}/Applications"
hdiutil detach "${MOUNT_POINT}"
hdiutil convert "${OUTPUT_DIR}/${DMG_NAME}" -format UDZO -o "${OUTPUT_DIR}/${COMPRESSED_DMG_NAME}"

rm -rf "${BUILD_DIR}/${APP_NAME}.xcarchive"
rm -rf "${MOUNT_POINT}"
rm "${OUTPUT_DIR}/${DMG_NAME}"

echo "Done: DMG created at ${OUTPUT_DIR}/${COMPRESSED_DMG_NAME}"
