import 'dart:io';
import 'package:meal_planner/models/weekly_goals.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/shopping_list_item.dart';
import '../models/category.dart';
import '../models/store.dart';
import '../utils/haversine.dart';
import '../mock_data.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
 
//------------------------------------------------------------------------------------------------------------------
//Create Database
 
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
 
    // Delete existing DB on start
    //if (await databaseExists(dbPath)) await deleteDatabase(dbPath);
 
    return await openDatabase(dbPath, version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
  }
 
  static Future<void> initForTesting() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
 
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1, onCreate: instance._createDB),
    );
 
    _database = db;
  }
 
  static Future<void> closeForTesting() async {
    await _database?.close();
    _database = null;
  }
 
  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';
 
    // Define table schemas here for easy editing
    final tableSchemas = {
      'stores': '''
        CREATE TABLE stores (
          id $idType,
          name $textType,
          postcode $textType,
          latitude $realType,
          longitude $realType
        )
      ''',
 
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
 
      // storeId is nullable — an ingredient may not yet be linked to a store.
      'ingredients': '''
        CREATE TABLE ingredients (
          name $idType,
          genericName $textType,
          cost $realType,
          distance $realType,
          calories $intType,
          storeId TEXT,
          FOREIGN KEY (storeId) REFERENCES stores (id) ON DELETE SET NULL
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
 
      'recipe_favourites': '''
        CREATE TABLE recipe_favourites (
          recipeId TEXT PRIMARY KEY
        )
      ''',

      'shopping_list_items': '''
        CREATE TABLE shopping_list_items (
          account_id TEXT NOT NULL,
          ingredient_key TEXT NOT NULL,
          ingredient_name TEXT NOT NULL,
          cost $realType,
          distance $realType,
          calories $intType,
          storeId TEXT,
          quantity $intType,
          PRIMARY KEY (account_id, ingredient_key),
          FOREIGN KEY (account_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''',

      'goal': '''
        CREATE TABLE goal (
          goal_id INTEGER PRIMARY KEY AUTOINCREMENT,
          goal_type TEXT NOT NULL,
          account_id TEXT,
          day_id INTEGER NOT NULL,
          goal_value $realType
        )
      ''',
 
      'week_goal': '''
        CREATE TABLE week_goal (
          week_goal_id INTEGER NOT NULL,
          account_id TEXT NOT NULL,
          goal_id INTEGER NOT NULL,
          start_date DATE NOT NULL,
          FOREIGN KEY (account_id) REFERENCES users (id) ON DELETE CASCADE,
          PRIMARY KEY (week_goal_id, account_id, goal_id)
        )
      ''',

      'users': '''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL
        )
     ''',
    };
 
    // Execute creating tables
    for (var schema in tableSchemas.values) {
      await db.execute(schema);
    }
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // Seed Stores from mockStores
    for (final store in mockStores) {
      await db.insert('stores', store.toMap());
    }
 
    // Seed Ingredients from marketInventory
    for (var entry in marketInventory.entries) {
      final genericName = entry.key;
      for (var option in entry.value) {
        await db.insert('ingredients', {
          'name': option.name,        // e.g., 'Flour (Aldi)'
          'genericName': genericName, // e.g., 'Flour'
          'cost': option.cost,
          'distance': option.distance,
          'calories': option.calories,
          'storeId': option.storeId,  // nullable
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
 
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('CREATE TABLE IF NOT EXISTS recipe_favourites (recipeId TEXT PRIMARY KEY)');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shopping_list_items (
          account_id TEXT NOT NULL,
          ingredient_key TEXT NOT NULL,
          ingredient_name TEXT NOT NULL,
          cost REAL NOT NULL,
          distance REAL NOT NULL,
          calories INTEGER NOT NULL,
          storeId TEXT,
          quantity INTEGER NOT NULL,
          PRIMARY KEY (account_id, ingredient_key),
          FOREIGN KEY (account_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

    }
  }

//------------------------------------------------------------------------------------------------------------------
//Stores
 
  Future<void> createStore(Store store) async {
    final db = await instance.database;
    await db.insert('stores', store.toMap());
  }
 
  Future<List<Store>> getAllStores() async {
    final db = await instance.database;
    final result = await db.query('stores');
    return result.map(Store.fromMap).toList();
  }
 
  Future<Store?> getStoreById(String id) async {
    final db = await instance.database;
    final result = await db.query('stores', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Store.fromMap(result.first);
  }
 
  Future<void> updateStore(Store store) async {
    final db = await instance.database;
    await db.update(
      'stores',
      {
        'name': store.name,
        'postcode': store.postcode,
        'latitude': store.latitude,
        'longitude': store.longitude,
      },
      where: 'id = ?',
      whereArgs: [store.id],
    );
  }
 
  Future<void> deleteStore(String id) async {
    final db = await instance.database;
    await db.delete('stores', where: 'id = ?', whereArgs: [id]);
  }
 
//------------------------------------------------------------------------------------------------------------------
//Categories
 
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
 
//------------------------------------------------------------------------------------------------------------------
//Recipes
 
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
        prepTimeMinutes: 0,
        allergens: [],
        calories: 0,
        macros: Macros(proteinG: 0, carbsG: 0, fatG: 0),
        nutrients: {},
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
      prepTimeMinutes: 0,
      allergens: [],
      calories: 0,
      macros: Macros(proteinG: 0, carbsG: 0, fatG: 0),
      nutrients: {},
    );
  }
 
  Future<List<String>> getRequiredIngredientsForRecipe(String recipeId) async {
    final db = await instance.database;
    final result = await db.query(
      'recipe_ingredients',
      columns: ['ingredientName'],
      where: 'recipeId = ?',
      whereArgs: [recipeId],
    );
    return result.map((row) => row['ingredientName'] as String).toList();
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

  /// checks if a recipe is saved as a favourite
  Future<bool> isFavourite(String recipeId) async {
    final db = await instance.database;
    final result = await db.query('recipe_favourites', where: 'recipeId = ?', whereArgs: [recipeId]);
    return result.isNotEmpty;
  }

  /// toggles favourite status and returns the new state
  Future<bool> toggleFavourite(String recipeId) async {
    final fav = await isFavourite(recipeId);
    final db = await instance.database;
    if (fav) {
      await db.delete('recipe_favourites', where: 'recipeId = ?', whereArgs: [recipeId]);
    } else {
      await db.insert('recipe_favourites', {'recipeId': recipeId});
    }
    return !fav;
  }

//------------------------------------------------------------------------------------------------------------------
//Ingredients
 

  Ingredient _ingredientFromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] as String,
      genericName: map['genericName'] as String?,
      cost: map['cost'] as double,
      distance: map['distance'] as double,
      calories: map['calories'] as int,
      storeId: map['storeId'] as String?,
    );
  }
 
  // Ingredient CRUD operations
  Future<void> createIngredient(Ingredient ingredient, {String? genericName}) async {
    final db = await instance.database;
    await db.insert('ingredients', {
      'name': ingredient.name,
      'genericName': genericName ?? ingredient.name,
      'cost': ingredient.cost,
      'distance': ingredient.distance,
      'calories': ingredient.calories,
      'storeId': ingredient.storeId,
    });
  }
 
  Future<List<Ingredient>> getAllIngredients() async {
    final db = await instance.database;
    final result = await db.query('ingredients');
    return result.map(_ingredientFromMap).toList();
  }
 
  Future<Ingredient?> getIngredientByName(String name) async {
    final db = await instance.database;
    final result = await db.query('ingredients', where: 'name = ?', whereArgs: [name]);
    if (result.isEmpty) return null;
    return _ingredientFromMap(result.first);
  }
 
  Future<List<Ingredient>> getIngredientsByGenericName(String genericName) async {
    final db = await instance.database;
    final result = await db.query('ingredients', where: 'genericName = ?', whereArgs: [genericName]);
    return result.map(_ingredientFromMap).toList();
  }
 
  Future<Ingredient?> getBestIngredientOption(String ingredientName, String sortBy) async {
    final options = await getIngredientsByGenericName(ingredientName);
    if (options.isEmpty) return null;
 
    switch (sortBy.toLowerCase()) {
      case 'cost':
        options.sort((a, b) => a.cost.compareTo(b.cost));
        break;
      case 'distance':
        options.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'calories':
        options.sort((a, b) => a.calories.compareTo(b.calories));
        break;
      default:
        break;
    }
 
    return options.first;
  }
 
  Future<List<Ingredient>> getBestIngredientOptionsForRecipe(String recipeId, String sortBy) async {
    final requiredIngredientNames = await getRequiredIngredientsForRecipe(recipeId);
    final selectedIngredients = <Ingredient>[];
 
    for (var ingredientName in requiredIngredientNames) {
      final bestOption = await getBestIngredientOption(ingredientName, sortBy);
      if (bestOption != null) {
        selectedIngredients.add(bestOption);
      }
    }
 
    return selectedIngredients;
  }
 
  Future<void> updateIngredient(Ingredient ingredient) async {
    final db = await instance.database;
    await db.update(
      'ingredients',
      {
        'cost': ingredient.cost,
        'distance': ingredient.distance,
        'calories': ingredient.calories,
        'storeId': ingredient.storeId,
      },
      where: 'name = ?',
      whereArgs: [ingredient.name],
    );
  }
 

  Future<void> updateAllIngredientDistances({
    required double userLat,
    required double userLon,
  }) async {
    final ingredients = await getAllIngredients();
    final stores = <String, Store>{};
 

    for (final store in await getAllStores()) {
      stores[store.id] = store;
    }
 
    for (final ingredient in ingredients) {
      final storeId = ingredient.storeId;
      if (storeId == null) continue; 
 
      final store = stores[storeId];
      if (store == null) continue;   
 
      final newDistance = haversineDistance(
        userLat,
        userLon,
        store.latitude,
        store.longitude,
      );
 

      await updateIngredient(ingredient.copyWith(distance: newDistance));
    }
  }
 
  Future<void> deleteIngredient(String name) async {
    final db = await instance.database;
    await db.delete('ingredients', where: 'name = ?', whereArgs: [name]);
  }

  Future<String?> resolveAccountIdFromEmail(String? accountEmail) async {
    if (accountEmail == null) return null;

    final db = await instance.database;
    final users = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [accountEmail],
      limit: 1,
    );

    if (users.isEmpty) return null;
    return users.first['id'] as String?;
  }

  Future<List<ShoppingListItem>> loadShoppingListItemsForAccount(String accountId) async {
    final db = await instance.database;
    final rows = await db.rawQuery('''
      SELECT
        sli.account_id,
        COALESCE(i.genericName, sli.ingredient_key, sli.ingredient_name) AS ingredient_key,
        sli.ingredient_name,
        sli.cost,
        sli.distance,
        sli.calories,
        sli.storeId,
        sli.quantity
      FROM shopping_list_items sli
      LEFT JOIN ingredients i ON i.name = sli.ingredient_name
      WHERE sli.account_id = ?
      ORDER BY sli.ingredient_name ASC
    ''', [accountId]);

    return rows.map((row) {
      final ingredient = Ingredient(
        name: row['ingredient_name'] as String,
        genericName: row['ingredient_key'] as String,
        cost: (row['cost'] as num).toDouble(),
        distance: (row['distance'] as num).toDouble(),
        calories: row['calories'] as int,
        storeId: row['storeId'] as String?,
      );

      return ShoppingListItem(
        ingredient: ingredient,
        quantity: row['quantity'] as int,
      );
    }).toList();
  }

  Future<void> replaceShoppingListItemsForAccount({
    required String accountId,
    required List<ShoppingListItem> items,
  }) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      await txn.delete('shopping_list_items', where: 'account_id = ?', whereArgs: [accountId]);

      for (final item in items) {
        await txn.insert('shopping_list_items', {
          'account_id': accountId,
          'ingredient_key': item.ingredient.genericName,
          'ingredient_name': item.ingredient.name,
          'cost': item.ingredient.cost,
          'distance': item.ingredient.distance,
          'calories': item.ingredient.calories,
          'storeId': item.ingredient.storeId,
          'quantity': item.quantity,
        });
      }
    });
  }

//------------------------------------------------------------------------------------------------------------------
//Shopping List
 
  // Shopping List operations
  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
 
//------------------------------------------------------------------------------------------------------------------
//Goals
 
  Future<void> createWeeklyGoal(String accountId, WeeklyGoals weeklyGoals) async {
    final db = await instance.database;
 
    for (var entry in weeklyGoals.goals.entries) {
      final weekId = entry.key;
      final goalsForWeek = entry.value;
 
      for (var goal in goalsForWeek) {
        final createdGoalId = await createGoal(goal.id.toString(), accountId, goal.day, goal.value);

        await db.insert(
          'week_goal',
          {
            'week_goal_id': weekId,
            'account_id': accountId,
            'goal_id': createdGoalId,
            'start_date': weeklyGoals.weekStartDates[weekId]?.toIso8601String() ?? DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }
 
  Future<void> updateWeeklyGoal(String accountId, WeeklyGoals weeklyGoals) async {
    final db = await instance.database;
 
    for (var entry in weeklyGoals.goals.entries) {
      final weekId = entry.key;
      final goalsForWeek = entry.value;
 
      // Remove existing mappings for this week/account then recreate
      await db.delete('week_goal', where: 'week_goal_id = ? AND account_id = ?', whereArgs: [weekId, accountId]);
      for (var goal in goalsForWeek) {
        final createdGoalId = await createGoal(goal.id.toString(), accountId, goal.day, goal.value);
        await db.insert(
          'week_goal',
          {
            'week_goal_id': weekId,
            'account_id': accountId,
            'goal_id': createdGoalId,
            'start_date': weeklyGoals.weekStartDates[weekId]?.toIso8601String() ?? DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }
  Future<int> createGoal(String goalType, String? accountId, int dayId, double goalValue) async {
    final db = await instance.database;
    return await db.insert(
      'goal',
      {
        'goal_type': goalType,
        'account_id': accountId,
        'day_id': dayId,
        'goal_value': goalValue,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGoal(int goalId, int dayId, double goalValue) async {
    final db = await instance.database;
    await db.update(
      'goal',
      {
        'goal_value': goalValue,
      },
      where: 'goal_id = ? AND day_id = ?',
      whereArgs: [goalId, dayId],
    );
  }

  /// Finds the `goal.goal_id` for a given week/account/day, or null if none.
  /// Finds the `goal.goal_id` for a given week/account/day, optionally
  /// filtering by `goal_type` if `goalType` is provided.
  Future<int?> findGoalIdForWeekAccountDay(int weekId, String accountId, int dayId, {String? goalType}) async {
    final db = await instance.database;
    String query = '''
      SELECT g.goal_id
      FROM goal g
      JOIN week_goal wg ON wg.goal_id = g.goal_id
      WHERE wg.account_id = ? AND wg.week_goal_id = ? AND g.day_id = ?
    ''';
    final args = [accountId, weekId, dayId];
    if (goalType != null) {
      query += ' AND g.goal_type = ?';
      args.add(goalType);
    }
    query += ' LIMIT 1';

    final rows = await db.rawQuery(query, args);

    if (rows.isEmpty) return null;
    final val = rows.first['goal_id'];
    if (val is int) return val;
    if (val is int?) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString());
  }
}

// ----------------------------------------------------------------------
// USERS (AUTH SYSTEM)
// ----------------------------------------------------------------------

Future<void> createUser(String id, String email, String password) async {
  final db = await DatabaseService.instance.database;

  await db.insert(
    'users',
    {
      'id': id,
      'email': email,
      'password': password,
    },
    conflictAlgorithm: ConflictAlgorithm.fail,
  );
}

Future<Map<String, dynamic>?> getUserByEmailAndPassword(
    String email, String password) async {
  final db = await DatabaseService.instance.database;

  final result = await db.query(
    'users',
    where: 'email = ? AND password = ?',
    whereArgs: [email, password],
  );

  if (result.isEmpty) return null;
  return result.first;
}