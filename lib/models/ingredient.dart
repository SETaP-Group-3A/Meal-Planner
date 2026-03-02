class Ingredient {
  final String name;
  final double cost;
  final double distance;
  final int calories;

  Ingredient({
    required this.name,
    required this.cost,
    required this.distance,
    required this.calories,
  });

  @override
  String toString() {
    return '$name (Cost: $cost, Dist: $distance, Cal: $calories)';
  }
}
