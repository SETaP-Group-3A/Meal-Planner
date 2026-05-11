class Ingredient {
  final String name;
  final String genericName;
  final double cost;
  final double distance;
  final int calories;
  final String? storeId;
 
  const Ingredient({
    required this.name,
    String? genericName,
    required this.cost,
    required this.distance,
    required this.calories,
    this.storeId,
  }) : genericName = genericName ?? name;
 
  /// since all values are marked as final, this returns a copy of this ingredient with fields replaced by provided values (distance)
  Ingredient copyWith({
    String? name,
    String? genericName,
    double? cost,
    double? distance,
    int? calories,
    String? storeId,
  }) {
    return Ingredient(
      name: name?? this.name,
      genericName: genericName ?? this.genericName,
      cost: cost?? this.cost,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
      storeId: storeId ?? this.storeId,
    );
  }
 
  @override
  String toString() {
    final storePart = storeId != null ? ', Store: $storeId' : '';
    final genericPart = genericName != name ? ', Generic: $genericName' : '';
    return '$name (Cost: $cost, Dist: $distance, Cal: $calories$genericPart$storePart)';
  }
}