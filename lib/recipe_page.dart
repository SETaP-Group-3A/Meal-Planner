import 'package:flutter/material.dart';
import 'models/recipe.dart';

class RecipePage extends StatefulWidget {
  final String recipeId;

  const RecipePage({required this.recipeId, super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  bool _showAdvanced = false;

  Future<Recipe> _loadRecipe() async {
    // placeholder for async database fetch - replace with actual implementation
    throw UnimplementedError('Database fetch not implemented');
  }
  Future<void> _addToShoppingList(Recipe recipe) async {
    // placeholder again - replace with actual shopping list logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ingredients added to shopping list!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe')),
      body: FutureBuilder<Recipe>(
        future: _loadRecipe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(child: Text('Failed to load recipe.'));
          }
          final recipe = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(recipe.name),
                subtitle: Text('Cooking time: ${recipe.cookingTime} min'),
              ),
              SwitchListTile(
                title: const Text('Show Advanced'),
                value: _showAdvanced,
                onChanged: (val) => setState(() => _showAdvanced = val),
              ),
              if (_showAdvanced) ...[
                if (recipe.calories != null)
                  Text('Calories: ${recipe.calories}'),
                if (recipe.macros != null)
                  Text('Macros: ${recipe.macros}'),
                if (recipe.allergens != null)
                  Text('Allergens: ${recipe.allergens!.join(', ')}'),
              ],
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => _addToShoppingList(recipe),
                  child: const Text('Add to Shopping List'),
                ),
              ),
              if (recipe.instructions != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Instructions: ${recipe.instructions}'),
                ),
            ],
          );
        },
      ),
    );
  }
}
