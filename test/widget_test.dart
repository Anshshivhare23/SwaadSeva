// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:swaad_seva/main.dart';

void main() {
  testWidgets('SwaadSeva app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SwaadSevaApp());

    // Verify that the splash screen is shown
    expect(find.text('SwaadSeva'), findsOneWidget);
    
    // Wait for the splash screen timer and animations to complete
    await tester.pumpAndSettle(const Duration(seconds: 4));
    
    // Verify navigation to user type selection screen
    expect(find.textContaining('Welcome to SwaadSeva'), findsOneWidget);
  });
}
