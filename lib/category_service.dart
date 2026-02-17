import 'models/category.dart';
import 'dart:math';

class CategoryService {
  static final CategoryService instance = CategoryService._internal();

  CategoryService._internal();

  final List<Category> _categories = [
    Category(
      id: 'c-snacks',
      name: 'Snacks',
      targetRoute: '/category',
      recipeIds: ['r-1', 'r-2'],
      // example using an asset (prefix with "asset:")
      imageUrl: 'https://img.freepik.com/premium-psd/appetizer-platter-with-crackers-dip-delicious-snack-parties-gatherings_1270823-26939.jpg?semt=ais_hybrid&w=740&q=80',
    ),
    Category(
      id: 'c-healthy',
      name: 'Healthy',
      targetRoute: '/category',
      recipeIds: ['r-2', 'r-3'],
      // example using a network image
      imageUrl: 'https://freepngimg.com/png/13866-healthy-food-png-pic',
    ),
    Category(id: 'c-favourites', name: 'Favourites', targetRoute: '/category', recipeIds: [], imageUrl: 'https://www.freepik.com/free-photos-vectors/stars-png'),
  ];

  List<Category> get categories => List.unmodifiable(_categories);

  Category addCategory({required String name, String? targetRoute, List<String>? recipeIds}) {
    final id = 'c-${Random().nextInt(100000)}';
    final cat = Category(id: id, name: name, targetRoute: targetRoute, recipeIds: recipeIds);
    _categories.add(cat);
    return cat;
  }

  void updateCategory(String id, {String? name, String? targetRoute}) {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i != -1) {
      if (name != null) _categories[i].name = name;
      _categories[i].targetRoute = targetRoute;
    }
  }

  void removeCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
  }

  Category? getById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

 

  List<String> getRecipeIdsForCategory(String id) {
    final c = getById(id);
    return c == null ? [] : List.unmodifiable(c.recipeIds);
  }

  void addRecipeToCategory(String categoryId, String recipeId) {
    final c = getById(categoryId);
    if (c == null) return;
    if (!c.recipeIds.contains(recipeId)) c.recipeIds.add(recipeId);
  }

  void removeRecipeFromCategory(String categoryId, String recipeId) {
    final c = getById(categoryId);
    c?.recipeIds.remove(recipeId);
  }

  void setRecipesForCategory(String categoryId, List<String> recipeIds) {
    final c = getById(categoryId);
    if (c == null) return;
    c.recipeIds
      ..clear()
      ..addAll(recipeIds);
  }
}