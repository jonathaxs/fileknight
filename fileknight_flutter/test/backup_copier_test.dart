import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fileknight/src/core/backup_copier.dart';
import 'package:fileknight/src/models/entry.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('fk_test_');
  });

  tearDown(() async {
    if (await tmp.exists()) {
      await tmp.delete(recursive: true);
    }
  });

  test('copies a single file', () async {
    final src = File('${tmp.path}/save.co2')..writeAsStringSync('hello');
    final dest = Directory('${tmp.path}/dest');
    final entry = Entry(name: 'Game', source: src.path, mode: BackupMode.copy);

    final result = await BackupCopier.copyEntry(entry, dest, dryRun: false);

    expect(File(result).readAsStringSync(), 'hello');
    expect(result, '${dest.path}/Game/save.co2');
  });

  test('dry run returns the path without writing anything', () async {
    final src = File('${tmp.path}/save.co2')..writeAsStringSync('hi');
    final dest = Directory('${tmp.path}/dest');
    final entry = Entry(name: 'Game', source: src.path);

    final result = await BackupCopier.copyEntry(entry, dest, dryRun: true);

    expect(await dest.exists(), false);
    expect(result, endsWith('Game/save.co2'));
  });

  test('mirror replaces a directory exactly, removing stale files', () async {
    final src = Directory('${tmp.path}/src')..createSync();
    File('${src.path}/a.txt').writeAsStringSync('A');
    final dest = Directory('${tmp.path}/dest');
    final entry = Entry(name: 'Folder', source: src.path, mode: BackupMode.mirror);

    await BackupCopier.copyEntry(entry, dest, dryRun: false);
    final mirrored = Directory('${dest.path}/Folder/src');

    // Um arquivo obsoleto no backup e um arquivo novo na origem.
    File('${mirrored.path}/stale.txt').writeAsStringSync('stale');
    File('${src.path}/b.txt').writeAsStringSync('B');

    await BackupCopier.copyEntry(entry, dest, dryRun: false);

    expect(File('${mirrored.path}/a.txt').existsSync(), true);
    expect(File('${mirrored.path}/b.txt').readAsStringSync(), 'B');
    expect(File('${mirrored.path}/stale.txt').existsSync(), false);
  });

  test('copy mode keeps existing extra files (merge)', () async {
    final src = Directory('${tmp.path}/src')..createSync();
    File('${src.path}/a.txt').writeAsStringSync('A');
    final dest = Directory('${tmp.path}/dest');
    final entry = Entry(name: 'Folder', source: src.path, mode: BackupMode.copy);

    await BackupCopier.copyEntry(entry, dest, dryRun: false);
    final copied = Directory('${dest.path}/Folder/src');
    File('${copied.path}/extra.txt').writeAsStringSync('extra');

    await BackupCopier.copyEntry(entry, dest, dryRun: false);

    expect(File('${copied.path}/a.txt').existsSync(), true);
    expect(File('${copied.path}/extra.txt').existsSync(), true);
  });

  test('missing source throws and preserves the existing backup', () async {
    final src = Directory('${tmp.path}/src')..createSync();
    File('${src.path}/a.txt').writeAsStringSync('A');
    final dest = Directory('${tmp.path}/dest');
    final entry = Entry(name: 'Folder', source: src.path, mode: BackupMode.mirror);

    await BackupCopier.copyEntry(entry, dest, dryRun: false);
    final mirrored = Directory('${dest.path}/Folder/src');
    expect(File('${mirrored.path}/a.txt').existsSync(), true);

    // A origem some; a próxima execução deve falhar sem destruir o backup.
    src.deleteSync(recursive: true);

    await expectLater(
      BackupCopier.copyEntry(entry, dest, dryRun: false),
      throwsA(isA<FileSystemException>()),
    );
    expect(File('${mirrored.path}/a.txt').existsSync(), true);
  });

  test('reports progress up to the total file count', () async {
    final src = Directory('${tmp.path}/src')..createSync();
    File('${src.path}/a.txt').writeAsStringSync('A');
    File('${src.path}/b.txt').writeAsStringSync('B');
    final dest = Directory('${tmp.path}/dest');
    final entry = Entry(name: 'Folder', source: src.path, mode: BackupMode.copy);

    var lastDone = -1;
    var lastTotal = -1;
    await BackupCopier.copyEntry(
      entry,
      dest,
      dryRun: false,
      onProgress: (done, total) {
        lastDone = done;
        lastTotal = total;
      },
    );

    expect(lastTotal, 2);
    expect(lastDone, 2);
  });
}
