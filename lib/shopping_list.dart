import 'models/ingredient.dart';
import 'mock_data.dart';

class ShoppingList {
  static final ShoppingList _instance = ShoppingList._internal();

  factory ShoppingList() {
    return _instance;
  }

  ShoppingList._internal();

  final List<Ingredient> shoppingItems = [];

  void addRecipe(String recipeId, String sortBy) {
    final ingredients = _fetchIngredients(recipeId);

    final sortedIngredients = _processIngredients(ingredients, sortBy);

    shoppingItems.addAll(sortedIngredients);
  }

  List<Ingredient> _fetchIngredients(String recipeId) {
    try {
      final recipe = mockRecipes.firstWhere((r) => r.id == recipeId);
      return List.from(recipe.ingredients);
    } catch (_) {
      return [];
    }
  }

  List<Ingredient> _processIngredients(List<Ingredient> ingredients, String sortBy) {
    switch (sortBy.toLowerCase()) {
      case 'cost':
        ingredients.sort((a, b) => a.cost.compareTo(b.cost));
        break;
      case 'distance':
        ingredients.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'nutritional_value':
      case 'calories':
        ingredients.sort((a, b) => a.calories.compareTo(b.calories));
        break;
      default:
        break;
    }
    return ingredients;
  }
}
