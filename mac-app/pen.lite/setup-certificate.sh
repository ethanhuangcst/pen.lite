#!/bin/bash

# Setup script to create a self-signed certificate for Pen
# This creates a STABLE signature so accessibility permissions persist
# Run this ONCE to set up the certificate

set -e

CERT_NAME="${CERT_NAME:-Pen Developer}"

echo "=========================================="
echo "Setting up Self-Signed Certificate for Pen"
echo "=========================================="
echo ""

# Check if certificate already exists
if security find-identity -v -p codesigning 2>/dev/null | grep -q "$CERT_NAME"; then
    echo "✅ Certificate '$CERT_NAME' already exists!"
    echo ""
    echo "You can now build with: ./build-signed.sh"
    exit 0
fi

echo "Creating self-signed certificate..."
echo ""
echo "This will create a certificate named '$CERT_NAME' in your keychain."
echo "You may be prompted for your password."
echo ""

# Create certificate using openssl
openssl req -x509 -newkey rsa:2048 -keyout /tmp/pen-key.pem -out /tmp/pen-cert.pem \
    -days 3650 -nodes -subj "/CN=$CERT_NAME/O=Pen AI/C=US" 2>/dev/null

# Convert to DER format for macOS
openssl x509 -outform DER -in /tmp/pen-cert.pem -out /tmp/pen-cert.der 2>/dev/null

# Add to keychain as trusted
echo ""
echo "Adding certificate to keychain..."
echo "Please click 'Always Trust' if prompted."
echo ""

# Import the certificate
security add-trusted-cert -r trustAsRoot -k ~/Library/Keychains/login.keychain-db /tmp/pen-cert.der 2>/dev/null || {
    echo ""
    echo "⚠️  Could not add certificate automatically."
    echo ""
    echo "Manual steps:"
    echo "1. Open Keychain Access app"
    echo "2. Drag /tmp/pen-cert.der to 'My Certificates'"
    echo "3. Double-click the certificate"
    echo "4. Set 'Code Signing' to 'Always Trust'"
    echo ""
}

# Create PKCS12 for codesign
openssl pkcs12 -export -out /tmp/pen-cert.p12 \
    -inkey /tmp/pen-key.pem -in /tmp/pen-cert.pem \
    -name "$CERT_NAME" -passout pass:"" 2>/dev/null

# Import PKCS12
security import /tmp/pen-cert.p12 -k ~/Library/Keychains/login.keychain-db \
    -P "" -T /usr/bin/codesign 2>/dev/null || true

# Clean up
rm -f /tmp/pen-key.pem /tmp/pen-cert.pem /tmp/pen-cert.der /tmp/pen-cert.p12

if ! security find-identity -v -p codesigning 2>/dev/null | grep -q "$CERT_NAME"; then
    echo ""
    echo "❌ Certificate '$CERT_NAME' was not imported as a valid signing identity."
    echo ""
    echo "Open Keychain Access and ensure the certificate + private key exist in login keychain."
    echo "Then run this script again."
    echo ""
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Certificate '$CERT_NAME' created successfully!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Now run: ./build-signed.sh"
echo ""
