import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swaad_seva/main.dart';

void main() {
  group('Navigation Flow Tests', () {
    testWidgets('Basic navigation flow test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const SwaadSevaApp());

      // Verify that the splash screen is shown
      expect(find.text('SwaadSeva'), findsOneWidget);
      
      // Wait for the splash screen timer and animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      // Verify navigation to user type selection screen
      expect(find.textContaining('Welcome to SwaadSeva'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Home Cook'), findsOneWidget);
      expect(find.text('Delivery Partner'), findsOneWidget);
      
      // Tap on Customer user type
      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();
      
      // Verify navigation to login screen
      expect(find.text('Login as Customer'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
    
    testWidgets('Back navigation test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const SwaadSevaApp());
      
      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      // Navigate to login screen
      await tester.tap(find.text('Home Cook'));
      await tester.pumpAndSettle();
      
      // Verify we're on login screen
      expect(find.text('Login as Home Cook'), findsOneWidget);
      
      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();
      
      // Verify we're back to user type selection
      expect(find.textContaining('Welcome to SwaadSeva'), findsOneWidget);
    });
  });
}
