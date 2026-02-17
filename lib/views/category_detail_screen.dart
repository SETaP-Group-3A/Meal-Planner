import 'package:flutter/material.dart';
import '../category_service.dart';
import '../mock_data.dart';
import '../recipe_page.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String title;
  const CategoryDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final String title = this.title;
    // Find the category by title (id)
    final category = CategoryService.instance.getById(title);
    // Get recipes for this category
    final recipeIds = category?.recipeIds ?? [];
    final recipes = mockRecipes.where((r) => recipeIds.contains(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(category?.name ?? title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipes in this category:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ...recipes.map((recipe) => ListTile(
                  title: Text(recipe.name),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipePage(recipe: recipe),
                        ),
                      );
                    },
                    child: Text('Open Recipe'),
                  ),
                )),
            if (recipes.isEmpty)
              Text('No recipes in this category.'),
          ],
        ),
      ),
    );
  }
}