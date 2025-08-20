#!/bin/bash
APP_NAME="Eligere"
PROJECT_DIR="$(pwd)"
PROJECT_NAME="EligereApp"
SCHEME_NAME="Eligere"
BACKGROUND_SCHEME_NAME="Eligere Agent"
CONFIGURATION="Release"
BUILD_DIR="${PROJECT_DIR}/build"
OUTPUT_DIR="output"
DEVELOPER_ID="${DEVELOPER_ID}"
APPLE_ID="${APPLE_ID}"
APP_PASSWORD="${APP_PASSWORD}"

rm -rf "${BUILD_DIR}"

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
    -archivePath "${BUILD_DIR}/${APP_NAME}.xcarchive" \
    -allowProvisioningUpdates

echo "${BUILD_DIR}/${APP_NAME}.xcarchive/"

# Export main app
xcodebuild -exportArchive \
    -archivePath "${BUILD_DIR}/${APP_NAME}.xcarchive" \
    -exportOptionsPlist "${PROJECT_DIR}/ExportOptions.plist" \
    -exportPath "${BUILD_DIR}" \
    -allowProvisioningUpdates

# exit 0
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
LOGINITEMS_DIR="${APP_PATH}/Contents/Library/LoginItems"
mkdir -p "${LOGINITEMS_DIR}"

echo "Signing background service and main app components..."

# Sign background service first
codesign --sign "Developer ID Application: Roman Volkov (${DEVELOPER_ID})" \
    --force --options runtime --timestamp "${LOGINITEMS_DIR}/${BACKGROUND_SCHEME_NAME}.app"

# Extract marketing version and build number from Info.plist
MARKETING_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${APP_PATH}/Contents/Info.plist")
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${APP_PATH}/Contents/Info.plist")
echo "Marketing Version: ${MARKETING_VERSION}"
echo "Build Number: ${BUILD_NUMBER}"

codesign --sign "Developer ID Application: Roman Volkov (${DEVELOPER_ID})" \
    --force --options runtime --timestamp "${APP_PATH}"

echo "Verifying code signatures..."
codesign --verify --verbose "${LOGINITEMS_DIR}/${BACKGROUND_SCHEME_NAME}.app"
codesign --verify --verbose "${APP_PATH}"

# Use version information in DMG names
DMG_NAME="${APP_NAME}_${MARKETING_VERSION}_${BUILD_NUMBER}_Installer.dmg"
COMPRESSED_DMG_NAME="${APP_NAME}_${MARKETING_VERSION}_${BUILD_NUMBER}_Installer_compressed.dmg"

MOUNT_POINT=$(mktemp -d)
hdiutil create -fs HFS+ -size 200m -volname "${APP_NAME}" "${OUTPUT_DIR}/${DMG_NAME}"
hdiutil attach "${OUTPUT_DIR}/${DMG_NAME}" -mountpoint "${MOUNT_POINT}"
cp -R "${BUILD_DIR}/${APP_NAME}.app" "${MOUNT_POINT}/"
ln -s /Applications "${MOUNT_POINT}/Applications"
hdiutil detach "${MOUNT_POINT}"
hdiutil convert "${OUTPUT_DIR}/${DMG_NAME}" -format UDZO -o "${OUTPUT_DIR}/${COMPRESSED_DMG_NAME}"

rm -rf "${BUILD_DIR}/${APP_NAME}.xcarchive"
rm -rf "${MOUNT_POINT}"
rm "${OUTPUT_DIR}/${DMG_NAME}"

DMG_PATH="${OUTPUT_DIR}/${COMPRESSED_DMG_NAME}"
codesign --sign "Developer ID Application: Roman Volkov (${DEVELOPER_ID})" --timestamp --options runtime "${DMG_PATH}"
echo "Submitting for notarization..."

xcrun notarytool submit "${DMG_PATH}" \
    --apple-id "${APPLE_ID}" \
    --password "${APP_PASSWORD}" \
    --team-id "${DEVELOPER_ID}" \
    --output-format json >submission_info.json

SUBMISSION_ID=$(cat submission_info.json | grep -o '"id" *: *"[^"]*"' | cut -d'"' -f4)
echo "Submission ID: ${SUBMISSION_ID}"
echo "Checking notarization status periodically..."

check_status() {
    while true; do
        xcrun notarytool info ${SUBMISSION_ID} \
            --apple-id "${APPLE_ID}" \
            --password "${APP_PASSWORD}" \
            --team-id "${DEVELOPER_ID}" \
            --output-format json >status_info.json

        STATUS=$(cat status_info.json | grep -o '"status" *: *"[^"]*"' | cut -d'"' -f4)

        if [ "$STATUS" = "Accepted" ]; then
            echo "Notarization successful!"
            echo "Stapling notarization ticket to DMG..."
            xcrun stapler staple "${DMG_PATH}"
            if [ $? -eq 0 ]; then
                echo "Stapling completed successfully!"
                break
            else
                echo "Error: Failed to staple notarization ticket"
                exit 1
            fi
        elif [ "$STATUS" = "Invalid" ] || [ "$STATUS" = "Rejected" ]; then
            echo "Notarization failed. See details below:"
            cat status_info.json
            exit 1
        else
            echo "Current status: ${STATUS}. Checking again in 30 seconds..."
            sleep 30
        fi
    done
}

check_status &

echo "Continuing with other tasks while notarization is in progress..."

wait
