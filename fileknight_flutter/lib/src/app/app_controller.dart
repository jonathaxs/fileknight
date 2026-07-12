// Estado e orquestração do app: carrega/salva o config e aciona o core.
//
// É um ChangeNotifier para a UI se reconstruir nas mudanças sem pacotes extras.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/backup_copier.dart';
import '../core/config_store.dart';
import '../core/i18n.dart';
import '../core/macos_autostart.dart';
import '../core/path_utils.dart';
import '../models/app_config.dart';
import '../models/entry.dart';

class AppController extends ChangeNotifier {
  AppConfig config = AppConfig.defaults();
  Map<String, String> strings = loadLocale('en');
  bool loading = true;

  File? _configFile;
  File? _logFile;
  final Set<String> _running = <String>{};
  final Map<String, double> _progress = <String, double>{};
  final Map<String, String> _errors = <String, String>{};

  bool isRunning(String name) => _running.contains(name);
  bool get isBusy => _running.isNotEmpty;
  double? progressFor(String name) => _progress[name];
  String? errorFor(String name) => _errors[name];

  /// String localizada para [key].
  String tr(String key) => translate(strings, key);

  /// Carrega o config do disco, criando um padrão na primeira execução.
  Future<void> load() async {
    final dir = await getApplicationSupportDirectory();
    _configFile = File(p.join(dir.path, 'config.json'));
    _logFile = File(p.join(dir.path, 'fileknight.log'));
    config = await ConfigStore.ensureExists(_configFile!);
    _refreshStrings();
    loading = false;
    notifyListeners();
  }

  void _refreshStrings() {
    final setting = config.language.trim();
    final code =
        setting.isEmpty || setting == 'auto' ? detectLanguageCode() : setting;
    strings = loadLocale(code);
  }

  Future<void> _save() async {
    final file = _configFile;
    if (file != null) {
      await ConfigStore.write(file, config);
    }
  }

  Future<void> setDestination(String path) async {
    config.destinationRoot = path.trim();
    await _save();
    notifyListeners();
  }

  Future<void> setDryRun(bool value) async {
    config.dryRun = value;
    await _save();
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    config.language = code;
    _refreshStrings();
    await _save();
    notifyListeners();
  }

  /// Define o tema da interface: 'auto', 'light' ou 'dark'.
  Future<void> setThemeMode(String value) async {
    config.themeMode = value;
    await _save();
    notifyListeners();
  }

  /// Liga/desliga o iniciar-com-o-sistema (login) e salva a preferência.
  ///
  /// No macOS usamos um LaunchAgent próprio (ver [MacosAutostart]), porque o
  /// login item do launch_at_startup não repassa o --hidden e o app abriria a
  /// janela no login em vez de ficar só na bandeja. Nas demais plataformas o
  /// launch_at_startup já registra o --hidden certinho.
  Future<void> setAutoStart(bool value) async {
    config.autoStart = value;
    try {
      if (Platform.isMacOS) {
        final agent = MacosAutostart(
          label: 'io.github.jonathaxs.fileknight',
          executablePath: Platform.resolvedExecutable,
        );
        if (value) {
          agent.enable();
        } else {
          agent.disable();
        }
      } else if (value) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
    } catch (error) {
      // Se o SO recusar o registro, não quebra o app — só registra no log.
      await _appendLogLine('autostart falhou: $error');
    }
    await _save();
    notifyListeners();
  }

  Future<void> addOrUpdateEntry({
    required String name,
    required String source,
    required BackupMode mode,
  }) async {
    config.addOrUpdateEntry(name: name, source: source, mode: mode);
    await _save();
    notifyListeners();
  }

  Future<void> removeEntry(String name) async {
    config.removeEntry(name);
    _errors.remove(name);
    await _save();
    notifyListeners();
  }

  /// Exporta o config atual para [directoryPath]. Retorna o caminho do novo arquivo.
  Future<String> exportConfig(String directoryPath) async {
    final file = _configFile;
    if (file == null) return '';
    final exported = await ConfigStore.export(file, Directory(directoryPath));
    return exported.path;
  }

  /// Substitui o config atual pelo arquivo em [filePath] e o recarrega.
  Future<void> importConfig(String filePath) async {
    final file = _configFile;
    if (file == null) return;
    await ConfigStore.import(File(filePath), file);
    config = await ConfigStore.read(file);
    _refreshStrings();
    notifyListeners();
  }

