import 'models/ingredient.dart';
import 'models/shopping_list_item.dart';
import 'mock_data.dart';

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


  void addRecipeById(String recipeId) {

    addRecipe(recipeId, 'cost');
  }

  void addRecipe(String recipeId, String sortBy) {
    _addedRecipeHistory.add(recipeId);
    _processRecipeAddition(recipeId, sortBy);
  }

  void regenerateList(String sortBy) {
    shoppingItems.clear();
    for (var recipeId in _addedRecipeHistory) {
      _processRecipeAddition(recipeId, sortBy);
    }
  }

  void _processRecipeAddition(String recipeId, String sortBy) {
    final requiredIngredientNames = _fetchRequirements(recipeId);

    for (var name in requiredIngredientNames) {
      final bestOption = _findBestIngredientOption(name, sortBy);
      
      if (bestOption != null) {
        _addOrIncrementIngredient(bestOption);
      }
    }

    _sortItems(sortBy);
  }

  Ingredient? _findBestIngredientOption(String ingredientName, String sortBy) {
    if (!marketInventory.containsKey(ingredientName)) return null;

    final options = List<Ingredient>.from(marketInventory[ingredientName]!);
    
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

  List<String> _fetchRequirements(String recipeId) {
    try {
      final recipe = mockRecipes.firstWhere((r) => r.id == recipeId);
      return recipe.requiredIngredients;
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
