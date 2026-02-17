import 'package:flutter/material.dart';
import '../category_service.dart';
import '../models/category.dart';
import '../models/recipe.dart';
import '../mock_data.dart';
import '../shopping_list.dart';

class CategoryContentScreen extends StatefulWidget {
  final String? categoryId;
  const CategoryContentScreen({super.key, required this.categoryId});

  @override
  State<CategoryContentScreen> createState() => _CategoryContentScreenState();
}

class _CategoryContentScreenState extends State<CategoryContentScreen> {
  Category? category;

  @override
  void initState() {
    super.initState();
    if (widget.categoryId != null) {
      category = CategoryService.instance.getById(widget.categoryId!);
    }
  }

  Recipe? _findRecipeById(String id) {
    try {
      return mockRecipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Widget _buildIngredientRow(String ingredientName) {
    final options = marketInventory[ingredientName];
    if (options == null || options.isEmpty) {
      return ListTile(
        title: Text(ingredientName),
        subtitle: const Text('No market options'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((opt) {
        return ListTile(
          dense: true,
          title: Text(opt.name),
          subtitle: Text('Cost: £${opt.cost.toStringAsFixed(2)} · Dist: ${opt.distance}km · ${opt.calories} cal'),
        );
      }).toList(),
    );
  }

  int _calcTotalCalories(Recipe r) {
    var sum = 0;
    for (final ing in r.requiredIngredients) {
      final opt = marketInventory[ing]?.first;
      if (opt != null) sum += opt.calories;
    }
    return sum;
  }

  bool _isFavourite(String recipeId) {
    final fav = CategoryService.instance.getById('c-favourites');
    if (fav == null) return false;
    return fav.recipeIds.contains(recipeId);
  }

  void _toggleFavourite(String recipeId) {
    final fav = CategoryService.instance.getById('c-favourites');
    if (fav == null) {

      final created = CategoryService.instance.addCategory(name: 'Favourites', targetRoute: '/category', recipeIds: [recipeId]);

    } else {
      if (fav.recipeIds.contains(recipeId)) {
        CategoryService.instance.removeRecipeFromCategory(fav.id, recipeId);
      } else {
        CategoryService.instance.addRecipeToCategory(fav.id, recipeId);
      }
    }
    setState(() {});
  }

  void _refresh() {
    if (category != null) {
      category = CategoryService.instance.getById(category!.id);
      setState(() {});
    }
  }

  void _showAddItemDialog() async {
    if (category == null) return;

    final available = mockRecipes.where((r) => !category!.recipeIds.contains(r.id)).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No available recipes to add')));
      return;
    }

    final selected = await showDialog<Recipe?>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Add recipe to category'),
          children: available.map((r) {
            return SimpleDialogOption(
              child: Text(r.name),
              onPressed: () => Navigator.pop(ctx, r),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      CategoryService.instance.addRecipeToCategory(category!.id, selected.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category')),
        body: const Center(child: Text('Category not found')),
      );
    }

    final assignedIds = category!.recipeIds;
    final assignedRecipes = <Recipe>[];
    for (final id in assignedIds) {
      final r = _findRecipeById(id);
      if (r != null) assignedRecipes.add(r);
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

                          if (category!.id == 'c-favourites')
                            TextButton(
                              onPressed: () {
                                CategoryService.instance.removeRecipeFromCategory(category!.id, r.id);
                                _refresh();
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