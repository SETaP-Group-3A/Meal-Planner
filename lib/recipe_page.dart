import 'package:flutter/material.dart';

// Class for the recipe page
class Recipe {
  final String name;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> allegens;
  final int calories;
  final Map<String, double> macros;
  bool isFavourite;

  Recipe({
    required this.name,
    required this.imageUrl,
    required this.ingredients,
    required this.allegens,
    required this.calories,
    required this.macros,
    this.isFavourite = false,
  });
}
