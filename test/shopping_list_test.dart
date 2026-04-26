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
  });
}