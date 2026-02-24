API Reference
==============

Models
------

Category
^^^^^^^^

.. code-block:: dart

   class Category {
     final int id;
     final String name;
     final String description;
   }

Represents a meal category for organizing recipes.

Recipe
^^^^^^

.. code-block:: dart

   class Recipe {
     final int id;
     final String name;
     final String description;
     final List<Ingredient> ingredients;
     final String instructions;
     final int categoryId;
     final int servings;
     final int preparationTime;
   }

Represents a recipe with ingredients and cooking instructions.

Ingredient
^^^^^^^^^^

.. code-block:: dart

   class Ingredient {
     final int id;
     final String name;
     final double quantity;
     final String unit;
   }

Represents an ingredient with quantity and unit information.

ShoppingListItem
^^^^^^^^^^^^^^^^

.. code-block:: dart

   class ShoppingListItem {
     final int id;
     final int ingredientId;
     final double quantity;
     final String unit;
     final bool isChecked;
   }

Represents an item in the shopping list.

Services
--------

DatabaseService
^^^^^^^^^^^^^^^

Handles all database operations for the application.

Key Methods:

- ``getRecipes()``: Retrieve all recipes
- ``getRecipesByCategory(categoryId)``: Get recipes for a specific category
- ``addRecipe(recipe)``: Add a new recipe
- ``updateRecipe(recipe)``: Update an existing recipe
- ``deleteRecipe(id)``: Delete a recipe
- ``getShoppingList()``: Retrieve the shopping list
- ``addToShoppingList(item)``: Add item to shopping list

CategoryService
^^^^^^^^^^^^^^^

Manages category-related operations.

Key Methods:

- ``getCategories()``: Retrieve all categories
- ``addCategory(category)``: Add a new category
- ``updateCategory(category)``: Update a category
- ``deleteCategory(id)``: Delete a category

Views and Screens
-----------------

Main Screens
^^^^^^^^^^^^

- **LoginScreen**: User authentication
- **CategoriesScreen**: Browse all meal categories
- **CategoryContentScreen**: View recipes in a selected category
- **CategoryDetailScreen**: Detailed view of a recipe
- **ShoppingListScreen**: Manage shopping lists
- **SettingsScreen**: Application settings

Custom Widgets
^^^^^^^^^^^^^^

- **GraphWidget**: Displays visual graphs of meal data
- **RecipePage**: Detailed recipe display with ingredients and instructions

Utilities
---------

GraphController
^^^^^^^^^^^^^^^

Manages graph data and state for visualization components.

MockData
^^^^^^^^

Provides sample data for testing and development purposes.
