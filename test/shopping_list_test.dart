import 'package:flutter_test/flutter_test.dart';

import 'package:meal_planner/models/ingredient.dart';
import 'package:meal_planner/models/shopping_list_item.dart';
import 'package:meal_planner/shopping_list.dart';
import 'package:meal_planner/services/database_service.dart';

void main() {
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
}