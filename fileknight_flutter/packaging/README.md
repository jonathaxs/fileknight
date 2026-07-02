# Empacotamento do FileKnight

Cada plataforma é compilada no próprio sistema operacional dela.
App id: `io.github.jonathaxs.fileknight`.

## macOS — `.dmg` (compilar no Mac)

```
cd fileknight_flutter
packaging/macos/build_dmg.sh
```

Gera `dist/FileKnight-<versão>-macos.dmg` (arrastar para o Applications).

O app sai com **assinatura ad-hoc, sem notarização**. Em outros Macs, o
Gatekeeper avisa na primeira abertura — o usuário contorna com botão direito →
Abrir. Para distribuir sem avisos é preciso uma conta Apple Developer
(~US$99/ano) para assinar com Developer ID e notarizar.

## Windows — instalador `.exe` (compilar no Windows)

1. Instale o Flutter e o Visual Studio (com o workload "Desktop development with C++").
2. `flutter build windows --release`
3. Instale o Inno Setup: https://jrsoftware.org/isinfo.php
4. Abra `packaging/windows/fileknight.iss` no Inno Setup e compile.
   Saída: `dist/FileKnight-<versão>-windows-setup.exe`.

(Opcional: um certificado de code signing remove o aviso do SmartScreen.)

## Linux — `.flatpak` (compilar no Linux, ex.: Bazzite)

1. `flutter build linux --release`
2. Copie o bundle compilado para o lado do manifesto:
   ```
   cp -r build/linux/x64/release/bundle packaging/linux/bundle
   ```
3. Instale o runtime e faça o build:
   ```
   flatpak install flathub org.freedesktop.Platform//24.08 org.freedesktop.Sdk//24.08
   flatpak-builder --force-clean --user --install build-dir \
     packaging/linux/io.github.jonathaxs.fileknight.yml
   ```
4. Para gerar um único `.flatpak` compartilhável:
   ```
   flatpak-builder --repo=repo --force-clean build-dir \
     packaging/linux/io.github.jonathaxs.fileknight.yml
   flatpak build-bundle repo FileKnight.flatpak io.github.jonathaxs.fileknight
   ```

Este manifesto é um ponto de partida — pode ser preciso ajustar a versão do
runtime no Bazzite.

## TODO antes de um release público

- Adicionar um arquivo `LICENSE` e definir o id SPDX real no metainfo do Linux.
- macOS: assinatura Developer ID + notarização.
- Linux: adicionar screenshots ao metainfo AppStream para o Flathub.
- Subir a `version:` no `pubspec.yaml` a cada release.
