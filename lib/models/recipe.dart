class Macros {
  final double proteinG;
  final double carbsG;
  final double fatG;

  const Macros({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  @override
  String toString() =>
      'Macros(protein: ${proteinG}g, carbs: ${carbsG}g, fat: ${fatG}g)';
}

class Recipe {
  final String id;
  final String name;
  final List<String> requiredIngredients;
  final int prepTimeMinutes;
  final List<String> allergens;
  final int calories;
  final Macros macros;
  final Map<String, double> nutrients;
  /// which folder this recipe belongs to, null if none
  final String? folderName;

  Recipe({
    required this.id,
    required this.name,
    required this.requiredIngredients,
    required this.prepTimeMinutes,
    required this.allergens,
    required this.calories,
    required this.macros,
    required this.nutrients,
    this.folderName,
  });

  @override
  String toString() =>
      'Recipe(id: $id, name: $name, requirements: ${requiredIngredients.length})';
}
