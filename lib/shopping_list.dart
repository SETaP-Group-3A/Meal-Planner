import 'package:shared_preferences/shared_preferences.dart';

import 'models/ingredient.dart';
import 'models/shopping_list_item.dart';
import 'services/database_service.dart';

class ShoppingList {
  static final ShoppingList _instance = ShoppingList._internal();

  factory ShoppingList() => _instance;

  ShoppingList._internal();

  final List<ShoppingListItem> shoppingItems = [];
  String? _loadedAccountId;

  List<ShoppingListItem> get items => List.unmodifiable(shoppingItems);

  String _ingredientKey(Ingredient ingredient) => ingredient.genericName;

  Future<String?> _currentAccountEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accountEmail');
  }

  Future<String?> _currentAccountId() async {
    final accountEmail = await _currentAccountEmail();
    return DatabaseService.instance.resolveAccountIdFromEmail(accountEmail);
  }

  Future<void> initialize() async {
    final accountId = await _currentAccountId();

    if (accountId == null) {
      _loadedAccountId = null;
      shoppingItems.clear();
      return;
    }

    if (_loadedAccountId == accountId) {
      return;
    }

    shoppingItems
      ..clear()
      ..addAll(await DatabaseService.instance.loadShoppingListItemsForAccount(accountId));

    _loadedAccountId = accountId;
  }

  Future<void> _persistCurrentState() async {
    final accountId = await _currentAccountId();
    if (accountId == null) return;

    await DatabaseService.instance.replaceShoppingListItemsForAccount(
      accountId: accountId,
      items: shoppingItems,
    );

    _loadedAccountId = accountId;
  }

  Future<void> addRecipeById(String recipeId) async {
    await addRecipe(recipeId, 'cost');
  }

  Future<void> addRecipe(String recipeId, String sortBy) async {
    await initialize();
    final bestIngredients = await DatabaseService.instance
        .getBestIngredientOptionsForRecipe(recipeId, sortBy);

    for (final ingredient in bestIngredients) {
      _addOrIncrementIngredient(ingredient);
    }

    _sortItems(sortBy);
    await _persistCurrentState();
  }

  Future<void> regenerateList(String sortBy) async {
    await initialize();

    final updatedItems = <ShoppingListItem>[];
    for (final item in shoppingItems) {
      final bestIngredient = await DatabaseService.instance
          .getBestIngredientOption(_ingredientKey(item.ingredient), sortBy);

      if (bestIngredient != null) {
        updatedItems.add(
          ShoppingListItem(
            ingredient: bestIngredient,
            quantity: item.quantity,
          ),
        );
      }
    }

    shoppingItems
      ..clear()
      ..addAll(updatedItems);

    _sortItems(sortBy);
    await _persistCurrentState();
  }

  void _addOrIncrementIngredient(Ingredient ingredient) {
    final ingredientKey = _ingredientKey(ingredient);

    try {
      final existingItem = shoppingItems.firstWhere(
        (item) => _ingredientKey(item.ingredient) == ingredientKey,
      );
      existingItem.quantity++;
    } catch (_) {
      shoppingItems.add(ShoppingListItem(ingredient: ingredient));
    }
  }

  void updateQuantity(int index, int change) {
    if (index < 0 || index >= shoppingItems.length) {
      return;
    }

    shoppingItems[index].quantity += change;

    if (shoppingItems[index].quantity <= 0) {
      shoppingItems.removeAt(index);
    }

    _persistCurrentState();
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
