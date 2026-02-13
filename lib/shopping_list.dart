class ShoppingList {
  final List<String> shoppingItems = [];

  // [x] 1. Method for adding a recipe with specific conditions
  void addRecipe(String recipeId, String sortBy) {
    // [x] 2. Implement specific ingredient fetching logic (Mocked)
    final ingredients = _fetchIngredients(recipeId);

    // [x] 3. Implement preference filtering logic
    final sortedIngredients = _processIngredients(ingredients, sortBy);

    shoppingItems.addAll(sortedIngredients);
  }

  List<String> _fetchIngredients(String recipeId) {
    // TODO: Replace with actual data fetching
    return [
      'Ingredient 1 for $recipeId',
      'Ingredient 2 for $recipeId',
      'Ingredient 3 for $recipeId',
    ];
  }

  List<String> _processIngredients(List<String> ingredients, String sortBy) {
    // TODO: Implement actual sorting/filtering logic based on 'sortBy'
    // e.g. 'cost', 'distance', 'nutritional_value'
    // For now, we just pass them through.
    return ingredients;
  }
}
