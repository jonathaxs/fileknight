#!/usr/bin/env bash
# Build a drag-to-install .dmg for FileKnight (macOS).
# Run from the fileknight_flutter project root: packaging/macos/build_dmg.sh
set -euo pipefail

version="$(grep '^version:' pubspec.yaml | sed 's/version: //; s/+.*//')"
app="build/macos/Build/Products/Release/FileKnight.app"
out="dist/FileKnight-${version}-macos.dmg"

flutter build macos --release

rm -rf dist/staging "$out"
mkdir -p dist/staging
cp -R "$app" dist/staging/
ln -s /Applications dist/staging/Applications
hdiutil create -volname "FileKnight" -srcfolder dist/staging -ov -format UDZO "$out"
rm -rf dist/staging

echo "Created $out"
