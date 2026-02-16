import 'package:flutter/material.dart';
import 'mock_data.dart'; // for mockRecipes
import 'models/recipe.dart';

class RecipePage extends StatelessWidget {
  final Recipe recipe;
  const RecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Add isFavourite button logic later
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.requiredIngredients.map(
              (ingredient) => ListTile(title: Text(ingredient)),
            ),
            SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                // TODO: Add isFavourite button logic later
              },
              child: Text('Add to Shopping List'),
            ),
          ],
        ),
      ),
    );
  }
}
