import 'dart:io';

import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'src/app/app_controller.dart';
import 'src/app/home_screen.dart';
import 'src/app/theme.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Configura o iniciar-com-o-sistema. O login injeta o argumento --hidden,
  // que fazemos o app abrir oculto na bandeja.
  final info = await PackageInfo.fromPlatform();
  launchAtStartup.setup(
    appName: info.appName,
    appPath: Platform.resolvedExecutable,
    args: ['--hidden'],
  );

  final startHidden = args.contains('--hidden');

  const windowOptions = WindowOptions(
    size: Size(560, 720),
    center: true,
    title: 'FileKnight',
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // Ao fechar a janela, escondemos na bandeja em vez de encerrar o app.
    await windowManager.setPreventClose(true);
    if (startHidden) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  });

  runApp(const FileKnightApp());
}

class FileKnightApp extends StatefulWidget {
  const FileKnightApp({super.key});

  @override
  State<FileKnightApp> createState() => _FileKnightAppState();
}

class _FileKnightAppState extends State<FileKnightApp>
    with WindowListener, TrayListener {
  final AppController _controller = AppController();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    _startup();
  }

  Future<void> _startup() async {
    await _controller.load();
    await _initTray();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    _controller.dispose();
    super.dispose();
  }

  // -- Bandeja do sistema -----------------------------------------------------

  Future<void> _initTray() async {
    try {
      await trayManager.setIcon(
        Platform.isMacOS
            ? 'assets/tray/tray_mac.png'
            : Platform.isWindows
                ? 'assets/tray/tray.ico'
                : 'assets/tray/tray_color.png',
        isTemplate: Platform.isMacOS,
      );
      await trayManager.setToolTip('FileKnight');
      await _rebuildTrayMenu();
    } catch (_) {
      // Se a bandeja não estiver disponível, o app segue funcionando normal.
    }
  }

  Future<void> _rebuildTrayMenu() async {
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(key: 'show', label: _controller.tr('tray_open')),
      MenuItem(key: 'backup_all', label: _controller.tr('backup_all')),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: _controller.tr('tray_quit')),
    ]));
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayIconMouseDown() {
    // No macOS o clique no ícone da barra abre o menu; nos demais, mostra a janela.
    if (Platform.isMacOS) {
      trayManager.popUpContextMenu();
    } else {
      _showWindow();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        _showWindow();
      case 'backup_all':
        _controller.runAll();
      case 'quit':
        _quit();
    }
  }

  Future<void> _quit() async {
    await trayManager.destroy();
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  // -- Janela -----------------------------------------------------------------

  @override
  void onWindowClose() async {
    // Com setPreventClose ligado, o fechar é interceptado: escondemos na bandeja.
    if (await windowManager.isPreventClose()) {
      await windowManager.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reconstrói o MaterialApp quando o tema escolhido nas configurações muda.
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'FileKnight',
          debugShowCheckedModeBanner: false,
          theme: buildFileKnightTheme(Brightness.light),
          darkTheme: buildFileKnightTheme(Brightness.dark),
          themeMode: _themeModeFrom(_controller.config.themeMode),
          home: HomeScreen(controller: _controller),
        );
      },
    );
  }

  // Converte o valor salvo no config para o ThemeMode do Flutter.
  ThemeMode _themeModeFrom(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
