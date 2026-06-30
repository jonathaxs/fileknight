import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fileknight/src/app/app_controller.dart';
import 'package:fileknight/src/app/home_screen.dart';
import 'package:fileknight/src/models/app_config.dart';
import 'package:fileknight/src/models/entry.dart';

void main() {
  testWidgets('home screen lists entries from the config', (tester) async {
    final controller = AppController()
      ..config = AppConfig(
        destinationRoot: '~/Backups',
        entries: const [Entry(name: 'Elden Ring', source: '~/saves')],
      )
      ..loading = false;

    await tester.pumpWidget(MaterialApp(home: HomeScreen(controller: controller)));

    expect(find.text('FileKnight'), findsOneWidget);
    expect(find.text('Elden Ring'), findsOneWidget);
  });
}
