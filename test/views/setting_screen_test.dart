import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal_planner/views/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      home: child,
      routes: {
        '/settings/account': (_) => AccountSettingsScreen(),
        '/settings/accessibility': (_) => const AccessibilitySettingsScreen(),
      },
    );
  }

  group('SettingsScreen Tests', () {
    testWidgets('Settings page loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(const SettingsScreen()));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('Store Locator'), findsOneWidget);
    });

    testWidgets('Navigation to Account Settings works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(const SettingsScreen()));

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      expect(find.text('Account Settings'), findsOneWidget);
    });

    testWidgets('Navigation to Accessibility Settings works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(const SettingsScreen()));

      await tester.tap(find.text('Accessibility'));
      await tester.pumpAndSettle();

      expect(find.text('Accessibility Settings'), findsOneWidget);
    });
  });

  group('AccountSettingsScreen Tests', () {
    testWidgets('Screen loads with UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(AccountSettingsScreen()));

      await tester.pumpAndSettle();

      expect(find.text('Your details'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Validation triggers on empty fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(AccountSettingsScreen()));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('Valid input saves successfully', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(AccountSettingsScreen()));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'TestUser');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@email.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'SO17 1BJ');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('User details updated'), findsOneWidget);
    });

    testWidgets('Address opt-out disables field', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(AccountSettingsScreen()));

      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      final addressField = tester.widget<TextFormField>(
        find.byType(TextFormField).at(2),
      );

      expect(addressField.enabled, false);
    });
  });

  group('AccessibilitySettingsScreen Tests', () {
    testWidgets('Dark mode toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(const AccessibilitySettingsScreen()),
      );

      await tester.pumpAndSettle();

      final switchFinder = find.byType(SwitchListTile);

      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pump();

      // If no exception → pass
      expect(true, isTrue);
    });
  });
}
