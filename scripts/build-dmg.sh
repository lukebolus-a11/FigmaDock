#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "→ Generating Xcode project..."
xcodegen generate

echo "→ Building release..."
xcodebuild -project FigmaDock.xcodeproj -scheme FigmaDock -configuration Release \
  clean build CONFIGURATION_BUILD_DIR="$(pwd)/build/Release" 2>&1 | grep -E "(BUILD|error:)"

echo "→ Staging DMG..."
rm -rf build/dmg-staging
mkdir -p build/dmg-staging
cp -R build/Release/FigmaDock.app build/dmg-staging/
ln -s /Applications build/dmg-staging/Applications

echo "→ Creating DMG..."
rm -f build/FigmaDock.dmg
hdiutil create -volname "FigmaDock" -srcfolder build/dmg-staging -ov -format UDZO build/FigmaDock.dmg

echo "✓ DMG created at build/FigmaDock.dmg"
echo "  Size: $(du -h build/FigmaDock.dmg | cut -f1)"
open build/
