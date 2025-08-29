import 'package:flutter_test/flutter_test.dart';

import 'package:swaad_seva/main.dart';

void main() {
  group('Navigation Flow Tests', () {
    testWidgets('Complete navigation flow test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const SwaadSevaApp());

      // Verify that the splash screen is shown
      expect(find.text('SwaadSeva'), findsOneWidget);
      
      // Wait for the splash screen timer and animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      // Verify navigation to service selection screen
      expect(find.textContaining('Welcome to SwaadSeva'), findsOneWidget);
      expect(find.text('HOME-COOKED TIFFIN DELIVERY'), findsOneWidget);
      expect(find.text('COOK-ON-CALL'), findsOneWidget);
      
      // Tap on Tiffin Delivery service
      await tester.tap(find.text('HOME-COOKED TIFFIN DELIVERY'));
      await tester.pumpAndSettle();
      
      // Verify navigation to user type selection screen for tiffin service
      expect(find.textContaining('Choose your role for Tiffin Delivery'), findsOneWidget);
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
    
    testWidgets('Cook-on-Call service flow test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const SwaadSevaApp());
      
      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      // Tap on Cook-on-Call service
      await tester.tap(find.text('COOK-ON-CALL'));
      await tester.pumpAndSettle();
      
      // Verify navigation to user type selection for cook service
      expect(find.textContaining('Choose your role for Cook-on-Call'), findsOneWidget);
      expect(find.text('Customer'), findsOneWidget);
      expect(find.text('Home Cook'), findsOneWidget);
      // Note: No delivery partner for cook-on-call service
      expect(find.text('Delivery Partner'), findsNothing);
    });
  });
}
