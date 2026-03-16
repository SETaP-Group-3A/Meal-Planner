import 'package:flutter/material.dart';
import '../category_service.dart';
import '../models/recipe.dart';
import '../services/database_service.dart';
import '../recipe_page.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String title;
  const CategoryDetailScreen({super.key, required this.title});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  Future<List<Recipe>> _loadRecipes() async {
    final category = CategoryService.instance.getById(widget.title);
    final recipeIds = category?.recipeIds ?? [];
    final allRecipes = await DatabaseService.instance.getAllRecipes();
    return allRecipes.where((r) => recipeIds.contains(r.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Recipe>>(
          future: _loadRecipes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final recipes = snapshot.data ?? [];
            return Column(
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
                          builder: (context) => RecipePage(recipeId: recipe.id),
                        ),
                      );
                    },
                    child: Text('Open Recipe'),
                  ),
                )),
                if (recipes.isEmpty)
                  Text('No recipes in this category.'),
              ],
            );
          },
        ),
      ),
    );
  }
}