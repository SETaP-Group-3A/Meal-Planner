import 'models/category.dart';
import 'dart:math';
import 'package:meal_planner/services/database_service.dart';
import 'models/recipe.dart';

class CategoryService {
  static final CategoryService instance = CategoryService._internal();

  CategoryService._internal();

  final List<Category> _categories = [
    Category(
      id: 'c-snacks',
      name: 'Snacks',
      targetRoute: '/category',
      recipeIds: ['r-1', 'r-2'],
      imageUrl: 'https://img.freepik.com/premium-psd/appetizer-platter-with-crackers-dip-delicious-snack-parties-gatherings_1270823-26939.jpg?semt=ais_hybrid&w=740&q=80',
    ),
    Category(
      id: 'c-healthy',
      name: 'Healthy',
      targetRoute: '/category',
      recipeIds: ['r-2', 'r-3'],
      imageUrl: 'https://freepngimg.com/png/13866-healthy-food-png-pic',
    ),
    Category(id: 'c-favourites', name: 'Favourites', targetRoute: '/category', recipeIds: [], imageUrl: 'https://www.freepik.com/free-photos-vectors/stars-png'),
  ];


  List<Category> get categories => List.unmodifiable(_categories);


  Future<List<Category>> getAllCategories() async {
    try {
      return await DatabaseService.instance.getAllCategories();
    } catch (_) {
      return List.unmodifiable(_categories);
    }
  }

 
  Future<Category> addCategory({required String name, String? targetRoute, List<String>? recipeIds, String? imageUrl}) async {
    final id = 'c-${Random().nextInt(100000)}';
    final cat = Category(id: id, name: name, targetRoute: targetRoute, recipeIds: recipeIds ?? [], imageUrl: imageUrl);
    try {
      await DatabaseService.instance.createCategory(cat);
    } catch (_) {

    }
    _categories.add(cat);
    return cat;
  }


  Future<void> updateCategory(String id, {String? name, String? targetRoute, String? imageUrl}) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i != -1) {
      if (name != null) _categories[i].name = name;
      if (targetRoute != null) _categories[i].targetRoute = targetRoute;
      if (imageUrl != null) _categories[i].imageUrl = imageUrl;
    }

    try {
      final cat = await getById(id);
      if (cat != null) {
        final updated = Category(
          id: cat.id,
          name: name ?? cat.name,
          targetRoute: targetRoute ?? cat.targetRoute,
          recipeIds: cat.recipeIds,
          imageUrl: imageUrl ?? cat.imageUrl,
        );
        await DatabaseService.instance.updateCategory(updated);
      }
    } catch (_) {

    }
  }


  Future<void> removeCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    try {
      await DatabaseService.instance.deleteCategory(id);
    } catch (_) {

    }
  }


  Future<Category?> getById(String id) async {
    try {
      final cats = await DatabaseService.instance.getAllCategories();
      final found = cats.where((c) => c.id == id);
      if (found.isNotEmpty) return found.first;
    } catch (_) {
      // DB failed, continue to in-memory
    }

    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }


  Future<List<String>> getRecipeIdsForCategory(String id) async {
    final c = await getById(id);
    return c == null ? [] : List.unmodifiable(c.recipeIds);
  }


  Future<List<Recipe>> getRecipesForCategory(String categoryId) async {
    final ids = await getRecipeIdsForCategory(categoryId);
    List<Recipe> recipes = [];
    try {
      for (var rid in ids) {
        final recipe = await DatabaseService.instance.getRecipeById(rid);
        if (recipe != null) recipes.add(recipe);
      }
    } catch (_) {

    }
    return recipes;
  }


  Future<void> addRecipeToCategory(String categoryId, String recipeId) async {
    final c = await getById(categoryId);
    if (c == null) return;
    if (!c.recipeIds.contains(recipeId)) {
      c.recipeIds.add(recipeId);
      try {
        await DatabaseService.instance.updateCategory(c);
      } catch (_) {

      }
    }

    final i = _categories.indexWhere((cat) => cat.id == categoryId);
    if (i != -1 && !_categories[i].recipeIds.contains(recipeId)) {
      _categories[i].recipeIds.add(recipeId);
    }
  }


  Future<void> removeRecipeFromCategory(String categoryId, String recipeId) async {
    final c = await getById(categoryId);
    if (c == null) return;
    c.recipeIds.remove(recipeId);
    try {
      await DatabaseService.instance.updateCategory(c);
    } catch (_) {

    }

    final i = _categories.indexWhere((cat) => cat.id == categoryId);
    if (i != -1) {
      _categories[i].recipeIds.remove(recipeId);
    }
  }


  Future<void> setRecipesForCategory(String categoryId, List<String> recipeIds) async {
    final c = await getById(categoryId);
    if (c == null) return;
    c.recipeIds
      ..clear()
      ..addAll(recipeIds);
    try {
      await DatabaseService.instance.updateCategory(c);
    } catch (_) {

    }
    final i = _categories.indexWhere((cat) => cat.id == categoryId);
    if (i != -1) {
      _categories[i].recipeIds
        ..clear()
        ..addAll(recipeIds);
    }
  }
}