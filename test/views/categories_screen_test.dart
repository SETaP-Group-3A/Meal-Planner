import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/models/category.dart';
import 'package:meal_planner/views/categories_screen.dart';
import 'package:meal_planner/category_service.dart';

Future<void> pumpScreen(WidgetTester tester, List<Category> categories) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CategoriesScreen(categories: categories),
      routes: {
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
      id: '1',
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

    expect(find.text(' '), findsOneWidget);

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
      targetRoute: ' ', 
      imageUrl: 'https://freepng.image.com/png/13866-healthyfood-png-pic',
    );

    await pumpScreen(tester, [cat]);

    expect(find.text('Snacks'), findsOneWidget);

    await tester.tap(find.text('Snacks'));
    await tester.pumpAndSettle();


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
        imageUrl: '', 
      );

      await pumpScreen(tester, [cat]);

      expect(find.text('NoImage'), findsOneWidget);


      expect(find.byType(Image), findsNothing);
    },
  );

  testWidgets('Search bar filters categories by name', (tester) async {
    final categories = [
      Category(
        id: 'c-1',
        name: 'Snacks',
        recipeIds: [],
        targetRoute: '/category',
        imageUrl: '',
      ),
      Category(
        id: 'c-2',
        name: 'Desserts',
        recipeIds: [],
        targetRoute: '/category',
        imageUrl: '',
      ),
    ];

    await pumpScreen(tester, categories);

    expect(find.text('Snacks'), findsOneWidget);
    expect(find.text('Desserts'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'sn');

    await tester.pumpAndSettle();

    expect(find.text('Snacks'), findsOneWidget);
    expect(find.text('Desserts'), findsNothing);
  });

  testWidgets('Search is case insensitive', (tester) async {
    final categories = [
      Category(
        id: 'c-1',
        name: 'Snacks',
        recipeIds: [],
        targetRoute: '/category',
        imageUrl: '',
      ),
    ];

    await pumpScreen(tester, categories);

    await tester.enterText(find.byType(TextField), 'SNACK');

    await tester.pumpAndSettle();

    expect(find.text('Snacks'), findsOneWidget);
  });

  testWidgets('Search with no matching categories shows no tiles', (
    tester,
  ) async {
    final categories = [
      Category(
        id: 'c-1',
        name: 'Snacks',
        recipeIds: [],
        targetRoute: '/category',
        imageUrl: '',
      ),
    ];

    await pumpScreen(tester, categories);

    await tester.enterText(find.byType(TextField), 'pizza');

    await tester.pumpAndSettle();

    expect(find.text('Snacks'), findsNothing);
  });

  testWidgets('User clicks "Favourites" category on first setup (should appear empty)', (tester) async {
    final fav = Category(
      id: 'c-favourites',
      name: 'Favourites',
      recipeIds: [],
      targetRoute: '/category',
      imageUrl: '',
    );

    await pumpScreen(tester, [fav]);

    expect(find.text('Favourites'), findsOneWidget);

    await tester.tap(find.text('Favourites'));
    await tester.pumpAndSettle();

    expect(find.text('Category: c-favourites'), findsOneWidget);
    expect(find.text('Recipes: 0'), findsOneWidget);
  });

  testWidgets('addRecipeToCategory(c-favourites, r-1) should add recipe 1 to favourites', (tester) async {
    await CategoryService.instance.setRecipesForCategory('c-favourites', []);
    await CategoryService.instance.addRecipeToCategory('c-favourites', 'r-1');
    final ids = await CategoryService.instance.getRecipeIdsForCategory('c-favourites');
    expect(ids, contains('r-1'));
  });

  testWidgets('addRecipeToCategory(c-favourites, 1) should add nothing due to invalid recipe id', (tester) async {
    await CategoryService.instance.setRecipesForCategory('c-favourites', []);
    await CategoryService.instance.addRecipeToCategory('c-favourites', '1'); 
    final ids = await CategoryService.instance.getRecipeIdsForCategory('c-favourites');
    expect(ids, isNot(contains('1')));
  });

  testWidgets('addRecipeToCategory(c-favourites) (no recipe id) should add nothing - simulated with empty string', (tester) async {
    await CategoryService.instance.setRecipesForCategory('c-favourites', []);
    await CategoryService.instance.addRecipeToCategory('c-favourites', ''); 
    final ids = await CategoryService.instance.getRecipeIdsForCategory('c-favourites');
    expect(ids, isNot(contains('')));
  });

  testWidgets('addRecipeToCategory(1, r-1) invalid category should add nothing', (tester) async {
    await CategoryService.instance.setRecipesForCategory('c-favourites', []);
    await CategoryService.instance.addRecipeToCategory('1', 'r-1'); 
    final favIds = await CategoryService.instance.getRecipeIdsForCategory('c-favourites');
    expect(favIds, isEmpty);
    final other = await CategoryService.instance.getRecipeIdsForCategory('1');
    expect(other, isEmpty);
  });

  testWidgets('removeRecipeFromCategory(c-favourites, r-1) should remove recipe 1 if present', (tester) async {
    await CategoryService.instance.setRecipesForCategory('c-favourites', ['r-1']);
    await CategoryService.instance.removeRecipeFromCategory('c-favourites', 'r-1');
    final ids = await CategoryService.instance.getRecipeIdsForCategory('c-favourites');
    expect(ids, isNot(contains('r-1')));
  });

  testWidgets('removeRecipeFromCategory(c-favourites, 1) invalid recipe id should remove nothing', (tester) async {
    await CategoryService.instance.setRecipesForCategory('c-favourites', ['r-1']);
    await CategoryService.instance.removeRecipeFromCategory('c-favourites', '1'); 
    final ids = await CategoryService.instance.getRecipeIdsForCategory('c-favourites');
    expect(ids, contains('r-1'));
  });

  testWidgets('removeRecipeFromCategory(c-favourites) (no recipe id) should remove nothing - simulated with empty string', (tester) async {
    await CategoryService.instance.setRecipesForCategory('c-favourites', ['r-1']);
    await CategoryService.instance.removeRecipeFromCategory('c-favourites', ''); 
    final ids = await CategoryService.instance.getRecipeIdsForCategory('c-favourites');
    expect(ids, contains('r-1'));
  });

  testWidgets('removeRecipeFromCategory(1, r-1) invalid category should remove nothing from favourites', (tester) async {
    await CategoryService.instance.setRecipesForCategory('c-favourites', ['r-1']);
    await CategoryService.instance.removeRecipeFromCategory('1', 'r-1'); 
    final favIds = await CategoryService.instance.getRecipeIdsForCategory('c-favourites');
    expect(favIds, contains('r-1'));
    final other = await CategoryService.instance.getRecipeIdsForCategory('1');
    expect(other, isEmpty);
  });
}

