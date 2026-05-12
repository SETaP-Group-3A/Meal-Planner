import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/recipe.dart';
import 'package:meal_planner/recipe_page.dart';

/// A minimal recipe with known calories used across all widget tests.
final _recipe = Recipe(
  id: 'widget-test-1',
  name: 'Test Pancakes',
  requiredIngredients: ['Flour', 'Eggs'],
  prepTimeMinutes: 15,
  allergens: [],
  calories: 400,
  macros: Macros(proteinG: 10, carbsG: 50, fatG: 12),
  nutrients: {},
);

Widget _buildApp() => MaterialApp(home: RecipePage(recipe: _recipe));

void main() {
  testWidgets(
    'RW-01: recipe page renders with both + and - serving buttons visible',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    },
  );

  testWidgets(
    'RW-02: tapping + increments the displayed serving count from 2 to 3',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      expect(find.text('Servings: 2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Servings: 3'), findsOneWidget);
    },
  );

  testWidgets(
    'RW-03: tapping - decrements serving count and does not go below 1',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp());

      // 2 → 1
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('Servings: 1'), findsOneWidget);

      // should stay at 1 (button is disabled)
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(find.text('Servings: 1'), findsOneWidget);
    },
  );
}
