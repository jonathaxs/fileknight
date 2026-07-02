// Tema Material 3 do FileKnight (construído a partir de uma única cor semente).

import 'package:flutter/material.dart';

/// Um azul-royal/aço evoca a identidade de "cavaleiro".
const Color _seedColor = Color(0xFF3457D5);

ThemeData buildFileKnightTheme(Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    ),
  );
}
