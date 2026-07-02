// Expansão de caminhos multiplataforma (~ e variáveis de ambiente).

import 'dart:io';

/// O diretório home do usuário, ou null quando não dá para determinar.
String? homeDirectory() =>
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

/// Expande `~`, `$VAR`, `${VAR}` e `%VAR%` em um caminho cru.
///
/// Variáveis desconhecidas ficam como estão. A ordem de expansão segue a
/// versão Python: variáveis de ambiente primeiro, depois o `~` inicial.
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
