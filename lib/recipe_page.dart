import 'package:flutter/material.dart';
import 'models/recipe.dart';

class RecipePage extends StatelessWidget {
  final Recipe recipe;
  const RecipePage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.requiredIngredients.map((ingredient) => Text(ingredient)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Add to shopping list logic later
              },
              child: Text('Add to Shopping List'),
            ),
          ],
        ),
      ),
    );
  }
}
