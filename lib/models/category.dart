class Category {
  final String id;
  String name;
  String? targetRoute;
  final List<String> recipeIds; // list of recipe IDs assigned to this category

  Category({
    required this.id,
    required this.name,
    this.targetRoute,
    List<String>? recipeIds,
  }) : recipeIds = recipeIds ?? [];

  @override
  String toString() => 'Category(id: $id, name: $name, route: $targetRoute, recipes: ${recipeIds.length})';
}