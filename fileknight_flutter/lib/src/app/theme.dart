// Material 3 theme for FileKnight (built from a single seed color).

import 'package:flutter/material.dart';

/// A royal/steel blue evokes the "knight" identity.
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
