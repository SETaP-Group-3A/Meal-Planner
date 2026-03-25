import 'models/ingredient.dart';
import 'models/shopping_list_item.dart';
import 'services/database_service.dart';

class ShoppingList {
  static final ShoppingList _instance = ShoppingList._internal();

  factory ShoppingList() => _instance;

  ShoppingList._internal();

  final List<ShoppingListItem> shoppingItems = [];
  final List<String> _addedRecipeHistory = [];


  final List<String> _ingredientNames = [];


  List<String> get ingredientNames => List.unmodifiable(_ingredientNames);


  void addIngredientName(String name) {
    if (!_ingredientNames.contains(name)) {
      _ingredientNames.add(name);
    }
  }


  Future<void> addRecipeById(String recipeId) async {
    await addRecipe(recipeId, 'cost');
  }

  Future<void> addRecipe(String recipeId, String sortBy) async {
    _addedRecipeHistory.add(recipeId);
    await _processRecipeAddition(recipeId, sortBy);
  }

  Future<void> regenerateList(String sortBy) async {
    shoppingItems.clear();
    for (var recipeId in _addedRecipeHistory) {
      await _processRecipeAddition(recipeId, sortBy);
    }
  }

  Future<void> _processRecipeAddition(String recipeId, String sortBy) async {
    final bestIngredients = await DatabaseService.instance
        .getBestIngredientOptionsForRecipe(recipeId, sortBy);

    for (var ingredient in bestIngredients) {
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

  void _sortItems(String sortBy) {
    switch (sortBy.toLowerCase()) {
      case 'cost':
        shoppingItems.sort((a, b) => a.totalCost.compareTo(b.totalCost));
        break;
      case 'distance':
        shoppingItems.sort((a, b) => a.ingredient.distance.compareTo(b.ingredient.distance));
        break;
      case 'calories':
        shoppingItems.sort((a, b) => b.ingredient.calories.compareTo(a.ingredient.calories));
        break;
      default:
        break;
    }
  }
}
