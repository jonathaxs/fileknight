// Motor de backup: copia uma entrada para o destino.
//
// O modo espelho (mirror) em pastas é à prova de falhas: a cópia nova é montada
// por completo ao lado do alvo antes de o backup antigo ser tocado — assim uma
// execução interrompida nunca destrói um backup válido. Arquivos únicos são
// gravados via temporário + rename.
//
// Um callback opcional de progresso informa quantos arquivos já foram copiados.

import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/entry.dart';
import 'path_utils.dart';

/// Reporta o progresso como (arquivosCopiados, totalDeArquivos).
typedef ProgressCallback = void Function(int done, int total);

class BackupCopier {
  /// Copia a [entry] para `destinationRoot/<entry.name>/<source_name>`.
  ///
  /// Retorna o caminho final de destino. Com [dryRun] true, nada é gravado e
  /// apenas o caminho que *seria* usado é retornado.
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

  // Espelho = réplica exata. Monta uma cópia nova e faz a troca de forma atômica.
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
          // A troca falhou: restaura o backup anterior antes de desistir.
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

  // Cópia = mesclagem aditiva. Sobrescreve/adiciona arquivos e mantém os que já existem no destino.
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

  // Nome de rascunho único e oculto, vizinho do alvo (mesmo sistema de arquivos).
  static String _scratchName(String kind) =>
      '.fk-$kind-${DateTime.now().microsecondsSinceEpoch}-${_counter++}';
}
