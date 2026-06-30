// Backup engine: copies a single entry into the destination.
//
// Mirror mode for directories is crash-safe: the new copy is fully staged next
// to the target before the old backup is touched, so an interrupted run never
// destroys a valid backup. Single files are written via a temp-then-rename swap.
//
// An optional progress callback reports how many files have been copied so far.

import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/entry.dart';
import 'path_utils.dart';

/// Reports progress as (filesCopied, totalFiles).
typedef ProgressCallback = void Function(int done, int total);

class BackupCopier {
  /// Copy [entry] into `destinationRoot/<entry.name>/<source_name>`.
  ///
  /// Returns the final destination path. With [dryRun] true, nothing is written
  /// and only the path that *would* be used is returned.
  static Future<String> copyEntry(
    Entry entry,
    Directory destinationRoot, {
    required bool dryRun,
    ProgressCallback? onProgress,
  }) async {
    final sourcePath = expandUserAndVars(entry.source);
    final sourceType = FileSystemEntity.typeSync(sourcePath, followLinks: true);
    if (sourceType == FileSystemEntityType.notFound) {
      throw FileSystemException('Source does not exist', sourcePath);
    }

    final destinationDir = Directory(p.join(destinationRoot.path, entry.name));
    final destinationItem = p.join(destinationDir.path, p.basename(sourcePath));

    if (dryRun) {
      return destinationItem;
    }

    await destinationDir.create(recursive: true);

    if (sourceType == FileSystemEntityType.directory) {
      final source = Directory(sourcePath);
      final total = await _countFiles(source);
      var done = 0;
      void onFile() {
        done++;
        onProgress?.call(done, total);
      }

      onProgress?.call(0, total);
      if (entry.mode == BackupMode.mirror) {
        await _mirrorDirectory(source, Directory(destinationItem), onFile);
      } else {
        await _mergeDirectory(source, Directory(destinationItem), onFile);
      }
      onProgress?.call(total, total);
    } else {
      onProgress?.call(0, 1);
      await _copyFileAtomic(File(sourcePath), File(destinationItem));
      onProgress?.call(1, 1);
    }

    return destinationItem;
  }

  static Future<int> _countFiles(Directory source) async {
    var count = 0;
    await for (final entity in source.list(recursive: true, followLinks: false)) {
      if (entity is File) count++;
    }
    return count;
  }

  // Mirror = exact replica. Stage a fresh copy, then swap it in atomically.
  static Future<void> _mirrorDirectory(
      Directory source, Directory target, void Function() onFile) async {
    final parent = target.parent;
    await parent.create(recursive: true);

    final staging = Directory(p.join(parent.path, _scratchName('staging')));
    final previous = Directory(p.join(parent.path, _scratchName('old')));

    try {
      await _copyDirectory(source, staging, onFile);

      if (await target.exists()) {
        await target.rename(previous.path);
        try {
          await staging.rename(target.path);
        } catch (_) {
          // Swap failed: restore the previous backup before giving up.
          await previous.rename(target.path);
          rethrow;
        }
        await previous.delete(recursive: true);
      } else {
        await staging.rename(target.path);
      }
    } finally {
      if (await staging.exists()) {
        await staging.delete(recursive: true);
      }
    }
  }

  // Copy = additive merge. Overwrite/add files, keep files already in target.
  static Future<void> _mergeDirectory(
      Directory source, Directory target, void Function() onFile) async {
    await target.create(recursive: true);
    await for (final entity in source.list(recursive: true, followLinks: false)) {
      final relative = p.relative(entity.path, from: source.path);
      final targetPath = p.join(target.path, relative);
      if (entity is Directory) {
        await Directory(targetPath).create(recursive: true);
      } else if (entity is File) {
        await Directory(p.dirname(targetPath)).create(recursive: true);
        await entity.copy(targetPath);
        onFile();
      }
    }
  }

  static Future<void> _copyDirectory(
      Directory source, Directory target, void Function() onFile) async {
    await target.create(recursive: true);
    await for (final entity in source.list(recursive: false, followLinks: false)) {
      final targetPath = p.join(target.path, p.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(targetPath), onFile);
      } else if (entity is File) {
        await entity.copy(targetPath);
        onFile();
      }
    }
  }

  static Future<void> _copyFileAtomic(File source, File target) async {
    await target.parent.create(recursive: true);
    final tmp = File(p.join(
        target.parent.path, '${_scratchName('tmp')}-${p.basename(target.path)}'));
    try {
      await source.copy(tmp.path);
      await tmp.rename(target.path);
    } finally {
      if (await tmp.exists()) {
        await tmp.delete();
      }
    }
  }

  static int _counter = 0;

  // Unique, hidden scratch name living next to the target (same filesystem).
  static String _scratchName(String kind) =>
      '.fk-$kind-${DateTime.now().microsecondsSinceEpoch}-${_counter++}';
}
