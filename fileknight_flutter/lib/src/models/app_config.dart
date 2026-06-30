// AppConfig model: the whole config.json contents.
//
// Mirrors the Python config (language, dry_run, destination_root, entries) and
// preserves the optional "_meta" block so it round-trips without data loss.

import 'entry.dart';

class AppConfig {
  String language;
  bool dryRun;
  String destinationRoot;
  List<Entry> entries;
  Map<String, dynamic>? meta;

  AppConfig({
    this.language = 'auto',
    this.dryRun = false,
    this.destinationRoot = '~/Desktop/FileKnight',
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
      dryRun: json['dry_run'] == true,
      destinationRoot: (json['destination_root'] ?? '').toString(),
      entries: parsed,
      meta: json['_meta'] is Map
          ? Map<String, dynamic>.from(json['_meta'] as Map)
          : null,
    );
  }

  // _meta is written first to match the layout of the existing config.json.
  Map<String, dynamic> toJson() => {
        if (meta != null) '_meta': meta,
        'language': language,
        'dry_run': dryRun,
        'destination_root': destinationRoot,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  factory AppConfig.defaults() => AppConfig(
        language: 'auto',
        dryRun: false,
        destinationRoot: '~/Desktop/FileKnight',
        entries: const [
          Entry(
            name: 'Example Entry',
            source: '~/Desktop/ExampleSource',
            mode: BackupMode.mirror,
          ),
        ],
      );

  /// Entries that are safe to back up: both name and source must be non-empty.
  List<Entry> validEntries() => entries
      .where((e) => e.name.trim().isNotEmpty && e.source.trim().isNotEmpty)
      .toList();

  /// Add a new entry, or update an existing one matched by name.
  /// When updating, the existing [Entry.lastBackup] is preserved.
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

  /// Remove an entry by name. Returns true when something was removed.
  bool removeEntry(String name) {
    final trimmedName = name.trim();
    final before = entries.length;
    entries.removeWhere((e) => e.name.trim() == trimmedName);
    return entries.length != before;
  }
}
