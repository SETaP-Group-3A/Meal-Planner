import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/category.dart';
import 'package:meal_planner/views/categories_screen.dart';

Future<void> pumpScreen(WidgetTester tester, List<Category> categories) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CategoriesScreen(categories: categories),
      routes: {
        // route builder uses the injected categories to render recipe count for assertions
        '/category': (ctx) {
          final arg = ModalRoute.of(ctx)!.settings.arguments as String?;
          final cat = categories.firstWhere(
            (c) => c.id == arg,
            orElse: () => Category(
              id: '',
              name: '',
              recipeIds: [],
              targetRoute: '',
              imageUrl: '',
            ),
          );
          return Scaffold(
            body: Column(
              children: [
                Text('Category: $arg'),
                Text('Recipes: ${cat.recipeIds.length}'),
              ],
            ),
          );
        },
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Snacks category (two recipes) is shown and navigates to show 2 recipes',
    (tester) async {
      final cat = Category(
        id: 'c-1',
        name: 'Snacks',
        recipeIds: ['r-1', 'r-2'],
        targetRoute: '/category',
        imageUrl: 'https://freepngimg.com/png/13866-healthy-food-png-pic',
      );

      await pumpScreen(tester, [cat]);

      expect(find.text('Snacks'), findsOneWidget);

      await tester.tap(find.text('Snacks'));
      await tester.pumpAndSettle();

      expect(find.text('Category: c-1'), findsOneWidget);
      expect(find.text('Recipes: 2'), findsOneWidget);
    },
  );

  testWidgets(
    'Snack category generated with zero recipes shows tile and navigates showing 0',
    (tester) async {
      final cat = Category(
        id: 'c-2',
        name: 'Snack',
        recipeIds: [],
        targetRoute: '/category',
        imageUrl: 'https://freepngimg.com/png/13866-healthy-food-png-pic',
      );

      await pumpScreen(tester, [cat]);

      expect(find.text('Snack'), findsOneWidget);

      await tester.tap(find.text('Snack'));
      await tester.pumpAndSettle();

      expect(find.text('Category: c-2'), findsOneWidget);
      expect(find.text('Recipes: 0'), findsOneWidget);
    },
  );

  testWidgets('No category tile is shown for items with invalid id', (
    tester,
  ) async {
    final cat = Category(
      id: '1', // invalid id - should be filtered out
      name: 'Snacks',
      recipeIds: ['r-1', 'r-2'],
      targetRoute: '/category',
      imageUrl: 'https://freepngimg.com/png/13866-healthy-food-png-pic',
    );

    await pumpScreen(tester, [cat]);

    expect(find.text('Snacks'), findsNothing);
  });

  testWidgets('A blank category tile is displayed with zero recipes', (
    tester,
  ) async {
    final cat = Category(
      id: 'c-0',
      name: ' ',
      recipeIds: [],
      targetRoute: '/category',
      imageUrl: ' ',
    );

    await pumpScreen(tester, [cat]);

    // title is a single space
    expect(find.text(' '), findsOneWidget);

    // tapping should navigate because targetRoute is valid
    await tester.tap(find.text(' '));
    await tester.pumpAndSettle();

    expect(find.text('Category: c-0'), findsOneWidget);
    expect(find.text('Recipes: 0'), findsOneWidget);
  });

  testWidgets('Category with blank route does not navigate when tapped', (
    tester,
  ) async {
    final cat = Category(
      id: 'c-1',
      name: 'Snacks',
      recipeIds: [],
      targetRoute: ' ', // blank route -> should not navigate
      imageUrl: 'https://freepng.image.com/png/13866-healthyfood-png-pic',
    );

    await pumpScreen(tester, [cat]);

    expect(find.text('Snacks'), findsOneWidget);

    await tester.tap(find.text('Snacks'));
    await tester.pumpAndSettle();

    // navigation should not have occurred
    expect(find.text('Category: c-1'), findsNothing);
  });

  testWidgets(
    'Category with empty imageUrl renders no Image widget (no placeholder)',
    (tester) async {
      final cat = Category(
        id: 'c-img-empty',
        name: 'NoImage',
        recipeIds: ['r-1', 'r-2'],
        targetRoute: '/category',
        imageUrl: '', // explicit empty -> should render blank (no placeholder)
      );

      await pumpScreen(tester, [cat]);

      expect(find.text('NoImage'), findsOneWidget);

      // no Image widgets should be present for this single-tile scenario
      expect(find.byType(Image), findsNothing);
    },
  );
}
