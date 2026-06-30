import 'package:flutter_test/flutter_test.dart';
import 'package:fileknight/src/models/app_config.dart';
import 'package:fileknight/src/models/entry.dart';

void main() {
  group('AppConfig', () {
    test('round-trips through JSON', () {
      final config = AppConfig(
        language: 'pt-BR',
        dryRun: true,
        destinationRoot: '~/Backups',
        entries: [
          const Entry(name: 'Saves', source: '~/games', mode: BackupMode.copy),
        ],
        meta: {'file': 'config.json'},
      );

      final restored = AppConfig.fromJson(config.toJson());

      expect(restored.language, 'pt-BR');
      expect(restored.dryRun, true);
      expect(restored.destinationRoot, '~/Backups');
      expect(restored.entries.single.name, 'Saves');
      expect(restored.entries.single.mode, BackupMode.copy);
      expect(restored.meta?['file'], 'config.json');
    });

    test('validEntries drops entries without a name or source', () {
      final config = AppConfig(entries: const [
        Entry(name: '', source: '~/a'),
        Entry(name: 'ok', source: ''),
        Entry(name: 'good', source: '~/b'),
      ]);

      expect(config.validEntries().map((e) => e.name), ['good']);
    });

    test('addOrUpdateEntry updates an existing entry and keeps lastBackup', () {
      final config = AppConfig(entries: [
        Entry(
          name: 'A',
          source: '~/old',
          mode: BackupMode.mirror,
          lastBackup: DateTime.utc(2020),
        ),
      ]);

      config.addOrUpdateEntry(name: 'A', source: '~/new', mode: BackupMode.copy);

      expect(config.entries.length, 1);
      expect(config.entries.single.source, '~/new');
      expect(config.entries.single.mode, BackupMode.copy);
      expect(config.entries.single.lastBackup, DateTime.utc(2020));
    });

    test('removeEntry removes by name', () {
      final config = AppConfig(entries: const [Entry(name: 'A', source: '~/a')]);

      expect(config.removeEntry('A'), true);
      expect(config.entries, isEmpty);
      expect(config.removeEntry('A'), false);
    });

    test('unknown mode falls back to mirror', () {
      final entry = Entry.fromJson({'name': 'x', 'source': 'y', 'mode': 'weird'});
      expect(entry.mode, BackupMode.mirror);
    });
  });
}
