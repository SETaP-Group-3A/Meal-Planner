import 'models/ingredient.dart';
import 'models/recipe.dart';
import 'models/account.dart';

final Map<String, List<Ingredient>> marketInventory = {
  'Flour': [
    Ingredient(name: 'Flour (Tesco)', cost: 1.50, distance: 0.5, calories: 364),
    Ingredient(name: 'Flour (Aldi)', cost: 0.80, distance: 3.0, calories: 360),
  ],
  'Milk': [
    Ingredient(name: 'Milk (Tesco)', cost: 1.20, distance: 0.5, calories: 42),
    Ingredient(name: 'Milk (Waitrose)', cost: 1.80, distance: 1.0, calories: 45),
  ],
  'Eggs': [
    Ingredient(name: 'Eggs (Free Range)', cost: 2.50, distance: 1.0, calories: 155),
    Ingredient(name: 'Eggs (Value)', cost: 1.50, distance: 0.5, calories: 155),
  ],
  'Lettuce': [
    Ingredient(name: 'Lettuce (Fresh)', cost: 1.00, distance: 0.2, calories: 15),
  ],
  'Tomatoes': [
    Ingredient(name: 'Tomatoes', cost: 1.50, distance: 0.2, calories: 18),
  ],
  'Cucumber': [
    Ingredient(name: 'Cucumber', cost: 0.80, distance: 0.2, calories: 16),
  ],
  'Pasta': [
    Ingredient(name: 'Pasta (Brand)', cost: 1.50, distance: 0.5, calories: 131),
    Ingredient(name: 'Pasta (Basic)', cost: 0.50, distance: 2.0, calories: 131),
  ],
  'Tomato Sauce': [
    Ingredient(name: 'Tomato Sauce', cost: 2.50, distance: 0.5, calories: 29),
  ],
  'Cheese': [
    Ingredient(name: 'Cheese', cost: 3.00, distance: 1.0, calories: 402),
  ],
  'Banana': [
    Ingredient(name: 'Banana', cost: 0.50, distance: 0.3, calories: 89),
  ],
  'Berries': [
    Ingredient(name: 'Berries', cost: 3.00, distance: 0.3, calories: 57),
  ],
  'Yogurt': [
    Ingredient(name: 'Yogurt', cost: 1.20, distance: 0.3, calories: 59),
  ],
};

final List<Recipe> mockRecipes = [
  Recipe(
    id: 'pancakes',
    name: 'Pancakes',
    requiredIngredients: ['Flour', 'Milk', 'Eggs'],
  ),
  Recipe(
    id: 'salad',
    name: 'Fresh Salad',
    requiredIngredients: ['Lettuce', 'Tomatoes', 'Cucumber'],
  ),
  Recipe(
    id: 'pasta',
    name: 'Tomato Pasta',
    requiredIngredients: ['Pasta', 'Tomato Sauce', 'Cheese'],
  ),
  Recipe(
    id: 'smoothie',
    name: 'Berry Smoothie',
    requiredIngredients: ['Banana', 'Berries', 'Yogurt'],
  ),
];

final List<Map<String, String>> mockAccounts = [
  {
    "name": "John Doe",
    "email": "john.doe@example.com",
    "password": "johnspassword!"
  },
  {
    "name": "Jane Doe",
    "email": "jane.doe@example.com",
    "password": "janespassword!"
  },
  {
    "name": "Jane Johnson",
    "email": "jane.johnson@example.com",
    "password": "jjpassword"
  },
];