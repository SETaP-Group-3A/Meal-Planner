import 'models/ingredient.dart';
import 'models/recipe.dart';

final List<Recipe> mockRecipes = [
  Recipe(
    id: 'pancakes',
    name: 'Pancakes',
    ingredients: [
      Ingredient(name: 'Flour', cost: 1.50, distance: 0.5, calories: 364),
      Ingredient(name: 'Milk', cost: 1.20, distance: 0.5, calories: 42),
      Ingredient(name: 'Eggs', cost: 2.00, distance: 1.0, calories: 155),
    ],
  ),
  Recipe(
    id: 'salad',
    name: 'Fresh Salad',
    ingredients: [
      Ingredient(name: 'Lettuce', cost: 1.00, distance: 0.2, calories: 15),
      Ingredient(name: 'Tomatoes', cost: 1.50, distance: 0.2, calories: 18),
      Ingredient(name: 'Cucumber', cost: 0.80, distance: 0.2, calories: 16),
    ],
  ),
  Recipe(
    id: 'pasta',
    name: 'Tomato Pasta',
    ingredients: [
      Ingredient(name: 'Pasta', cost: 1.00, distance: 0.5, calories: 131),
      Ingredient(name: 'Tomato Sauce', cost: 2.50, distance: 0.5, calories: 29),
      Ingredient(name: 'Cheese', cost: 3.00, distance: 1.0, calories: 402), 
    ],
  ),
  Recipe(
    id: 'smoothie',
    name: 'Berry Smoothie',
    ingredients: [
      Ingredient(name: 'Banana', cost: 0.50, distance: 0.3, calories: 89),
      Ingredient(name: 'Berries', cost: 3.00, distance: 0.3, calories: 57),
      Ingredient(name: 'Yogurt', cost: 1.20, distance: 0.3, calories: 59),
    ],
  ),
];
