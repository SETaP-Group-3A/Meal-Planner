class Recipe {
  final String id;
  final String name;
  final List<String> requiredIngredients;

  Recipe({
    required this.id,
    required this.name,
    required this.requiredIngredients,
  });

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, requirements: ${requiredIngredients.length})';
  }
}
