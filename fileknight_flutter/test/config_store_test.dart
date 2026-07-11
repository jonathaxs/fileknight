import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fileknight/src/core/config_store.dart';
import 'package:fileknight/src/models/app_config.dart';
import 'package:fileknight/src/models/entry.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('fk_cfg_');
  });

  tearDown(() async {
    if (await tmp.exists()) {
      await tmp.delete(recursive: true);
    }
  });

  test('write then read preserves the config', () async {
    final file = File('${tmp.path}/config.json');
    final config = AppConfig(
      language: 'en',
      dryRun: false,
      destinationRoot: '~/Backups',
      entries: const [Entry(name: 'Saves', source: '~/games')],
      meta: {'file': 'config.json'},
    );

    await ConfigStore.write(file, config);
    final restored = await ConfigStore.read(file);

    expect(restored.destinationRoot, '~/Backups');
    expect(restored.entries.single.name, 'Saves');
    expect(restored.meta?['file'], 'config.json');
  });

  test('ensureExists creates a default config when missing', () async {
    final file = File('${tmp.path}/config.json');
    expect(await file.exists(), false);

    final config = await ConfigStore.ensureExists(file);

    expect(await file.exists(), true);
    expect(config.entries, isEmpty);
    expect(config.destinationRoot, '~/Downloads/FileKnight');
    expect(config.meta?['created_at'], isNotNull);
  });

  test('export copies the config into the target directory', () async {
    final file = File('${tmp.path}/config.json');
    await ConfigStore.write(file, AppConfig.defaults());
    final exportDir = Directory('${tmp.path}/out');

    final exported = await ConfigStore.export(file, exportDir);

    expect(await exported.exists(), true);
    expect(exported.path, contains('out'));
  });

  test('import rejects a non-json file', () async {
    final file = File('${tmp.path}/config.json');
    final bad = File('${tmp.path}/notes.txt')..writeAsStringSync('nope');

    expect(
      () => ConfigStore.import(bad, file),
      throwsA(isA<FormatException>()),
    );
  });
}
