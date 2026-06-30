import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fileknight/src/core/path_utils.dart';

void main() {
  final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

  group('expandUserAndVars', () {
    test('expands a leading ~ to the home directory', () {
      if (home == null) return;
      expect(expandUserAndVars('~/Desktop'), '$home/Desktop');
    });

    test('leaves an absolute path unchanged', () {
      expect(expandUserAndVars('/tmp/save.co2'), '/tmp/save.co2');
    });

    test('expands a \$VAR style environment variable', () {
      if (home == null) return;
      expect(expandUserAndVars(r'$HOME/games'), '$home/games');
    });

    test('keeps unknown variables untouched', () {
      expect(expandUserAndVars(r'$FK_DOES_NOT_EXIST/x'), r'$FK_DOES_NOT_EXIST/x');
    });
  });
}
