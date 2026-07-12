#!/usr/bin/env bash
# Gera o .zip do FileKnight para macOS: o código-fonte do projeto Flutter mais
# os guias COMO-RODAR-NO-MAC.txt / HOW-TO-RUN-ON-MAC.txt na raiz da pasta.
#
# No Mac não distribuímos um app pronto (evita a notarização paga da Apple): o
# usuário extrai o zip e roda o app a partir do código, seguindo o guia.
#
# Usa `git archive`, então empacota apenas o que está COMMITADO (build/,
# .dart_tool/, dist/ etc. ficam de fora automaticamente). Commite antes de rodar.
#
# Uso:
#   packaging/macos/build_zip.sh
set -euo pipefail

APP_NAME="FileKnight"

here="$(cd "$(dirname "$0")" && pwd)"   # packaging/macos
project="$(cd "$here/../.." && pwd)"    # fileknight_flutter
gitroot="$(git -C "$project" rev-parse --show-toplevel)"
subdir="$(git -C "$project" rev-parse --show-prefix)"  # ex.: fileknight_flutter/
subdir="${subdir%/}"
dist="$project/dist"

version="$(grep '^version:' "$project/pubspec.yaml" | sed -E 's/version:[[:space:]]*([0-9.]+).*/\1/')"
foldername="${APP_NAME}-${version}-macos-source"

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

# Exporta só os arquivos versionados do projeto para uma pasta limpa.
mkdir -p "$staging/$foldername"
git -C "$gitroot" archive "HEAD:$subdir" | tar -x -C "$staging/$foldername"

# Deixa os guias visíveis já na raiz da pasta extraída.
cp "$here/COMO-RODAR-NO-MAC.txt" "$staging/$foldername/"
cp "$here/HOW-TO-RUN-ON-MAC.txt" "$staging/$foldername/"

mkdir -p "$dist"
out="$dist/${APP_NAME}-${version}-macos.zip"
rm -f "$out"
( cd "$staging" && zip -r -q "$out" "$foldername" )

echo "Zip gerado: $out"
