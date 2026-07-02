// IO do arquivo de config: ler, gravar, criar padrão, exportar e importar.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/app_config.dart';

class ConfigStore {
  static Future<AppConfig> read(File file) async {
    final text = await file.readAsString();
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('config.json must contain a JSON object');
    }
    return AppConfig.fromJson(decoded);
  }

  static Future<void> write(File file, AppConfig config) async {
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(config.toJson())}\n');
  }

  /// Lê o config, criando um padrão se o arquivo ainda não existir.
  static Future<AppConfig> ensureExists(File file) async {
    if (await file.exists()) {
      return read(file);
    }
    final config = AppConfig.defaults();
    config.meta = {
      'file': 'config.json',
      'created_by': '@jonathaxs',
      'created_at': DateTime.now().toIso8601String(),
    };
    await write(file, config);
    return config;
  }

  /// Exporta uma cópia do config com carimbo de data/hora para [exportDir].
  static Future<File> export(File configFile, Directory exportDir) async {
    await exportDir.create(recursive: true);
    final target =
        File(p.join(exportDir.path, 'fileknight_${_timestamp()}_config.json'));
    return configFile.copy(target.path);
  }

  /// Importa um arquivo .json, substituindo o config atual.
  static Future<void> import(File sourceJson, File configFile) async {
    if (!await sourceJson.exists()) {
      throw FileSystemException('Import source does not exist', sourceJson.path);
    }
    if (p.extension(sourceJson.path).toLowerCase() != '.json') {
      throw const FormatException('Import file must be a .json');
    }
    await configFile.parent.create(recursive: true);
    await sourceJson.copy(configFile.path);
  }

  static String _timestamp() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}_'
        '${two(now.hour)}h${two(now.minute)}m${two(now.second)}s';
  }
}
