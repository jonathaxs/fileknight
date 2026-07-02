#!/usr/bin/env bash
# Gera o .dmg de instalação (arrastar para o Applications) do FileKnight (macOS).
# Rode a partir da raiz do projeto fileknight_flutter: packaging/macos/build_dmg.sh
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
