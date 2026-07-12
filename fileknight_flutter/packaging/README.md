# Empacotamento do FileKnight

App id: `io.github.jonathaxs.fileknight`.

Os instaladores são gerados automaticamente pelo **GitHub Actions**
([`.github/workflows/release.yml`](../../.github/workflows/release.yml)). Ao
criar uma tag `vX.Y.Z`, o workflow builda as 3 plataformas e publica os arquivos
num **release rascunho** (revise e publique).

| Plataforma | Arquivo                              | Como |
| ---------- | ------------------------------------ | ---- |
| Windows    | `.exe` (Inno Setup, x64)             | `flutter build windows` + `fileknight.iss` |
| Linux      | `.deb`, `.rpm` e `.AppImage` (x64)   | `flutter build linux` + `build_packages.sh` (fpm + appimagetool) |
| macOS      | `.app` compilado dentro de um `.zip` | `flutter build macos` + `build_zip.sh` |

## Como disparar um release

```sh
# a partir de uma versão pronta (ajuste a version: no pubspec.yaml antes):
git tag v0.2.0
git push origin v0.2.0
```

Ou manualmente em **Actions > Release > Run workflow**. Ao terminar, os arquivos
ficam nos _assets_ do release em rascunho.

## Rodar os scripts localmente (opcional)

Cada script empacota o que já foi buildado no próprio sistema:

- **Linux** (ex.: Bazzite): `flutter build linux --release` e depois
  `packaging/linux/build_packages.sh`. Gera `.deb`, `.rpm` e `.AppImage`. Precisa
  do `fpm` (`gem install fpm`), do `rpmbuild` (para o `.rpm`) e do `appimagetool`
  (o script baixa a versão contínua se não estiver no PATH).
- **Windows**: `flutter build windows --release`, instale o
  [Inno Setup](https://jrsoftware.org/isinfo.php) e compile
  `packaging/windows/fileknight.iss` (a versão pode vir por
  `ISCC.exe /DAppVersion=0.2.0`).
- **macOS**: `packaging/macos/build_zip.sh` compila o app (`flutter build macos`),
  assina ad-hoc e gera `dist/FileKnight-<versão>-macos.zip` com o `FileKnight.app`
  e os guias `COMO-ABRIR-NO-MAC.txt` / `HOW-TO-OPEN-ON-MAC.txt`.

## Notas de assinatura

- **macOS**: o `.app` sai com assinatura **ad-hoc** (sem Developer ID nem
  notarização). Na primeira abertura o macOS bloqueia; o guia no `.zip` explica
  como autorizar em Ajustes > Privacidade e Segurança. Para abrir sem aviso
  seria preciso assinar com Developer ID e notarizar (conta Apple Developer).
- **Windows**: o `.exe` sai sem assinatura (o SmartScreen mostra um aviso, mas
  instala). Assinar exige um certificado de code signing pago.

## TODO antes de um release público

- Adicionar um arquivo `LICENSE` e confirmar o id SPDX no metainfo do Linux.
- Linux: adicionar screenshots ao metainfo AppStream (caso vá para o Flathub).
