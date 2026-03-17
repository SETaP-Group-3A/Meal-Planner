import 'package:flutter/material.dart';
import '../category_service.dart';
import '../models/category.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../mock_data.dart';
import '../shopping_list.dart';
import '../recipe_page.dart';
import '../services/database_service.dart';

class CategoryContentScreen extends StatefulWidget {
  final String? categoryId;
  const CategoryContentScreen({super.key, required this.categoryId});

  @override
  State<CategoryContentScreen> createState() => _CategoryContentScreenState();
}

class _CategoryContentScreenState extends State<CategoryContentScreen> {
  Category? category;
  List<Recipe> assignedRecipes = [];
  Set<String> favouriteIds = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      _loadCategory(widget.categoryId!);
    } else {
      setState(() {
        loading = false;
        category = null;
      });
    }
  }

  Future<void> _loadCategory(String id) async {
    setState(() => loading = true);

    final cat = await CategoryService.instance.getById(id);
    if (cat == null) {
      setState(() {
        category = null;
        assignedRecipes = [];
        favouriteIds = {};
        loading = false;
      });
      return;
    }

    final recipes = await CategoryService.instance.getRecipesForCategory(id);


    final fav = await CategoryService.instance.getById('c-favourites');
    final favIds = fav?.recipeIds.toSet() ?? <String>{};

    setState(() {
      category = cat;
      assignedRecipes = recipes;
      favouriteIds = favIds;
      loading = false;
    });
  }

  Widget _buildIngredientRow(String ingredientName) {
    return FutureBuilder<List<Ingredient>>(
      future: () async {
        try {
          final dbOptions = await DatabaseService.instance.getIngredientsByGenericName(ingredientName);
          if (dbOptions.isNotEmpty) return dbOptions;
        } catch (_) {
          // ignore DB errors and fall back to mock
        }
        final options = marketInventory[ingredientName] ?? [];
        // convert mock option objects to Ingredient for uniform rendering
        return options
            .map((o) => Ingredient(name: o.name, cost: o.cost, distance: o.distance, calories: o.calories))
            .toList();
      }(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return ListTile(
            title: Text(ingredientName),
            subtitle: const Text('Loading options...'),
          );
        }

        final options = snapshot.data ?? [];
        if (options.isEmpty) {
          return ListTile(
            title: Text(ingredientName),
            subtitle: const Text('No market options'),
          );
        }

        // pick the single cheapest option, tie-breaker lower distance
        options.sort((a, b) {
          final costCmp = a.cost.compareTo(b.cost);
          if (costCmp != 0) return costCmp;
          return a.distance.compareTo(b.distance);
        });
        final chosen = options.first;

        return ListTile(
          dense: true,
          title: Text(chosen.name),
          subtitle: Text('Cost: £${chosen.cost.toStringAsFixed(2)} · Dist: ${chosen.distance}km · ${chosen.calories} cal'),
        );
      },
    );
  }

  int _calcTotalCalories(Recipe r) {
    var sum = 0;
    for (final ing in r.requiredIngredients) {
      final options = marketInventory[ing];
      if (options != null && options.isNotEmpty) {
        // choose cheapest mock option
        options.sort((a, b) {
          final costCmp = a.cost.compareTo(b.cost);
          if (costCmp != 0) return costCmp;
          return a.distance.compareTo(b.distance);
        });
        final opt = options.first;
        sum += opt.calories;
      } else {
        // no mock option; try DB synchronously is not possible here - assume 0
      }
    }
    return sum;
  }

  bool _isFavourite(String recipeId) {
    return favouriteIds.contains(recipeId);
  }

  Future<void> _toggleFavourite(String recipeId) async {
    final fav = await CategoryService.instance.getById('c-favourites');
    if (fav == null) {
      await CategoryService.instance.addCategory(name: 'Favourites', targetRoute: '/category', recipeIds: [recipeId]);
    } else {
      if (fav.recipeIds.contains(recipeId)) {
        await CategoryService.instance.removeRecipeFromCategory(fav.id, recipeId);
      } else {
        await CategoryService.instance.addRecipeToCategory(fav.id, recipeId);
      }
    }

    final refreshedFav = await CategoryService.instance.getById('c-favourites');
    setState(() {
      favouriteIds = refreshedFav?.recipeIds.toSet() ?? {};
    });
  }

  Future<void> _refresh() async {
    if (category != null) {
      await _loadCategory(category!.id);
    }
  }

  void _showAddItemDialog() async {
    if (category == null) return;

    // get all recipes from DB, fall back to mockRecipes on error
    List<Recipe> allRecipes = [];
    try {
      allRecipes = await DatabaseService.instance.getAllRecipes();
    } catch (_) {
      allRecipes = mockRecipes;
    }

    final available = allRecipes.where((r) => !category!.recipeIds.contains(r.id)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No available recipes to add')));
      return;
    }

    final selected = await showDialog<Recipe?>(context: context, builder: (ctx) {
      return SimpleDialog(
        title: const Text('Add recipe to category'),
        children: available.map((r) {
          return SimpleDialogOption(
            child: Text(r.name),
            onPressed: () => Navigator.pop(ctx, r),
          );
        }).toList(),
      );
    });

    if (selected != null) {
      await CategoryService.instance.addRecipeToCategory(category!.id, selected.id);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category')),
        body: const Center(child: Text('Category not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(category!.name),
        actions: [
          IconButton(
            tooltip: 'Add recipe',
            icon: const Icon(Icons.add),
            onPressed: _showAddItemDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: assignedRecipes.isEmpty
            ? const Center(child: Text('No recipes in this category yet.'))
            : ListView.separated(
                itemCount: assignedRecipes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = assignedRecipes[i];
                  final totalCal = _calcTotalCalories(r);

                  final titleWidget = Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text('Ingredients (${r.requiredIngredients.length}) · $totalCal cal',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavourite(r.id) ? Icons.favorite : Icons.favorite_border,
                          color: _isFavourite(r.id) ? Colors.red : null,
                        ),
                        onPressed: () => _toggleFavourite(r.id),
                        tooltip: _isFavourite(r.id) ? 'Remove from favourites' : 'Add to favourites',
                      ),
                    ],
                  );

                  return ExpansionTile(
                    title: titleWidget,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: r.requiredIngredients.map((ing) {
                            return _buildIngredientRow(ing);
                          }).toList(),
                        ),
                      ),
                      ButtonBar(
                        children: [
                          TextButton(
                            onPressed: () {
                              ShoppingList().addRecipeById(r.id);
                              final count = r.requiredIngredients.length;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added $count ingredient(s) from "${r.name}" to shopping list')),
                              );
                            },
                            child: const Text('Add ingredients to shopping list'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipePage(recipe: r),
                                ),
                              );
                            },
                            child: const Text('Open recipe'),
                          ),
                          if (category!.id == 'c-favourites')
                            TextButton(
                              onPressed: () async {
                                await CategoryService.instance.removeRecipeFromCategory(category!.id, r.id);
                                await _refresh();
                              },
                              child: const Text('Remove from favourites'),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}