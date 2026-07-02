// Modelo Entry: um item de backup.
//
// Guarda o nome lógico, o caminho de origem cru (como está no config), o modo
// de cópia e, opcionalmente, a data/hora do último backup bem-sucedido (usada
// pelo status "Protegido" na interface).

/// Como a entrada é copiada para o destino.
///
/// - [mirror]: o destino vira uma réplica exata da origem.
/// - [copy]: arquivos são adicionados/sobrescritos, mas os extras já existentes são mantidos.
enum BackupMode { mirror, copy }

/// Converte um modo vindo do JSON. Valores desconhecidos caem em [BackupMode.mirror].
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
