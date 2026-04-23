class Ingredient {
  final String name;
  final double cost;
  final double distance;
  final int calories;
  final String? storeId;
 
  const Ingredient({
    required this.name,
    required this.cost,
    required this.distance,
    required this.calories,
    this.storeId,
  });
 
  @override
  String toString() {
    final storePart = storeId != null ? ', Store: $storeId' : '';
    return '$name (Cost: $cost, Dist: $distance, Cal: $calories$storePart)';
  }
}