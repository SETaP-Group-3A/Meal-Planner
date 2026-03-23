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
    final requiredIngredientNames = await _fetchRequirements(recipeId);

    for (var name in requiredIngredientNames) {
      final bestOption = await _findBestIngredientOption(name, sortBy);
      
      if (bestOption != null) {
        _addOrIncrementIngredient(bestOption);
      }
    }

    _sortItems(sortBy);
  }

  Future<Ingredient?> _findBestIngredientOption(String ingredientName, String sortBy) async {
    final db = DatabaseService.instance;
    // Get all options for the generic ingredient (e.g. "Flour" -> ["Flour (Aldi)", "Flour (Waitrose)"])
    final options = await db.getIngredientsByGenericName(ingredientName);
    
    if (options.isEmpty) return null;

    switch (sortBy.toLowerCase()) {
      case 'cost':
        options.sort((a, b) => a.cost.compareTo(b.cost));
        break;
      case 'distance':
        options.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'nutritional_value':
      case 'calories':
        options.sort((a, b) => a.calories.compareTo(b.calories));
        break;
      default:
        break;
    }

    return options.first;
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

  Future<List<String>> _fetchRequirements(String recipeId) async {
    try {
      final db = DatabaseService.instance;
      final recipe = await db.getRecipeById(recipeId);
      return recipe?.requiredIngredients ?? [];
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
        shoppingItems.sort((a, b) => b.ingredient.calories.compareTo(a.ingredient.calories));
        break;
      default:
        break;
    }
  }
}
