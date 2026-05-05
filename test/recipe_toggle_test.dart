import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/recipe.dart';
import 'package:meal_planner/recipe_page.dart';

/// Builds a bare [MaterialApp] wrapping [RecipePage] so the widget can render.
Widget _buildTestApp(Recipe recipe) {
  return MaterialApp(home: RecipePage(recipe: recipe));
}

/// A minimal recipe with known values used across all toggle tests.
final _testRecipe = Recipe(
  id: 'test-1',
  name: 'Test Recipe',
  requiredIngredients: ['Eggs', 'Milk'],
  prepTimeMinutes: 10,
  allergens: ['Dairy', 'Eggs'],
  calories: 350,
  macros: Macros(proteinG: 20.0, carbsG: 30.0, fatG: 15.0),
  nutrients: {'Iron (mg)': 2.5, 'Vitamin C (mg)': 10.0},
);

void main() {
  testWidgets('TR-04: Toggle basic/advanced view', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp(_testRecipe));

    // Basic fields visible by default.
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('• Eggs'), findsOneWidget);
    expect(find.text('• Milk'), findsOneWidget);
    expect(find.text('Prep Time: 10 min'), findsOneWidget);
    expect(find.text('Allergens: Dairy, Eggs'), findsOneWidget);

    // Advanced section headers should not exist yet.
    expect(find.text('Calories'), findsNothing);
    expect(find.text('Macros'), findsNothing);
    expect(find.text('Nutrients'), findsNothing);

    // Flip the toggle to Advanced.
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Advanced section headers now visible.
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Macros'), findsOneWidget);
    expect(find.text('Nutrients'), findsOneWidget);

    // Basic fields should still be present.
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Prep Time: 10 min'), findsOneWidget);

    // Flip back to Basic.
    await tester.tap(find.byType(Switch));
    await tester.pump();

    // Advanced section headers gone again.
    expect(find.text('Calories'), findsNothing);
    expect(find.text('Macros'), findsNothing);
    expect(find.text('Nutrients'), findsNothing);
  });
}
