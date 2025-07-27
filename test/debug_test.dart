import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swaad_seva/main.dart';

void main() {
  testWidgets('Debug what appears on user type selection screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SwaadSevaApp());

    // Wait for splash screen
    await tester.pumpAndSettle(const Duration(seconds: 4));
    
    // Print all text widgets on screen for debugging
    final textFinder = find.byType(Text);
    final texts = tester.widgetList<Text>(textFinder);
    
    print('All text widgets found:');
    for (var text in texts) {
      print('Text: "${text.data}"');
    }
    
    // Verify we're on the user type selection screen
    expect(find.textContaining('Welcome to SwaadSeva'), findsOneWidget);
  });
}
