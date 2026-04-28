import 'models/ingredient.dart';
import 'models/recipe.dart';
import 'models/store.dart';

final Map<String, List<Ingredient>> marketInventory = {
  'Flour': [
    Ingredient(name: 'Flour (Aldi)', cost: 0.80, distance: 3.0, calories: 360),
    Ingredient(
      name: 'Flour (Waitrose)',
      cost: 1.20,
      distance: 1.0,
      calories: 360,
    ),
  ],
  'Milk': [
    Ingredient(
      name: 'Milk (Waitrose)',
      cost: 1.80,
      distance: 1.0,
      calories: 45,
    ),
    Ingredient(name: 'Milk (Aldi)', cost: 1.50, distance: 3.0, calories: 45),
  ],
  'Eggs': [
    Ingredient(name: 'Eggs (Value)', cost: 1.50, distance: 0.5, calories: 155),
    Ingredient(
      name: 'Eggs (Free Range)',
      cost: 2.50,
      distance: 0.5,
      calories: 155,
    ),
  ],
  'Lettuce': [
    Ingredient(
      name: 'Lettuce (Fresh)',
      cost: 1.00,
      distance: 0.2,
      calories: 15,
    ),
    Ingredient(
      name: 'Lettuce (Bagged)',
      cost: 1.50,
      distance: 0.2,
      calories: 15,
    ),
  ],
  'Tomatoes': [
    Ingredient(
      name: 'Tomatoes',
      cost: 1.50,
      distance: 0.2,
      calories: 18,
      storeId: 's-lidl-e1',
    ),
  ],
  'Cucumber': [
    Ingredient(
      name: 'Cucumber',
      cost: 0.80,
      distance: 0.2,
      calories: 16,
      storeId: 's-aldi-sw1',
    ),
  ],
  'Pasta': [
    Ingredient(
      name: 'Pasta (Basic)',
      cost: 0.50,
      distance: 2.0,
      calories: 131,
      storeId: 's-lidl-e1',
    ),
  ],
};

final List<Recipe> mockRecipes = [
  Recipe(
    id: 'r-1',
    name: 'Scrambled Eggs on Toast',
    requiredIngredients: ['Eggs', 'Milk', 'Flour'],
    prepTimeMinutes: 10,
    allergens: ['Gluten', 'Dairy', 'Eggs'],
    calories: 420,
    macros: Macros(proteinG: 22.0, carbsG: 38.0, fatG: 18.0),
    nutrients: {'Iron (mg)': 3.2, 'Calcium (mg)': 180.0, 'Vitamin D (µg)': 2.5},
  ),
  Recipe(
    id: 'r-2',
    name: 'Tomato & Cucumber Salad',
    requiredIngredients: ['Tomatoes', 'Cucumber', 'Lettuce'],
    prepTimeMinutes: 5,
    allergens: [],
    calories: 85,
    macros: Macros(proteinG: 3.0, carbsG: 14.0, fatG: 1.5),
    nutrients: {'Vitamin C (mg)': 28.0, 'Potassium (mg)': 410.0, 'Fibre (g)': 3.1},
  ),
  Recipe(
    id: 'r-3',
    name: 'Simple Pasta',
    requiredIngredients: ['Pasta', 'Tomatoes', 'Milk'],
    prepTimeMinutes: 20,
    allergens: ['Gluten', 'Dairy'],
    calories: 510,
    macros: Macros(proteinG: 16.0, carbsG: 72.0, fatG: 12.0),
    nutrients: {'Iron (mg)': 2.1, 'Calcium (mg)': 120.0, 'Vitamin C (mg)': 14.0},
  ),
];

final List<Store> mockStores = [
  Store(id: 's-aldi-sw1', name: 'Aldi', postcode: 'SW1A 1AA', latitude: 51.4994, longitude: -0.1248),
  Store(id: 's-lidl-e1',  name: 'Lidl', postcode: 'E1 6RF',   latitude: 51.5155, longitude: -0.0699),
  Store(id: 's-tesco-n1', name: 'Tesco', postcode: 'N1 9GU',   latitude: 51.5362, longitude: -0.1033),
];
