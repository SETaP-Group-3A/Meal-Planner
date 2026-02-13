import 'models/ingredient.dart';
import 'models/shopping_list_item.dart';
import 'mock_data.dart';

class ShoppingList {
  static final ShoppingList _instance = ShoppingList._internal();

  factory ShoppingList() {
    return _instance;
  }

  ShoppingList._internal();

  final List<ShoppingListItem> shoppingItems = [];

  void addRecipe(String recipeId, String sortBy) {
    final ingredients = _fetchIngredients(recipeId);

    for (var ingredient in ingredients) {
      _addOrIncrementIngredient(ingredient);
    }

    _sortItems(sortBy);
  }

  void _addOrIncrementIngredient(Ingredient ingredient) {
    try {
      final existingItem = shoppingItems.firstWhere(
        (item) => item.ingredient.name == ingredient.name
      );
      existingItem.quantity++;
    } catch (_) {
      // Not found, add new
      shoppingItems.add(ShoppingListItem(ingredient: ingredient));
    }
  }

  void updateQuantity(int index, int change) {
    if (index >= 0 && index < shoppingItems.length) {
      shoppingItems[index].quantity += change;
      if (shoppingItems[index].quantity <= 0) {
        shoppingItems.removeAt(index);
      }
    }
  }

  List<Ingredient> _fetchIngredients(String recipeId) {
    try {
      final recipe = mockRecipes.firstWhere((r) => r.id == recipeId);
      return List.from(recipe.ingredients);
    } catch (_) {
      return [];
    }
  }

  void _sortItems(String sortBy) {
    switch (sortBy.toLowerCase()) {
      case 'cost':
        shoppingItems.sort((a, b) => a.totalCost.compareTo(b.totalCost));
        break;
      case 'distance':
        shoppingItems.sort((a, b) => a.ingredient.distance.compareTo(b.ingredient.distance));
        break;
      case 'nutritional_value':
      case 'calories':
        shoppingItems.sort((a, b) => a.totalCalories.compareTo(b.totalCalories));
        break;
      default:
        break;
    }
  }
}
