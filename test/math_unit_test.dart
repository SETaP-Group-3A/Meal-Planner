import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/ingredient.dart';

// Pure helper functions, mirrors the private getters in the app.

/// Mirrors AddRecipeScreen._totalCalories:
///   calories-per-100g * user_grams / 100, summed across all picked ingredients.
int totalCalories(
  Map<String, int> pickedIngredients,
  Map<String, List<Ingredient>> inventory,
) {
  var total = 0.0;
  for (final entry in pickedIngredients.entries) {
    final options = inventory[entry.key];
    if (options != null && options.isNotEmpty) {
      total += (entry.value / 100) * options.first.calories;
    }
  }
  return total.round();
}

/// Mirrors RecipePage._scaledCalories:
///   (baseCalories * currentServings / defaultServings).round()
int scaledCalories(int base, int current, int defaultServings) =>
    (base * current / defaultServings).round();

void main() {
  group('AddRecipeScreen — proportional calorie calculation', () {
    test('MU-01: 200 g of a 500 kcal/100 g ingredient equals 1000 kcal', () {
      final inventory = {
        'Flour': [
          Ingredient(name: 'Flour', cost: 1.0, distance: 0.5, calories: 500),
        ],
      };
      expect(totalCalories({'Flour': 200}, inventory), 1000);
    });

    test(
      'MU-02: two ingredients sum their proportional calories correctly',
      () {
        // 150 g rice  @ 360 kcal/100 g = 540 kcal
        // 50 g oil    @ 900 kcal/100 g = 450 kcal
        // total = 990 kcal
        final inventory = {
          'Rice': [
            Ingredient(name: 'Rice', cost: 1.0, distance: 0.5, calories: 360),
          ],
          'Oil': [
            Ingredient(name: 'Oil', cost: 2.0, distance: 0.5, calories: 900),
          ],
        };
        expect(totalCalories({'Rice': 150, 'Oil': 50}, inventory), 990);
      },
    );

    test('MU-03: unknown ingredient is silently ignored and returns 0', () {
      expect(totalCalories({'GhostFood': 100}, {}), 0);
    });
  });

  group('RecipePage — serving size scaling', () {
    test('MU-04: doubling servings doubles the calorie count', () {
      // base 400, default 2, current 4  →  800
      expect(scaledCalories(400, 4, 2), 800);
    });

    test('MU-05: halving servings halves the calorie count', () {
      // base 300, default 2, current 1  →  150
      expect(scaledCalories(300, 1, 2), 150);
    });

    test('MU-06: non-even scaling rounds to the nearest integer', () {
      // 350 * 3 / 2 = 525.0  →  525
      expect(scaledCalories(350, 3, 2), 525);
    });
  });
}