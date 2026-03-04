import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/category.dart';
import '../mock_data.dart'; // Import data for seeding the database

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meal_planner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
        ? join(Directory.current.path, filePath)
        : join(await getDatabasesPath(), filePath);

    // Delete existing DB on start (Remove this line for production!)
    if (await databaseExists(dbPath)) await deleteDatabase(dbPath);

    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Define table schemas here for easy editing
    final tableSchemas = {
      'categories': '''
        CREATE TABLE categories (
          id $idType,
          name $textType,
          targetRoute TEXT,
          imageUrl TEXT
        )
      ''',
      
      'recipes': '''
        CREATE TABLE recipes (
          id $idType,
          name $textType,
          categoryId TEXT,
          FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
        )
      ''',
      
      'ingredients': '''
        CREATE TABLE ingredients (
          name $idType,
          genericName $textType,
          cost $realType,
          distance $realType,
          calories $intType
        )
      ''',
      
      'recipe_ingredients': '''
        CREATE TABLE recipe_ingredients (
          recipeId TEXT NOT NULL,
          ingredientName TEXT NOT NULL,
          PRIMARY KEY (recipeId, ingredientName),
          FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE
        )
      ''',
      
      'category_recipes': '''
        CREATE TABLE category_recipes (
          categoryId TEXT NOT NULL,
          recipeId TEXT NOT NULL,
          PRIMARY KEY (categoryId, recipeId),
          FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE,
          FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE
        )
      ''',
      
      'shopping_list': '''
        CREATE TABLE shopping_list (
          ingredientName TEXT PRIMARY KEY,
          quantity $intType,
          FOREIGN KEY (ingredientName) REFERENCES ingredients (name) ON DELETE CASCADE
        )
      '''
    };

    // Execute creating tables
    for (var schema in tableSchemas.values) {
      await db.execute(schema);
    }
    
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // Seed Ingredients from marketInventory
    for (var entry in marketInventory.entries) {
      final genericName = entry.key;
      for (var option in entry.value) {
        await db.insert('ingredients', {
          'name': option.name, // e.g., 'Flour (Aldi)'
          'genericName': genericName, // e.g., 'Flour'
          'cost': option.cost,
          'distance': option.distance,
          'calories': option.calories,
        });
      }
    }

    // Seed Recipes from mockRecipes
    for (var recipe in mockRecipes) {
      await db.insert('recipes', {'id': recipe.id, 'name': recipe.name});

      for (var ing in recipe.requiredIngredients) {
        await db.insert('recipe_ingredients', {
          'recipeId': recipe.id,
          'ingredientName': ing, // e.g., 'Flour'
        });
      }
    }
  }

  // Category CRUD operations
  Future<void> createCategory(Category category) async {
    final db = await instance.database;
    await db.insert('categories', {
      'id': category.id,
      'name': category.name,
      'targetRoute': category.targetRoute,
      'imageUrl': category.imageUrl,
    });

    // Insert category-recipe relationships
    for (var recipeId in category.recipeIds) {
      await db.insert('category_recipes', {
        'categoryId': category.id,
        'recipeId': recipeId,
      });
    }
  }

  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');

    List<Category> categories = [];
    for (var categoryMap in result) {
      final recipeIds = await _getRecipeIdsForCategory(categoryMap['id'] as String);
      categories.add(Category(
        id: categoryMap['id'] as String,
        name: categoryMap['name'] as String,
        targetRoute: categoryMap['targetRoute'] as String?,
        recipeIds: recipeIds,
        imageUrl: categoryMap['imageUrl'] as String?,
      ));
    }
    return categories;
  }

  Future<List<String>> _getRecipeIdsForCategory(String categoryId) async {
    final db = await instance.database;
    final result = await db.query(
      'category_recipes',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return result.map((row) => row['recipeId'] as String).toList();
  }

  Future<void> updateCategory(Category category) async {
    final db = await instance.database;
    await db.update(
      'categories',
      {
        'name': category.name,
        'targetRoute': category.targetRoute,
        'imageUrl': category.imageUrl,
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );

    // Update category-recipe relationships
    await db.delete('category_recipes', where: 'categoryId = ?', whereArgs: [category.id]);
    for (var recipeId in category.recipeIds) {
      await db.insert('category_recipes', {
        'categoryId': category.id,
        'recipeId': recipeId,
      });
    }
  }

  Future<void> deleteCategory(String id) async {
    final db = await instance.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Recipe CRUD operations
  Future<void> createRecipe(Recipe recipe, {String? categoryId}) async {
    final db = await instance.database;
    await db.insert('recipes', {
      'id': recipe.id,
      'name': recipe.name,
      'categoryId': categoryId,
    });

    // Insert recipe ingredients
    for (var ingredientName in recipe.requiredIngredients) {
      await db.insert('recipe_ingredients', {
        'recipeId': recipe.id,
        'ingredientName': ingredientName,
      });
    }
  }

  Future<List<Recipe>> getAllRecipes() async {
    final db = await instance.database;
    final result = await db.query('recipes');

    List<Recipe> recipes = [];
    for (var recipeMap in result) {
      final ingredients = await _getIngredientsForRecipe(recipeMap['id'] as String);
      recipes.add(Recipe(
        id: recipeMap['id'] as String,
        name: recipeMap['name'] as String,
        requiredIngredients: ingredients,
      ));
    }
    return recipes;
  }

  Future<Recipe?> getRecipeById(String id) async {
    final db = await instance.database;
    final result = await db.query('recipes', where: 'id = ?', whereArgs: [id]);
    
    if (result.isEmpty) return null;
    
    final recipeMap = result.first;
    final ingredients = await _getIngredientsForRecipe(id);
    
    return Recipe(
      id: recipeMap['id'] as String,
      name: recipeMap['name'] as String,
      requiredIngredients: ingredients,
    );
  }

  Future<List<String>> _getIngredientsForRecipe(String recipeId) async {
    final db = await instance.database;
    final result = await db.query(
      'recipe_ingredients',
      where: 'recipeId = ?',
      whereArgs: [recipeId],
    );
    return result.map((row) => row['ingredientName'] as String).toList();
  }

  Future<void> deleteRecipe(String id) async {
    final db = await instance.database;
    await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }

  // Ingredient CRUD operations
  Future<void> createIngredient(Ingredient ingredient) async {
    final db = await instance.database;
    await db.insert('ingredients', {
      'name': ingredient.name,
      'cost': ingredient.cost,
      'distance': ingredient.distance,
      'calories': ingredient.calories,
    });
  }

  Future<List<Ingredient>> getAllIngredients() async {
    final db = await instance.database;
    final result = await db.query('ingredients');

    return result.map((ingredientMap) => Ingredient(
      name: ingredientMap['name'] as String,
      cost: ingredientMap['cost'] as double,
      distance: ingredientMap['distance'] as double,
      calories: ingredientMap['calories'] as int,
    )).toList();
  }

  Future<Ingredient?> getIngredientByName(String name) async {
    final db = await instance.database;
    final result = await db.query('ingredients', where: 'name = ?', whereArgs: [name]);
    
    if (result.isEmpty) return null;
    
    final ingredientMap = result.first;
    return Ingredient(
      name: ingredientMap['name'] as String,
      cost: ingredientMap['cost'] as double,
      distance: ingredientMap['distance'] as double,
      calories: ingredientMap['calories'] as int,
    );
  }

  Future<List<Ingredient>> getIngredientsByGenericName(String genericName) async {
    final db = await instance.database;
    final result = await db.query('ingredients', where: 'genericName = ?', whereArgs: [genericName]);
    
    return result.map((ingredientMap) => Ingredient(
      name: ingredientMap['name'] as String,
      cost: ingredientMap['cost'] as double,
      distance: ingredientMap['distance'] as double,
      calories: ingredientMap['calories'] as int,
    )).toList();
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    final db = await instance.database;
    await db.update(
      'ingredients',
      {
        'cost': ingredient.cost,
        'distance': ingredient.distance,
        'calories': ingredient.calories,
      },
      where: 'name = ?',
      whereArgs: [ingredient.name],
    );
  }

  Future<void> deleteIngredient(String name) async {
    final db = await instance.database;
    await db.delete('ingredients', where: 'name = ?', whereArgs: [name]);
  }

  // Shopping List operations
  Future<void> addToShoppingList(String ingredientName, int quantity) async {
    final db = await instance.database;
    final existing = await db.query(
      'shopping_list',
      where: 'ingredientName = ?',
      whereArgs: [ingredientName],
    );

    if (existing.isNotEmpty) {
      final currentQuantity = existing.first['quantity'] as int;
      await db.update(
        'shopping_list',
        {'quantity': currentQuantity + quantity},
        where: 'ingredientName = ?',
        whereArgs: [ingredientName],
      );
    } else {
      await db.insert('shopping_list', {
        'ingredientName': ingredientName,
        'quantity': quantity,
      });
    }
  }

  Future<Map<String, int>> getShoppingList() async {
    final db = await instance.database;
    final result = await db.query('shopping_list');
    
    Map<String, int> shoppingList = {};
    for (var item in result) {
      shoppingList[item['ingredientName'] as String] = item['quantity'] as int;
    }
    return shoppingList;
  }

  Future<void> updateShoppingListQuantity(String ingredientName, int quantity) async {
    final db = await instance.database;
    if (quantity <= 0) {
      await db.delete('shopping_list', where: 'ingredientName = ?', whereArgs: [ingredientName]);
    } else {
      await db.update(
        'shopping_list',
        {'quantity': quantity},
        where: 'ingredientName = ?',
        whereArgs: [ingredientName],
      );
    }
  }

  Future<void> removeFromShoppingList(String ingredientName) async {
    final db = await instance.database;
    await db.delete('shopping_list', where: 'ingredientName = ?', whereArgs: [ingredientName]);
  }

  Future<void> clearShoppingList() async {
    final db = await instance.database;
    await db.delete('shopping_list');
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
