import 'models/ingredient.dart';
import 'models/recipe.dart';
import 'models/store.dart';
 
// ---------------------------------------------------------------------------
// Mock stores
// ---------------------------------------------------------------------------
 
final List<Store> mockStores = [
  Store(
    id: 's-aldi-sw1',
    name: 'Aldi',
    postcode: 'SW1A 1AA',
    latitude: 51.5014,
    longitude: -0.1419,
  ),
  Store(
    id: 's-waitrose-wc2',
    name: 'Waitrose',
    postcode: 'WC2N 5DU',
    latitude: 51.5074,
    longitude: -0.1240,
  ),
  Store(
    id: 's-tesco-se1',
    name: 'Tesco',
    postcode: 'SE1 7PB',
    latitude: 51.5045,
    longitude: -0.0865,
  ),
  Store(
    id: 's-lidl-e1',
    name: 'Lidl',
    postcode: 'E1 6RF',
    latitude: 51.5155,
    longitude: -0.0726,
  ),
];
 
// ---------------------------------------------------------------------------
// Mock Ingredients
// ---------------------------------------------------------------------------
 
final Map<String, List<Ingredient>> marketInventory = {
  'Flour': [
    Ingredient(
      name: 'Flour (Aldi)',
      cost: 0.80,
      distance: 3.0,
      calories: 360,
      storeId: 's-aldi-sw1',
    ),
    Ingredient(
      name: 'Flour (Waitrose)',
      cost: 1.20,
      distance: 1.0,
      calories: 360,
      storeId: 's-waitrose-wc2',
    ),
  ],
  'Milk': [
    Ingredient(
      name: 'Milk (Waitrose)',
      cost: 1.80,
      distance: 1.0,
      calories: 45,
      storeId: 's-waitrose-wc2',
    ),
    Ingredient(
      name: 'Milk (Aldi)',
      cost: 1.50,
      distance: 3.0,
      calories: 45,
      storeId: 's-aldi-sw1',
    ),
  ],
  'Eggs': [
    Ingredient(
      name: 'Eggs (Value)',
      cost: 1.50,
      distance: 0.5,
      calories: 155,
      storeId: 's-lidl-e1',
    ),
    Ingredient(
      name: 'Eggs (Free Range)',
      cost: 2.50,
      distance: 0.5,
      calories: 155,
      storeId: 's-tesco-se1',
    ),
  ],
  'Lettuce': [
    Ingredient(
      name: 'Lettuce (Fresh)',
      cost: 1.00,
      distance: 0.2,
      calories: 15,
      storeId: 's-tesco-se1',
    ),
    Ingredient(
      name: 'Lettuce (Bagged)',
      cost: 1.50,
      distance: 0.2,
      calories: 15,
      storeId: 's-waitrose-wc2',
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
 
// ---------------------------------------------------------------------------
// Mock recipes 
// ---------------------------------------------------------------------------
 
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
