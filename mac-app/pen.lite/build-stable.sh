#!/bin/bash

# Build script for creating Pen.app bundle with stable self-signed certificate
# This creates a STABLE signature so accessibility permissions persist

set -e

echo "=========================================="
echo "Building Pen for Distribution"
echo "=========================================="

# Configuration
APP_NAME="Pen"
VERSION="1.1.0"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
CERT_NAME="Pen Self-Signed"

# Check if self-signed certificate exists
echo "[0/6] Checking for self-signed certificate..."
if ! security find-identity -v -p codesigning | grep -q "$CERT_NAME"; then
    echo ""
    echo "⚠️  Self-signed certificate not found!"
    echo ""
    echo "Creating a self-signed certificate for stable signing..."
    echo ""
    
    # Create self-signed certificate
    # This certificate will be used to sign the app consistently
    openssl req -x509 -newkey rsa:2048 -keyout /tmp/pen-key.pem -out /tmp/pen-cert.pem \
        -days 3650 -nodes -subj "/CN=$CERT_NAME" 2>/dev/null
    
    # Convert to PKCS12 format for Keychain
    openssl pkcs12 -export -out /tmp/pen-cert.p12 \
        -inkey /tmp/pen-key.pem -in /tmp/pen-cert.pem \
        -passout pass:"" 2>/dev/null
    
    # Import into Keychain
    security import /tmp/pen-cert.p12 -k ~/Library/Keychains/login.keychain-db \
        -P "" -T /usr/bin/codesign 2>/dev/null || true
    
    # Clean up temp files
    rm -f /tmp/pen-key.pem /tmp/pen-cert.pem /tmp/pen-cert.p12
    
    # Set trust settings for the certificate
    security add-trusted-cert -r trustAsRoot -k ~/Library/Keychains/login.keychain-db \
        /tmp/pen-cert.pem 2>/dev/null || true
    
    echo "✅ Self-signed certificate created: '$CERT_NAME'"
    echo ""
fi

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

# Copy app icon (try both possible locations)
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
    # Generate icns from png if needed
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

# Sign the app with self-signed certificate (stable signature)
echo "[4/6] Signing app with stable certificate..."
codesign --deep --force --sign "$CERT_NAME" "${APP_BUNDLE}"
echo "  Signed with: $CERT_NAME"

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
echo "ℹ️  App is signed with self-signed certificate (free, stable)"
echo ""
echo "   IMPORTANT: After first install, you need to:"
echo "   1. Right-click Pen.app → Open → Open"
echo "   2. Go to System Settings → Privacy & Security → Accessibility"
echo "   3. Enable Pen in the list"
echo ""
echo "   The signature is STABLE, so permissions will persist across updates!"
echo ""
