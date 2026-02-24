Development
============

Setting Up Development Environment
-----------------------------------

1. **Install Flutter:**

   Follow the official `Flutter installation guide <https://flutter.dev/docs/get-started/install>`_

2. **Clone the repository:**

   .. code-block:: bash

      git clone <repository-url>
      cd Meal-Planner

3. **Install dependencies:**

   .. code-block:: bash

      flutter pub get

4. **Run the application:**

   .. code-block:: bash

      flutter run

Running Tests
-------------

Execute widget tests with:

.. code-block:: bash

   flutter test

Run specific test files:

.. code-block:: bash

   flutter test test/widget_test.dart
   flutter test test/graph_widget_test.dart

Code Style
----------

The project follows Dart style guidelines:

- Use meaningful variable and function names
- Follow the `Effective Dart <https://dart.dev/guides/language/effective-dart>`_ guidelines
- Format code with:

  .. code-block:: bash

     dart format lib/

- Analyze code for issues:

  .. code-block:: bash

     dart analyze

Building for Release
--------------------

**Android:**

.. code-block:: bash

   flutter build apk
   flutter build appbundle

**iOS:**

.. code-block:: bash

   flutter build ios

**Web:**

.. code-block:: bash

   flutter build web

**Windows:**

.. code-block:: bash

   flutter build windows

Contributing
------------

1. Create a feature branch from ``main``
2. Make your changes
3. Run tests to ensure nothing is broken
4. Submit a pull request with a clear description

For more details, see the main README.md file.
