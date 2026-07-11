// Modelo AppConfig: o conteúdo completo do config.json.
//
// Espelha o config da versão Python (language, dry_run, destination_root,
// entries) e preserva o bloco opcional "_meta" para não perder dados no
// ciclo de ler → salvar.

import 'entry.dart';

class AppConfig {
  String language;
  // Tema da interface: 'auto' (segue o sistema), 'light' ou 'dark'.
  String themeMode;
  // Iniciar com o sistema (login), abrindo oculto na bandeja.
  bool autoStart;
  bool dryRun;
  String destinationRoot;
  List<Entry> entries;
  Map<String, dynamic>? meta;

  AppConfig({
    this.language = 'auto',
    this.themeMode = 'auto',
    this.autoStart = false,
    this.dryRun = false,
    this.destinationRoot = '~/Downloads/FileKnight',
    List<Entry>? entries,
    this.meta,
  }) : entries = entries == null ? <Entry>[] : List<Entry>.of(entries);

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    final parsed = <Entry>[];
    if (rawEntries is List) {
      for (final item in rawEntries) {
        if (item is Map<String, dynamic>) {
          parsed.add(Entry.fromJson(item));
        }
      }
    }
    return AppConfig(
      language: (json['language'] ?? 'auto').toString(),
      themeMode: (json['theme_mode'] ?? 'auto').toString(),
      autoStart: json['auto_start'] == true,
      dryRun: json['dry_run'] == true,
      destinationRoot: (json['destination_root'] ?? '').toString(),
      entries: parsed,
      meta: json['_meta'] is Map
          ? Map<String, dynamic>.from(json['_meta'] as Map)
          : null,
    );
  }

  // O _meta é escrito primeiro para manter o layout do config.json existente.
  Map<String, dynamic> toJson() => {
        if (meta != null) '_meta': meta,
        'language': language,
        'theme_mode': themeMode,
        'auto_start': autoStart,
        'dry_run': dryRun,
        'destination_root': destinationRoot,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  factory AppConfig.defaults() => AppConfig(
        language: 'auto',
        themeMode: 'auto',
        dryRun: false,
        destinationRoot: '~/Downloads/FileKnight',
        entries: const [],
      );

  /// Entradas seguras para backup: nome e origem precisam estar preenchidos.
  List<Entry> validEntries() => entries
      .where((e) => e.name.trim().isNotEmpty && e.source.trim().isNotEmpty)
      .toList();

  /// Adiciona uma entrada nova, ou atualiza a existente com o mesmo nome.
  /// Ao atualizar, o [Entry.lastBackup] existente é preservado.
  void addOrUpdateEntry({
    required String name,
    required String source,
    BackupMode mode = BackupMode.mirror,
  }) {
    final trimmedName = name.trim();
    final index = entries.indexWhere((e) => e.name.trim() == trimmedName);
    final updated = Entry(name: trimmedName, source: source.trim(), mode: mode);
    if (index >= 0) {
      entries[index] = updated.copyWith(lastBackup: entries[index].lastBackup);
    } else {
      entries.add(updated);
    }
  }

  /// Remove uma entrada pelo nome. Retorna true quando algo foi removido.
  bool removeEntry(String name) {
    final trimmedName = name.trim();
    final before = entries.length;
    entries.removeWhere((e) => e.name.trim() == trimmedName);
    return entries.length != before;
  }
}
