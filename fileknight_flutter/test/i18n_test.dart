import 'package:flutter_test/flutter_test.dart';
import 'package:fileknight/src/core/i18n.dart';

void main() {
  group('i18n', () {
    test('falls back to English for unknown codes', () {
      final strings = loadLocale('xx');
      expect(strings['run_backup'], 'Copy');
    });

    test('loads Brazilian Portuguese strings', () {
      final strings = loadLocale('pt-BR');
      expect(strings['run_backup'], 'Copiar');
    });

    test('translate returns the key itself when it is missing', () {
      expect(translate(const <String, String>{}, 'missing_key'), 'missing_key');
    });
  });
}
