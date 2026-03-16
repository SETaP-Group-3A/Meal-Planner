import 'dart:convert';

class Recipe {
  final String id;
  final String name;
  final List<String> requiredIngredients;
  final int cookingTime;
  final List<String>? allergens;
  final int? calories;
  final Map<String, double>? macros;
  final Map<String, double>? nutrients;
  final String? instructions;

  Recipe({
    required this.id,
    required this.name,
    required this.requiredIngredients,
    required this.cookingTime,
    this.allergens,
    this.calories,
    this.macros,
    this.nutrients,
    this.instructions,
  });


  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, requirements: ${requiredIngredients.length})';
  }
}
