import 'models/ingredient.dart';
import 'models/recipe.dart';

final Map<String, List<Ingredient>> marketInventory = {
  'Flour': [
    Ingredient(name: 'Flour (Aldi)', cost: 0.80, distance: 3.0, calories: 360),
    Ingredient(name: 'Flour (Waitrose)', cost: 1.20, distance: 1.0, calories: 360),
  ],
  'Milk': [
    Ingredient(name: 'Milk (Waitrose)', cost: 1.80, distance: 1.0, calories: 45),
    Ingredient(name: 'Milk (Aldi)', cost: 1.50, distance: 3.0, calories: 45),
  ],
  'Eggs': [
    Ingredient(name: 'Eggs (Value)', cost: 1.50, distance: 0.5, calories: 155),
    Ingredient(name: 'Eggs (Free Range)', cost: 2.50, distance: 0.5, calories: 155),
  ],
  'Lettuce': [
    Ingredient(name: 'Lettuce (Fresh)', cost: 1.00, distance: 0.2, calories: 15),
    Ingredient(name: 'Lettuce (Bagged)', cost: 1.50, distance: 0.2, calories: 15),
  ],
  'Tomatoes': [
    Ingredient(name: 'Tomatoes', cost: 1.50, distance: 0.2, calories: 18),
  ],
  'Cucumber': [
    Ingredient(name: 'Cucumber', cost: 0.80, distance: 0.2, calories: 16),
  ],
  'Pasta': [
    Ingredient(name: 'Pasta (Basic)', cost: 0.50, distance: 2.0, calories: 131),
  ],
};

final List<Recipe> mockRecipes = [
  Recipe(
    id: 'r-1',
    name: 'Scrambled Eggs on Toast',
    requiredIngredients: ['Eggs', 'Milk', 'Flour'],
  ),
  Recipe(
    id: 'r-2',
    name: 'Tomato & Cucumber Salad',
    requiredIngredients: ['Tomatoes', 'Cucumber', 'Lettuce'],
  ),
  Recipe(
    id: 'r-3',
    name: 'Simple Pasta',
    requiredIngredients: ['Pasta', 'Tomatoes', 'Milk'],
  ),
];
