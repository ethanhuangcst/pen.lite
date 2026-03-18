#!/bin/bash

# Build script for creating Pen.app with stable self-signed certificate
# Run setup-certificate.sh FIRST to create the certificate

set -e

echo "=========================================="
echo "Building Pen for Distribution (Signed)"
echo "=========================================="

# Configuration
APP_NAME="Pen"
VERSION="1.1.0"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
CERT_NAME="${CERT_NAME:-}"

# Check if signing identity exists
echo "[0/6] Checking for signing identity..."
if [ -z "$CERT_NAME" ]; then
    CERT_NAME=$(security find-identity -v -p codesigning 2>/dev/null | sed -n 's/.*"Developer ID Application: \(.*\)"/Developer ID Application: \1/p' | head -n 1)
fi

if [ -z "$CERT_NAME" ]; then
    CERT_NAME="Pen Developer"
fi

if ! security find-identity -v -p codesigning 2>/dev/null | grep -q "$CERT_NAME"; then
    echo ""
    echo "❌ Signing identity '$CERT_NAME' not found!"
    echo ""
    echo "Install a valid Developer ID Application certificate in Keychain."
    echo "Or create a local self-signed certificate with:"
    echo "  CERT_NAME='Pen Developer' ./setup-certificate.sh"
    echo ""
    exit 1
fi
echo "  Found signing identity: $CERT_NAME"

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
cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Copy Info.plist
cp Info.plist "${APP_BUNDLE}/Contents/Info.plist"

# Update Info.plist with actual values
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable ${APP_NAME}" "${APP_BUNDLE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleName ${APP_NAME}" "${APP_BUNDLE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.penai.${APP_NAME}" "${APP_BUNDLE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "${APP_BUNDLE}/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${VERSION}" "${APP_BUNDLE}/Contents/Info.plist"

# Copy resources
cp -R Resources/Assets "${APP_BUNDLE}/Contents/Resources/"
cp -R Resources/config "${APP_BUNDLE}/Contents/Resources/" 2>/dev/null || true
cp -R Resources/en.lproj "${APP_BUNDLE}/Contents/Resources/" 2>/dev/null || true
cp -R Resources/zh-Hans.lproj "${APP_BUNDLE}/Contents/Resources/" 2>/dev/null || true

# Copy app icon
if [ -f "Resources/Assets/AppIcon.icns" ]; then
    cp Resources/Assets/AppIcon.icns "${APP_BUNDLE}/Contents/Resources/"
    echo "  App icon: AppIcon.icns"
elif [ -f "Resources/Assets/logo.png" ]; then
    echo "  Generating AppIcon.icns from logo.png..."
    mkdir -p Pen.iconset
    sips -z 16 16 Resources/Assets/logo.png --out Pen.iconset/icon_16x16.png 2>/dev/null
    sips -z 32 32 Resources/Assets/logo.png --out Pen.iconset/icon_16x16@2x.png 2>/dev/null
    sips -z 32 32 Resources/Assets/logo.png --out Pen.iconset/icon_32x32.png 2>/dev/null
    sips -z 64 64 Resources/Assets/logo.png --out Pen.iconset/icon_32x32@2x.png 2>/dev/null
    sips -z 128 128 Resources/Assets/logo.png --out Pen.iconset/icon_128x128.png 2>/dev/null
    sips -z 256 256 Resources/Assets/logo.png --out Pen.iconset/icon_128x128@2x.png 2>/dev/null
    sips -z 256 256 Resources/Assets/logo.png --out Pen.iconset/icon_256x256.png 2>/dev/null
    sips -z 512 512 Resources/Assets/logo.png --out Pen.iconset/icon_256x256@2x.png 2>/dev/null
    sips -z 512 512 Resources/Assets/logo.png --out Pen.iconset/icon_512x512.png 2>/dev/null
    sips -z 1024 1024 Resources/Assets/logo.png --out Pen.iconset/icon_512x512@2x.png 2>/dev/null
    iconutil -c icns Pen.iconset -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    rm -rf Pen.iconset
    echo "  App icon: AppIcon.icns (generated from logo.png)"
elif [ -f "Resources/Assets/icon.png" ]; then
    echo "  Generating AppIcon.icns from icon.png..."
    mkdir -p Pen.iconset
    sips -z 16 16 Resources/Assets/icon.png --out Pen.iconset/icon_16x16.png 2>/dev/null
    sips -z 32 32 Resources/Assets/icon.png --out Pen.iconset/icon_16x16@2x.png 2>/dev/null
    sips -z 32 32 Resources/Assets/icon.png --out Pen.iconset/icon_32x32.png 2>/dev/null
    sips -z 64 64 Resources/Assets/icon.png --out Pen.iconset/icon_32x32@2x.png 2>/dev/null
    sips -z 128 128 Resources/Assets/icon.png --out Pen.iconset/icon_128x128.png 2>/dev/null
    sips -z 256 256 Resources/Assets/icon.png --out Pen.iconset/icon_128x128@2x.png 2>/dev/null
    sips -z 256 256 Resources/Assets/icon.png --out Pen.iconset/icon_256x256.png 2>/dev/null
    sips -z 512 512 Resources/Assets/icon.png --out Pen.iconset/icon_256x256@2x.png 2>/dev/null
    sips -z 512 512 Resources/Assets/icon.png --out Pen.iconset/icon_512x512.png 2>/dev/null
    sips -z 1024 1024 Resources/Assets/icon.png --out Pen.iconset/icon_512x512@2x.png 2>/dev/null
    iconutil -c icns Pen.iconset -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
    rm -rf Pen.iconset
    echo "  App icon: AppIcon.icns (generated)"
fi

# Set permissions
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
chmod -R 755 "${APP_BUNDLE}"

# Sign app bundle
echo "[4/6] Signing app with stable certificate..."
codesign --deep --force --sign "$CERT_NAME" \
    --identifier "com.penai.Pen" \
    --options runtime \
    "${APP_BUNDLE}"
echo "  Signed with: $CERT_NAME (STABLE)"

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
echo "✅ App is signed with a stable identity"
echo ""
echo "   Accessibility permissions will PERSIST across launches!"
echo ""
echo "   First-time installation:"
echo "   1. Open the DMG"
echo "   2. Drag Pen.app to Applications"
echo "   3. Right-click Pen.app → Open → Open"
echo "   4. Grant Accessibility permission when prompted"
echo "   5. Permissions will be remembered!"
echo ""
