// Tela principal: destino, cartões de entrada, switch de simulação e ações de backup.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/entry.dart';
import 'app_controller.dart';

class HomeScreen extends StatelessWidget {
  final AppController controller;
  const HomeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return _scaffold(context);
      },
    );
  }

  Widget _scaffold(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final entries = controller.config.entries;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: cs.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('FileKnight',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                Text(controller.tr('app_subtitle'),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _showSettingsDialog(context);
                case 'export':
                  _exportConfig(context);
                case 'import':
                  _importConfig(context);
                case 'log':
                  _showLogDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child:
                    _menuRow(Icons.settings_outlined, controller.tr('menu_settings')),
              ),
              PopupMenuItem(
                value: 'export',
                child:
                    _menuRow(Icons.upload_outlined, controller.tr('export_config')),
              ),
              PopupMenuItem(
                value: 'import',
                child: _menuRow(
                    Icons.download_outlined, controller.tr('import_config')),
              ),
              PopupMenuItem(
                value: 'log',
                child: _menuRow(
                    Icons.receipt_long_outlined, controller.tr('menu_log')),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _destinationCard(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(controller.tr('label_entries'),
                    style: theme.textTheme.titleMedium),
                const SizedBox(width: 8),
                _countBadge(context, entries.length),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () => _showEntryDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(controller.tr('btn_add')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: entries.isEmpty
                ? _emptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _entryCard(context, entries[i]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomBar(context),
    );
  }

  Widget _destinationCard(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final destination = controller.config.destinationRoot;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.folder_outlined, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.tr('destination_label'),
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  destination.isEmpty ? '—' : destination,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontFamily: 'monospace'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _pickDestination(context),
            child: Text(controller.tr('btn_change')),
          ),
        ],
      ),
    );
  }

  Widget _countBadge(BuildContext context, int count) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$count',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
    );
  }

  Widget _entryCard(BuildContext context, Entry entry) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final running = controller.isRunning(entry.name);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.videogame_asset_outlined,
                color: cs.onSurfaceVariant, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  entry.source,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant, fontFamily: 'monospace'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (running)
                  _progressRow(context, entry.name)
                else
                  Row(
                    children: [
                      _modeChip(context, entry.mode),
                      const SizedBox(width: 6),
                      Flexible(
                        child: controller.errorFor(entry.name) != null
                            ? _errorChip(context, entry.name)
                            : _statusChip(context, entry),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: controller.tr('run_backup'),
            onPressed: running ? null : () => _runOne(context, entry),
            icon: const Icon(Icons.play_arrow_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEntryDialog(context, entry: entry);
              } else if (value == 'remove') {
                _confirmRemove(context, entry);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 'edit', child: Text(controller.tr('btn_add_update'))),
              PopupMenuItem(
                  value: 'remove', child: Text(controller.tr('btn_remove'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeChip(BuildContext context, BackupMode mode) {
    final cs = Theme.of(context).colorScheme;
    final label = mode == BackupMode.mirror
        ? controller.tr('mode_mirror')
        : controller.tr('mode_copy');
    return _pill(label, cs.secondaryContainer, cs.onSecondaryContainer);
  }

  Widget _statusChip(BuildContext context, Entry entry) {
    final cs = Theme.of(context).colorScheme;
    final lastBackup = entry.lastBackup;
    if (lastBackup == null) {
      return _pill(controller.tr('status_never'),
          cs.surfaceContainerHighest, cs.onSurfaceVariant);
    }
    final text = '${controller.tr('status_protected')} · ${_relative(lastBackup)}';
    return _pill(text, cs.tertiaryContainer, cs.onTertiaryContainer,
        icon: Icons.verified_outlined);
  }

  Widget _pill(String text, Color background, Color foreground,
      {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: foreground),
            ),
          ),
        ],
      ),
    );
  }

  String _relative(DateTime when) {
    final diff = DateTime.now().difference(when);
    String withCount(String key, int n) =>
        controller.tr(key).replaceAll('{n}', '$n');
    if (diff.inMinutes < 1) return controller.tr('time_now');
    if (diff.inMinutes < 60) return withCount('time_min', diff.inMinutes);
    if (diff.inHours < 24) return withCount('time_hour', diff.inHours);
    if (diff.inDays == 1) return controller.tr('time_yesterday');
    return withCount('time_day', diff.inDays);
  }

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(controller.tr('empty_entries'),
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(controller.tr('empty_hint'),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: controller.isBusy ? null : () => _runAll(context),
            icon: const Icon(Icons.shield_outlined),
            label: Text(controller.tr('backup_all')),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
      ),
    );
  }

  Future<void> _runAll(BuildContext context) async {
    final hasMirror = controller.config
        .validEntries()
        .any((e) => e.mode == BackupMode.mirror);
    if (hasMirror) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(controller.tr('confirm_title')),
          content: Text(controller.tr('confirm_mirror_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(controller.tr('btn_cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(controller.tr('btn_continue')),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    final message = await controller.runAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runOne(BuildContext context, Entry entry) async {
    final message = await controller.runEntry(entry);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDestination(BuildContext context) async {
    final path = await FilePicker.getDirectoryPath();
    if (path != null) {
      await controller.setDestination(path);
    }
  }

  Widget _menuRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }

  Future<void> _exportConfig(BuildContext context) async {
    final directory = await FilePicker.getDirectoryPath();
    if (directory == null) return;
    final path = await controller.exportConfig(directory);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(controller.tr('msg_export_body').replaceAll('{path}', path)),
      ),
    );
  }

  Future<void> _importConfig(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return;
    await controller.importConfig(path);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(controller.tr('msg_import_body'))),
    );
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(controller.tr('menu_settings')),
        // Escuta o controller para as opções refletirem a escolha na hora
        // (idioma e tema são aplicados ao vivo, sem fechar o diálogo).
        content: SizedBox(
          width: 340,
          child: SingleChildScrollView(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel(context, controller.tr('language_label')),
                  _settingOption(context, controller.config.language == 'auto',
                      controller.tr('language_auto'),
                      () => controller.setLanguage('auto')),
                  _settingOption(context, controller.config.language == 'en',
                      'English', () => controller.setLanguage('en')),
                  _settingOption(context, controller.config.language == 'pt-BR',
                      'Português (Brasil)',
                      () => controller.setLanguage('pt-BR')),
                  const SizedBox(height: 16),
                  _sectionLabel(context, controller.tr('theme_label')),
                  _settingOption(context, controller.config.themeMode == 'auto',
                      controller.tr('theme_auto'),
                      () => controller.setThemeMode('auto')),
                  _settingOption(context, controller.config.themeMode == 'light',
                      controller.tr('theme_light'),
                      () => controller.setThemeMode('light')),
                  _settingOption(context, controller.config.themeMode == 'dark',
                      controller.tr('theme_dark'),
                      () => controller.setThemeMode('dark')),
                  const SizedBox(height: 16),
                  _sectionLabel(context, controller.tr('startup_label')),
                  _autoStartRow(context),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(controller.tr('btn_close')),
          ),
        ],
      ),
    );
  }

  // Rótulo de uma seção do diálogo de configurações (ex.: "Idioma", "Tema").
  Widget _sectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.labelLarge
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }

  // Linha com o interruptor de "iniciar com o sistema".
  Widget _autoStartRow(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.tr('autostart_label')),
              const SizedBox(height: 2),
              Text(
                controller.tr('autostart_desc'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Switch(
          value: controller.config.autoStart,
          onChanged: (value) => controller.setAutoStart(value),
        ),
      ],
    );
  }

  // Uma opção selecionável (rádio) dentro de uma seção de configurações.
  Widget _settingOption(
      BuildContext context, bool selected, String label, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }

  Future<void> _showEntryDialog(BuildContext context, {Entry? entry}) async {
    final nameField = TextEditingController(text: entry?.name ?? '');
    final sourceField = TextEditingController(text: entry?.source ?? '');
    var mode = entry?.mode ?? BackupMode.mirror;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(controller.tr('dialog_new_entry')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameField,
                autofocus: true,
                decoration:
                    InputDecoration(labelText: controller.tr('field_name')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sourceField,
                decoration: InputDecoration(
                  labelText: controller.tr('field_source'),
                  hintText: '~/Library/...',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.pickFiles();
                      final path = result?.files.single.path;
                      if (path != null) sourceField.text = path;
                    },
                    icon: const Icon(Icons.insert_drive_file_outlined, size: 16),
                    label: Text(controller.tr('btn_file')),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final path = await FilePicker.getDirectoryPath();
                      if (path != null) sourceField.text = path;
                    },
                    icon: const Icon(Icons.folder_outlined, size: 16),
                    label: Text(controller.tr('btn_folder')),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SegmentedButton<BackupMode>(
                segments: [
                  ButtonSegment(
                      value: BackupMode.mirror,
                      label: Text(controller.tr('mode_mirror'))),
                  ButtonSegment(
                      value: BackupMode.copy,
                      label: Text(controller.tr('mode_copy'))),
                ],
                selected: {mode},
                onSelectionChanged: (selection) =>
                    setState(() => mode = selection.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(controller.tr('btn_cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(controller.tr('btn_save')),
            ),
          ],
        ),
      ),
    );

    if (saved == true &&
        nameField.text.trim().isNotEmpty &&
        sourceField.text.trim().isNotEmpty) {
      await controller.addOrUpdateEntry(
        name: nameField.text,
        source: sourceField.text,
        mode: mode,
      );
    }
  }

  Widget _progressRow(BuildContext context, String name) {
    final progress = controller.progressFor(name);
    final percent = progress == null ? '' : '${(progress * 100).round()}%';
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: progress, minHeight: 6),
          ),
        ),
        const SizedBox(width: 8),
        Text(percent, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  Widget _errorChip(BuildContext context, String name) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: controller.errorFor(name) ?? '',
      child: _pill(controller.tr('status_failed'), cs.errorContainer,
          cs.onErrorContainer,
          icon: Icons.error_outline),
    );
  }

  Future<void> _confirmRemove(BuildContext context, Entry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(controller.tr('confirm_remove_title')),
        content: Text(
            controller.tr('confirm_remove_body').replaceAll('{name}', entry.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(controller.tr('btn_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(controller.tr('btn_remove')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.removeEntry(entry.name);
    }
  }

  Future<void> _showLogDialog(BuildContext context) async {
    final content = await controller.readLog();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(controller.tr('log_title')),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Text(
              content.isEmpty ? controller.tr('log_empty') : content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(controller.tr('btn_close')),
          ),
        ],
      ),
    );
  }
}
