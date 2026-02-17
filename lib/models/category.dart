class Category {
  final String id;
  String name;
  String? targetRoute;
  final List<String> recipeIds;
  String? imageUrl; // new: network URL or "asset:assets/images/xxx.jpg"

  Category({
    required this.id,
    required this.name,
    this.targetRoute,
    List<String>? recipeIds,
    this.imageUrl,
  }) : recipeIds = recipeIds ?? [];

  @override
  String toString() => 'Category(id: $id, name: $name, route: $targetRoute, recipes: ${recipeIds.length})';
}