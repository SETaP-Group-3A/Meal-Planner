import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/log_in.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginScreen basic tests', () {
    testWidgets('renders login screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      expect(find.text('Login'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('shows email required error (NO LOGIN BUTTON TAP)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LoginScreen()),
      );

      // leave email empty
      await tester.enterText(
        find.byType(TextField).at(1),
        'Password123',
      );

      // directly call handle login via button tap BUT avoid async success flow
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });
  });
}