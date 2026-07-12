#!/usr/bin/env bash
# Gera o .zip do FileKnight para macOS: o app compilado (FileKnight.app) mais um
# guia curto de como autorizar a abertura (o app não é assinado pela Apple).
#
# Pré-requisitos: Flutter + Xcode instalados.
# Uso:
#   packaging/macos/build_zip.sh
set -euo pipefail

APP_NAME="FileKnight"

here="$(cd "$(dirname "$0")" && pwd)"   # packaging/macos
project="$(cd "$here/../.." && pwd)"    # fileknight_flutter
dist="$project/dist"
app_build="$project/build/macos/Build/Products/Release/$APP_NAME.app"

version="$(grep '^version:' "$project/pubspec.yaml" | sed -E 's/version:[[:space:]]*([0-9.]+).*/\1/')"

# Compila o app de release.
( cd "$project" && flutter build macos --release )

if [ ! -d "$app_build" ]; then
  echo "App não encontrado em $app_build" >&2
  exit 1
fi

# Assinatura ad-hoc: evita o "app está danificado" ao abrir um app sem Developer ID.
codesign --force --deep --sign - "$app_build"

# Monta a pasta do zip: o .app + os guias de abertura.
staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT
foldername="$APP_NAME-$version-macos"
mkdir -p "$staging/$foldername"
cp -R "$app_build" "$staging/$foldername/"
cp "$here/COMO-ABRIR-NO-MAC.txt" "$staging/$foldername/"
cp "$here/HOW-TO-OPEN-ON-MAC.txt" "$staging/$foldername/"

mkdir -p "$dist"
out="$dist/$APP_NAME-$version-macos.zip"
rm -f "$out"
# -y preserva os symlinks internos do .app (frameworks), senão ele incha/quebra.
( cd "$staging" && zip -r -q -y "$out" "$foldername" )

echo "Zip gerado: $out"
