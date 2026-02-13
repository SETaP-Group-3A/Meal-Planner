import 'mock_data.dart';

class ShoppingList {
  static final ShoppingList _instance = ShoppingList._internal();

  factory ShoppingList() {
    return _instance;
  }

  ShoppingList._internal();

  final List<Ingredient> shoppingItems = [];

  // [x] 1. Method for adding a recipe with specific conditions
  void addRecipe(String recipeId, String sortBy) {
    // [x] 2. Implement specific ingredient fetching logic (Mocked)
    final ingredients = _fetchIngredients(recipeId);

    // [x] 3. Implement preference filtering logic
    final sortedIngredients = _processIngredients(ingredients, sortBy);

    shoppingItems.addAll(sortedIngredients);
  }

  List<Ingredient> _fetchIngredients(String recipeId) {
    // Return mock data if available, otherwise return empty list or generic placeholder
    if (mockRecipes.containsKey(recipeId)) {
      return List.from(mockRecipes[recipeId]!); // Return a copy
    }
    // Fallback if recipe not found in mock data
    return [];
  }

  List<Ingredient> _processIngredients(List<Ingredient> ingredients, String sortBy) {
    // Sort logic based on 'sortBy' criteria
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
        // No sorting or default sorting
        break;
    }
    return ingredients;
  }
}
