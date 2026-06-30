// Translations and OS language detection (English / Brazilian Portuguese).
//
// Strings are kept as plain Dart maps so the core stays Flutter-free and
// testable. The GUI stage can later move these into the localization system.

import 'dart:io';

/// Returns 'pt-BR' when the OS locale is Portuguese, otherwise 'en'.
String detectLanguageCode() {
  final locale = Platform.localeName.toLowerCase();
  return locale.startsWith('pt') ? 'pt-BR' : 'en';
}

/// Load the string table for [code], falling back to English.
Map<String, String> loadLocale(String code) {
  switch (code) {
    case 'pt-BR':
      return _ptBr;
    default:
      return _en;
  }
}

/// Look up [key], returning the key itself when it is missing.
String translate(Map<String, String> strings, String key) =>
    strings[key] ?? key;

const Map<String, String> _en = {
  'app_title': '📁⚔️ FileKnight',
  'select_source': 'Select source',
  'select_destination': 'Select destination',
  'entry_name': 'Entry name',
  'run_backup': 'Copy',
  'export_config': 'Export config',
  'import_config': 'Import config',
  'btn_file': 'File',
  'btn_folder': 'Folder',
  'label_mode': 'Mode',
  'label_dry_run': 'Dry run',
  'label_entries': 'Entries',
  'btn_add_update': 'Add/Update',
  'btn_remove': 'Remove',
  'warn_set_name': 'Please set a name.',
  'warn_select_source': 'Please select a source.',
  'msg_done_title': 'FileKnight',
  'msg_done_body': 'Done!\nOK: {ok}\nFAIL: {fail}',
  'status_saved_entry': 'Saved entry: {name}',
  'status_removed_entry': 'Removed entry: {name}',
  'status_backup_finished': 'Backup finished | OK: {ok} | FAIL: {fail}',
  'msg_export_title': 'FileKnight',
  'msg_export_body': 'Exported config:\n{path}',
  'msg_import_title': 'FileKnight',
  'msg_import_body': 'Config imported successfully!',
  'label_dry_run_cli': 'Dry run',
  'summary_ok_fail': 'OK: {ok} | FAIL: {fail}',
};

const Map<String, String> _ptBr = {
  'app_title': '📁⚔️ FileKnight',
  'select_source': 'Selecionar origem',
  'select_destination': 'Selecionar destino',
  'entry_name': 'Nome da entrada',
  'run_backup': 'Copiar',
  'export_config': 'Exportar config',
  'import_config': 'Importar config',
  'btn_file': 'Arquivo',
  'btn_folder': 'Pasta',
  'label_mode': 'Modo',
  'label_dry_run': 'Simular (dry run)',
  'label_entries': 'Entradas',
  'btn_add_update': 'Adicionar/Atualizar',
  'btn_remove': 'Remover',
  'warn_set_name': 'Defina um nome.',
  'warn_select_source': 'Selecione uma origem.',
  'msg_done_title': 'FileKnight',
  'msg_done_body': 'Pronto!\nOK: {ok}\nFAIL: {fail}',
  'status_saved_entry': 'Entrada salva: {name}',
  'status_removed_entry': 'Entrada removida: {name}',
  'status_backup_finished': 'Backup finalizado | OK: {ok} | FAIL: {fail}',
  'msg_export_title': 'FileKnight',
  'msg_export_body': 'Config exportado:\n{path}',
  'msg_import_title': 'FileKnight',
  'msg_import_body': 'Config importado com sucesso!',
  'label_dry_run_cli': 'Simular (dry run)',
  'summary_ok_fail': 'OK: {ok} | FAIL: {fail}',
};
