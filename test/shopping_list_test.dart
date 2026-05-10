import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meal_planner/models/ingredient.dart';
import 'package:meal_planner/models/shopping_list_item.dart';
import 'package:meal_planner/shopping_list.dart';
import 'package:meal_planner/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('Shopping List - updateQuantity', () {
    setUp(() {
      final shoppingList = ShoppingList();
      shoppingList.shoppingItems.clear();
      shoppingList.shoppingItems.add(
        ShoppingListItem(
          ingredient: Ingredient(
            name: 'Flour',
            cost: 1.0,
            distance: 2.0,
            calories: 100,
          ),
        ),
      );
    });

    test('Increment quantity of shopping list item', () {
      final shoppingList = ShoppingList();
      shoppingList.updateQuantity(0, 1);

      expect(shoppingList.items[0].quantity, 2);
    });

    test('Decrement quantity of shopping list item removes item at zero', () {
      final shoppingList = ShoppingList();
      shoppingList.updateQuantity(0, -1);

      expect(shoppingList.items.length, 0);
    });

    test('Invalid index for updating quantity does nothing', () {
      final shoppingList = ShoppingList();
      shoppingList.updateQuantity(-1, 1);

      expect(shoppingList.items[0].quantity, 1);
    });

    test('Zero change keeps quantity the same', () {
      final shoppingList = ShoppingList();
      shoppingList.updateQuantity(0, 0);

      expect(shoppingList.items[0].quantity, 1);
    });
  });

  group('Shopping List - addRecipe/regenerateList', () {
    setUp(() {
      final shoppingList = ShoppingList();
      shoppingList.shoppingItems.clear();
    });

    // Functions to calculate optimized list so testing the functions have something to compare against
    int totalQuantity(ShoppingList list) =>
        list.items.fold(0, (sum, item) => sum + item.quantity);

    bool isAscendingByCost(List<ShoppingListItem> items) {
      for (int i = 1; i < items.length; i++) {
        if (items[i - 1].totalCost > items[i].totalCost) return false;
      }
      return true;
    }

    bool isAscendingByDistance(List<ShoppingListItem> items) {
      for (int i = 1; i < items.length; i++) {
        if (items[i - 1].ingredient.distance > items[i].ingredient.distance) {
          return false;
        }
      }
      return true;
    }

    bool isDescendingByCalories(List<ShoppingListItem> items) {
      for (int i = 1; i < items.length; i++) {
        if (items[i - 1].ingredient.calories < items[i].ingredient.calories) {
          return false;
        }
      }
      return true;
    }

    // Must use async tests to await the async functions being tested as they rely on database calls
    test('addRecipe(r-1, cost) adds recipe ingredients', () async {
      final shoppingList = ShoppingList();
      final before = totalQuantity(shoppingList);

      await shoppingList.addRecipe('r-1', 'cost');

      expect(totalQuantity(shoppingList), before + 3);
      expect(shoppingList.items, isNotEmpty);
    });

    test('addRecipe(r-2, distance) adds recipe ingredients', () async {
      final shoppingList = ShoppingList();
      final before = totalQuantity(shoppingList);

      await shoppingList.addRecipe('r-2', 'distance');

      expect(totalQuantity(shoppingList), before + 3);
      expect(shoppingList.items, isNotEmpty);
    });

    test('addRecipe(r-1, calories) adds recipe ingredients', () async {
      final shoppingList = ShoppingList();
      final before = totalQuantity(shoppingList);

      await shoppingList.addRecipe('r-1', 'calories');

      expect(totalQuantity(shoppingList), before + 3);
      expect(shoppingList.items, isNotEmpty);
    });

    test('addRecipe(invalid, cost) adds no items', () async {
      final shoppingList = ShoppingList();
      final before = totalQuantity(shoppingList);

      await shoppingList.addRecipe('recipe_id', 'cost');

      expect(totalQuantity(shoppingList), before);
    });

    test('addRecipe(r-1, invalid sort) still adds items (current behavior)',
        () async {
      final shoppingList = ShoppingList();
      final before = totalQuantity(shoppingList);

      await shoppingList.addRecipe('r-1', 'money');

      expect(totalQuantity(shoppingList), before + 3);
    });

    test('regenerateList(cost) returns list sorted by total cost asc', () async {
      final shoppingList = ShoppingList();
      await shoppingList.addRecipe('r-1', 'cost');
      await shoppingList.addRecipe('r-2', 'cost');

      await shoppingList.regenerateList('cost');

      expect(isAscendingByCost(shoppingList.items), isTrue);
    });

    test('regenerateList(distance) returns list sorted by distance asc',
        () async {
      final shoppingList = ShoppingList();
      await shoppingList.addRecipe('r-1', 'distance');
      await shoppingList.addRecipe('r-2', 'distance');

      await shoppingList.regenerateList('distance');

      expect(isAscendingByDistance(shoppingList.items), isTrue);
    });

    test('regenerateList(calories) returns list sorted by calories desc',
        () async {
      final shoppingList = ShoppingList();
      await shoppingList.addRecipe('r-1', 'calories');
      await shoppingList.addRecipe('r-2', 'calories');

      await shoppingList.regenerateList('calories');

      expect(isDescendingByCalories(shoppingList.items), isTrue);
    });

    test('regenerateList(invalid) keeps same item set size', () async {
      final shoppingList = ShoppingList();
      await shoppingList.addRecipe('r-1', 'cost');
      await shoppingList.addRecipe('r-2', 'distance');
      final beforeLen = shoppingList.items.length;

      await shoppingList.regenerateList('12');

      expect(shoppingList.items.length, beforeLen);
    });
  });

  group('DatabaseService - findBestIngredientOption', () {
    test('findBestIngredientOption("Flour", cost) returns lowest cost',
        () async {
      final ingredient =
          await DatabaseService.instance.getBestIngredientOption('Flour', 'cost');

      expect(ingredient, isNotNull);
      expect(ingredient!.name, 'Flour (Aldi)');
    });

    test('findBestIngredientOption("Milk", distance) returns lowest distance',
        () async {
      final ingredient = await DatabaseService.instance
          .getBestIngredientOption('Milk', 'distance');

      expect(ingredient, isNotNull);
      expect(ingredient!.name, 'Milk (Waitrose)');
    });

    test('findBestIngredientOption("Flour", calories) returns fewest calories',
        () async {
      final ingredient = await DatabaseService.instance
          .getBestIngredientOption('Flour', 'calories');

      expect(ingredient, isNotNull);
      expect(ingredient!.calories, 360);
    });

    test('findBestIngredientOption(invalid ingredient, cost) returns null',
        () async {
      final ingredient =
          await DatabaseService.instance.getBestIngredientOption('50', 'cost');

      expect(ingredient, isNull);
    });

    test('findBestIngredientOption("Flour", invalid sort) returns first option',
        () async {
      final ingredient =
          await DatabaseService.instance.getBestIngredientOption('Flour', '50');

      expect(ingredient, isNotNull);
      expect(ingredient!.name, 'Flour (Aldi)');
    });
  });
}