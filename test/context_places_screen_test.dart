import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focus_assistant/l10n/app_language.dart';
import 'package:focus_assistant/screens/context_places_screen.dart';
import 'package:focus_assistant/services/context_place_service.dart';

void main() {
  testWidgets('undo restores a deleted place', (tester) async {
    SharedPreferences.setMockInitialValues({
      'context_places':
          '[{"id":"work-1","type":"work","name":"Office","address":"Main Street 1"}]',
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ContextPlacesScreen(language: AppLanguage.english),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Office'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Office'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Office'), findsOneWidget);
    final stored = await ContextPlaceService.loadPlaces();
    expect(stored.single.id, 'work-1');
  });
}
