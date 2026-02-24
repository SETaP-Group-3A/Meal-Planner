Architecture
=============

Project Structure
-----------------

The Meal-Planner application follows a modular Flutter architecture:

.. code-block:: 

   lib/
   ├── main.dart                    # Application entry point
   ├── log_in.dart                  # Authentication screen
   ├── models/                      # Data models
   │   ├── category.dart
   │   ├── ingredient.dart
   │   ├── recipe.dart
   │   └── shopping_list_item.dart
   ├── services/                    # Business logic
   │   └── database_service.dart
   ├── views/                       # UI screens
   │   ├── app_styles.dart
   │   ├── categories_screen.dart
   │   ├── category_content_screen.dart
   │   ├── category_detail_screen.dart
   │   ├── settings_screen.dart
   │   └── shopping_list_screen.dart
   ├── widgets/                     # Reusable UI components
   │   ├── graph_widget.dart
   │   └── recipe_page.dart
   └── utilities/
       ├── category_service.dart
       ├── graph_controller.dart
       ├── mock_data.dart
       └── shopping_list.dart

Data Models
-----------

The application uses several key data models:

- **Category**: Represents meal categories (e.g., Breakfast, Lunch, Dinner)
- **Recipe**: Stores recipe information including ingredients and instructions
- **Ingredient**: Represents individual ingredients with quantities
- **ShoppingListItem**: Items in the user's shopping list

Database
--------

The application uses SQLite for persistent data storage via the ``database_service.dart``.

Key Features:

- Local storage of recipes, ingredients, and shopping lists
- Category-based organization
- Efficient querying and filtering

UI/UX Design
------------

The application provides multiple screens:

- **Login Screen**: User authentication
- **Categories Screen**: Browse meal categories
- **Category Content Screen**: View recipes in a category
- **Category Detail Screen**: Detailed recipe information
- **Shopping List Screen**: Manage shopping lists
- **Settings Screen**: Application preferences

State Management
----------------

The application uses a clean architecture with separation of concerns:

- **Models**: Define data structures
- **Services**: Handle data operations and business logic
- **Views**: Present UI components
- **Controllers**: Manage state and coordination

Testing
-------

Widget tests are available in the ``test/`` directory:

- ``widget_test.dart``: General widget tests
- ``graph_widget_test.dart``: Tests for graph visualization components
