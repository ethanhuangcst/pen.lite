#!/bin/bash

# Build script for creating Pen.app bundle with stable ad-hoc signature
# Uses a deterministic identifier for consistent accessibility permissions

set -e

echo "=========================================="
echo "Building Pen for Distribution"
echo "=========================================="

# Configuration
APP_NAME="Pen Lite"
EXECUTABLE_NAME="Pen"
VERSION="1.1.1"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"

# Clean previous build
echo "[1/6] Cleaning previous build..."
rm -rf "${APP_BUNDLE}"
rm -rf dmg_temp
rm -f "${APP_NAME}-${VERSION}.dmg"
rm -f "${APP_NAME}-${VERSION}.zip"

# Build the release version
echo "[2/6] Building release version..."
swift build -c release

# Create app bundle structure
echo "[3/6] Creating app bundle..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy executable
cp "${BUILD_DIR}/${EXECUTABLE_NAME}" "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}"

# Copy Info.plist
cp Info.plist "${APP_BUNDLE}/Contents/Info.plist"

# Update Info.plist with actual values
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable ${EXECUTABLE_NAME}" "${APP_BUNDLE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleName ${APP_NAME}" "${APP_BUNDLE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.penai.PenLite" "${APP_BUNDLE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "${APP_BUNDLE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${VERSION}" "${APP_BUNDLE}/Contents/Info.plist"

# Copy resources
cp -R Resources/Assets "${APP_BUNDLE}/Contents/Resources/"
cp -R Resources/config "${APP_BUNDLE}/Contents/Resources/" 2>/dev/null || true
cp -R Resources/en.lproj "${APP_BUNDLE}/Contents/Resources/" 2>/dev/null || true
cp -R Resources/zh-Hans.lproj "${APP_BUNDLE}/Contents/Resources/" 2>/dev/null || true

# Copy app icon (try both possible locations)
if [ -f "Resources/Assets/AppIcon.icns" ]; then
    cp Resources/Assets/AppIcon.icns "${APP_BUNDLE}/Contents/Resources/"
    echo "  App icon: AppIcon.icns"
elif [ -f "Resources/Assets/logo.png" ]; then
    echo "  Generating AppIcon.icns from logo.png..."
    mkdir -p AppIcon.iconset
    sips -z 16 16 Resources/Assets/logo.png --out AppIcon.iconset/icon_16x16.png 2>/dev/null
    sips -z 32 32 Resources/Assets/logo.png --out AppIcon.iconset/icon_16x16@2x.png 2>/dev/null
    sips -z 32 32 Resources/Assets/logo.png --out AppIcon.iconset/icon_32x32.png 2>/dev/null
    sips -z 64 64 Resources/Assets/logo.png --out AppIcon.iconset/icon_32x32@2x.png 2>/dev/null
    sips -z 128 128 Resources/Assets/logo.png --out AppIcon.iconset/icon_128x128.png 2>/dev/null
    sips -z 256 256 Resources/Assets/logo.png --out AppIcon.iconset/icon_128x128@2x.png 2>/dev/null
    sips -z 256 256 Resources/Assets/logo.png --out AppIcon.iconset/icon_256x256.png 2>/dev/null
    sips -z 512 512 Resources/Assets/logo.png --out AppIcon.iconset/icon_256x256@2x.png 2>/dev/null
    sips -z 512 512 Resources/Assets/logo.png --out AppIcon.iconset/icon_512x512.png 2>/dev/null
    sips -z 1024 1024 Resources/Assets/logo.png --out AppIcon.iconset/icon_512x512@2x.png 2>/dev/null
    iconutil -c icns AppIcon.iconset -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    rm -rf AppIcon.iconset
    echo "  App icon: AppIcon.icns (generated from logo.png)"
elif [ -f "Resources/Assets/icon.png" ]; then
    # Generate icns from png if needed
    echo "  Generating AppIcon.icns from icon.png..."
    mkdir -p AppIcon.iconset
    sips -z 16 16 Resources/Assets/icon.png --out AppIcon.iconset/icon_16x16.png 2>/dev/null
    sips -z 32 32 Resources/Assets/icon.png --out AppIcon.iconset/icon_16x16@2x.png 2>/dev/null
    sips -z 32 32 Resources/Assets/icon.png --out AppIcon.iconset/icon_32x32.png 2>/dev/null
    sips -z 64 64 Resources/Assets/icon.png --out AppIcon.iconset/icon_32x32@2x.png 2>/dev/null
    sips -z 128 128 Resources/Assets/icon.png --out AppIcon.iconset/icon_128x128.png 2>/dev/null
    sips -z 256 256 Resources/Assets/icon.png --out AppIcon.iconset/icon_128x128@2x.png 2>/dev/null
    sips -z 256 256 Resources/Assets/icon.png --out AppIcon.iconset/icon_256x256.png 2>/dev/null
    sips -z 512 512 Resources/Assets/icon.png --out AppIcon.iconset/icon_256x256@2x.png 2>/dev/null
    sips -z 512 512 Resources/Assets/icon.png --out AppIcon.iconset/icon_512x512.png 2>/dev/null
    sips -z 1024 1024 Resources/Assets/icon.png --out AppIcon.iconset/icon_512x512@2x.png 2>/dev/null
    iconutil -c icns AppIcon.iconset -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    rm -rf AppIcon.iconset
    echo "  App icon: AppIcon.icns (generated)"
fi

# Set permissions
chmod +x "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}"
chmod -R 755 "${APP_BUNDLE}"

# Sign the app with ad-hoc signature and specific identifier
# The --identifier flag helps create a more stable signature
echo "[4/6] Signing app..."
codesign --deep --force --sign - \
    --identifier "com.penai.PenLite" \
    --options runtime \
    "${APP_BUNDLE}"
echo "  Signed with ad-hoc signature (identifier: com.penai.PenLite)"

# Create DMG
echo "[5/6] Creating DMG installer..."
mkdir -p dmg_temp
cp -R "${APP_BUNDLE}" dmg_temp/
ln -s /Applications dmg_temp/Applications
cp README-install.txt dmg_temp/README.txt 2>/dev/null || true

hdiutil create -volname "${APP_NAME}" \
    -srcfolder dmg_temp \
    -ov -format UDZO \
    "${APP_NAME}-${VERSION}.dmg"

rm -rf dmg_temp

# Create ZIP
echo "[6/6] Creating ZIP archive..."
ditto -c -k --keepParent "${APP_BUNDLE}" "${APP_NAME}-${VERSION}.zip"

echo ""
echo "✅ Build complete!"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Files created:"
echo "  • ${APP_NAME}-${VERSION}.dmg ($(du -h "${APP_NAME}-${VERSION}.dmg" | cut -f1))"
echo "  • ${APP_NAME}-${VERSION}.zip ($(du -h "${APP_NAME}-${VERSION}.zip" | cut -f1))"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "⚠️  IMPORTANT: Accessibility Permissions"
echo ""
echo "   Ad-hoc signed apps have UNSTABLE signatures."
echo "   macOS may forget accessibility permissions between launches."
echo ""
echo "   SOLUTION: Join Apple Developer Program (\$99/year) for"
echo "   a stable Developer ID signature."
echo ""
echo "   WORKAROUND for free distribution:"
echo "   1. After installing, go to:"
echo "      System Settings → Privacy & Security → Accessibility"
echo "   2. Remove Pen from the list (if present)"
echo "   3. Launch Pen (Right-click → Open)"
echo "   4. When prompted, grant accessibility permission"
echo "   5. The permission should now persist"
echo ""
