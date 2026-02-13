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

final Map<String, List<Ingredient>> mockRecipes = {
  'pancakes': [
    Ingredient(name: 'Flour', cost: 1.50, distance: 0.5, calories: 364),
    Ingredient(name: 'Milk', cost: 1.20, distance: 0.5, calories: 42),
    Ingredient(name: 'Eggs', cost: 2.00, distance: 1.0, calories: 155),
  ],
  'salad': [
    Ingredient(name: 'Lettuce', cost: 1.00, distance: 0.2, calories: 15),
    Ingredient(name: 'Tomatoes', cost: 1.50, distance: 0.2, calories: 18),
    Ingredient(name: 'Cucumber', cost: 0.80, distance: 0.2, calories: 16),
  ],
  'pasta': [
    Ingredient(name: 'Pasta', cost: 1.00, distance: 0.5, calories: 131),
    Ingredient(name: 'Tomato Sauce', cost: 2.50, distance: 0.5, calories: 29),
    Ingredient(name: 'Cheese', cost: 3.00, distance: 1.0, calories: 402),
  ],
  'smoothie': [
    Ingredient(name: 'Banana', cost: 0.50, distance: 0.3, calories: 89),
    Ingredient(name: 'Berries', cost: 3.00, distance: 0.3, calories: 57),
    Ingredient(name: 'Yogurt', cost: 1.20, distance: 0.3, calories: 59),
  ],
};
