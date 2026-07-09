import 'package:flutter/material.dart';

import 'src/app/app_controller.dart';
import 'src/app/home_screen.dart';
import 'src/app/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FileKnightApp());
}

class FileKnightApp extends StatefulWidget {
  const FileKnightApp({super.key});

  @override
  State<FileKnightApp> createState() => _FileKnightAppState();
}

class _FileKnightAppState extends State<FileKnightApp> {
  final AppController _controller = AppController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
