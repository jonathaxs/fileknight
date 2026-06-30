// App state and orchestration: loads/saves the config and drives the core.
//
// Kept as a ChangeNotifier so the UI rebuilds on changes without extra packages.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/backup_copier.dart';
import '../core/config_store.dart';
import '../core/i18n.dart';
import '../core/path_utils.dart';
import '../models/app_config.dart';
import '../models/entry.dart';

class AppController extends ChangeNotifier {
  AppConfig config = AppConfig.defaults();
  Map<String, String> strings = loadLocale('en');
  bool loading = true;

  File? _configFile;
  final Set<String> _running = <String>{};

  bool isRunning(String name) => _running.contains(name);
  bool get isBusy => _running.isNotEmpty;

  /// Localized string for [key].
  String tr(String key) => translate(strings, key);

  /// Load the config from disk, creating a default one on first run.
  Future<void> load() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'config.json'));
    _configFile = file;
    config = await ConfigStore.ensureExists(file);
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
    await _save();
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    config.language = code;
    _refreshStrings();
    await _save();
    notifyListeners();
  }

  /// Export the current config into [directoryPath]. Returns the new file path.
  Future<String> exportConfig(String directoryPath) async {
    final file = _configFile;
    if (file == null) return '';
    final exported = await ConfigStore.export(file, Directory(directoryPath));
    return exported.path;
  }

  /// Replace the current config with [filePath] and reload it.
  Future<void> importConfig(String filePath) async {
    final file = _configFile;
    if (file == null) return;
    await ConfigStore.import(File(filePath), file);
    config = await ConfigStore.read(file);
    _refreshStrings();
    notifyListeners();
  }

  /// Back up a single entry. Returns a localized result message.
  Future<String> runEntry(Entry entry) async {
    if (config.destinationRoot.trim().isEmpty) {
      return tr('no_destination');
    }
    _running.add(entry.name);
    notifyListeners();
    try {
      final destination = Directory(expandUserAndVars(config.destinationRoot));
      await BackupCopier.copyEntry(entry, destination, dryRun: config.dryRun);
      if (!config.dryRun) {
        _markBackedUp(entry.name);
        await _save();
      }
      return config.dryRun
          ? tr('done_dry')
          : tr('backup_done').replaceAll('{name}', entry.name);
    } catch (_) {
      return tr('backup_failed').replaceAll('{name}', entry.name);
    } finally {
      _running.remove(entry.name);
      notifyListeners();
    }
  }

  /// Back up every valid entry. Returns a localized summary.
  Future<String> runAll() async {
    if (config.destinationRoot.trim().isEmpty) {
      return tr('no_destination');
    }
    final entries = config.validEntries();
    _running.addAll(entries.map((e) => e.name));
    notifyListeners();

    final destination = Directory(expandUserAndVars(config.destinationRoot));
    var ok = 0;
    var fail = 0;
    for (final entry in entries) {
      try {
        await BackupCopier.copyEntry(entry, destination, dryRun: config.dryRun);
        if (!config.dryRun) {
          _markBackedUp(entry.name);
        }
        ok++;
      } catch (_) {
        fail++;
      } finally {
        _running.remove(entry.name);
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

  void _markBackedUp(String name) {
    final index = config.entries.indexWhere((e) => e.name == name);
    if (index >= 0) {
      config.entries[index] =
          config.entries[index].copyWith(lastBackup: DateTime.now());
    }
  }
}
