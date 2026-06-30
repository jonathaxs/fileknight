# Packaging FileKnight

Each platform is built on its own OS. App id: `io.github.jonathaxs.fileknight`.

## macOS — `.dmg` (build on Mac)

```
cd fileknight_flutter
packaging/macos/build_dmg.sh
```

Produces `dist/FileKnight-<version>-macos.dmg` (drag onto Applications).

The app is **ad-hoc signed, not notarized**. On other Macs, Gatekeeper warns on
first launch — users right-click → Open. To distribute without warnings you need
an Apple Developer account (~US$99/yr) to sign with a Developer ID and notarize.

## Windows — `.exe` installer (build on Windows)

1. Install Flutter and Visual Studio (with the "Desktop development with C++" workload).
2. `flutter build windows --release`
3. Install Inno Setup: https://jrsoftware.org/isinfo.php
4. Open `packaging/windows/fileknight.iss` in Inno Setup and compile.
   Output: `dist/FileKnight-<version>-windows-setup.exe`.

(Optional: a code-signing certificate removes the SmartScreen warning.)

## Linux — `.flatpak` (build on Linux, e.g. Bazzite)

1. `flutter build linux --release`
2. Copy the built bundle next to the manifest:
   ```
   cp -r build/linux/x64/release/bundle packaging/linux/bundle
   ```
3. Install the runtime and build:
   ```
   flatpak install flathub org.freedesktop.Platform//24.08 org.freedesktop.Sdk//24.08
   flatpak-builder --force-clean --user --install build-dir \
     packaging/linux/io.github.jonathaxs.fileknight.yml
   ```
4. To produce a single shareable `.flatpak`:
   ```
   flatpak-builder --repo=repo --force-clean build-dir \
     packaging/linux/io.github.jonathaxs.fileknight.yml
   flatpak build-bundle repo FileKnight.flatpak io.github.jonathaxs.fileknight
   ```

This manifest is a starting point — expect to adjust the runtime version on Bazzite.

## TODO before a public release

- Add a `LICENSE` file and set the real SPDX id in the Linux metainfo.
- macOS: Developer ID signing + notarization.
- Linux: add screenshots to the AppStream metainfo for Flathub.
- Bump `version:` in `pubspec.yaml` per release.
