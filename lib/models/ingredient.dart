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
 
  /// since all values are marked as final, this returns a copy of this ingredient with fields replaced by provided values (distance)
  Ingredient copyWith({
    String? name,
    double? cost,
    double? distance,
    int? calories,
    String? storeId,
  }) {
    return Ingredient(
      name: name?? this.name,
      cost: cost?? this.cost,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      storeId: storeId ?? this.storeId,
    );
  }
 
  @override
  String toString() {
    final storePart = storeId != null ? ', Store: $storeId' : '';
    return '$name (Cost: $cost, Dist: $distance, Cal: $calories$storePart)';
  }
}