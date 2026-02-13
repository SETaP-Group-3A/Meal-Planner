import 'ingredient.dart';

class ShoppingListItem {
  final Ingredient ingredient;
  int quantity;

  ShoppingListItem({
    required this.ingredient,
    this.quantity = 1,
  });

  double get totalCost => ingredient.cost * quantity;
  int get totalCalories => ingredient.calories * quantity;
}
