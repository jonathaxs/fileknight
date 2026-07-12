#!/usr/bin/env bash
# Gera os pacotes .deb (Ubuntu/Debian) e .rpm (Fedora) do FileKnight usando o fpm.
#
# Pré-requisitos:
#   1. flutter build linux --release   (deixa o app em build/linux/x64/release/bundle)
#   2. fpm instalado  (gem install fpm) + rpmbuild disponível para o alvo .rpm
#
# Uso:
#   packaging/linux/build_packages.sh [versao]
# Sem argumento, a versão é lida do pubspec.yaml.
set -euo pipefail

APP_ID="io.github.jonathaxs.fileknight"
APP_NAME="fileknight"

here="$(cd "$(dirname "$0")" && pwd)"   # packaging/linux
project="$(cd "$here/../.." && pwd)"    # fileknight_flutter
bundle="$project/build/linux/x64/release/bundle"
dist="$project/dist"

# Versão: 1º argumento, ou extraída do pubspec (version: X.Y.Z+N -> X.Y.Z).
version="${1:-$(grep '^version:' "$project/pubspec.yaml" | sed -E 's/version:[[:space:]]*([0-9.]+).*/\1/')}"

if [ ! -d "$bundle" ]; then
  echo "Bundle não encontrado em $bundle." >&2
  echo "Rode antes: flutter build linux --release" >&2
  exit 1
fi

# Monta a árvore de instalação num diretório temporário (staging).
staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

# O app inteiro vai para /usr/lib/fileknight; um wrapper em /usr/bin o coloca no PATH.
install -d "$staging/usr/lib/$APP_NAME"
cp -r "$bundle/." "$staging/usr/lib/$APP_NAME/"

install -d "$staging/usr/bin"
cat > "$staging/usr/bin/$APP_NAME" <<EOF
#!/bin/sh
exec /usr/lib/$APP_NAME/$APP_NAME "\$@"
EOF
chmod 755 "$staging/usr/bin/$APP_NAME"

# Integração com o desktop: atalho, ícone e metadados AppStream.
install -Dm644 "$here/$APP_ID.desktop" "$staging/usr/share/applications/$APP_ID.desktop"
install -Dm644 "$here/$APP_ID.png" "$staging/usr/share/icons/hicolor/512x512/apps/$APP_ID.png"
install -Dm644 "$here/$APP_ID.metainfo.xml" "$staging/usr/share/metainfo/$APP_ID.metainfo.xml"

mkdir -p "$dist"

# Argumentos comuns aos dois formatos.
common_args=(
  -s dir
  -C "$staging"
  --name "$APP_NAME"
  --version "$version"
  --license "MIT"
  --maintainer "jonathaxs"
  --url "https://github.com/jonathaxs/fileknight"
  --description "FileKnight protege seus arquivos de serem perdidos."
  --vendor "jonathaxs"
  usr
)

# .deb (nomes de dependência do Debian/Ubuntu).
fpm -t deb -f -p "$dist/${APP_NAME}_${version}_amd64.deb" \
  --depends "libgtk-3-0" \
  --depends "libayatana-appindicator3-1" \
  "${common_args[@]}"

# .rpm (nomes de dependência do Fedora).
fpm -t rpm -f -p "$dist/${APP_NAME}-${version}-1.x86_64.rpm" \
  --depends "gtk3" \
  --depends "libappindicator-gtk3" \
  "${common_args[@]}"

echo "Pacotes gerados em $dist:"
ls -1 "$dist"/*.deb "$dist"/*.rpm
