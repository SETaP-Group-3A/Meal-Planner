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

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      name: map['name'] as String,
      requiredIngredients: map['requiredIngredients'] != null
          ? List<String>.from(jsonDecode(map['requiredIngredients']))
          : [],
      cookingTime: map['cookingTime'] as int,
      allergens: map['allergens'] != null && (map['allergens'] as String).isNotEmpty
          ? List<String>.from(jsonDecode(map['allergens']))
          : null,
      calories: map['calories'] as int?,
      macros: map['macros'] != null && (map['macros'] as String).isNotEmpty
          ? Map<String, double>.from(jsonDecode(map['macros']))
          : null,
      nutrients: map['nutrients'] != null && (map['nutrients'] as String).isNotEmpty
          ? Map<String, double>.from(jsonDecode(map['nutrients']))
          : null,
      instructions: map['instructions'] as String?,
    );
  }
  
  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, requirements: ${requiredIngredients.length})';
  }
}
