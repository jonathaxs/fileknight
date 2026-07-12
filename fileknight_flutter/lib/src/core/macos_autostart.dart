// Autostart (iniciar com o login) no macOS via LaunchAgent próprio.
//
// O plugin launch_at_startup, no macOS, registra um "login item" que NÃO repassa
// argumentos. Por isso o app nunca recebia o --hidden no login e abria a janela
// em vez de ficar só na bandeja. Aqui gravamos um LaunchAgent com o --hidden nos
// ProgramArguments, então o app nasce escondido. Como o FileKnight roda sem
// sandbox, podemos escrever em ~/Library/LaunchAgents normalmente.

import 'dart:io';

class MacosAutostart {
  MacosAutostart({required this.label, required this.executablePath});

  /// Identificador do agente (usamos o app id). Vira o nome do arquivo .plist.
  final String label;

  /// Caminho do binário dentro do .app (Platform.resolvedExecutable).
  final String executablePath;

  File get _plistFile {
    final home = Platform.environment['HOME'] ?? '';
    return File('$home/Library/LaunchAgents/$label.plist');
  }

  /// Habilitado quando o .plist do LaunchAgent existe.
  bool isEnabled() => _plistFile.existsSync();

  /// Cria o LaunchAgent que abre o app com --hidden no login.
  void enable() {
    final dir = _plistFile.parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    _plistFile.writeAsStringSync(_plistContents());
  }

  /// Remove o LaunchAgent.
  void disable() {
    if (_plistFile.existsSync()) {
      _plistFile.deleteSync();
    }
  }

  String _plistContents() {
    // RunAtLoad faz o launchd iniciar o app no login; o --hidden faz abrir só
    // na bandeja. O caminho aponta para o binário dentro do .app.
    return '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$label</string>
    <key>ProgramArguments</key>
    <array>
        <string>$executablePath</string>
        <string>--hidden</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
''';
  }
}
