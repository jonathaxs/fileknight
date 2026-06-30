// Entry model: a single backup item.
//
// Holds the logical name, the raw source path (as stored in config), the copy
// mode, and an optional timestamp of the last successful backup (used later for
// the "protected" status shown in the UI).

/// How an entry is copied into the destination.
///
/// - [mirror]: the destination becomes an exact replica of the source.
/// - [copy]: files are added/overwritten, but existing extra files are kept.
enum BackupMode { mirror, copy }

/// Parse a mode coming from JSON. Anything unknown falls back to [BackupMode.mirror].
BackupMode backupModeFromString(Object? value) {
  final raw = (value ?? '').toString().trim().toLowerCase();
  return raw == 'copy' ? BackupMode.copy : BackupMode.mirror;
}

class Entry {
  final String name;
  final String source;
  final BackupMode mode;
  final DateTime? lastBackup;

  const Entry({
    required this.name,
    required this.source,
    this.mode = BackupMode.mirror,
    this.lastBackup,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    final rawLast = json['last_backup'];
    return Entry(
      name: (json['name'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      mode: backupModeFromString(json['mode']),
      lastBackup: rawLast == null ? null : DateTime.tryParse(rawLast.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'source': source,
        'mode': mode.name,
        if (lastBackup != null) 'last_backup': lastBackup!.toUtc().toIso8601String(),
      };

  Entry copyWith({
    String? name,
    String? source,
    BackupMode? mode,
    DateTime? lastBackup,
  }) {
    return Entry(
      name: name ?? this.name,
      source: source ?? this.source,
      mode: mode ?? this.mode,
      lastBackup: lastBackup ?? this.lastBackup,
    );
  }
}
