#!/bin/bash
set -euo pipefail

# ShowTracker Release Script
# Usage: ./scripts/release.sh
# Prerequisites: Sparkle EdDSA private key in Keychain (run generate_keys first)

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
SITE_DIR="$PROJECT_ROOT/docs"
SCHEME="ShowTracker"

# Find Sparkle CLI tools dynamically (DerivedData hash can change)
SPARKLE_BIN=$(find ~/Library/Developer/Xcode/DerivedData -path "*/artifacts/sparkle/Sparkle/bin" -type d 2>/dev/null | head -1)
if [ -z "$SPARKLE_BIN" ]; then
    echo "Error: Sparkle CLI tools not found. Build the project in Xcode first to resolve SPM packages."
    exit 1
fi
echo "Using Sparkle tools: $SPARKLE_BIN"

# Get version from project.yml
VERSION=$(grep 'MARKETING_VERSION:' "$PROJECT_ROOT/project.yml" | awk '{print $2}')
BUILD_NUM=$(grep 'CURRENT_PROJECT_VERSION:' "$PROJECT_ROOT/project.yml" | awk '{print $2}')
DMG_NAME="ShowTracker-${VERSION}.dmg"

echo ""
echo "=== Building ShowTracker v${VERSION} (build ${BUILD_NUM}) ==="
echo ""

# Step 1: Regenerate Xcode project
echo "--- Generating Xcode project ---"
cd "$PROJECT_ROOT"
xcodegen generate

# Step 2: Build Release configuration
echo "--- Building Release ---"
xcodebuild -project "$PROJECT_ROOT/ShowTracker.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    clean build

# Step 3: Stage app for DMG
APP_PATH="$BUILD_DIR/DerivedData/Build/Products/Release/ShowTracker.app"
if [ ! -d "$APP_PATH" ]; then
    echo "Error: Built app not found at $APP_PATH"
    exit 1
fi

STAGING_DIR="$BUILD_DIR/dmg-staging"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

# Step 4: Create DMG
echo "--- Creating DMG ---"
DMG_PATH="$BUILD_DIR/$DMG_NAME"
rm -f "$DMG_PATH"
hdiutil create -volname "ShowTracker" \
    -srcfolder "$STAGING_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

# Step 5: Sign the DMG with EdDSA (reads private key from Keychain)
echo "--- Signing DMG with EdDSA ---"
"$SPARKLE_BIN/sign_update" "$DMG_PATH"

# Step 6: Copy DMG to site directory for GitHub Pages hosting
echo "--- Copying DMG to docs/ ---"
mkdir -p "$SITE_DIR"
cp "$DMG_PATH" "$SITE_DIR/$DMG_NAME"

# Step 7: Generate/update appcast.xml
echo "--- Generating appcast.xml ---"
"$SPARKLE_BIN/generate_appcast" "$SITE_DIR" \
    --download-url-prefix "https://owldesign.github.io/ShowTracker/"

echo ""
echo "=== Release v${VERSION} ready ==="
echo ""
echo "Files:"
echo "  DMG:     $SITE_DIR/$DMG_NAME"
echo "  Appcast: $SITE_DIR/appcast.xml"
echo ""
echo "Next steps:"
echo "  1. git add docs/appcast.xml docs/$DMG_NAME"
echo "  2. git commit -m 'Release v${VERSION}'"
echo "  3. git tag v${VERSION}"
echo "  4. git push origin main --tags"