  /// Faz backup de uma única entrada. Retorna uma mensagem de resultado localizada.
  Future<String> runEntry(Entry entry) async {
    if (config.destinationRoot.trim().isEmpty) {
      return tr('no_destination');
    }
    _errors.remove(entry.name);
    _progress[entry.name] = 0;
    _running.add(entry.name);
    notifyListeners();
    try {
      await _copy(entry);
      if (!config.dryRun) {
        _markBackedUp(entry.name);
        await _save();
      }
      await _appendLog(entry, success: true, error: null);
      return config.dryRun
          ? tr('done_dry')
          : tr('backup_done').replaceAll('{name}', entry.name);
    } catch (error) {
      _errors[entry.name] = error.toString();
      await _appendLog(entry, success: false, error: error.toString());
      return tr('backup_failed').replaceAll('{name}', entry.name);
    } finally {
      _running.remove(entry.name);
      _progress.remove(entry.name);
      notifyListeners();
    }
  }

  /// Faz backup de todas as entradas válidas. Retorna um resumo localizado.
  Future<String> runAll() async {
    if (config.destinationRoot.trim().isEmpty) {
      return tr('no_destination');
    }
    final entries = config.validEntries();
    if (entries.isEmpty) {
      return tr('no_entries');
    }
    for (final entry in entries) {
      _errors.remove(entry.name);
      _progress[entry.name] = 0;
    }
    _running.addAll(entries.map((e) => e.name));
    notifyListeners();

    var ok = 0;
    var fail = 0;
    for (final entry in entries) {
      try {
        await _copy(entry);
        if (!config.dryRun) {
          _markBackedUp(entry.name);
        }
        await _appendLog(entry, success: true, error: null);
        ok++;
      } catch (error) {
        _errors[entry.name] = error.toString();
        await _appendLog(entry, success: false, error: error.toString());
        fail++;
      } finally {
        _running.remove(entry.name);
        _progress.remove(entry.name);
        notifyListeners();
      }
    }
    if (!config.dryRun) {
      await _save();
    }
    return tr('summary_ok_fail')
        .replaceAll('{ok}', '$ok')
        .replaceAll('{fail}', '$fail');
  }

  // Executa a cópia da [entry], enviando à UI atualizações de progresso com limite de frequência.
  Future<void> _copy(Entry entry) async {
    final destination = Directory(expandUserAndVars(config.destinationRoot));
    var lastPercent = -1;
    await BackupCopier.copyEntry(
      entry,
      destination,
      dryRun: config.dryRun,
      onProgress: (done, total) {
        final percent = total == 0 ? 100 : (done * 100 ~/ total);
        _progress[entry.name] = percent / 100;
        if (percent != lastPercent) {
          lastPercent = percent;
          notifyListeners();
        }
      },
    );
  }

  void _markBackedUp(String name) {
    final index = config.entries.indexWhere((e) => e.name == name);
    if (index >= 0) {
      config.entries[index] =
          config.entries[index].copyWith(lastBackup: DateTime.now());
    }
  }

  Future<void> _appendLog(Entry entry,
      {required bool success, String? error}) async {
    final file = _logFile;
    if (file == null) return;
    final stamp = DateTime.now().toIso8601String();
    final mode = config.dryRun ? 'dry-run' : entry.mode.name;
    final status = success ? 'OK' : 'FAIL';
    final detail = error == null ? '' : ' — $error';
    try {
      await file.writeAsString(
        '[$stamp] $status  ${entry.name} ($mode)$detail\n',
        mode: FileMode.append,
      );
    } catch (_) {
      // Falha no log nunca pode quebrar um backup.
    }
  }

  // Escreve uma linha avulsa no log (eventos gerais, não ligados a uma entrada).
  Future<void> _appendLogLine(String message) async {
    final file = _logFile;
    if (file == null) return;
    final stamp = DateTime.now().toIso8601String();
    try {
      await file.writeAsString('[$stamp] $message\n', mode: FileMode.append);
    } catch (_) {
      // Log é best-effort; nunca quebra o fluxo.
    }
  }

  /// Linhas recentes do log, mais novas primeiro (com limite). Vazio se ainda não há log.
  Future<String> readLog() async {
    final file = _logFile;
    if (file == null || !await file.exists()) return '';
    final lines = await file.readAsLines();
    final tail =
        lines.length > 100 ? lines.sublist(lines.length - 100) : lines;
    return tail.reversed.join('\n');
  }
}
