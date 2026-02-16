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
    );
  }
}