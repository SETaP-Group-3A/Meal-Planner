import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/sign_up.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignUpScreen basic tests', () {
    testWidgets('renders signup screen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SignUpScreen()),
      );

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('shows error when fields are empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SignUpScreen()),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('shows invalid email error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SignUpScreen()),
      );

      await tester.enterText(
        find.byType(TextField).at(0),
        'invalid',
      );

      await tester.enterText(
        find.byType(TextField).at(1),
        'Password123',
      );

      await tester.enterText(
        find.byType(TextField).at(2),
        'Password123',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('shows password mismatch error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SignUpScreen()),
      );

      await tester.enterText(
        find.byType(TextField).at(0),
        'test@test.com',
      );

      await tester.enterText(
        find.byType(TextField).at(1),
        'Password123',
      );

      await tester.enterText(
        find.byType(TextField).at(2),
        'Password321',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows weak password error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SignUpScreen()),
      );

      await tester.enterText(
        find.byType(TextField).at(0),
        'test@test.com',
      );

      await tester.enterText(
        find.byType(TextField).at(1),
        'weak',
      );

      await tester.enterText(
        find.byType(TextField).at(2),
        'weak',
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(
        find.textContaining('Password must'),
        findsOneWidget,
      );
    });
  });
}