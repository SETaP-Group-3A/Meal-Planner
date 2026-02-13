import 'ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final List<Ingredient> ingredients;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
  });

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, ingredients: ${ingredients.length})';
  }
}
