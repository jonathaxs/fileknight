# Empacotamento do FileKnight

App id: `io.github.jonathaxs.fileknight`.

Os instaladores são gerados automaticamente pelo **GitHub Actions**
([`.github/workflows/release.yml`](../../.github/workflows/release.yml)). Ao
criar uma tag `vX.Y.Z`, o workflow builda as 3 plataformas e publica os arquivos
num **release rascunho** (revise e publique).

| Plataforma | Arquivo                              | Como |
| ---------- | ------------------------------------ | ---- |
| Windows    | `.exe` (Inno Setup, x64)             | `flutter build windows` + `fileknight.iss` |
| Linux      | `.deb` e `.rpm` (x64)                | `flutter build linux` + `build_packages.sh` (fpm) |
| macOS      | `.zip` do código-fonte + guia        | `build_zip.sh` (roda a partir do código) |

## Como disparar um release

```sh
# a partir de uma versão pronta (ajuste a version: no pubspec.yaml antes):
git tag v0.1.0
git push origin v0.1.0
```

Ou manualmente em **Actions > Release > Run workflow**. Ao terminar, os arquivos
ficam nos _assets_ do release em rascunho.

## Rodar os scripts localmente (opcional)

Cada script empacota o que já foi buildado no próprio sistema:

- **Linux** (ex.: Bazzite): `flutter build linux --release` e depois
  `packaging/linux/build_packages.sh`. Precisa do `fpm` (`gem install fpm`) e,
  para o `.rpm`, do `rpmbuild`.
- **Windows**: `flutter build windows --release`, instale o
  [Inno Setup](https://jrsoftware.org/isinfo.php) e compile
  `packaging/windows/fileknight.iss` (a versão pode vir por
  `ISCC.exe /DAppVersion=0.1.0`).
- **macOS**: `packaging/macos/build_zip.sh` (usa `git archive`, então empacota o
  que está commitado). Gera `dist/FileKnight-<versão>-macos.zip` com o código e
  os guias `COMO-RODAR-NO-MAC.txt` / `HOW-TO-RUN-ON-MAC.txt`.

## Notas de assinatura

- **macOS**: distribuímos o código-fonte (o dono do Mac é o desenvolvedor), então
  não há app assinado nem notarização. O guia no `.zip` explica como rodar.
- **Windows**: o `.exe` sai sem assinatura (o SmartScreen mostra um aviso, mas
  instala). Assinar exige um certificado de code signing pago.

## TODO antes de um release público

- Adicionar um arquivo `LICENSE` e confirmar o id SPDX no metainfo do Linux.
- Linux: adicionar screenshots ao metainfo AppStream (caso vá para o Flathub).
