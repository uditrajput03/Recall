#!/bin/bash
set -e

# Version handling (defaults to 1.0.0, strips leading 'v' or 'V' if passed e.g. v1.2.3 / V1.2.3 -> 1.2.3)
RAW_VERSION="${1:-1.0.0}"
VERSION="${RAW_VERSION#[vV]}"

# Check for --package flag in any argument position
PACKAGE_FLAG=false
for arg in "$@"; do
    if [ "$arg" == "--package" ]; then
        PACKAGE_FLAG=true
    fi
done

APP_NAME="Recall"
BUNDLE_DIR="$APP_NAME.app"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🔨 Building $APP_NAME in release mode (Universal: arm64 + x86_64)..."
if swift build -c release --arch arm64 --arch x86_64; then
    BINARY_PATH=".build/apple/Products/Release/$APP_NAME"
    echo "✅ Universal binary built successfully."
else
    echo "⚠️ Universal build not supported or failed; falling back to native architecture build..."
    swift build -c release
    BINARY_PATH=".build/release/$APP_NAME"
fi

if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ Binary not found at $BINARY_PATH"
    exit 1
fi

echo "📦 Creating macOS App Bundle ($BUNDLE_DIR)..."
rm -rf "$BUNDLE_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp "$BINARY_PATH" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

# Copy official AppIcon if present
if [ -f "Resources/AppIcon.icns" ]; then
    echo "🎨 Bundling official AppIcon.icns..."
    cp "Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
fi

# Create Info.plist (LSUIElement=true ensures it runs strictly as a menu bar app)
cat << EOF > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Recall</string>
    <key>CFBundleIdentifier</key>
    <string>com.recall.app</string>
    <key>CFBundleName</key>
    <string>Recall</string>
    <key>CFBundleDisplayName</key>
    <string>Recall</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "🔐 Applying ad-hoc code signature..."
codesign --force --deep --sign - "$BUNDLE_DIR"
codesign -v "$BUNDLE_DIR"

echo "✅ App bundle created and signed at $BUNDLE_DIR (Version: ${VERSION})"

if [ "$PACKAGE_FLAG" = true ]; then
    DIST_DIR="dist"
    mkdir -p "$DIST_DIR"

    ZIP_NAME="Recall-${VERSION}-macOS.zip"
    DMG_NAME="Recall-${VERSION}-macOS.dmg"

    echo "📦 Packaging $ZIP_NAME..."
    rm -f "$DIST_DIR/$ZIP_NAME"
    ditto -c -k --sequesterRsrc --keepParent "$BUNDLE_DIR" "$DIST_DIR/$ZIP_NAME"

    echo "💿 Creating $DMG_NAME..."
    rm -f "$DIST_DIR/$DMG_NAME"
    DMG_STAGING="$(mktemp -d -t recall-dmg-XXXXXX)"
    cp -R "$BUNDLE_DIR" "$DMG_STAGING/"
    ln -s /Applications "$DMG_STAGING/Applications"
    hdiutil create -volname "Recall" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DIST_DIR/$DMG_NAME" > /dev/null
    rm -rf "$DMG_STAGING"

    echo "🔐 Generating checksums..."
    (cd "$DIST_DIR" && shasum -a 256 "$ZIP_NAME" "$DMG_NAME" > checksums.txt)

    echo "🎉 Release distribution files generated in $DIST_DIR/:"
    ls -lh "$DIST_DIR"
fi
