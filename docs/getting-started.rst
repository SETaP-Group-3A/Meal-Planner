Getting Started
===============

Installation
------------

To get started with the Meal-Planner application:

1. **Clone the repository:**

   .. code-block:: bash

      git clone <repository-url>
      cd Meal-Planner

2. **Install Flutter dependencies:**

   .. code-block:: bash

      flutter pub get

3. **Run the application:**

   For Android:

   .. code-block:: bash

      flutter run -d android

   For iOS:

   .. code-block:: bash

      flutter run -d ios

   For Web:

   .. code-block:: bash

      flutter run -d chrome

   For Windows:

   .. code-block:: bash

      flutter run -d windows

Requirements
------------

- Flutter SDK (v3.35.6 or higher)
- Dart SDK (included with Flutter)
- Android Studio / Android SDK (for Android development)
- Xcode (for iOS development)
- A compatible IDE (VS Code, Android Studio, etc.)

Configuration
-------------

The application uses a local SQLite database for storing meal plans, recipes, and shopping lists. No additional configuration is required after installation.

For development, ensure that all dependencies in ``pubspec.yaml`` are installed:

.. code-block:: bash

   flutter pub get
