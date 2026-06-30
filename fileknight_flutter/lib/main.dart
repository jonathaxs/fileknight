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
    return MaterialApp(
      title: 'FileKnight',
      debugShowCheckedModeBanner: false,
      theme: buildFileKnightTheme(Brightness.light),
      darkTheme: buildFileKnightTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: HomeScreen(controller: _controller),
    );
  }
}
