// Cross-platform path expansion (~ and environment variables).

import 'dart:io';

/// The user's home directory, or null when it cannot be determined.
String? homeDirectory() =>
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

/// Expand `~`, `$VAR`, `${VAR}` and `%VAR%` in a raw path string.
///
/// Unknown variables are left untouched. Expansion order matches the Python
/// version: environment variables first, then a leading `~`.
String expandUserAndVars(String raw) {
  var result = raw;

  result = result.replaceAllMapped(
    RegExp(r'%([A-Za-z_][A-Za-z0-9_]*)%'),
    (m) => Platform.environment[m[1]!] ?? m[0]!,
  );
  result = result.replaceAllMapped(
    RegExp(r'\$\{([A-Za-z_][A-Za-z0-9_]*)\}'),
    (m) => Platform.environment[m[1]!] ?? m[0]!,
  );
  result = result.replaceAllMapped(
    RegExp(r'\$([A-Za-z_][A-Za-z0-9_]*)'),
    (m) => Platform.environment[m[1]!] ?? m[0]!,
  );

  if (result == '~' || result.startsWith('~/') || result.startsWith(r'~\')) {
    final home = homeDirectory();
    if (home != null && home.isNotEmpty) {
      result = home + result.substring(1);
    }
  }

  return result;
}
